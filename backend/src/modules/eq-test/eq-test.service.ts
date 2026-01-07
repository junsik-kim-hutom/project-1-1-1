import prisma from '../../config/database';
import { AnswerType, EQCategory, PersonalityType } from '@prisma/client';

interface CreateEQQuestionDto {
  questionKey: string;
  category: EQCategory;
  questionText: {
    ko: string;
    ja: string;
    en: string;
  };
  answerType: AnswerType;
  options?: any;
  scoring: any;
  displayOrder: number;
}

interface SubmitAnswerDto {
  userId: number;
  questionId: number;
  answer: any;
}

export class EQTestService {
  // EQ 테스트 질문 초기 데이터 생성
  async seedQuestions() {
    const questions: CreateEQQuestionDto[] = [
      // 공감 능력 (Empathy) - 4문항
      {
        questionKey: 'empathy_1',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '친구가 힘든 일을 털어놓으면, 해결책보다 먼저 감정을 공감해줍니다',
          ja: '友達が悩みを打ち明けた時、解決策より先に気持ちに寄り添います',
          en: 'When a friend vents, I empathize with their feelings before offering solutions',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 1,
      },
      {
        questionKey: 'empathy_2',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '메시지(카톡/DM)에서도 상대의 감정 변화를 비교적 잘 알아챕니다',
          ja: 'メッセージ（LINE/DM）でも相手の感情の変化を比較的よく察します',
          en: 'I can often pick up emotional shifts even through messages (chat/DM)',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 2,
      },
      {
        questionKey: 'empathy_3',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '상대와 의견이 달라도, 왜 그렇게 느끼는지 이유를 이해하려고 합니다',
          ja: '意見が違っても、なぜそう感じるのか理由を理解しようとします',
          en: 'Even when I disagree, I try to understand why they feel that way',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 3,
      },
      {
        questionKey: 'empathy_4',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '주변 사람이 지쳐 보이면, 부담되지 않는 방식으로 도움을 제안합니다',
          ja: '周りの人が疲れていそうなら、負担にならない形で助けを提案します',
          en: 'If someone looks drained, I offer support in a non-pushy way',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 4,
      },

      // 자기 인식 (Self Awareness) - 4문항
      {
        questionKey: 'self_awareness_1',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '내 감정을 말로 정확히 표현(예: 서운함/불안/짜증)할 수 있습니다',
          ja: '自分の感情を言葉で正確に表現できます（例：寂しさ/不安/苛立ち）',
          en: 'I can accurately name my emotions (e.g., hurt, anxious, irritated)',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 5,
      },
      {
        questionKey: 'self_awareness_2',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '내가 스트레스를 받는 신호(수면/식욕/집중 변화 등)를 비교적 빨리 알아챕니다',
          ja: '自分がストレスを受けているサイン（睡眠/食欲/集中の変化など）に早めに気づきます',
          en: 'I notice early signs of stress (sleep, appetite, focus changes)',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 6,
      },
      {
        questionKey: 'self_awareness_3',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: 'SNS/뉴스를 많이 본 날, 내 기분이 어떻게 달라지는지 인식하고 조절합니다',
          ja: 'SNS/ニュースをたくさん見た日は、気分の変化に気づき調整します',
          en: 'I notice how heavy social/news consumption affects my mood and adjust',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 7,
      },
      {
        questionKey: 'self_awareness_4',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '나에게 중요한 경계(시간/에너지/관계)를 스스로 정하고 지키려 합니다',
          ja: '自分にとって大切な境界（時間/エネルギー/関係）を決めて守ろうとします',
          en: 'I set and try to maintain boundaries (time, energy, relationships)',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 8,
      },

      // 사회적 기술 (Social Skills) - 4문항
      {
        questionKey: 'social_skills_1',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '오해가 생기면 톤을 부드럽게 하며 사실과 감정을 분리해 대화합니다',
          ja: '誤解が生じたら、トーンを柔らかくして事実と感情を分けて話します',
          en: 'When misunderstandings happen, I separate facts and feelings and keep a calm tone',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 9,
      },
      {
        questionKey: 'social_skills_2',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '피드백을 줄 때, 상대가 방어적이 되지 않도록 배려하며 전달합니다',
          ja: 'フィードバックを伝える時、相手が防衛的にならないよう配慮します',
          en: 'I give feedback in a way that helps the other person stay open',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 10,
      },
      {
        questionKey: 'social_skills_3',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '모임/회의에서 말수가 적은 사람도 자연스럽게 참여하도록 분위기를 만듭니다',
          ja: '集まり/会議で、口数が少ない人も自然に参加できる雰囲気を作ります',
          en: 'I help quieter people feel included in group conversations',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 11,
      },
      {
        questionKey: 'social_skills_4',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '실수했을 때 빠르게 사과하고 관계를 회복하려고 노력합니다',
          ja: '間違えた時、素早く謝り関係を修復しようとします',
          en: 'When I mess up, I apologize quickly and try to repair the relationship',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 12,
      },

      // 동기부여 (Motivation) - 4문항
      {
        questionKey: 'motivation_1',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '목표를 큰 계획보다 작은 습관(루틴)으로 쪼개서 꾸준히 실행합니다',
          ja: '目標を大きな計画より小さな習慣（ルーティン）に分けて継続します',
          en: 'I break goals into small habits and keep showing up consistently',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 13,
      },
      {
        questionKey: 'motivation_2',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '실패하거나 평가를 낮게 받아도, 원인을 분석하고 다시 시도합니다',
          ja: '失敗したり評価が低くても、原因を分析して再挑戦します',
          en: 'Even after failure or criticism, I analyze what happened and try again',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 14,
      },
      {
        questionKey: 'motivation_3',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '새로운 환경(이직/이사/새 팀)에서도 빠르게 적응하려 노력합니다',
          ja: '新しい環境（転職/引っ越し/新しいチーム）でも早く適応しようとします',
          en: 'I actively adapt when I enter a new environment (job/team/life change)',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 15,
      },
      {
        questionKey: 'motivation_4',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '동기가 떨어질 때도, 스스로를 격려하며 다시 페이스를 찾습니다',
          ja: 'やる気が落ちた時も、自分を励ましてペースを取り戻します',
          en: 'When my motivation dips, I encourage myself and regain momentum',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 16,
      },

      // 감정 조절 (Emotion Regulation) - 4문항
      {
        questionKey: 'emotion_regulation_1',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '감정이 올라올 때 바로 반응하기보다, 잠깐 멈추고 생각한 뒤 행동합니다',
          ja: '感情が高ぶった時、すぐ反応せず少し立ち止まってから行動します',
          en: 'When emotions rise, I pause and think before responding',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 17,
      },
      {
        questionKey: 'emotion_regulation_2',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '예민해질 때도 타인에게 감정을 쏟아내기보다 건강한 방식으로 해소합니다',
          ja: 'イライラしても他人にぶつけず、健全な方法で発散します',
          en: 'Even when irritable, I regulate without dumping it on others',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 18,
      },
      {
        questionKey: 'emotion_regulation_3',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '갈등이 있어도 감정이 가라앉은 뒤에 차분히 대화로 풀어갑니다',
          ja: '葛藤があっても気持ちが落ち着いてから冷静に話し合います',
          en: 'After cooling down, I can talk through conflicts calmly',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 19,
      },
      {
        questionKey: 'emotion_regulation_4',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '감정적으로 지칠 때, 휴식/운동/상담 등 도움을 요청할 수 있습니다',
          ja: '感情的に疲れた時、休息/運動/相談など助けを求められます',
          en: 'When emotionally drained, I can seek support (rest, exercise, talking it out)',
        },
        answerType: AnswerType.SCALE_5,
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 20,
      },
    ];

    const createdQuestions = [];
    for (const question of questions) {
      const existing = await prisma.eQTestQuestion.findUnique({
        where: { questionKey: question.questionKey },
      });

      if (!existing) {
        const created = await prisma.eQTestQuestion.create({
          data: question as any,
        });
        createdQuestions.push(created);
      }
    }

    return createdQuestions;
  }

  // 활성화된 EQ 테스트 질문 가져오기
  async getActiveQuestions(category?: EQCategory) {
    return prisma.eQTestQuestion.findMany({
      where: {
        isActive: true,
        ...(category && { category }),
      },
      orderBy: {
        displayOrder: 'asc',
      },
    });
  }

  // 모든 EQ 테스트 질문 가져오기 (관리자용)
  async getAllQuestions() {
    return prisma.eQTestQuestion.findMany({
      orderBy: {
        displayOrder: 'asc',
      },
    });
  }

  // 사용자 답변 제출 및 점수 계산
  async submitAnswer(data: SubmitAnswerDto) {
    const question = await prisma.eQTestQuestion.findUnique({
      where: { id: data.questionId },
    });

    if (!question) {
      throw new Error('Question not found');
    }

    // 점수 계산 (호환: { "1": 1 } 또는 { scale: [1..] })
    const scoring = question.scoring as any;
    const answerValue = typeof data.answer === 'number' ? data.answer : Number(data.answer);
    let score = 0;
    if (scoring && typeof scoring === 'object') {
      const mapped = scoring[data.answer?.toString?.() ?? ''];
      if (typeof mapped === 'number') score = mapped;
      if (score === 0 && Array.isArray(scoring.scale) && Number.isFinite(answerValue)) {
        score = answerValue;
      }
    }

    const answer = await prisma.eQTestAnswer.upsert({
      where: {
        userId_questionId: {
          userId: data.userId,
          questionId: data.questionId,
        },
      },
      update: {
        answer: data.answer as any,
        score,
      },
      create: {
        userId: data.userId,
        questionId: data.questionId,
        answer: data.answer as any,
        score,
      },
    });

    return answer;
  }

  // 사용자 EQ 테스트 결과 계산
  async calculateResults(userId: number) {
    // 모든 답변 가져오기
    const answers = await prisma.eQTestAnswer.findMany({
      where: { userId },
      include: { question: true },
    });

    if (answers.length === 0) {
      throw new Error('No answers found for this user');
    }

    const categoryScores: Record<EQCategory, number[]> = {
      [EQCategory.EMPATHY]: [],
      [EQCategory.SELF_AWARENESS]: [],
      [EQCategory.SOCIAL_SKILLS]: [],
      [EQCategory.MOTIVATION]: [],
      [EQCategory.EMOTION_REGULATION]: [],
    };

    for (const answer of answers) {
      categoryScores[answer.question.category].push(answer.score);
    }

    const scores: Record<EQCategory, number> = {
      [EQCategory.EMPATHY]: this.calculateAverage(categoryScores[EQCategory.EMPATHY]),
      [EQCategory.SELF_AWARENESS]: this.calculateAverage(categoryScores[EQCategory.SELF_AWARENESS]),
      [EQCategory.SOCIAL_SKILLS]: this.calculateAverage(categoryScores[EQCategory.SOCIAL_SKILLS]),
      [EQCategory.MOTIVATION]: this.calculateAverage(categoryScores[EQCategory.MOTIVATION]),
      [EQCategory.EMOTION_REGULATION]: this.calculateAverage(categoryScores[EQCategory.EMOTION_REGULATION]),
    };

    const totalScore = Math.round(
      (scores[EQCategory.EMPATHY] +
        scores[EQCategory.SELF_AWARENESS] +
        scores[EQCategory.SOCIAL_SKILLS] +
        scores[EQCategory.MOTIVATION] +
        scores[EQCategory.EMOTION_REGULATION]) /
        5
    );

    const personalityType = this.determinePersonalityType(scores);
    const insights = this.generateInsights(scores, personalityType);

    // 결과 저장
    const result = await prisma.eQTestResult.create({
      data: {
        userId,
        totalScore,
        empathyScore: scores[EQCategory.EMPATHY],
        selfAwarenessScore: scores[EQCategory.SELF_AWARENESS],
        socialSkillsScore: scores[EQCategory.SOCIAL_SKILLS],
        motivationScore: scores[EQCategory.MOTIVATION],
        emotionRegulationScore: scores[EQCategory.EMOTION_REGULATION],
        personalityType,
        insights: insights as any,
      },
    });

    return result;
  }

  // 사용자 EQ 테스트 결과 조회
  async getResults(userId: number) {
    const result = await prisma.eQTestResult.findFirst({
      where: { userId },
      orderBy: { completedAt: 'desc' },
    });

    if (!result) {
      throw new Error('No test results found for this user');
    }

    return result;
  }

  // 평균 계산 헬퍼
  private calculateAverage(scores: number[]): number {
    if (scores.length === 0) return 0;
    const sum = scores.reduce((acc, score) => acc + score, 0);
    return Math.round(sum / scores.length);
  }

  // 성격 유형 결정
  private determinePersonalityType(scores: {
    [EQCategory.EMPATHY]: number;
    [EQCategory.SELF_AWARENESS]: number;
    [EQCategory.SOCIAL_SKILLS]: number;
    [EQCategory.MOTIVATION]: number;
    [EQCategory.EMOTION_REGULATION]: number;
  }): PersonalityType {
    const maxScore = Math.max(
      scores[EQCategory.EMPATHY],
      scores[EQCategory.SELF_AWARENESS],
      scores[EQCategory.SOCIAL_SKILLS],
      scores[EQCategory.MOTIVATION],
      scores[EQCategory.EMOTION_REGULATION]
    );

    // 가장 높은 점수의 카테고리로 성격 유형 결정
    if (scores[EQCategory.EMPATHY] === maxScore && scores[EQCategory.EMPATHY] >= 4) {
      return PersonalityType.EMPATHETIC; // 공감형
    } else if (scores[EQCategory.SELF_AWARENESS] === maxScore && scores[EQCategory.SELF_AWARENESS] >= 4) {
      return PersonalityType.INTROSPECTIVE; // 성찰형
    } else if (scores[EQCategory.SOCIAL_SKILLS] === maxScore && scores[EQCategory.SOCIAL_SKILLS] >= 4) {
      return PersonalityType.SOCIAL; // 사교형
    } else if (scores[EQCategory.MOTIVATION] === maxScore && scores[EQCategory.MOTIVATION] >= 4) {
      return PersonalityType.ACHIEVER; // 성취형
    } else if (
      scores[EQCategory.EMOTION_REGULATION] === maxScore &&
      scores[EQCategory.EMOTION_REGULATION] >= 4
    ) {
      return PersonalityType.RATIONAL; // 이성형
    } else {
      return PersonalityType.BALANCED; // 균형형
    }
  }

  // 인사이트 생성
  private generateInsights(scores: Record<EQCategory, number>, personalityType: PersonalityType) {
    const strengths = [];
    const improvements = [];
    const matchingTips = [];

    // 강점 분석
    if (scores[EQCategory.EMPATHY] >= 4) {
      strengths.push({
        ko: '타인의 감정을 잘 이해하고 공감하는 능력이 뛰어납니다',
        ja: '他人の感情をよく理解し共感する能力が優れています',
        en: 'Excellent ability to understand and empathize with others',
      });
    }
    if (scores[EQCategory.SELF_AWARENESS] >= 4) {
      strengths.push({
        ko: '자신의 감정과 행동을 객관적으로 파악할 수 있습니다',
        ja: '自分の感情と行動を客観的に把握できます',
        en: 'Can objectively understand your own emotions and behaviors',
      });
    }
    if (scores[EQCategory.SOCIAL_SKILLS] >= 4) {
      strengths.push({
        ko: '대인관계에서 원활한 소통과 협력이 가능합니다',
        ja: '対人関係で円滑なコミュニケーションと協力が可能です',
        en: 'Capable of smooth communication and collaboration in relationships',
      });
    }

    // 개선점 분석
    if (scores[EQCategory.EMPATHY] < 3) {
      improvements.push({
        ko: '상대방의 입장에서 생각해보는 연습이 필요합니다',
        ja: '相手の立場で考えてみる練習が必要です',
        en: 'Practice seeing things from others\' perspectives',
      });
    }
    if (scores[EQCategory.EMOTION_REGULATION] < 3) {
      improvements.push({
        ko: '감정 조절 능력을 키우면 더 안정적인 관계를 유지할 수 있습니다',
        ja: '感情調節能力を高めればより安定した関係を維持できます',
        en: 'Improving emotion regulation can lead to more stable relationships',
      });
    }
    if (scores[EQCategory.MOTIVATION] < 3) {
      improvements.push({
        ko: '목표 설정과 달성 경험이 자신감을 높여줄 것입니다',
        ja: '目標設定と達成経験が自信を高めてくれます',
        en: 'Setting and achieving goals will boost your confidence',
      });
    }

    // 매칭 팁
    switch (personalityType) {
      case PersonalityType.EMPATHETIC:
        matchingTips.push({
          ko: '감정적 교류를 중요하게 생각하는 상대와 잘 맞습니다',
          ja: '感情的な交流を重要視する相手とよく合います',
          en: 'You match well with partners who value emotional connection',
        });
        break;
      case PersonalityType.SOCIAL:
        matchingTips.push({
          ko: '활발한 사회 활동을 함께 즐길 수 있는 상대가 좋습니다',
          ja: '活発な社会活動を一緒に楽しめる相手が良いです',
          en: 'You thrive with partners who enjoy social activities',
        });
        break;
      case PersonalityType.INTROSPECTIVE:
        matchingTips.push({
          ko: '깊이 있는 대화와 자기 성찰을 즐기는 상대와 잘 맞습니다',
          ja: '深い会話と自己省察を楽しむ相手とよく合います',
          en: 'You connect well with partners who enjoy deep conversations',
        });
        break;
      case PersonalityType.ACHIEVER:
        matchingTips.push({
          ko: '목표 지향적이고 성장을 추구하는 상대와 시너지가 있습니다',
          ja: '目標志向的で成長を追求する相手とシナジーがあります',
          en: 'You synergize with goal-oriented partners who pursue growth',
        });
        break;
      case PersonalityType.RATIONAL:
        matchingTips.push({
          ko: '침착하고 논리적인 의사소통을 선호하는 상대가 좋습니다',
          ja: '落ち着いて論理的なコミュニケーションを好む相手が良いです',
          en: 'You work well with partners who prefer calm, logical communication',
        });
        break;
      case PersonalityType.BALANCED:
        matchingTips.push({
          ko: '다양한 성향의 상대와 조화롭게 지낼 수 있습니다',
          ja: '様々な性向の相手と調和よく過ごせます',
          en: 'You can harmonize with partners of various personality types',
        });
        break;
    }

    return {
      strengths,
      improvements,
      matchingTips,
    };
  }

  // EQ 질문 생성 (관리자용)
  async createQuestion(data: CreateEQQuestionDto) {
    return prisma.eQTestQuestion.create({
      data: data as any,
    });
  }

  // EQ 질문 수정 (관리자용)
  async updateQuestion(questionId: number, data: Partial<CreateEQQuestionDto>) {
    return prisma.eQTestQuestion.update({
      where: { id: questionId },
      data: data as any,
    });
  }

  // EQ 질문 활성화/비활성화 (관리자용)
  async toggleQuestion(questionId: number) {
    const question = await prisma.eQTestQuestion.findUnique({
      where: { id: questionId },
    });

    if (!question) {
      throw new Error('Question not found');
    }

    return prisma.eQTestQuestion.update({
      where: { id: questionId },
      data: {
        isActive: !question.isActive,
      },
    });
  }
}
