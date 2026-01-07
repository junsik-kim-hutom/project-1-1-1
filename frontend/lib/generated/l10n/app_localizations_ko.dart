// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TruePair';

  @override
  String get appSubtitle => '특별한 사람과의 만남,\n지금 시작하세요';

  @override
  String get loginSuccess => '로그인 성공!';

  @override
  String get loginFailed => '로그인 실패';

  @override
  String get unknownError => '알 수 없는 오류';

  @override
  String get comingSoon => '준비 중';

  @override
  String comingSoonMessage(String provider) {
    return '$provider 로그인은 곧 지원될 예정입니다.';
  }

  @override
  String get confirm => '확인';

  @override
  String get startWithGoogle => 'Google로 시작하기';

  @override
  String get startWithLine => 'LINE으로 시작하기';

  @override
  String get startWithYahoo => 'Yahoo로 시작하기';

  @override
  String get termsAgreement => '로그인하시면 ';

  @override
  String get termsOfService => '서비스 이용약관';

  @override
  String get and => ' 및 ';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get termsAgreementEnd => '에\n동의하는 것으로 간주됩니다.';

  @override
  String get login => '로그인';

  @override
  String get loginWithGoogle => 'Google로 로그인';

  @override
  String get loginWithLine => 'LINE으로 로그인';

  @override
  String get loginWithYahoo => 'Yahoo로 로그인';

  @override
  String get profile => '프로필';

  @override
  String get createProfile => '프로필 작성';

  @override
  String get editProfile => '프로필 수정';

  @override
  String get name => '이름';

  @override
  String get gender => '성별';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get other => '기타';

  @override
  String get birthDate => '생년월일';

  @override
  String get height => '키';

  @override
  String get occupation => '직업';

  @override
  String get education => '학력';

  @override
  String get smoking => '흡연';

  @override
  String get drinking => '음주';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get sometimes => '가끔';

  @override
  String get all => '전체';

  @override
  String get bio => '자기소개';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get location => '위치';

  @override
  String get setLocation => '위치 설정';

  @override
  String get currentLocation => '현재 위치';

  @override
  String get matching => '매칭';

  @override
  String get matchList => '매칭 목록';

  @override
  String get balanceGame => '밸런스 게임';

  @override
  String get compatibility => '매칭률';

  @override
  String get chat => '채팅';

  @override
  String get chatList => '채팅 목록';

  @override
  String get sendMessage => '메시지 전송';

  @override
  String get typing => '입력 중...';

  @override
  String get payment => '결제';

  @override
  String get subscribe => '구독하기';

  @override
  String get premium => '프리미엄';

  @override
  String get upgrade => '업그레이드';

  @override
  String get settings => '설정';

  @override
  String get logout => '로그아웃';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get loading => '로딩 중...';

  @override
  String get retry => '다시 시도';

  @override
  String get close => '닫기';

  @override
  String get home => '홈';

  @override
  String get notifications => '알림';

  @override
  String get hello => '안녕하세요! 👋';

  @override
  String get todayMessage => '오늘은 어떤 특별한 만남이 기다리고 있을까요?';

  @override
  String get findMatching => '매칭 찾기';

  @override
  String get eqTest => 'EQ 테스트';

  @override
  String get myActivity => '나의 활동';

  @override
  String get profileViews => '프로필 조회';

  @override
  String get likesSent => '보낸 좋아요';

  @override
  String get likesReceived => '받은 좋아요';

  @override
  String get boostsSent => '보낸 부스트';

  @override
  String get boostsReceived => '받은 부스트';

  @override
  String get ongoingChats => '진행 중인 채팅';

  @override
  String get noNotifications => '알림이 없습니다.';

  @override
  String get noActivity => '표시할 내역이 없습니다.';

  @override
  String get recommendedMatches => '추천 매칭';

  @override
  String get seeMore => '더보기';

  @override
  String get eqTestTitle => 'EQ 감성 지능 테스트';

  @override
  String get eqTestSubtitle => '나의 성격 유형을 알아보세요';

  @override
  String get eqTestDescription =>
      '25개의 간단한 질문으로 당신의 감성 지능을 분석하고, 더 잘 맞는 상대를 찾아드립니다.';

  @override
  String get startTest => '테스트 시작하기';

  @override
  String get eqTestResultTitle => 'EQ 테스트 결과';

  @override
  String get eqTestNoQuestions => '질문이 없습니다.';

  @override
  String get eqTestAutoAdvanceHint => '선택하면 자동으로 다음 문항으로 이동해요';

  @override
  String get eqTestCategoryEmpathy => '공감';

  @override
  String get eqTestCategorySelfAwareness => '자기 인식';

  @override
  String get eqTestCategorySocialSkills => '사회성';

  @override
  String get eqTestCategoryMotivation => '동기';

  @override
  String get eqTestCategoryEmotionRegulation => '감정 조절';

  @override
  String get eqTestCategoryEQ => 'EQ';

  @override
  String get eqTestLikert1 => '전혀 아니다';

  @override
  String get eqTestLikert2 => '아니다';

  @override
  String get eqTestLikert3 => '보통이다';

  @override
  String get eqTestLikert4 => '그렇다';

  @override
  String get eqTestLikert5 => '매우 그렇다';

  @override
  String get eqTestAllAnsweredTitle => '모든 질문에 답변하셨습니다!';

  @override
  String get eqTestCalculatingResult => '결과를 계산하고 있습니다...';

  @override
  String get eqTestViewResult => '결과 보기';

  @override
  String get eqTestResultCalculationError => '결과 계산 오류';

  @override
  String get eqTestStrengthsTitle => '당신의 강점';

  @override
  String get eqTestImprovementsTitle => '개선할 점';

  @override
  String get eqTestMatchingTipsTitle => '매칭 팁';

  @override
  String get eqTestPersonalityType => '성격 유형';

  @override
  String get eqTestOverallScore => '종합 점수';

  @override
  String get eqTestDetailedScores => '세부 점수';

  @override
  String get eqTestScoreEmpathy => '공감 능력';

  @override
  String get eqTestScoreSelfAwareness => '자기 인식';

  @override
  String get eqTestScoreSocialSkills => '사회적 기술';

  @override
  String get eqTestScoreMotivation => '동기부여';

  @override
  String get eqTestScoreEmotionRegulation => '감정 조절';

  @override
  String get years => '세';

  @override
  String get km => 'km';

  @override
  String matchPercent(int percent) {
    return '$percent% 매칭';
  }

  @override
  String get matchingTitle => '매칭';

  @override
  String get distance => '거리';

  @override
  String get filters => '필터';

  @override
  String get filterSettings => '필터 설정';

  @override
  String get matchingActionGuideTitle => '매칭 사용 안내';

  @override
  String get matchingActionGuideInterest => '관심: 상대에게 관심을 표시해요.';

  @override
  String get matchingActionGuideBoost => '부스트: 관심보다 더 강하게 표시되어 우선 노출될 수 있어요.';

  @override
  String get matchingActionGuideChat => '메시지: 채팅을 시작해요.';

  @override
  String get age => '나이';

  @override
  String get cm => 'cm';

  @override
  String get educationHighSchool => '고등학교';

  @override
  String get educationCollege => '대학교';

  @override
  String get educationGraduate => '대학원';

  @override
  String get pass => '패스';

  @override
  String get interest => '관심';

  @override
  String get boost => '부스트';

  @override
  String get swipeHint => '좌우로 스와이프';

  @override
  String get apply => '적용';

  @override
  String get allMatchesViewed => '모든 매칭을 확인했어요';

  @override
  String get findingNewMatches => '새로운 매칭을 찾고 있습니다';

  @override
  String get viewAgain => '다시 보기';

  @override
  String get superLike => '부스트를 보냈어요!';

  @override
  String get likeSent => '관심을 보냈어요';

  @override
  String get nextMatch => '다음 프로필로 넘겼어요';

  @override
  String get user => '사용자';

  @override
  String get developer => '개발자';

  @override
  String get designer => '디자이너';

  @override
  String get marketer => '마케터';

  @override
  String get planner => '기획자';

  @override
  String get teacher => '교사';

  @override
  String get seoulGangnam => '서울시 강남구';

  @override
  String get greeting => '안녕하세요! 특별한 만남을 기대합니다.';

  @override
  String get chatTitle => '채팅';

  @override
  String get noChatsYet => '아직 채팅이 없습니다';

  @override
  String get startMatchingToChat => '매칭을 시작하고 대화를 나눠보세요';

  @override
  String get goToMatching => '매칭하러 가기';

  @override
  String get online => '온라인';

  @override
  String get justNow => '방금';

  @override
  String minutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String daysAgo(int days) {
    return '$days일 전';
  }

  @override
  String get myProfile => '내 프로필';

  @override
  String get profileCompleteness => '프로필 완성도';

  @override
  String get completeProfile => '프로필을 완성해주세요';

  @override
  String get premiumMember => '프리미엄 회원';

  @override
  String get upgradeToPremium => '프리미엄으로 업그레이드';

  @override
  String get accountSettings => '계정 설정';

  @override
  String get privacySettings => '개인정보 설정';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get help => '도움말';

  @override
  String get aboutApp => '앱 정보';

  @override
  String get version => '버전';

  @override
  String get appSettings => '앱 설정';

  @override
  String get subscriptionAndPayment => '구독 및 결제';

  @override
  String get support => '지원';

  @override
  String get account => '계정';

  @override
  String get manageLocations => '활동 지역 관리';

  @override
  String get locationMyNeighborhoodSettings => '내 동네 설정';

  @override
  String get locationSearchHint => '내 동네 이름(동,읍,면)으로 검색';

  @override
  String get locationFindByCurrentLocation => '현재 위치로 찾기';

  @override
  String get locationFinding => '찾는 중...';

  @override
  String get locationNearbyNeighborhoods => '근처 동네';

  @override
  String get locationSearchResults => '검색 결과';

  @override
  String get locationNoSearchResults => '검색 결과가 없어요.';

  @override
  String get locationFailedToLoadNearby => '근처 동네를 불러오지 못했어요.';

  @override
  String get locationCurrentLocationFailed => '현재 위치를 가져오지 못했어요.';

  @override
  String get locationSearchFailed => '검색에 실패했어요.';

  @override
  String get locationMaxTwoAreas => '최대 2개의 지역만 등록할 수 있습니다';

  @override
  String get locationMyNeighborhood => '내 동네';

  @override
  String get locationMyNeighborhoodSubtitle => '선택한 동네를 기준으로 게시글을 볼 수 있어요.';

  @override
  String get locationHelpBody =>
      '• 최대 2개의 활동 지역을 설정할 수 있어요.\n• 선택한 동네를 기준으로 매칭/게시글을 볼 수 있어요.\n• 동네 칩을 길게 누르면 동네를 변경할 수 있어요.';

  @override
  String get locationMapSetupRequiredTitle => '지도 설정 필요';

  @override
  String get locationMapSetupRequiredBody =>
      'Google Maps API Key가 설정되어 있지 않아 지도 화면을 표시할 수 없어요.\n\niOS: `frontend/ios/Flutter/Secrets.xcconfig`에 `GOOGLE_MAPS_API_KEY`를 설정하세요.\nAndroid: `frontend/android/local.properties`에 `GOOGLE_MAPS_API_KEY`를 설정하세요(또는 환경변수로 설정).';

  @override
  String get locationMapCannotShowTitle => '지도를 표시할 수 없어요';

  @override
  String get locationMapCannotShowBody =>
      'Google Maps API Key가 설정되지 않았습니다.\n아래 버튼을 눌러 설정 방법을 확인해주세요.';

  @override
  String get locationViewSetupGuide => '설정 안내 보기';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get themeSettings => '테마 설정';

  @override
  String get myPasses => '나의 이용권';

  @override
  String get paymentHistory => '결제 내역';

  @override
  String get customerSupport => '고객 지원';

  @override
  String get languageChanged => '언어가 변경되었습니다';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get languageEnglish => '영어';

  @override
  String get themeLight => '라이트 모드';

  @override
  String get themeDark => '다크 모드';

  @override
  String get themeSystem => '시스템 설정 따르기';

  @override
  String get navigateToPrivacySettings => '개인정보 설정 화면으로 이동';

  @override
  String get navigateToNotificationSettings => '알림 설정 화면으로 이동';

  @override
  String get navigateToCustomerSupport => '고객 지원 화면으로 이동';

  @override
  String get navigateToTermsOfService => '이용 약관 화면으로 이동';

  @override
  String get navigateToPrivacyPolicy => '개인정보 처리방침 화면으로 이동';

  @override
  String get aboutDescription => '위치 기반 결혼 상대 매칭 서비스';

  @override
  String get aboutLegal => '© 2025 Marriage Matching. All rights reserved.';

  @override
  String get deleteAccount => '회원 탈퇴';

  @override
  String get deleteAccountConfirm =>
      '정말로 회원 탈퇴를 하시겠습니까?\n\n탈퇴 시 모든 데이터가 삭제되며, 복구할 수 없습니다.';

  @override
  String get deleteAccountCompleted => '회원 탈퇴가 처리되었습니다';

  @override
  String get deleteAccountAction => '탈퇴';

  @override
  String get logoutConfirm => '정말 로그아웃 하시겠습니까?';

  @override
  String get profileNotFoundMessage => '프로필을 먼저 등록해 주세요.';

  @override
  String get failedToLoadProfile => '프로필을 불러오지 못했습니다.';

  @override
  String get notEntered => '미입력';

  @override
  String get seeLess => '접기';

  @override
  String get loginRequired => '로그인이 필요합니다.';

  @override
  String get pleaseSelect => '선택해주세요';

  @override
  String get pleaseSelectBirthDate => '생년월일을 선택해주세요.';

  @override
  String pleaseEnterField(String field) {
    return '$field 입력해주세요';
  }

  @override
  String pleaseSelectField(String field) {
    return '$field 선택해주세요';
  }

  @override
  String get residence => '거주지';

  @override
  String get residenceHint => '예: 서울 강남구';

  @override
  String get bodyType => '몸매';

  @override
  String get bodyTypeSlim => '슬림';

  @override
  String get bodyTypeAverage => '보통';

  @override
  String get bodyTypeGlamorous => '글래머러스';

  @override
  String get bodyTypeMuscular => '근육질';

  @override
  String get bodyTypeChubby => '통통';

  @override
  String get marriageIntention => '결혼 의향';

  @override
  String get marriageIntentionActive => '적극적';

  @override
  String get marriageIntentionYes => '있음';

  @override
  String get marriageIntentionSlow => '천천히 생각 중';

  @override
  String get marriageIntentionNotSure => '아직 모름';

  @override
  String get childrenPlan => '자녀 계획';

  @override
  String get childrenPlanWant => '원함';

  @override
  String get childrenPlanNo => '원하지 않음';

  @override
  String get childrenPlanUndecided => '미정';

  @override
  String get childrenPlanDiscuss => '상의 후 결정';

  @override
  String get annualIncome => '연 수입';

  @override
  String get annualIncomeHint => '예: 5000만원';

  @override
  String get marriageTiming => '결혼 시기 희망';

  @override
  String get marriageTimingWithin6Months => '6개월 이내';

  @override
  String get marriageTimingWithin1Year => '1년 이내';

  @override
  String get marriageTimingWithin2to3Years => '2-3년 이내';

  @override
  String get marriageTimingSlowly => '천천히';

  @override
  String get marriageTimingUndecided => '미정';

  @override
  String get dateCostSharing => '데이트 비용 부담';

  @override
  String get dateCostSharingManPays => '남성 부담';

  @override
  String get dateCostSharingWomanPays => '여성 부담';

  @override
  String get dateCostSharingDutch => '더치페이';

  @override
  String get dateCostSharingAlternate => '번갈아 부담';

  @override
  String get dateCostSharingDiscuss => '협의';

  @override
  String get importantValue => '배우자 선택 시 중시하는 가치';

  @override
  String get importantValuePersonality => '성격/인성';

  @override
  String get importantValueFinancial => '경제력';

  @override
  String get importantValueAppearance => '외모';

  @override
  String get importantValueFamily => '가정환경';

  @override
  String get importantValueOccupationEducation => '직업/학벌';

  @override
  String get importantValueValues => '가치관';

  @override
  String get importantValueReligion => '종교';

  @override
  String get houseworkSharing => '가사·육아 분담';

  @override
  String get houseworkSharingEqual => '평등 분담';

  @override
  String get houseworkSharingFlexible => '유연하게';

  @override
  String get houseworkSharingMostlyWoman => '주로 여성';

  @override
  String get houseworkSharingMostlyMan => '주로 남성';

  @override
  String get houseworkSharingDiscuss => '협의';

  @override
  String get charmPoint => '매력 포인트';

  @override
  String get charmPointHint => '예: 유머 감각, 배려심 등';

  @override
  String get idealPartner => '이상적인 상대';

  @override
  String get idealPartnerHint => '원하는 상대의 특징을 적어주세요';

  @override
  String get holidayActivity => '휴일 활동';

  @override
  String get holidayActivityHint => '예: 영화 감상, 등산, 카페 투어 등';

  @override
  String get occupationOfficeWorker => '회사원';

  @override
  String get occupationPublicServant => '공무원';

  @override
  String get occupationSelfEmployed => '자영업';

  @override
  String get occupationProfessional => '전문직 (의사, 변호사 등)';

  @override
  String get occupationDeveloper => '개발자/IT';

  @override
  String get occupationEducation => '교육/강사';

  @override
  String get occupationService => '서비스업';

  @override
  String get occupationArtDesign => '예술/디자인';

  @override
  String get occupationStudent => '학생';

  @override
  String get occupationOther => '기타';

  @override
  String get educationHighSchoolGraduate => '고등학교 졸업';

  @override
  String get educationJuniorCollegeGraduate => '전문대 졸업';

  @override
  String get educationUniversityGraduate => '대학교 졸업';

  @override
  String get educationMasters => '대학원 석사';

  @override
  String get educationPhd => '대학원 박사';

  @override
  String get educationOther => '기타';

  @override
  String get profilePhotos => '프로필 사진';

  @override
  String get selectMainPhoto => '대표 사진을 선택해주세요';

  @override
  String get selectFromGallery => '갤러리에서 선택';

  @override
  String get takePhoto => '카메라로 촬영';

  @override
  String get selectMultiplePhotos => '여러 장 선택';

  @override
  String get addPhoto => '사진 추가';

  @override
  String get mainPhoto => '대표';

  @override
  String maxImagesSelectLimit(int max) {
    return '최대 $max장까지만 선택할 수 있습니다';
  }

  @override
  String maxImagesSelected(int max) {
    return '최대 $max장까지만 선택되었습니다';
  }

  @override
  String imageSelectionFailed(String error) {
    return '이미지 선택 실패: $error';
  }

  @override
  String get imageUploadCompleted => '이미지 업로드 완료';

  @override
  String imagesUploadCompleted(int count) {
    return '$count개 이미지 업로드 완료';
  }

  @override
  String imageUploadFailed(String error) {
    return '업로드 실패: $error';
  }

  @override
  String profilePhotoGuidelines(int max) {
    return '• 최소 1장, 최대 $max장까지 등록 가능합니다\n• 여러 장 등록 시 대표 사진을 선택해주세요\n• 이미지는 자동으로 서버에 업로드됩니다';
  }

  @override
  String get alreadyLiked => '이미 좋아요를 보냈습니다';

  @override
  String get alreadyBoosted => '이미 부스트를 보냈습니다';

  @override
  String get cancelAction => '취소';

  @override
  String get cancelConfirm => '정말 취소하시겠습니까?';

  @override
  String get actionCanceled => '취소되었습니다';

  @override
  String get locationNotSet => '내 동네를 설정해주세요';

  @override
  String get locationNotSetMessage => '거리 필터를 사용하려면 먼저 내 동네를 설정해야 합니다.';

  @override
  String get goToSettings => '설정하러 가기';
}
