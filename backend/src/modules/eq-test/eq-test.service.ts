import prisma from '../../config/database';
import { EQCategory, PersonalityType } from '@prisma/client';

interface CreateEQQuestionDto {
  questionKey: string;
  category: EQCategory;
  questionText: {
    ko: string;
    ja: string;
    en: string;
  };
  answerType: string;
  options?: any;
  scoring: any;
  displayOrder: number;
}

interface SubmitAnswerDto {
  userId: string;
  questionId: string;
  answer: any;
}

export class EQTestService {
  // EQ 테스트 질문 초기 데이터 생성
  async seedQuestions() {
    const questions: CreateEQQuestionDto[] = [
      // 공감 능력 (Empathy) - 5문항
      {
        questionKey: 'empathy_1',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '친구가 슬퍼하면 나도 함께 슬퍼집니다',
          ja: '友達が悲しんでいると、私も一緒に悲しくなります',
          en: 'When a friend is sad, I feel sad too',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 1,
      },
      {
        questionKey: 'empathy_2',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '다른 사람의 감정을 쉽게 알아챌 수 있습니다',
          ja: '他の人の感情を簡単に察することができます',
          en: 'I can easily sense how others are feeling',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 2,
      },
      {
        questionKey: 'empathy_3',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '상대방의 입장에서 생각하려고 노력합니다',
          ja: '相手の立場で考えようと努力します',
          en: 'I try to see things from others\' perspectives',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 3,
      },
      {
        questionKey: 'empathy_4',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '다른 사람이 힘들어할 때 도와주고 싶은 마음이 듭니다',
          ja: '他の人が困っている時に助けたい気持ちになります',
          en: 'I feel compelled to help when someone is struggling',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 4,
      },
      {
        questionKey: 'empathy_5',
        category: EQCategory.EMPATHY,
        questionText: {
          ko: '영화나 드라마를 볼 때 등장인물의 감정에 몰입합니다',
          ja: '映画やドラマを見る時、登場人物の感情に没入します',
          en: 'I get emotionally involved with characters in movies or dramas',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 5,
      },

      // 자기 인식 (Self Awareness) - 5문항
      {
        questionKey: 'self_awareness_1',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '내 감정이 왜 생기는지 이해합니다',
          ja: '自分の感情がなぜ生じるのか理解しています',
          en: 'I understand why I feel the way I do',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 6,
      },
      {
        questionKey: 'self_awareness_2',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '나의 강점과 약점을 잘 알고 있습니다',
          ja: '自分の強みと弱みをよく知っています',
          en: 'I am well aware of my strengths and weaknesses',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 7,
      },
      {
        questionKey: 'self_awareness_3',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '나의 행동이 다른 사람에게 어떤 영향을 미치는지 생각합니다',
          ja: '自分の行動が他の人にどんな影響を与えるか考えます',
          en: 'I think about how my actions affect others',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 8,
      },
      {
        questionKey: 'self_awareness_4',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '내가 어떤 상황에서 스트레스를 받는지 알고 있습니다',
          ja: 'どんな状況でストレスを受けるか知っています',
          en: 'I know what situations stress me out',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 9,
      },
      {
        questionKey: 'self_awareness_5',
        category: EQCategory.SELF_AWARENESS,
        questionText: {
          ko: '나의 가치관과 신념을 명확히 알고 있습니다',
          ja: '自分の価値観と信念を明確に知っています',
          en: 'I have a clear understanding of my values and beliefs',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 10,
      },

      // 사회적 기술 (Social Skills) - 5문항
      {
        questionKey: 'social_skills_1',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '새로운 사람들과 쉽게 친해질 수 있습니다',
          ja: '新しい人たちと簡単に親しくなれます',
          en: 'I can easily connect with new people',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 11,
      },
      {
        questionKey: 'social_skills_2',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '갈등 상황에서 중재하고 해결하는 것을 잘합니다',
          ja: '葛藤状況で仲裁し解決するのが得意です',
          en: 'I am good at mediating and resolving conflicts',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 12,
      },
      {
        questionKey: 'social_skills_3',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '팀워크를 발휘하여 협력하는 것을 좋아합니다',
          ja: 'チームワークを発揮して協力するのが好きです',
          en: 'I enjoy working collaboratively with others',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 13,
      },
      {
        questionKey: 'social_skills_4',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '다른 사람의 의견을 경청하고 존중합니다',
          ja: '他の人の意見を傾聴し尊重します',
          en: 'I listen to and respect others\' opinions',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 14,
      },
      {
        questionKey: 'social_skills_5',
        category: EQCategory.SOCIAL_SKILLS,
        questionText: {
          ko: '상황에 맞게 대화 주제를 조절할 수 있습니다',
          ja: '状況に合わせて会話のテーマを調整できます',
          en: 'I can adjust conversation topics to suit the situation',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 15,
      },

      // 동기부여 (Motivation) - 5문항
      {
        questionKey: 'motivation_1',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '목표를 달성하기 위해 꾸준히 노력합니다',
          ja: '目標を達成するために継続的に努力します',
          en: 'I consistently work towards achieving my goals',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 16,
      },
      {
        questionKey: 'motivation_2',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '실패해도 다시 도전하는 편입니다',
          ja: '失敗してもまた挑戦する方です',
          en: 'I tend to try again even after failure',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 17,
      },
      {
        questionKey: 'motivation_3',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '새로운 것을 배우는 것에 열정이 있습니다',
          ja: '新しいことを学ぶことに情熱があります',
          en: 'I am passionate about learning new things',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 18,
      },
      {
        questionKey: 'motivation_4',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '어려운 상황에서도 긍정적인 면을 찾으려 합니다',
          ja: '困難な状況でも肯定的な面を探そうとします',
          en: 'I try to find the positive even in difficult situations',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 19,
      },
      {
        questionKey: 'motivation_5',
        category: EQCategory.MOTIVATION,
        questionText: {
          ko: '나만의 내적 동기로 움직이는 편입니다',
          ja: '自分だけの内的動機で動く方です',
          en: 'I am driven by my own internal motivation',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 20,
      },

      // 감정 조절 (Emotion Regulation) - 5문항
      {
        questionKey: 'emotion_regulation_1',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '화가 나도 침착하게 대처할 수 있습니다',
          ja: '怒っても冷静に対処できます',
          en: 'I can stay calm even when I am angry',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 21,
      },
      {
        questionKey: 'emotion_regulation_2',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '스트레스를 해소하는 나만의 방법이 있습니다',
          ja: 'ストレスを解消する自分なりの方法があります',
          en: 'I have my own ways of managing stress',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 22,
      },
      {
        questionKey: 'emotion_regulation_3',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '부정적인 감정을 적절히 표현할 수 있습니다',
          ja: '否定的な感情を適切に表現できます',
          en: 'I can express negative emotions appropriately',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 23,
      },
      {
        questionKey: 'emotion_regulation_4',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '감정적으로 힘들 때 주변에 도움을 요청할 수 있습니다',
          ja: '感情的に辛い時、周りに助けを求めることができます',
          en: 'I can ask for help when I am emotionally struggling',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 24,
      },
      {
        questionKey: 'emotion_regulation_5',
        category: EQCategory.EMOTION_REGULATION,
        questionText: {
          ko: '급한 결정을 내리기 전에 한 번 더 생각합니다',
          ja: '急な決定をする前にもう一度考えます',
          en: 'I think twice before making hasty decisions',
        },
        answerType: 'scale_5',
        scoring: { '1': 1, '2': 2, '3': 3, '4': 4, '5': 5 },
        displayOrder: 25,
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

    // 점수 계산
    const scoring = question.scoring as any;
    const score = scoring[data.answer.toString()] || 0;

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
  async calculateResults(userId: string) {
    // 모든 답변 가져오기
    const answers = await prisma.eQTestAnswer.findMany({
      where: { userId },
      include: { question: true },
    });

    if (answers.length === 0) {
      throw new Error('No answers found for this user');
    }

    // 카테고리별 점수 계산
    const categoryScores: { [key: string]: number[] } = {
      empathy: [],
      self_awareness: [],
      social_skills: [],
      motivation: [],
      emotion_regulation: [],
    };

    answers.forEach((answer) => {
      const category = answer.question.category;
      if (categoryScores[category]) {
        categoryScores[category].push(answer.score);
      }
    });

    // 각 카테고리 평균 점수
    const empathyScore = this.calculateAverage(categoryScores.empathy);
    const selfAwarenessScore = this.calculateAverage(categoryScores.self_awareness);
    const socialSkillsScore = this.calculateAverage(categoryScores.social_skills);
    const motivationScore = this.calculateAverage(categoryScores.motivation);
    const emotionRegulationScore = this.calculateAverage(categoryScores.emotion_regulation);

    const totalScore = Math.round(
      (empathyScore + selfAwarenessScore + socialSkillsScore + motivationScore + emotionRegulationScore) / 5
    );

    // 성격 유형 결정
    const personalityType = this.determinePersonalityType({
      empathy: empathyScore,
      selfAwareness: selfAwarenessScore,
      socialSkills: socialSkillsScore,
      motivation: motivationScore,
      emotionRegulation: emotionRegulationScore,
    });

    // 인사이트 생성
    const insights = this.generateInsights({
      empathy: empathyScore,
      selfAwareness: selfAwarenessScore,
      socialSkills: socialSkillsScore,
      motivation: motivationScore,
      emotionRegulation: emotionRegulationScore,
      personalityType,
    });

    // 결과 저장
    const result = await prisma.eQTestResult.create({
      data: {
        userId,
        totalScore,
        empathyScore,
        selfAwarenessScore,
        socialSkillsScore,
        motivationScore,
        emotionRegulationScore,
        personalityType,
        insights: insights as any,
      },
    });

    return result;
  }

  // 사용자 EQ 테스트 결과 조회
  async getResults(userId: string) {
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
    empathy: number;
    selfAwareness: number;
    socialSkills: number;
    motivation: number;
    emotionRegulation: number;
  }): PersonalityType {
    const maxScore = Math.max(
      scores.empathy,
      scores.selfAwareness,
      scores.socialSkills,
      scores.motivation,
      scores.emotionRegulation
    );

    // 가장 높은 점수의 카테고리로 성격 유형 결정
    if (scores.empathy === maxScore && scores.empathy >= 4) {
      return PersonalityType.EMPATHETIC; // 공감형
    } else if (scores.selfAwareness === maxScore && scores.selfAwareness >= 4) {
      return PersonalityType.INTROSPECTIVE; // 성찰형
    } else if (scores.socialSkills === maxScore && scores.socialSkills >= 4) {
      return PersonalityType.SOCIAL; // 사교형
    } else if (scores.motivation === maxScore && scores.motivation >= 4) {
      return PersonalityType.ACHIEVER; // 성취형
    } else if (scores.emotionRegulation === maxScore && scores.emotionRegulation >= 4) {
      return PersonalityType.RATIONAL; // 이성형
    } else {
      return PersonalityType.BALANCED; // 균형형
    }
  }

  // 인사이트 생성
  private generateInsights(data: {
    empathy: number;
    selfAwareness: number;
    socialSkills: number;
    motivation: number;
    emotionRegulation: number;
    personalityType: PersonalityType;
  }) {
    const strengths = [];
    const improvements = [];
    const matchingTips = [];

    // 강점 분석
    if (data.empathy >= 4) {
      strengths.push({
        ko: '타인의 감정을 잘 이해하고 공감하는 능력이 뛰어납니다',
        ja: '他人の感情をよく理解し共感する能力が優れています',
        en: 'Excellent ability to understand and empathize with others',
      });
    }
    if (data.selfAwareness >= 4) {
      strengths.push({
        ko: '자신의 감정과 행동을 객관적으로 파악할 수 있습니다',
        ja: '自分の感情と行動を客観的に把握できます',
        en: 'Can objectively understand your own emotions and behaviors',
      });
    }
    if (data.socialSkills >= 4) {
      strengths.push({
        ko: '대인관계에서 원활한 소통과 협력이 가능합니다',
        ja: '対人関係で円滑なコミュニケーションと協力が可能です',
        en: 'Capable of smooth communication and collaboration in relationships',
      });
    }

    // 개선점 분석
    if (data.empathy < 3) {
      improvements.push({
        ko: '상대방의 입장에서 생각해보는 연습이 필요합니다',
        ja: '相手の立場で考えてみる練習が必要です',
        en: 'Practice seeing things from others\' perspectives',
      });
    }
    if (data.emotionRegulation < 3) {
      improvements.push({
        ko: '감정 조절 능력을 키우면 더 안정적인 관계를 유지할 수 있습니다',
        ja: '感情調節能力を高めればより安定した関係を維持できます',
        en: 'Improving emotion regulation can lead to more stable relationships',
      });
    }
    if (data.motivation < 3) {
      improvements.push({
        ko: '목표 설정과 달성 경험이 자신감을 높여줄 것입니다',
        ja: '目標設定と達成経験が自信を高めてくれます',
        en: 'Setting and achieving goals will boost your confidence',
      });
    }

    // 매칭 팁
    switch (data.personalityType) {
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
  async updateQuestion(questionId: string, data: Partial<CreateEQQuestionDto>) {
    return prisma.eQTestQuestion.update({
      where: { id: questionId },
      data: data as any,
    });
  }

  // EQ 질문 활성화/비활성화 (관리자용)
  async toggleQuestion(questionId: string) {
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
