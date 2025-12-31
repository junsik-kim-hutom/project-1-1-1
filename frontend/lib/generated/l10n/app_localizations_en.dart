// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'I Can Get Married';

  @override
  String get appSubtitle => 'Start your journey to find\nsomeone special';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String comingSoonMessage(String provider) {
    return '$provider login will be available soon.';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get startWithGoogle => 'Continue with Google';

  @override
  String get startWithLine => 'Continue with LINE';

  @override
  String get startWithYahoo => 'Continue with Yahoo';

  @override
  String get termsAgreement => 'By logging in, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAgreementEnd => '.';

  @override
  String get login => 'Login';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get loginWithLine => 'Login with LINE';

  @override
  String get loginWithYahoo => 'Login with Yahoo';

  @override
  String get profile => 'Profile';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get name => 'Name';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get height => 'Height';

  @override
  String get occupation => 'Occupation';

  @override
  String get education => 'Education';

  @override
  String get smoking => 'Smoking';

  @override
  String get drinking => 'Drinking';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get sometimes => 'Sometimes';

  @override
  String get bio => 'Bio';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get location => 'Location';

  @override
  String get setLocation => 'Set Location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get matching => 'Matching';

  @override
  String get matchList => 'Match List';

  @override
  String get balanceGame => 'Balance Game';

  @override
  String get compatibility => 'Compatibility';

  @override
  String get chat => 'Chat';

  @override
  String get chatList => 'Chat List';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get typing => 'Typing...';

  @override
  String get payment => 'Payment';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get premium => 'Premium';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get hello => 'Hello! 👋';

  @override
  String get todayMessage => 'What special encounters await you today?';

  @override
  String get findMatching => 'Find Match';

  @override
  String get eqTest => 'EQ Test';

  @override
  String get myActivity => 'My Activity';

  @override
  String get profileViews => 'Profile Views';

  @override
  String get likesReceived => 'Likes Received';

  @override
  String get ongoingChats => 'Ongoing Chats';

  @override
  String get recommendedMatches => 'Recommended Matches';

  @override
  String get seeMore => 'See More';

  @override
  String get eqTestTitle => 'EQ Emotional Intelligence Test';

  @override
  String get eqTestSubtitle => 'Discover your personality type';

  @override
  String get eqTestDescription =>
      '25 simple questions to analyze your emotional intelligence and find better matches for you.';

  @override
  String get startTest => 'Start Test';

  @override
  String get years => 'years old';

  @override
  String get km => 'km';

  @override
  String matchPercent(int percent) {
    return '$percent% Match';
  }

  @override
  String get matchingTitle => 'Matching';

  @override
  String get filters => 'Filters';

  @override
  String get filterSettings => 'Filter Settings';

  @override
  String get age => 'Age';

  @override
  String get apply => 'Apply';

  @override
  String get allMatchesViewed => 'You\'ve viewed all matches';

  @override
  String get findingNewMatches => 'Finding new matches';

  @override
  String get viewAgain => 'View Again';

  @override
  String get superLike => 'Super Like!';

  @override
  String get likeSent => 'Like sent!';

  @override
  String get nextMatch => 'Moving to next match';

  @override
  String get user => 'User';

  @override
  String get developer => 'Developer';

  @override
  String get designer => 'Designer';

  @override
  String get marketer => 'Marketer';

  @override
  String get planner => 'Planner';

  @override
  String get teacher => 'Teacher';

  @override
  String get seoulGangnam => 'Gangnam, Seoul';

  @override
  String get greeting => 'Hello! Looking forward to special encounters.';

  @override
  String get chatTitle => 'Chat';

  @override
  String get noChatsYet => 'No chats yet';

  @override
  String get startMatchingToChat => 'Start matching and have conversations';

  @override
  String get goToMatching => 'Go to Matching';

  @override
  String get online => 'Online';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get myProfile => 'My Profile';

  @override
  String get profileCompleteness => 'Profile Completeness';

  @override
  String get completeProfile => 'Please complete your profile';

  @override
  String get premiumMember => 'Premium Member';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get help => 'Help';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version';
}
