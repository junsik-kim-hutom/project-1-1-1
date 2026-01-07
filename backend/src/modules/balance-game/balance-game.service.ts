import prisma from '../../config/database';

export interface CreateBalanceGameDto {
  question: {
    ko: string;
    ja: string;
    en: string;
  };
  optionA: {
    ko: string;
    ja: string;
    en: string;
  };
  optionB: {
    ko: string;
    ja: string;
    en: string;
  };
  category: string;
}

export class BalanceGameService {
  async createBalanceGame(data: CreateBalanceGameDto) {
    const maxOrder = await prisma.balanceGame.findFirst({
      orderBy: { displayOrder: 'desc' },
      select: { displayOrder: true },
    });

    const balanceGame = await prisma.balanceGame.create({
      data: {
        question: data.question as any,
        optionA: data.optionA as any,
        optionB: data.optionB as any,
        category: data.category,
        displayOrder: (maxOrder?.displayOrder || 0) + 1,
        isActive: true,
      },
    });

    return balanceGame;
  }

  async getActiveBalanceGames(limit: number = 20) {
    const games = await prisma.balanceGame.findMany({
      where: { isActive: true },
      orderBy: { displayOrder: 'asc' },
      take: limit,
    });

    return games;
  }

  async getRandomBalanceGames(limit: number = 15) {
    const totalGames = await prisma.balanceGame.count({
      where: { isActive: true },
    });

    const skip = Math.max(0, Math.floor(Math.random() * (totalGames - limit)));

    const games = await prisma.balanceGame.findMany({
      where: { isActive: true },
      skip,
      take: limit,
    });

    return games.sort(() => Math.random() - 0.5);
  }

  async submitAnswer(userId: number, gameId: number, selectedOption: 'A' | 'B') {
    const answer = await prisma.userBalanceGameAnswer.upsert({
      where: {
        userId_gameId: {
          userId,
          gameId,
        },
      },
      update: {
        selectedOption,
        answeredAt: new Date(),
      },
      create: {
        userId,
        gameId,
        selectedOption,
      },
    });

    return answer;
  }

  async getUserAnswers(userId: number) {
    const answers = await prisma.userBalanceGameAnswer.findMany({
      where: { userId },
      include: {
        game: true,
      },
      orderBy: { answeredAt: 'desc' },
    });

    return answers;
  }

  async calculateCompatibility(user1Id: number, user2Id: number) {
    const [user1Answers, user2Answers] = await Promise.all([
      prisma.userBalanceGameAnswer.findMany({
        where: { userId: user1Id },
        orderBy: { gameId: 'asc' },
      }),
      prisma.userBalanceGameAnswer.findMany({
        where: { userId: user2Id },
        orderBy: { gameId: 'asc' },
      }),
    ]);

    const commonGameIds = user1Answers
      .map(a => a.gameId)
      .filter(id => user2Answers.some(a => a.gameId === id));

    if (commonGameIds.length === 0) {
      return { compatibility: 0, commonAnswers: 0, totalQuestions: 0 };
    }

    let matchCount = 0;
    commonGameIds.forEach(gameId => {
      const user1Answer = user1Answers.find(a => a.gameId === gameId);
      const user2Answer = user2Answers.find(a => a.gameId === gameId);

      if (user1Answer && user2Answer && user1Answer.selectedOption === user2Answer.selectedOption) {
        matchCount++;
      }
    });

    const compatibility = (matchCount / commonGameIds.length) * 100;

    return {
      compatibility: Math.round(compatibility),
      commonAnswers: matchCount,
      totalQuestions: commonGameIds.length,
    };
  }

  async updateBalanceGame(gameId: number, data: Partial<CreateBalanceGameDto>) {
    const game = await prisma.balanceGame.update({
      where: { id: gameId },
      data: {
        question: data.question as any,
        optionA: data.optionA as any,
        optionB: data.optionB as any,
        category: data.category,
      },
    });

    return game;
  }

  async toggleBalanceGame(gameId: number) {
    const game = await prisma.balanceGame.findUnique({
      where: { id: gameId },
    });

    if (!game) {
      throw new Error('Balance game not found');
    }

    const updated = await prisma.balanceGame.update({
      where: { id: gameId },
      data: { isActive: !game.isActive },
    });

    return updated;
  }
}
