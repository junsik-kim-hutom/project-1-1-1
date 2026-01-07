import prisma from '../../config/database';
import { ProfileFieldType, ProfileFieldCategory } from '@prisma/client';

export interface CreateProfileFieldDto {
  fieldKey: string;
  fieldType: ProfileFieldType;
  category: ProfileFieldCategory;
  label: {
    ko: string;
    ja: string;
    en: string;
  };
  options?: any;
  isRequired?: boolean;
  displayOrder: number;
  validation?: any;
  placeholder?: any;
  helpText?: any;
}

export class ProfileFieldService {
  async createField(data: CreateProfileFieldDto) {
    const field = await prisma.profileField.create({
      data: {
        fieldKey: data.fieldKey,
        fieldType: data.fieldType,
        category: data.category,
        label: data.label as any,
        options: data.options as any,
        isRequired: data.isRequired || false,
        displayOrder: data.displayOrder,
        validation: data.validation as any,
        placeholder: data.placeholder as any,
        helpText: data.helpText as any,
        isActive: true,
      },
    });

    return field;
  }

  async getActiveFields(category?: ProfileFieldCategory) {
    const fields = await prisma.profileField.findMany({
      where: {
        isActive: true,
        ...(category && { category }),
      },
      orderBy: {
        displayOrder: 'asc',
      },
    });

    return fields;
  }

  async getAllFields() {
    const fields = await prisma.profileField.findMany({
      orderBy: {
        displayOrder: 'asc',
      },
    });

    return fields;
  }

  async updateField(fieldId: number, data: Partial<CreateProfileFieldDto>) {
    const field = await prisma.profileField.update({
      where: { id: fieldId },
      data: {
        fieldType: data.fieldType,
        category: data.category,
        label: data.label as any,
        options: data.options as any,
        isRequired: data.isRequired,
        displayOrder: data.displayOrder,
        validation: data.validation as any,
        placeholder: data.placeholder as any,
        helpText: data.helpText as any,
      },
    });

    return field;
  }

  async toggleField(fieldId: number) {
    const field = await prisma.profileField.findUnique({
      where: { id: fieldId },
    });

    if (!field) {
      throw new Error('Field not found');
    }

    const updated = await prisma.profileField.update({
      where: { id: fieldId },
      data: { isActive: !field.isActive },
    });

    return updated;
  }

  async deleteField(fieldId: number) {
    await prisma.profileField.delete({
      where: { id: fieldId },
    });

    return { success: true };
  }

  // 초기 데이터 생성 (마이그레이션용)
  async seedFields() {
    const fields: CreateProfileFieldDto[] = [
      // 기본 정보
      {
        fieldKey: 'residence',
        fieldType: ProfileFieldType.TEXT,
        category: ProfileFieldCategory.BASIC,
        label: { ko: '거주지', ja: '居住地', en: 'Residence' },
        placeholder: { ko: '예: 서울시 강남구', ja: '例: 東京都渋谷区', en: 'e.g. Seoul, Gangnam' },
        isRequired: true,
        displayOrder: 1,
      },
      {
        fieldKey: 'body_type',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.BASIC,
        label: { ko: '몸매', ja: '体型', en: 'Body Type' },
        options: {
          ko: ['슬림', '보통', '글래머러스', '근육질', '통통'],
          ja: ['スリム', '普通', 'グラマラス', '筋肉質', 'ぽっちゃり'],
          en: ['Slim', 'Average', 'Curvy', 'Athletic', 'Full-figured'],
        },
        displayOrder: 2,
      },
      {
        fieldKey: 'smoking',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.LIFESTYLE,
        label: { ko: '흡연 여부', ja: '喫煙', en: 'Smoking' },
        options: {
          ko: ['비흡연', '흡연', '가끔 흡연'],
          ja: ['吸わない', '吸う', 'たまに吸う'],
          en: ['Non-smoker', 'Smoker', 'Occasional'],
        },
        isRequired: true,
        displayOrder: 3,
      },
      {
        fieldKey: 'drinking',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.LIFESTYLE,
        label: { ko: '음주 여부', ja: '飲酒', en: 'Drinking' },
        options: {
          ko: ['마시지 않음', '가끔 마심', '자주 마심'],
          ja: ['飲まない', 'たまに飲む', 'よく飲む'],
          en: ['Non-drinker', 'Social drinker', 'Regular drinker'],
        },
        isRequired: true,
        displayOrder: 4,
      },

      // 결혼 관련
      {
        fieldKey: 'marriage_intention',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.FAMILY,
        label: { ko: '결혼 의향', ja: '結婚意向', en: 'Marriage Intention' },
        options: {
          ko: ['1년 이내', '2-3년 이내', '좋은 사람 만나면', '아직 모름'],
          ja: ['1年以内', '2-3年以内', '良い人に出会えば', 'まだわからない'],
          en: ['Within 1 year', 'Within 2-3 years', 'If I meet the right person', 'Not sure yet'],
        },
        isRequired: true,
        displayOrder: 10,
      },
      {
        fieldKey: 'children_plan',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.FAMILY,
        label: { ko: '자녀 계획', ja: '子供の計画', en: 'Children Plan' },
        options: {
          ko: ['원함', '원하지 않음', '파트너와 상의', '아직 모름'],
          ja: ['欲しい', '欲しくない', 'パートナーと相談', 'まだわからない'],
          en: ['Want children', 'Do not want', 'Discuss with partner', 'Not sure'],
        },
        isRequired: true,
        displayOrder: 11,
      },
      {
        fieldKey: 'housework_division',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.FAMILY,
        label: { ko: '가사·육아 분담', ja: '家事·育児分担', en: 'Housework Division' },
        options: {
          ko: ['완전히 평등', '주로 나', '주로 상대방', '상황에 따라'],
          ja: ['完全に平等', '主に自分', '主に相手', '状況に応じて'],
          en: ['Completely equal', 'Mostly me', 'Mostly partner', 'Depends'],
        },
        displayOrder: 12,
      },

      // 직업 및 경제
      {
        fieldKey: 'occupation',
        fieldType: ProfileFieldType.TEXT,
        category: ProfileFieldCategory.CAREER,
        label: { ko: '직업', ja: '職業', en: 'Occupation' },
        placeholder: { ko: '예: IT 개발자', ja: '例: ITエンジニア', en: 'e.g. Software Engineer' },
        isRequired: true,
        displayOrder: 20,
      },
      {
        fieldKey: 'workplace',
        fieldType: ProfileFieldType.TEXT,
        category: ProfileFieldCategory.CAREER,
        label: { ko: '근무지', ja: '勤務地', en: 'Workplace' },
        placeholder: { ko: '예: 서울시 강남구', ja: '例: 東京都渋谷区', en: 'e.g. Seoul, Gangnam' },
        displayOrder: 21,
      },
      {
        fieldKey: 'annual_income',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.CAREER,
        label: { ko: '연 수입', ja: '年収', en: 'Annual Income' },
        options: {
          ko: ['3천만원 미만', '3천-5천만원', '5천-7천만원', '7천만원-1억', '1억 이상', '밝히고 싶지 않음'],
          ja: ['300万円未満', '300-500万円', '500-700万円', '700万-1000万円', '1000万円以上', '言いたくない'],
          en: ['<$30K', '$30-50K', '$50-70K', '$70-100K', '>$100K', 'Prefer not to say'],
        },
        displayOrder: 22,
      },
      {
        fieldKey: 'education',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.CAREER,
        label: { ko: '최종 학력', ja: '最終学歴', en: 'Education' },
        options: {
          ko: ['고등학교 졸업', '전문대 졸업', '대학교 졸업', '대학원 재학/졸업'],
          ja: ['高校卒業', '専門学校卒業', '大学卒業', '大学院在学/卒業'],
          en: ['High school', 'Associate degree', 'Bachelor degree', 'Graduate degree'],
        },
        isRequired: true,
        displayOrder: 23,
      },

      // 성격 및 라이프스타일
      {
        fieldKey: 'personality',
        fieldType: ProfileFieldType.MULTI_SELECT,
        category: ProfileFieldCategory.PERSONALITY,
        label: { ko: '성격', ja: '性格', en: 'Personality' },
        options: {
          ko: ['외향적', '내향적', '활발함', '차분함', '유머러스', '진지함', '낙천적', '신중함'],
          ja: ['外向的', '内向的', '活発', '落ち着いている', 'ユーモラス', '真面目', '楽観的', '慎重'],
          en: ['Extroverted', 'Introverted', 'Energetic', 'Calm', 'Humorous', 'Serious', 'Optimistic', 'Cautious'],
        },
        displayOrder: 30,
      },
      {
        fieldKey: 'sociability',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.PERSONALITY,
        label: { ko: '사교성', ja: '社交性', en: 'Sociability' },
        options: {
          ko: ['매우 사교적', '사교적', '보통', '조용한 편', '매우 조용함'],
          ja: ['とても社交的', '社交的', '普通', '静かな方', 'とても静か'],
          en: ['Very social', 'Social', 'Average', 'Quiet', 'Very quiet'],
        },
        displayOrder: 31,
      },
      {
        fieldKey: 'charm_points',
        fieldType: ProfileFieldType.MULTI_SELECT,
        category: ProfileFieldCategory.PERSONALITY,
        label: { ko: '매력 포인트', ja: '魅力ポイント', en: 'Charm Points' },
        options: {
          ko: ['웃는 얼굴', '목소리', '패션 감각', '요리 실력', '유머 감각', '배려심', '지적인 면'],
          ja: ['笑顔', '声', 'ファッションセンス', '料理の腕', 'ユーモア', '思いやり', '知的な面'],
          en: ['Smile', 'Voice', 'Fashion sense', 'Cooking skills', 'Humor', 'Thoughtfulness', 'Intelligence'],
        },
        displayOrder: 32,
      },

      // 선호사항
      {
        fieldKey: 'ideal_partner',
        fieldType: ProfileFieldType.TEXT,
        category: ProfileFieldCategory.PREFERENCES,
        label: { ko: '이상적인 상대', ja: '理想の相手', en: 'Ideal Partner' },
        placeholder: { ko: '어떤 사람을 원하시나요?', ja: 'どんな人を望みますか?', en: 'What kind of person do you want?' },
        displayOrder: 40,
      },
      {
        fieldKey: 'date_cost_sharing',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.PREFERENCES,
        label: { ko: '데이트 비용 부담', ja: 'デート費用分担', en: 'Date Cost Sharing' },
        options: {
          ko: ['항상 더치페이', '주로 더치페이', '번갈아 냄', '주로 남성', '상황에 따라'],
          ja: ['常に割り勘', '主に割り勘', '交互に出す', '主に男性', '状況に応じて'],
          en: ['Always split', 'Mostly split', 'Take turns', 'Mostly male pays', 'Depends'],
        },
        displayOrder: 41,
      },
      {
        fieldKey: 'important_values',
        fieldType: ProfileFieldType.MULTI_SELECT,
        category: ProfileFieldCategory.PREFERENCES,
        label: { ko: '배우자 선택 시 중시하는 가치', ja: '配偶者選択で重視する価値', en: 'Important Values in Partner' },
        options: {
          ko: ['성격', '외모', '경제력', '가족관', '취미 공유', '종교', '학력', '직업'],
          ja: ['性格', '外見', '経済力', '家族観', '趣味の共有', '宗教', '学歴', '職業'],
          en: ['Personality', 'Appearance', 'Financial status', 'Family values', 'Shared hobbies', 'Religion', 'Education', 'Occupation'],
        },
        displayOrder: 42,
      },
      {
        fieldKey: 'hobby_sharing',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.PREFERENCES,
        label: { ko: '취미 공유 여부', ja: '趣味の共有', en: 'Hobby Sharing' },
        options: {
          ko: ['모두 함께하고 싶음', '일부는 함께', '각자의 시간 존중', '상관없음'],
          ja: ['全て一緒にしたい', '一部は一緒に', 'お互いの時間を尊重', '気にしない'],
          en: ['Want to share all', 'Share some', 'Respect individual time', 'Does not matter'],
        },
        displayOrder: 43,
      },
      {
        fieldKey: 'weekend_activities',
        fieldType: ProfileFieldType.MULTI_SELECT,
        category: ProfileFieldCategory.LIFESTYLE,
        label: { ko: '휴일 활동', ja: '休日の活動', en: 'Weekend Activities' },
        options: {
          ko: ['집에서 휴식', '운동', '여행', '쇼핑', '문화생활', '친구 만남', '취미 활동'],
          ja: ['家で休む', '運動', '旅行', 'ショッピング', '文化生活', '友達と会う', '趣味活動'],
          en: ['Rest at home', 'Exercise', 'Travel', 'Shopping', 'Cultural activities', 'Meet friends', 'Hobbies'],
        },
        displayOrder: 44,
      },
      {
        fieldKey: 'work_after_marriage',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.FAMILY,
        label: { ko: '결혼 후 일하는 형태', ja: '結婚後の働き方', en: 'Work After Marriage' },
        options: {
          ko: ['계속 전일제', '파트타임', '프리랜서', '가정에 전념', '상황에 따라'],
          ja: ['フルタイム継続', 'パートタイム', 'フリーランス', '家庭に専念', '状況に応じて'],
          en: ['Continue full-time', 'Part-time', 'Freelance', 'Focus on family', 'Depends'],
        },
        displayOrder: 45,
      },
      {
        fieldKey: 'living_situation',
        fieldType: ProfileFieldType.SELECT,
        category: ProfileFieldCategory.FAMILY,
        label: { ko: '동거 형태', ja: '同居形態', en: 'Living Situation' },
        options: {
          ko: ['혼자 거주', '가족과 동거', '룸메이트와 동거', '기타'],
          ja: ['一人暮らし', '家族と同居', 'ルームメイトと同居', 'その他'],
          en: ['Living alone', 'Living with family', 'Living with roommate', 'Other'],
        },
        displayOrder: 46,
      },
      {
        fieldKey: 'siblings',
        fieldType: ProfileFieldType.TEXT,
        category: ProfileFieldCategory.FAMILY,
        label: { ko: '형제자매', ja: '兄弟姉妹', en: 'Siblings' },
        placeholder: { ko: '예: 형 1명, 여동생 1명', ja: '例: 兄1人、妹1人', en: 'e.g. 1 older brother, 1 younger sister' },
        displayOrder: 47,
      },
    ];

    const created = [];
    for (const field of fields) {
      const existing = await prisma.profileField.findUnique({
        where: { fieldKey: field.fieldKey },
      });

      if (!existing) {
        const newField = await this.createField(field);
        created.push(newField);
      }
    }

    return created;
  }
}
