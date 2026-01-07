import { AnswerType, EQCategory, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
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
}

main()
  .catch((error) => {
    console.error('Seed EQ test failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

