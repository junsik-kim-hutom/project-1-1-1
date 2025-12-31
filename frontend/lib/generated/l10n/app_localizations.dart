import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'I Can Get Married'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to find\nsomeone special'**
  String get appSubtitle;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'{provider} login will be available soon.'**
  String comingSoonMessage(String provider);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @startWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get startWithGoogle;

  /// No description provided for @startWithLine.
  ///
  /// In en, this message translates to:
  /// **'Continue with LINE'**
  String get startWithLine;

  /// No description provided for @startWithYahoo.
  ///
  /// In en, this message translates to:
  /// **'Continue with Yahoo'**
  String get startWithYahoo;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to our '**
  String get termsAgreement;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAgreementEnd.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsAgreementEnd;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithLine.
  ///
  /// In en, this message translates to:
  /// **'Login with LINE'**
  String get loginWithLine;

  /// No description provided for @loginWithYahoo.
  ///
  /// In en, this message translates to:
  /// **'Login with Yahoo'**
  String get loginWithYahoo;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @smoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get smoking;

  /// No description provided for @drinking.
  ///
  /// In en, this message translates to:
  /// **'Drinking'**
  String get drinking;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @sometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get sometimes;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @matching.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get matching;

  /// No description provided for @matchList.
  ///
  /// In en, this message translates to:
  /// **'Match List'**
  String get matchList;

  /// No description provided for @balanceGame.
  ///
  /// In en, this message translates to:
  /// **'Balance Game'**
  String get balanceGame;

  /// No description provided for @compatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get compatibility;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatList.
  ///
  /// In en, this message translates to:
  /// **'Chat List'**
  String get chatList;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get hello;

  /// No description provided for @todayMessage.
  ///
  /// In en, this message translates to:
  /// **'What special encounters await you today?'**
  String get todayMessage;

  /// No description provided for @findMatching.
  ///
  /// In en, this message translates to:
  /// **'Find Match'**
  String get findMatching;

  /// No description provided for @eqTest.
  ///
  /// In en, this message translates to:
  /// **'EQ Test'**
  String get eqTest;

  /// No description provided for @myActivity.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivity;

  /// No description provided for @profileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile Views'**
  String get profileViews;

  /// No description provided for @likesReceived.
  ///
  /// In en, this message translates to:
  /// **'Likes Received'**
  String get likesReceived;

  /// No description provided for @ongoingChats.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Chats'**
  String get ongoingChats;

  /// No description provided for @recommendedMatches.
  ///
  /// In en, this message translates to:
  /// **'Recommended Matches'**
  String get recommendedMatches;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @eqTestTitle.
  ///
  /// In en, this message translates to:
  /// **'EQ Emotional Intelligence Test'**
  String get eqTestTitle;

  /// No description provided for @eqTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover your personality type'**
  String get eqTestSubtitle;

  /// No description provided for @eqTestDescription.
  ///
  /// In en, this message translates to:
  /// **'25 simple questions to analyze your emotional intelligence and find better matches for you.'**
  String get eqTestDescription;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get startTest;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get years;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @matchPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Match'**
  String matchPercent(int percent);

  /// No description provided for @matchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get matchingTitle;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filterSettings.
  ///
  /// In en, this message translates to:
  /// **'Filter Settings'**
  String get filterSettings;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @allMatchesViewed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve viewed all matches'**
  String get allMatchesViewed;

  /// No description provided for @findingNewMatches.
  ///
  /// In en, this message translates to:
  /// **'Finding new matches'**
  String get findingNewMatches;

  /// No description provided for @viewAgain.
  ///
  /// In en, this message translates to:
  /// **'View Again'**
  String get viewAgain;

  /// No description provided for @superLike.
  ///
  /// In en, this message translates to:
  /// **'Super Like!'**
  String get superLike;

  /// No description provided for @likeSent.
  ///
  /// In en, this message translates to:
  /// **'Like sent!'**
  String get likeSent;

  /// No description provided for @nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Moving to next match'**
  String get nextMatch;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @designer.
  ///
  /// In en, this message translates to:
  /// **'Designer'**
  String get designer;

  /// No description provided for @marketer.
  ///
  /// In en, this message translates to:
  /// **'Marketer'**
  String get marketer;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @seoulGangnam.
  ///
  /// In en, this message translates to:
  /// **'Gangnam, Seoul'**
  String get seoulGangnam;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! Looking forward to special encounters.'**
  String get greeting;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @startMatchingToChat.
  ///
  /// In en, this message translates to:
  /// **'Start matching and have conversations'**
  String get startMatchingToChat;

  /// No description provided for @goToMatching.
  ///
  /// In en, this message translates to:
  /// **'Go to Matching'**
  String get goToMatching;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @profileCompleteness.
  ///
  /// In en, this message translates to:
  /// **'Profile Completeness'**
  String get profileCompleteness;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile'**
  String get completeProfile;

  /// No description provided for @premiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get premiumMember;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
