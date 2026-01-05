import { PrismaClient, Prisma } from '@prisma/client';

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

  const eqQuestion = await prisma.eQTestQuestion.create({
    data: {
      questionKey: 'empathy_1',
      category: 'EMPATHY',
      questionText: {
        ko: '상대방의 감정을 쉽게 이해하는 편인가요?',
        en: 'Do you easily understand others’ feelings?',
        ja: '相手の気持ちを理解するのが得意ですか？',
      },
      answerType: 'SCALE_5',
      scoring: { scale: [1, 2, 3, 4, 5] },
      displayOrder: 1,
    },
  });

  await prisma.eQTestAnswer.create({
    data: {
      userId: user1.id,
      questionId: eqQuestion.id,
      answer: { value: 4 },
      score: 4,
    },
  });

  await prisma.eQTestResult.create({
    data: {
      userId: user1.id,
      totalScore: 82,
      empathyScore: 17,
      selfAwarenessScore: 16,
      socialSkillsScore: 17,
      motivationScore: 16,
      emotionRegulationScore: 16,
      personalityType: 'BALANCED',
      insights: {
        ko: '균형 잡힌 성향으로 감정 조절이 안정적입니다.',
        en: 'Balanced personality with stable emotional regulation.',
        ja: 'バランス型で感情コントロールが安定しています。',
      },
    },
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
