import { AnswerType, EQCategory, Prisma, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function clearData() {
  await prisma.messageReadStatus.deleteMany();
  await prisma.chatMessage.deleteMany();
  await prisma.chatRoomParticipant.deleteMany();
  await prisma.chatRoom.deleteMany();
  await prisma.chatRequest.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.deviceToken.deleteMany();
  await prisma.notificationSettings.deleteMany();
  await prisma.subscription.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.subscriptionPlan.deleteMany();
  await prisma.eQTestAnswer.deleteMany();
  await prisma.eQTestResult.deleteMany();
  await prisma.eQTestQuestion.deleteMany();
  await prisma.matchingHistory.deleteMany();
  await prisma.userBlock.deleteMany();
  await prisma.userBalanceGameAnswer.deleteMany();
  await prisma.balanceGame.deleteMany();
  await prisma.locationArea.deleteMany();
  await prisma.userProfileValue.deleteMany();
  await prisma.profileImage.deleteMany();
  await prisma.profile.deleteMany();
  await prisma.profileField.deleteMany();
  await prisma.user.deleteMany();
}

async function main() {
  await clearData();

  const user1 = await prisma.user.create({
    data: {
      email: 'demo1@example.com',
      authProvider: 'GOOGLE',
      authProviderId: 'google-demo-1',
      emailVerified: true,
      lastLoginAt: new Date(),
    },
  });

  const user2 = await prisma.user.create({
    data: {
      email: 'demo2@example.com',
      authProvider: 'LINE',
      authProviderId: 'line-demo-2',
      emailVerified: true,
      lastLoginAt: new Date(),
    },
  });

  const user3 = await prisma.user.create({
    data: {
      email: 'demo3@example.com',
      authProvider: 'KAKAO',
      authProviderId: 'kakao-demo-3',
      emailVerified: false,
      lastLoginAt: new Date(),
    },
  });

  const profile1 = await prisma.profile.create({
    data: {
      userId: user1.id,
      displayName: '김하늘',
      gender: 'FEMALE',
      birthDate: new Date('1996-05-03'),
      age: 28,
      height: 165,
      occupation: '프로덕트 디자이너',
      education: '서울대학교',
      income: '4,000만원',
      smoking: '비흡연',
      drinking: '가끔',
      bio: '여행과 사진을 좋아합니다.',
      isComplete: true,
      isVerified: true,
      verifiedAt: new Date(),
    },
  });

  const profile2 = await prisma.profile.create({
    data: {
      userId: user2.id,
      displayName: '이준호',
      gender: 'MALE',
      birthDate: new Date('1993-11-21'),
      age: 31,
      height: 178,
      occupation: '백엔드 개발자',
      education: '연세대학교',
      income: '5,500만원',
      smoking: '비흡연',
      drinking: '주 1회',
      bio: '운동과 음악을 좋아합니다.',
      isComplete: true,
    },
  });

  await prisma.profile.create({
    data: {
      userId: user3.id,
      displayName: '박소연',
      gender: 'FEMALE',
      birthDate: new Date('1998-02-12'),
      age: 26,
      height: 162,
      occupation: '마케터',
      education: '고려대학교',
      bio: '새로운 사람과의 만남을 기대해요.',
      isComplete: true,
    },
  });

  await prisma.profileImage.createMany({
    data: [
      {
        profileId: profile1.id,
        imageUrl: 'https://example.com/images/profile-1-main.jpg',
        imageType: 'MAIN',
        displayOrder: 0,
        isApproved: true,
        approvedAt: new Date(),
      },
      {
        profileId: profile1.id,
        imageUrl: 'https://example.com/images/profile-1-sub.jpg',
        imageType: 'SUB',
        displayOrder: 1,
        isApproved: true,
        approvedAt: new Date(),
      },
      {
        profileId: profile2.id,
        imageUrl: 'https://example.com/images/profile-2-main.jpg',
        imageType: 'MAIN',
        displayOrder: 0,
        isApproved: true,
        approvedAt: new Date(),
      },
    ],
  });

  const fieldHobby = await prisma.profileField.create({
    data: {
      fieldKey: 'hobby',
      fieldType: 'TEXT',
      category: 'LIFESTYLE',
      label: { ko: '취미', en: 'Hobby', ja: '趣味' },
      displayOrder: 1,
    },
  });

  const fieldReligion = await prisma.profileField.create({
    data: {
      fieldKey: 'religion',
      fieldType: 'SELECT',
      category: 'VALUES',
      label: { ko: '종교', en: 'Religion', ja: '宗教' },
      options: {
        ko: ['무교', '기독교', '불교'],
        en: ['None', 'Christian', 'Buddhist'],
        ja: ['なし', 'キリスト教', '仏教'],
      },
      displayOrder: 2,
    },
  });

  await prisma.userProfileValue.createMany({
    data: [
      {
        userId: user1.id,
        fieldId: fieldHobby.id,
        value: '등산',
      },
      {
        userId: user1.id,
        fieldId: fieldReligion.id,
        value: '무교',
      },
    ],
  });

  await prisma.locationArea.createMany({
    data: [
      {
        userId: user1.id,
        latitude: 37.498095,
        longitude: 127.02761,
        address: '서울특별시 강남구',
        radius: 8000,
        isPrimary: true,
        verifiedAt: new Date(),
      },
      {
        userId: user2.id,
        latitude: 37.5665,
        longitude: 126.978,
        address: '서울특별시 중구',
        radius: 6000,
        isPrimary: true,
        verifiedAt: new Date(),
      },
    ],
  });

  const balanceGame = await prisma.balanceGame.create({
    data: {
      question: { ko: '바다 vs 산', en: 'Sea vs Mountain', ja: '海 vs 山' },
      optionA: { ko: '바다', en: 'Sea', ja: '海' },
      optionB: { ko: '산', en: 'Mountain', ja: '山' },
      category: 'lifestyle',
      displayOrder: 1,
    },
  });

  await prisma.userBalanceGameAnswer.create({
    data: {
      userId: user1.id,
      gameId: balanceGame.id,
      selectedOption: 'A',
    },
  });

  await prisma.matchingHistory.create({
    data: {
      userId: user1.id,
      targetUserId: user2.id,
      matchScore: 87,
      action: 'LIKE',
      viewedProfile: true,
      viewDuration: 120,
    },
  });

  await prisma.userBlock.create({
    data: {
      userId: user1.id,
      blockedUserId: user3.id,
      reason: '원치 않는 메시지',
    },
  });

  await prisma.chatRequest.create({
    data: {
      senderId: user1.id,
      receiverId: user2.id,
      initialMessage: '안녕하세요! 대화해보고 싶어요.',
      status: 'ACCEPTED',
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      respondedAt: new Date(),
    },
  });

  const chatRoom = await prisma.chatRoom.create({
    data: {
      roomType: 'direct',
      status: 'ACTIVE',
      startedAt: new Date(Date.now() - 60 * 60 * 1000),
    },
  });

  await prisma.chatRoomParticipant.createMany({
    data: [
      {
        roomId: chatRoom.id,
        userId: user1.id,
        role: 'owner',
        unreadCount: 0,
      },
      {
        roomId: chatRoom.id,
        userId: user2.id,
        role: 'member',
        unreadCount: 1,
      },
    ],
  });

  const firstMessage = await prisma.chatMessage.create({
    data: {
      roomId: chatRoom.id,
      senderId: user1.id,
      content: '안녕하세요! 오늘 하루 어떠셨어요?',
      messageType: 'TEXT',
      createdAt: new Date(Date.now() - 30 * 60 * 1000),
    },
  });

  const secondMessage = await prisma.chatMessage.create({
    data: {
      roomId: chatRoom.id,
      senderId: user2.id,
      content: '반가워요! 저는 괜찮았어요.',
      messageType: 'TEXT',
      isRead: true,
      readAt: new Date(),
      createdAt: new Date(Date.now() - 25 * 60 * 1000),
    },
  });

  await prisma.messageReadStatus.create({
    data: {
      messageId: firstMessage.id,
      userId: user2.id,
      readAt: new Date(),
    },
  });

  const plan = await prisma.subscriptionPlan.create({
    data: {
      planKey: 'basic_monthly',
      name: { ko: '베이직', en: 'Basic', ja: 'ベーシック' },
      description: {
        ko: '기본 매칭과 채팅 기능 제공',
        en: 'Basic matching and chat features',
        ja: '基本的なマッチングとチャット',
      },
      price: new Prisma.Decimal('980'),
      currency: 'JPY',
      durationDays: 30,
      features: {
        ko: ['기본 매칭', '채팅 10회'],
        en: ['Basic matching', '10 chats'],
        ja: ['基本マッチング', 'チャット10回'],
      },
      maxChatRooms: 10,
      unlimitedChat: false,
      prioritySupport: false,
      displayOrder: 1,
    },
  });

  await prisma.payment.create({
    data: {
      userId: user1.id,
      planId: plan.id,
      amount: new Prisma.Decimal('980'),
      currency: 'JPY',
      paymentMethod: 'stripe',
      paymentProvider: 'stripe',
      transactionId: 'txn_demo_1',
      status: 'COMPLETED',
      completedAt: new Date(),
    },
  });

  await prisma.subscription.create({
    data: {
      userId: user1.id,
      planId: plan.id,
      status: 'ACTIVE',
      startedAt: new Date(),
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      autoRenew: true,
    },
  });

  await prisma.eQTestQuestion.createMany({
    data: [
      // EMPATHY (4)
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

      // SELF_AWARENESS (4)
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

      // SOCIAL_SKILLS (4)
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

      // MOTIVATION (4)
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

      // EMOTION_REGULATION (4)
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
    ],
    skipDuplicates: true,
  });

  await prisma.notification.create({
    data: {
      userId: user1.id,
      type: 'CHAT_NEW_MESSAGE',
      title: {
        ko: '새 메시지',
        en: 'New message',
        ja: '新しいメッセージ',
      },
      message: {
        ko: '이준호님이 메시지를 보냈습니다.',
        en: 'Junho sent you a message.',
        ja: 'ジュノさんからメッセージが届きました。',
      },
      data: {
        roomId: chatRoom.id,
        messageId: secondMessage.id,
      },
      relatedMessageId: secondMessage.id,
    },
  });

  await prisma.deviceToken.create({
    data: {
      userId: user1.id,
      token: 'demo-device-token-1',
      platform: 'IOS',
    },
  });

  await prisma.notificationSettings.create({
    data: {
      userId: user1.id,
    },
  });
}

main()
  .catch((error) => {
    console.error('Seed failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
