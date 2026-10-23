import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
  ];

  /// Native name of this locale, shown in the language selector.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @sanctuaryWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get sanctuaryWelcome;

  /// No description provided for @sanctuaryTitle.
  ///
  /// In en, this message translates to:
  /// **'HIKARU SANCTUARY'**
  String get sanctuaryTitle;

  /// No description provided for @sanctuaryTagline.
  ///
  /// In en, this message translates to:
  /// **'Where Beauty Meets Frequency.'**
  String get sanctuaryTagline;

  /// No description provided for @sanctuaryEnter.
  ///
  /// In en, this message translates to:
  /// **'ENTER THE SANCTUARY'**
  String get sanctuaryEnter;

  /// No description provided for @discoveryRoomEyebrow.
  ///
  /// In en, this message translates to:
  /// **'THE DISCOVERY ROOM'**
  String get discoveryRoomEyebrow;

  /// No description provided for @discoveryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your Journey\nBegins With You'**
  String get discoveryHeadline;

  /// No description provided for @discoveryStepKnowYouTitle.
  ///
  /// In en, this message translates to:
  /// **'GETTING TO KNOW YOU'**
  String get discoveryStepKnowYouTitle;

  /// No description provided for @discoveryStepKnowYouBody.
  ///
  /// In en, this message translates to:
  /// **'A few details to make your Hikaru experience uniquely yours.'**
  String get discoveryStepKnowYouBody;

  /// No description provided for @discoveryStepSkinTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR SKIN JOURNEY'**
  String get discoveryStepSkinTitle;

  /// No description provided for @discoveryStepSkinBody.
  ///
  /// In en, this message translates to:
  /// **'Optional photos to help you observe your progress over time.'**
  String get discoveryStepSkinBody;

  /// No description provided for @discoveryStepPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR PRIVACY'**
  String get discoveryStepPrivacyTitle;

  /// No description provided for @discoveryStepPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your information is yours. Your trust is our priority.'**
  String get discoveryStepPrivacyBody;

  /// No description provided for @discoveryStepChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'ALWAYS YOUR CHOICE'**
  String get discoveryStepChoiceTitle;

  /// No description provided for @discoveryStepChoiceBody.
  ///
  /// In en, this message translates to:
  /// **'You decide what to share and how to personalize your experience.'**
  String get discoveryStepChoiceBody;

  /// No description provided for @discoveryBegin.
  ///
  /// In en, this message translates to:
  /// **'BEGIN MY DISCOVERY'**
  String get discoveryBegin;

  /// No description provided for @discoveryFooter.
  ///
  /// In en, this message translates to:
  /// **'BEAUTY MEETS FREQUENCY'**
  String get discoveryFooter;

  /// No description provided for @ritualHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your Sanctuary Is\nAlmost Ready'**
  String get ritualHeadline;

  /// No description provided for @ritualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A sacred tool will elevate your ritual\nand guide you to visible transformation.'**
  String get ritualSubtitle;

  /// No description provided for @ritualChoosePath.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR PATH'**
  String get ritualChoosePath;

  /// No description provided for @ritualPathNoHikaruTitle.
  ///
  /// In en, this message translates to:
  /// **'I DON\'T HAVE\nMY HIKARU YET'**
  String get ritualPathNoHikaruTitle;

  /// No description provided for @ritualPathNoHikaruAction.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER HIKARU'**
  String get ritualPathNoHikaruAction;

  /// No description provided for @ritualPathHaveHikaruTitle.
  ///
  /// In en, this message translates to:
  /// **'I ALREADY HAVE\nMY HIKARU'**
  String get ritualPathHaveHikaruTitle;

  /// No description provided for @ritualPathHaveHikaruAction.
  ///
  /// In en, this message translates to:
  /// **'BEGIN MY RITUAL'**
  String get ritualPathHaveHikaruAction;

  /// No description provided for @ritualFooter.
  ///
  /// In en, this message translates to:
  /// **'EVERY RITUAL BEGINS WITH INTENTION.\nYOU DESERVE THIS MOMENT.'**
  String get ritualFooter;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// No description provided for @authEmailHintExample.
  ///
  /// In en, this message translates to:
  /// **'you@domain.com'**
  String get authEmailHintExample;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authErrorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authErrorEmailRequired;

  /// No description provided for @authErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authErrorEmailInvalid;

  /// No description provided for @authErrorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authErrorPasswordRequired;

  /// No description provided for @authErrorPasswordPolicy.
  ///
  /// In en, this message translates to:
  /// **'Use 8 characters with upper, lower, number, and a symbol'**
  String get authErrorPasswordPolicy;

  /// No description provided for @authIdentityLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get authIdentityLabel;

  /// No description provided for @authIdentityHint.
  ///
  /// In en, this message translates to:
  /// **'username or you@domain.com'**
  String get authIdentityHint;

  /// No description provided for @authErrorIdentityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get authErrorIdentityRequired;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Not your email'**
  String get registerUsernameHint;

  /// No description provided for @registerErrorUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get registerErrorUsernameRequired;

  /// No description provided for @registerErrorUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use letters and numbers, not an email'**
  String get registerErrorUsernameInvalid;

  /// No description provided for @confirmSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get confirmSignUpTitle;

  /// No description provided for @confirmSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent you.'**
  String get confirmSignUpSubtitle;

  /// No description provided for @confirmSignUpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get confirmSignUpCodeLabel;

  /// No description provided for @confirmSignUpCodeHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get confirmSignUpCodeHint;

  /// No description provided for @confirmSignUpAction.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirmSignUpAction;

  /// No description provided for @confirmSignUpErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get confirmSignUpErrorCode;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Home'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR JOURNEY TO RADIANT SKIN'**
  String get loginSubtitle;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get loginRememberMe;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get loginSignIn;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOr;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a sanctuary? '**
  String get loginNoAccount;

  /// No description provided for @loginCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get loginCreateOne;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your\nSanctuary'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin with essentials to\npersonalize your experience.'**
  String get registerSubtitle;

  /// No description provided for @registerFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullNameLabel;

  /// No description provided for @registerFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get registerFullNameHint;

  /// No description provided for @registerBirthdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get registerBirthdayLabel;

  /// No description provided for @registerBirthdayHint.
  ///
  /// In en, this message translates to:
  /// **'MM / DD / YYYY'**
  String get registerBirthdayHint;

  /// intl DateFormat pattern used to display the chosen birthday. Not user-visible text.
  ///
  /// In en, this message translates to:
  /// **'MM / dd / yyyy'**
  String get registerBirthdayFormat;

  /// No description provided for @registerErrorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get registerErrorNameRequired;

  /// No description provided for @registerErrorBirthdayRequired.
  ///
  /// In en, this message translates to:
  /// **'Select your birthday'**
  String get registerErrorBirthdayRequired;

  /// No description provided for @registerContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get registerContinue;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @registerLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get registerLogIn;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Your\nPassword'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll help you regain access\nto your sanctuary.'**
  String get resetSubtitle;

  /// No description provided for @resetNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetNewPasswordLabel;

  /// No description provided for @resetNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get resetNewPasswordHint;

  /// No description provided for @resetConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetConfirmLabel;

  /// No description provided for @resetConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get resetConfirmHint;

  /// No description provided for @resetErrorNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get resetErrorNewPasswordRequired;

  /// No description provided for @resetErrorConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get resetErrorConfirmRequired;

  /// No description provided for @resetErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get resetErrorMismatch;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetButton;

  /// No description provided for @resetSendCode.
  ///
  /// In en, this message translates to:
  /// **'SEND CODE'**
  String get resetSendCode;

  /// No description provided for @resetResend.
  ///
  /// In en, this message translates to:
  /// **'RESEND CODE'**
  String get resetResend;

  /// No description provided for @resetCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get resetCodeLabel;

  /// No description provided for @resetCodeHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get resetCodeHint;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email.'**
  String get resetCodeSent;

  /// No description provided for @resetErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get resetErrorCode;

  /// No description provided for @resetRemember.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get resetRemember;

  /// No description provided for @resetSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get resetSignIn;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get commonNext;

  /// No description provided for @radiantFooter.
  ///
  /// In en, this message translates to:
  /// **'A  MORE  RADIANT  YOU  AWAITS'**
  String get radiantFooter;

  /// No description provided for @crystalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Your crystal recommendation is symbolic and is not a medical diagnosis or a scientifically proven treatment for skin conditions.'**
  String get crystalDisclaimer;

  /// No description provided for @listeningRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'The\nListening Room'**
  String get listeningRoomTitle;

  /// No description provided for @listeningRoomTagline.
  ///
  /// In en, this message translates to:
  /// **'A  SPACE  TO  BE  HEARD'**
  String get listeningRoomTagline;

  /// No description provided for @listeningRoomDescription.
  ///
  /// In en, this message translates to:
  /// **'Share what\'s on your mind\nso we can guide you with a\npersonalized ritual for your skin,\nyour body, and your energy.'**
  String get listeningRoomDescription;

  /// No description provided for @listeningRoomBegin.
  ///
  /// In en, this message translates to:
  /// **'BEGIN'**
  String get listeningRoomBegin;

  /// No description provided for @listeningRoomFooter.
  ///
  /// In en, this message translates to:
  /// **'LISTEN   ·   ALIGN   ·   RECEIVE'**
  String get listeningRoomFooter;

  /// No description provided for @quizHeader.
  ///
  /// In en, this message translates to:
  /// **'THE LISTENING GARDEN'**
  String get quizHeader;

  /// Second header line of the quiz. Its letters are tracked by the style, so words use single spaces.
  ///
  /// In en, this message translates to:
  /// **'A SPACE TO BE HEARD'**
  String get quizTagline;

  /// No description provided for @quizProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String quizProgressSemantics(int number, int total);

  /// No description provided for @quizSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option.'**
  String get quizSelectOption;

  /// No description provided for @ritualReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\nRitual Is Ready'**
  String get ritualReadyTitle;

  /// No description provided for @ritualReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your personalized Hikaru Ritual has been thoughtfully prepared, bringing together the techniques, crystal, frequencies, and intention that best support your skin and your energy today.'**
  String get ritualReadyBody;

  /// No description provided for @ritualReadyEnter.
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR RITUAL'**
  String get ritualReadyEnter;

  /// No description provided for @quizQ1Prompt.
  ///
  /// In en, this message translates to:
  /// **'What is your skin asking for today?'**
  String get quizQ1Prompt;

  /// No description provided for @quizQ2Prompt.
  ///
  /// In en, this message translates to:
  /// **'How does your skin feel right now?'**
  String get quizQ2Prompt;

  /// No description provided for @quizQ3Prompt.
  ///
  /// In en, this message translates to:
  /// **'How has your inner world been feeling lately?'**
  String get quizQ3Prompt;

  /// No description provided for @quizQ4Prompt.
  ///
  /// In en, this message translates to:
  /// **'What would you most like to release?'**
  String get quizQ4Prompt;

  /// No description provided for @quizQ5Prompt.
  ///
  /// In en, this message translates to:
  /// **'When you look in the mirror, what do you notice first?'**
  String get quizQ5Prompt;

  /// No description provided for @quizQ6Prompt.
  ///
  /// In en, this message translates to:
  /// **'What does your body need more of today?'**
  String get quizQ6Prompt;

  /// No description provided for @quizQ7Prompt.
  ///
  /// In en, this message translates to:
  /// **'Which intention resonates with you?'**
  String get quizQ7Prompt;

  /// No description provided for @quizQ8Prompt.
  ///
  /// In en, this message translates to:
  /// **'How would you like to feel after your ritual?'**
  String get quizQ8Prompt;

  /// No description provided for @quizQ9Prompt.
  ///
  /// In en, this message translates to:
  /// **'How much time would you like to dedicate to yourself?'**
  String get quizQ9Prompt;

  /// No description provided for @quizQ10Prompt.
  ///
  /// In en, this message translates to:
  /// **'Is your skin currently experiencing any of these?'**
  String get quizQ10Prompt;

  /// No description provided for @quizQ10Instruction.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get quizQ10Instruction;

  /// No description provided for @quizOptionQ1CalmComfort.
  ///
  /// In en, this message translates to:
  /// **'Calm and comfort'**
  String get quizOptionQ1CalmComfort;

  /// No description provided for @quizOptionQ1LiftedFirm.
  ///
  /// In en, this message translates to:
  /// **'A more lifted, firm appearance'**
  String get quizOptionQ1LiftedFirm;

  /// No description provided for @quizOptionQ1HydrationSoftness.
  ///
  /// In en, this message translates to:
  /// **'Hydration and softness'**
  String get quizOptionQ1HydrationSoftness;

  /// No description provided for @quizOptionQ1RadianceVitality.
  ///
  /// In en, this message translates to:
  /// **'Radiance and renewed vitality'**
  String get quizOptionQ1RadianceVitality;

  /// No description provided for @quizOptionQ2Sensitive.
  ///
  /// In en, this message translates to:
  /// **'Sensitive or easily irritated'**
  String get quizOptionQ2Sensitive;

  /// No description provided for @quizOptionQ2TightDry.
  ///
  /// In en, this message translates to:
  /// **'Tight or dry'**
  String get quizOptionQ2TightDry;

  /// No description provided for @quizOptionQ2PuffyTired.
  ///
  /// In en, this message translates to:
  /// **'Puffy or tired'**
  String get quizOptionQ2PuffyTired;

  /// No description provided for @quizOptionQ2ComfortableLackingRadiance.
  ///
  /// In en, this message translates to:
  /// **'Comfortable, but lacking radiance'**
  String get quizOptionQ2ComfortableLackingRadiance;

  /// No description provided for @quizOptionQ3EmotionallyOverwhelmed.
  ///
  /// In en, this message translates to:
  /// **'Emotionally overwhelmed'**
  String get quizOptionQ3EmotionallyOverwhelmed;

  /// No description provided for @quizOptionQ3MentallyBusy.
  ///
  /// In en, this message translates to:
  /// **'Mentally busy or distracted'**
  String get quizOptionQ3MentallyBusy;

  /// No description provided for @quizOptionQ3DisconnectedBody.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from my body'**
  String get quizOptionQ3DisconnectedBody;

  /// No description provided for @quizOptionQ3CalmBalanced.
  ///
  /// In en, this message translates to:
  /// **'Calm and balanced'**
  String get quizOptionQ3CalmBalanced;

  /// No description provided for @quizOptionQ4UncertaintyTension.
  ///
  /// In en, this message translates to:
  /// **'Uncertainty or hidden tension'**
  String get quizOptionQ4UncertaintyTension;

  /// No description provided for @quizOptionQ4MentalNoise.
  ///
  /// In en, this message translates to:
  /// **'Mental noise and overthinking'**
  String get quizOptionQ4MentalNoise;

  /// No description provided for @quizOptionQ4StressPressure.
  ///
  /// In en, this message translates to:
  /// **'Stress and emotional pressure'**
  String get quizOptionQ4StressPressure;

  /// No description provided for @quizOptionQ4FatigueHeaviness.
  ///
  /// In en, this message translates to:
  /// **'Fatigue and heaviness'**
  String get quizOptionQ4FatigueHeaviness;

  /// No description provided for @quizOptionQ5ChangesUnknown.
  ///
  /// In en, this message translates to:
  /// **'Changes I don\'t fully understand'**
  String get quizOptionQ5ChangesUnknown;

  /// No description provided for @quizOptionQ5LossBrightness.
  ///
  /// In en, this message translates to:
  /// **'A loss of brightness'**
  String get quizOptionQ5LossBrightness;

  /// No description provided for @quizOptionQ5StressTension.
  ///
  /// In en, this message translates to:
  /// **'Signs of stress or tension'**
  String get quizOptionQ5StressTension;

  /// No description provided for @quizOptionQ5FirmnessVitality.
  ///
  /// In en, this message translates to:
  /// **'Changes in firmness or vitality'**
  String get quizOptionQ5FirmnessVitality;

  /// No description provided for @quizOptionQ6SpaceReflect.
  ///
  /// In en, this message translates to:
  /// **'Space to reflect'**
  String get quizOptionQ6SpaceReflect;

  /// No description provided for @quizOptionQ6MomentClarity.
  ///
  /// In en, this message translates to:
  /// **'A moment of clarity'**
  String get quizOptionQ6MomentClarity;

  /// No description provided for @quizOptionQ6GentlenessBalance.
  ///
  /// In en, this message translates to:
  /// **'Gentleness and balance'**
  String get quizOptionQ6GentlenessBalance;

  /// No description provided for @quizOptionQ6GroundingStrength.
  ///
  /// In en, this message translates to:
  /// **'Grounding and strength'**
  String get quizOptionQ6GroundingStrength;

  /// No description provided for @quizOptionQ7UnderstandBeneath.
  ///
  /// In en, this message translates to:
  /// **'Understand what lies beneath the surface'**
  String get quizOptionQ7UnderstandBeneath;

  /// No description provided for @quizOptionQ7GreaterClarity.
  ///
  /// In en, this message translates to:
  /// **'See myself with greater clarity'**
  String get quizOptionQ7GreaterClarity;

  /// No description provided for @quizOptionQ7ReturnHarmony.
  ///
  /// In en, this message translates to:
  /// **'Return to harmony'**
  String get quizOptionQ7ReturnHarmony;

  /// No description provided for @quizOptionQ7InnerStrength.
  ///
  /// In en, this message translates to:
  /// **'Reconnect with my inner strength'**
  String get quizOptionQ7InnerStrength;

  /// No description provided for @quizOptionQ8SelfAware.
  ///
  /// In en, this message translates to:
  /// **'More self-aware'**
  String get quizOptionQ8SelfAware;

  /// No description provided for @quizOptionQ8ClearRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Clear and refreshed'**
  String get quizOptionQ8ClearRefreshed;

  /// No description provided for @quizOptionQ8CalmNurtured.
  ///
  /// In en, this message translates to:
  /// **'Calm and nurtured'**
  String get quizOptionQ8CalmNurtured;

  /// No description provided for @quizOptionQ8GroundedEnergized.
  ///
  /// In en, this message translates to:
  /// **'Grounded and energized'**
  String get quizOptionQ8GroundedEnergized;

  /// No description provided for @quizOptionQ9ThreeMinutes.
  ///
  /// In en, this message translates to:
  /// **'3 minutes'**
  String get quizOptionQ9ThreeMinutes;

  /// No description provided for @quizOptionQ9FiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get quizOptionQ9FiveMinutes;

  /// No description provided for @quizOptionQ9TenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get quizOptionQ9TenMinutes;

  /// No description provided for @quizOptionQ10OpenBroken.
  ///
  /// In en, this message translates to:
  /// **'Open or broken skin'**
  String get quizOptionQ10OpenBroken;

  /// No description provided for @quizOptionQ10ActiveIrritation.
  ///
  /// In en, this message translates to:
  /// **'Active irritation or painful inflammation'**
  String get quizOptionQ10ActiveIrritation;

  /// No description provided for @quizOptionQ10UnexplainedChange.
  ///
  /// In en, this message translates to:
  /// **'A new or unexplained skin change'**
  String get quizOptionQ10UnexplainedChange;

  /// No description provided for @quizOptionQ10None.
  ///
  /// In en, this message translates to:
  /// **'None of the above'**
  String get quizOptionQ10None;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get commonContinue;

  /// No description provided for @commonPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get commonPlay;

  /// No description provided for @commonPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get commonPause;

  /// No description provided for @commonExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get commonExit;

  /// No description provided for @mirrorGardenEyebrow.
  ///
  /// In en, this message translates to:
  /// **'THE MIRROR GARDEN'**
  String get mirrorGardenEyebrow;

  /// No description provided for @mirrorGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add A Photo Of Your Face For Personal Tracking'**
  String get mirrorGardenTitle;

  /// No description provided for @mirrorGardenSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP FOR NOW'**
  String get mirrorGardenSkip;

  /// No description provided for @mirrorGardenUpload.
  ///
  /// In en, this message translates to:
  /// **'UPLOAD A PHOTO'**
  String get mirrorGardenUpload;

  /// No description provided for @mirrorGardenOptional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get mirrorGardenOptional;

  /// No description provided for @mirrorGardenHint.
  ///
  /// In en, this message translates to:
  /// **'A photo helps you celebrate your progress over time and compare your results throughout your Hikaru journey.'**
  String get mirrorGardenHint;

  /// No description provided for @mirrorTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'TAKE A PHOTO'**
  String get mirrorTakePhoto;

  /// No description provided for @mirrorTakePhotoSemantics.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get mirrorTakePhotoSemantics;

  /// No description provided for @mirrorPhotoPreviewSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your face photo preview'**
  String get mirrorPhotoPreviewSemantics;

  /// No description provided for @mirrorPhotoError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the camera or photos. Check permissions and try again.'**
  String get mirrorPhotoError;

  /// No description provided for @mirrorCameraHint.
  ///
  /// In en, this message translates to:
  /// **'SWIPE UP TO TAKE THE PHOTO'**
  String get mirrorCameraHint;

  /// No description provided for @mirrorCameraCaptureSemantics.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get mirrorCameraCaptureSemantics;

  /// No description provided for @mirrorCameraCloseSemantics.
  ///
  /// In en, this message translates to:
  /// **'Close camera'**
  String get mirrorCameraCloseSemantics;

  /// No description provided for @resonanceChamberTitle.
  ///
  /// In en, this message translates to:
  /// **'THE RESONANCE CHAMBER'**
  String get resonanceChamberTitle;

  /// No description provided for @resonanceRevealTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR HIKARU JOURNEY'**
  String get resonanceRevealTitle;

  /// No description provided for @resonanceRevealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'HAS BEEN REVEALED'**
  String get resonanceRevealSubtitle;

  /// No description provided for @resonanceMissingCrystal.
  ///
  /// In en, this message translates to:
  /// **'Complete the Listening Garden to receive your crystal and personalized protocol.'**
  String get resonanceMissingCrystal;

  /// No description provided for @resonanceYourCrystal.
  ///
  /// In en, this message translates to:
  /// **'YOUR CRYSTAL'**
  String get resonanceYourCrystal;

  /// No description provided for @resonanceAssignedCrystalSemantics.
  ///
  /// In en, this message translates to:
  /// **'Assigned crystal {crystal}'**
  String resonanceAssignedCrystalSemantics(String crystal);

  /// No description provided for @resonanceRecommendedProtocol.
  ///
  /// In en, this message translates to:
  /// **'YOUR RECOMMENDED PROTOCOL'**
  String get resonanceRecommendedProtocol;

  /// No description provided for @resonanceProtocolCrystal.
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get resonanceProtocolCrystal;

  /// No description provided for @resonanceProtocolIntention.
  ///
  /// In en, this message translates to:
  /// **'Intention'**
  String get resonanceProtocolIntention;

  /// No description provided for @resonanceProtocolSkinFocus.
  ///
  /// In en, this message translates to:
  /// **'Skin-care focus'**
  String get resonanceProtocolSkinFocus;

  /// No description provided for @resonanceProtocolFacialRitual.
  ///
  /// In en, this message translates to:
  /// **'Recommended facial ritual'**
  String get resonanceProtocolFacialRitual;

  /// No description provided for @resonanceProtocolDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get resonanceProtocolDuration;

  /// No description provided for @resonanceProtocolTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get resonanceProtocolTemple;

  /// No description provided for @resonanceEnterSanctuary.
  ///
  /// In en, this message translates to:
  /// **'ENTER MY HIKARU SANCTUARY'**
  String get resonanceEnterSanctuary;

  /// No description provided for @resonanceYourFrequency.
  ///
  /// In en, this message translates to:
  /// **'YOUR FREQUENCY'**
  String get resonanceYourFrequency;

  /// No description provided for @resonanceYourCymaticSignature.
  ///
  /// In en, this message translates to:
  /// **'YOUR CYMATIC\nSIGNATURE'**
  String get resonanceYourCymaticSignature;

  /// No description provided for @resonanceCymaticSignatureSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your cymatic signature'**
  String get resonanceCymaticSignatureSemantics;

  /// No description provided for @resonanceYourRitual.
  ///
  /// In en, this message translates to:
  /// **'YOUR RITUAL'**
  String get resonanceYourRitual;

  /// No description provided for @resonanceStepRegulationName.
  ///
  /// In en, this message translates to:
  /// **'Regulation'**
  String get resonanceStepRegulationName;

  /// No description provided for @resonanceStepRegulationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The Merkaba Room'**
  String get resonanceStepRegulationSubtitle;

  /// No description provided for @resonanceStepGuaShaName.
  ///
  /// In en, this message translates to:
  /// **'Gua Sha'**
  String get resonanceStepGuaShaName;

  /// No description provided for @resonanceStepGuaShaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Physical Massage'**
  String get resonanceStepGuaShaSubtitle;

  /// No description provided for @resonanceStepIntegrationName.
  ///
  /// In en, this message translates to:
  /// **'Frequency & Cymatics Integration'**
  String get resonanceStepIntegrationName;

  /// No description provided for @resonanceStepIntegrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Closing Integration'**
  String get resonanceStepIntegrationSubtitle;

  /// No description provided for @crystalSceneSemanticsDefault.
  ///
  /// In en, this message translates to:
  /// **'Your crystal in the garden'**
  String get crystalSceneSemanticsDefault;

  /// No description provided for @crystalSceneSemantics.
  ///
  /// In en, this message translates to:
  /// **'{crystal} crystal'**
  String crystalSceneSemantics(String crystal);

  /// No description provided for @cymaticSemantics.
  ///
  /// In en, this message translates to:
  /// **'Cymatic'**
  String get cymaticSemantics;

  /// No description provided for @crystalDetailSymbolicMeaning.
  ///
  /// In en, this message translates to:
  /// **'SYMBOLIC MEANING'**
  String get crystalDetailSymbolicMeaning;

  /// No description provided for @crystalDetailAssociatedIntention.
  ///
  /// In en, this message translates to:
  /// **'ASSOCIATED INTENTION'**
  String get crystalDetailAssociatedIntention;

  /// No description provided for @crystalDetailTherapeuticPurpose.
  ///
  /// In en, this message translates to:
  /// **'THERAPEUTIC PURPOSE'**
  String get crystalDetailTherapeuticPurpose;

  /// No description provided for @crystalDetailSkinBenefit.
  ///
  /// In en, this message translates to:
  /// **'SKIN BENEFIT'**
  String get crystalDetailSkinBenefit;

  /// No description provided for @crystalDetailMeridians.
  ///
  /// In en, this message translates to:
  /// **'ILLUMINATED MERIDIANS'**
  String get crystalDetailMeridians;

  /// No description provided for @crystalDetailEnvironment.
  ///
  /// In en, this message translates to:
  /// **'VISUAL ENVIRONMENT'**
  String get crystalDetailEnvironment;

  /// No description provided for @crystalChoose.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE THIS CRYSTAL'**
  String get crystalChoose;

  /// No description provided for @crystalIsYours.
  ///
  /// In en, this message translates to:
  /// **'YOUR CRYSTAL'**
  String get crystalIsYours;

  /// No description provided for @crystalIsYoursSemantics.
  ///
  /// In en, this message translates to:
  /// **'{crystal} is your crystal'**
  String crystalIsYoursSemantics(String crystal);

  /// No description provided for @crystalChosenSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{crystal} is now your crystal.'**
  String crystalChosenSnackbar(String crystal);

  /// No description provided for @crystalFrequencyPlay.
  ///
  /// In en, this message translates to:
  /// **'Play frequency'**
  String get crystalFrequencyPlay;

  /// No description provided for @crystalFrequencyPause.
  ///
  /// In en, this message translates to:
  /// **'Pause frequency'**
  String get crystalFrequencyPause;

  /// No description provided for @crystalFrequencyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Frequency unavailable right now'**
  String get crystalFrequencyUnavailable;

  /// No description provided for @crystalCompositionCredit.
  ///
  /// In en, this message translates to:
  /// **'Composed by Maestro Jorge Alfano with Japanese instruments'**
  String get crystalCompositionCredit;

  /// No description provided for @crystalTextName.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{WHITE QUARTZ} jade{JADE} obsidian{OBSIDIAN} redJasper{RED JASPER} other{}}'**
  String crystalTextName(String crystal);

  /// No description provided for @crystalTextTemple.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Temple of Illumination} jade{Temple of Harmony} obsidian{Temple of Transformation} redJasper{Temple of Vitality} other{}}'**
  String crystalTextTemple(String crystal);

  /// No description provided for @crystalTextProtocol.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Quartz Illumination Protocol — Maestro Jorge Alfano} jade{Jade Harmony Protocol} obsidian{Obsidian Transformation Protocol} redJasper{Jasper Vitality Protocol — Maestro Jorge Alfano} other{}}'**
  String crystalTextProtocol(String crystal);

  /// No description provided for @crystalTextFrequency.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Cellular Coherence Frequency • 528 Hz} jade{528 Hz} obsidian{528 Hz} redJasper{Vitality & Vascular Flow Frequency • 639 Hz} other{}}'**
  String crystalTextFrequency(String crystal);

  /// No description provided for @crystalTextFrequencyDetail.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Energy amplification & cellular coherence} jade{Heart coherence, love & balance} obsidian{Transformation, repair, deep healing & protection} redJasper{Activates metabolic & vascular flow} other{}}'**
  String crystalTextFrequencyDetail(String crystal);

  /// No description provided for @crystalTextFrequencyTagline.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Cellular Coherence • Illumination • Expansion} jade{Heart Coherence • Love • Balance} obsidian{Deep Detox • Transformation • Protection} redJasper{Metabolic Flow • Vitality • Grounding} other{}}'**
  String crystalTextFrequencyTagline(String crystal);

  /// No description provided for @crystalTextPurpose.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Cellular biohacking, longevity, mental clarity and expansion of consciousness.} jade{Nervous system regulation, emotional balance, recovery and deep calm.} obsidian{Release of stagnant emotions (anger, stress, guilt), protection and detoxification.} redJasper{Vitality, physical strength, metabolic flow and grounding.} other{}}'**
  String crystalTextPurpose(String crystal);

  /// No description provided for @crystalTextSkinBenefit.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Amplifies cellular energy, enhancing luminosity and your natural inner glow.} jade{Soothes irritation and supports skin balance and health.} obsidian{Supports intensive sculpting, drainage and skin renewal.} redJasper{Awakens circulation, strength and resilience of facial and body tissues.} other{}}'**
  String crystalTextSkinBenefit(String crystal);

  /// No description provided for @crystalTextMeridians.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Kidney · Governing Vessel} jade{Heart · Pericardium · Lung} obsidian{Liver · Gallbladder · Heart} redJasper{Spleen · Stomach} other{}}'**
  String crystalTextMeridians(String crystal);

  /// No description provided for @crystalTextEnvironment.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{A crystalline temple of white light, sacred geometry and DNA activation.} jade{An emerald temple surrounded by nature, reflective water and green energy currents.} obsidian{Volcanic landscapes, temples of black crystal and sacred fire.} redJasper{Earth and fire elements with golden-red currents of energy.} other{}}'**
  String crystalTextEnvironment(String crystal);

  /// No description provided for @crystalTextSymbolicTitle.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{The Light of Clarity} jade{The Garden of Harmony} obsidian{The Mirror of the Unseen} redJasper{The Earth of Vitality} other{}}'**
  String crystalTextSymbolicTitle(String crystal);

  /// No description provided for @crystalTextRevelation.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Your answers point toward clarity and renewal. White Quartz invites you to clear mental noise, welcome illumination, and restore your natural radiance.} jade{Your answers suggest a need for gentleness and balance. Jade invites you to soften, return to harmony, and care for your skin with mindful presence.} obsidian{Your answers suggest this may be a moment for deeper reflection. Obsidian invites you to look beyond the surface, listen to yourself, and create space for understanding.} redJasper{Your answers speak to grounding and renewed strength. Red Jasper invites you to reconnect with your body, release heaviness, and restore vitality.} other{}}'**
  String crystalTextRevelation(String crystal);

  /// No description provided for @crystalTextBenefitTitle.
  ///
  /// In en, this message translates to:
  /// **'{id, select, whiteQuartz0{Cellular Biohacking} whiteQuartz1{Mental Clarity} whiteQuartz2{Luminosity & Glow} whiteQuartz3{Energetic Alignment} whiteQuartz4{Daily Habit Rhythm} jade0{Nervous System Regulation} jade1{Heart-Mind Coherence} jade2{Lymphatic Balance} jade3{Natural Radiance} jade4{Daily Habit Rhythm} obsidian0{Emotional Release} obsidian1{Deep Sculpt & Detox} obsidian2{Cellular Renewal} obsidian3{Energetic Protection} obsidian4{Daily Habit Rhythm} redJasper0{Metabolic & Vascular Flow} redJasper1{Physical Grounding} redJasper2{Tissue Resilience} redJasper3{Vital Energy Activation} redJasper4{Daily Habit Rhythm} other{}}'**
  String crystalTextBenefitTitle(String id);

  /// No description provided for @crystalTextBenefitDetail.
  ///
  /// In en, this message translates to:
  /// **'{id, select, whiteQuartz0{Supports regeneration and healthy cellular aging} whiteQuartz1{Expands consciousness and elevates focus} whiteQuartz2{Amplifies skin energy and inner radiance} whiteQuartz3{Harmonizes kidney and governing vessel meridians} whiteQuartz4{Builds a transformative 30-day ritual rhythm} jade0{Calms stress and restores deep inner balance} jade1{Promotes emotional harmony and heart connection} jade2{Calms inflammation and supports healthy skin tone} jade3{Enhances natural glow and overall skin wellness} jade4{Deepens consistency and long-term vitality} obsidian0{Transforms stress, guilt, and stagnant emotions} obsidian1{Promotes intense lymphatic fluid drainage} obsidian2{Releases stagnant energy and invites restoration} obsidian3{Shields and harmonizes liver and gallbladder pathways} obsidian4{Anchors a profound 30-day transformation practice} redJasper0{Awakens circulation and facial blood flow} redJasper1{Anchors energy and restores physical stamina} redJasper2{Enhances skin firmness and muscle tone} redJasper3{Stimulates spleen and stomach energy channels} redJasper4{Sustains daily strength and long-term resilience} other{}}'**
  String crystalTextBenefitDetail(String id);

  /// No description provided for @recIntentionSelfAwareness.
  ///
  /// In en, this message translates to:
  /// **'Self-awareness and reflection'**
  String get recIntentionSelfAwareness;

  /// No description provided for @recIntentionMentalClarity.
  ///
  /// In en, this message translates to:
  /// **'Mental clarity and radiance'**
  String get recIntentionMentalClarity;

  /// No description provided for @recIntentionCalmComfort.
  ///
  /// In en, this message translates to:
  /// **'Calm, comfort, and mindful skin care'**
  String get recIntentionCalmComfort;

  /// No description provided for @recIntentionVitality.
  ///
  /// In en, this message translates to:
  /// **'Vitality and reconnection with the body'**
  String get recIntentionVitality;

  /// No description provided for @recIntentionInnerIllumination.
  ///
  /// In en, this message translates to:
  /// **'Clarity and inner illumination'**
  String get recIntentionInnerIllumination;

  /// No description provided for @recIntentionHarmony.
  ///
  /// In en, this message translates to:
  /// **'Harmony and gentle balance'**
  String get recIntentionHarmony;

  /// No description provided for @recIntentionGrounding.
  ///
  /// In en, this message translates to:
  /// **'Grounding and inner strength'**
  String get recIntentionGrounding;

  /// No description provided for @recSkinFocusSoothing.
  ///
  /// In en, this message translates to:
  /// **'Soothing comfort and calming facial care'**
  String get recSkinFocusSoothing;

  /// No description provided for @recSkinFocusHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration and gentle facial care'**
  String get recSkinFocusHydration;

  /// No description provided for @recSkinFocusLift.
  ///
  /// In en, this message translates to:
  /// **'Lift, firmness, and depuffing support'**
  String get recSkinFocusLift;

  /// No description provided for @recSkinFocusRadiance.
  ///
  /// In en, this message translates to:
  /// **'Radiance and renewed vitality'**
  String get recSkinFocusRadiance;

  /// No description provided for @recRitualSoothing.
  ///
  /// In en, this message translates to:
  /// **'Soothing Comfort Protocol'**
  String get recRitualSoothing;

  /// No description provided for @recRitualHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration Protocol'**
  String get recRitualHydration;

  /// No description provided for @recRitualLift.
  ///
  /// In en, this message translates to:
  /// **'Lift & Sculpt Protocol'**
  String get recRitualLift;

  /// No description provided for @recRitualRadiance.
  ///
  /// In en, this message translates to:
  /// **'Radiance Protocol'**
  String get recRitualRadiance;

  /// No description provided for @recDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String recDuration(int minutes);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get navJourney;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navSanctuary.
  ///
  /// In en, this message translates to:
  /// **'Sanctuary'**
  String get navSanctuary;

  /// No description provided for @homeGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'THE HARMONY GARDEN'**
  String get homeGardenTitle;

  /// No description provided for @homeGardenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Journey Begins Within'**
  String get homeGardenSubtitle;

  /// No description provided for @homeTourGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR SANCTUARY'**
  String get homeTourGardenTitle;

  /// No description provided for @homeTourGardenBody.
  ///
  /// In en, this message translates to:
  /// **'This is your sanctuary. The numbers mark the order of the day.'**
  String get homeTourGardenBody;

  /// No description provided for @homeTourOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'THE ORDER'**
  String get homeTourOrderTitle;

  /// No description provided for @homeTourOrderBody.
  ///
  /// In en, this message translates to:
  /// **'Merkaba is 1. Face and body are 2. Your crystal is 3. Each circle opens on its own.'**
  String get homeTourOrderBody;

  /// No description provided for @homeTourBeginTitle.
  ///
  /// In en, this message translates to:
  /// **'BEGIN TODAY'**
  String get homeTourBeginTitle;

  /// No description provided for @homeTourBeginBody.
  ///
  /// In en, this message translates to:
  /// **'The center symbol starts today\'s ritual in that order. The circles open each part on its own.'**
  String get homeTourBeginBody;

  /// No description provided for @homeTourBarTitle.
  ///
  /// In en, this message translates to:
  /// **'THE BAR'**
  String get homeTourBarTitle;

  /// No description provided for @homeTourBarBody.
  ///
  /// In en, this message translates to:
  /// **'Journey keeps your day, streak, and photos. Settings keeps your account, language, and reminders.'**
  String get homeTourBarBody;

  /// No description provided for @homeTourSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get homeTourSkip;

  /// No description provided for @homeTourNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get homeTourNext;

  /// No description provided for @homeTourDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get homeTourDone;

  /// No description provided for @homeYourCrystal.
  ///
  /// In en, this message translates to:
  /// **'YOUR CRYSTAL'**
  String get homeYourCrystal;

  /// No description provided for @homeYourCrystalSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your crystal'**
  String get homeYourCrystalSemantics;

  /// No description provided for @homeYourCrystalNamedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your crystal {crystal}'**
  String homeYourCrystalNamedSemantics(String crystal);

  /// No description provided for @homeLibrary.
  ///
  /// In en, this message translates to:
  /// **'LIBRARY'**
  String get homeLibrary;

  /// No description provided for @homeLibrarySemantics.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get homeLibrarySemantics;

  /// No description provided for @homeRitualBody.
  ///
  /// In en, this message translates to:
  /// **'HIKARU RITUAL\nBODY'**
  String get homeRitualBody;

  /// No description provided for @homeRitualBodySemantics.
  ///
  /// In en, this message translates to:
  /// **'Hikaru Ritual Body'**
  String get homeRitualBodySemantics;

  /// No description provided for @homeRitualFace.
  ///
  /// In en, this message translates to:
  /// **'HIKARU RITUAL\nFACE'**
  String get homeRitualFace;

  /// No description provided for @homeRitualFaceSemantics.
  ///
  /// In en, this message translates to:
  /// **'Hikaru Ritual Face'**
  String get homeRitualFaceSemantics;

  /// No description provided for @templesTitle.
  ///
  /// In en, this message translates to:
  /// **'THE FOUR TEMPLES'**
  String get templesTitle;

  /// No description provided for @templesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Four paths. One transformation.'**
  String get templesSubtitle;

  /// No description provided for @templesChoose.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR TEMPLE'**
  String get templesChoose;

  /// No description provided for @templesRecommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get templesRecommended;

  /// No description provided for @templesSelected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get templesSelected;

  /// No description provided for @templesSemanticsRecommended.
  ///
  /// In en, this message translates to:
  /// **'recommended for you'**
  String get templesSemanticsRecommended;

  /// No description provided for @templesSemanticsSelected.
  ///
  /// In en, this message translates to:
  /// **'currently selected'**
  String get templesSemanticsSelected;

  /// No description provided for @commonDayOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String commonDayOfTotal(int day, int total);

  /// No description provided for @journeyTitle.
  ///
  /// In en, this message translates to:
  /// **'JOURNEY'**
  String get journeyTitle;

  /// No description provided for @journeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your 30-day evolution'**
  String get journeySubtitle;

  /// No description provided for @journeyCaption.
  ///
  /// In en, this message translates to:
  /// **'Small daily rituals. Profound transformation.'**
  String get journeyCaption;

  /// No description provided for @journeyChooseCrystal.
  ///
  /// In en, this message translates to:
  /// **'Choose your crystal'**
  String get journeyChooseCrystal;

  /// No description provided for @journeyActiveCrystalSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your active crystal, {crystal}'**
  String journeyActiveCrystalSemantics(String crystal);

  /// No description provided for @journeyActiveCrystalLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR ACTIVE CRYSTAL'**
  String get journeyActiveCrystalLabel;

  /// No description provided for @journeyChooseTemple.
  ///
  /// In en, this message translates to:
  /// **'Choose your temple'**
  String get journeyChooseTemple;

  /// No description provided for @journeyChooseTempleHint.
  ///
  /// In en, this message translates to:
  /// **'Select a crystal to begin your 30-day resonance.'**
  String get journeyChooseTempleHint;

  /// No description provided for @journeyStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY STREAK'**
  String get journeyStreakTitle;

  /// No description provided for @journeyStreakDaysInARow.
  ///
  /// In en, this message translates to:
  /// **'Days in a row'**
  String get journeyStreakDaysInARow;

  /// No description provided for @journeyPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS PHOTOS'**
  String get journeyPhotosTitle;

  /// No description provided for @journeyPhotosViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get journeyPhotosViewAll;

  /// No description provided for @journeyPhotosViewAllSemantics.
  ///
  /// In en, this message translates to:
  /// **'View all progress photos'**
  String get journeyPhotosViewAllSemantics;

  /// No description provided for @journeyPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See your evolution over time'**
  String get journeyPhotosSubtitle;

  /// No description provided for @journeyPhotoDay.
  ///
  /// In en, this message translates to:
  /// **'DAY {day}'**
  String journeyPhotoDay(int day);

  /// No description provided for @journeyPhotoBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get journeyPhotoBefore;

  /// No description provided for @journeyPhotoCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get journeyPhotoCurrent;

  /// No description provided for @journeyPhotoBeforeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Before photo, {day}'**
  String journeyPhotoBeforeSemantics(String day);

  /// No description provided for @journeyPhotoCurrentSemantics.
  ///
  /// In en, this message translates to:
  /// **'Current photo, {day}'**
  String journeyPhotoCurrentSemantics(String day);

  /// No description provided for @journeyPhotoCaptureSemantics.
  ///
  /// In en, this message translates to:
  /// **'Take today\'s progress photo'**
  String get journeyPhotoCaptureSemantics;

  /// No description provided for @journeyPhotosEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your photos will appear here as the cycle unfolds.'**
  String get journeyPhotosEmpty;

  /// No description provided for @journeyPhotoGallerySemantics.
  ///
  /// In en, this message translates to:
  /// **'Progress photo, {day}'**
  String journeyPhotoGallerySemantics(String day);

  /// No description provided for @journeyContinuesTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR JOURNEY CONTINUES'**
  String get journeyContinuesTitle;

  /// No description provided for @journeyContinuesSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your journey continues, {title}'**
  String journeyContinuesSemantics(String title);

  /// No description provided for @journeyContinuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Frequency · Cymatic Signature · Daily Ritual'**
  String get journeyContinuesSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'SANCTUARY PROFILE'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal details, daily ritual reminders & progress privacy'**
  String get profileSubtitle;

  /// No description provided for @profileMemberSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, sanctuary member, day {day} of {total}'**
  String profileMemberSemantics(String name, int day, int total);

  /// No description provided for @profileMemberLabel.
  ///
  /// In en, this message translates to:
  /// **'SANCTUARY MEMBER — DAY {day} OF {total}'**
  String profileMemberLabel(int day, int total);

  /// No description provided for @profileAccountEdit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get profileAccountEdit;

  /// No description provided for @profileAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR DETAILS'**
  String get profileAccountTitle;

  /// No description provided for @profileAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photo and name for your sanctuary.'**
  String get profileAccountSubtitle;

  /// No description provided for @profileAccountName.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get profileAccountName;

  /// No description provided for @profileAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileAccountNameHint;

  /// No description provided for @profileAccountSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get profileAccountSave;

  /// No description provided for @profileAccountClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get profileAccountClose;

  /// No description provided for @profileAccountPhotoSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your profile photo'**
  String get profileAccountPhotoSemantics;

  /// No description provided for @profileRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR HIKARU RECOMMENDATION'**
  String get profileRecommendationTitle;

  /// No description provided for @profileRecommendationFacialRitual.
  ///
  /// In en, this message translates to:
  /// **'Facial ritual'**
  String get profileRecommendationFacialRitual;

  /// No description provided for @profileRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'RITUAL ALARMS & REMINDERS'**
  String get profileRemindersTitle;

  /// No description provided for @profileReminderMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Sacred Ritual'**
  String get profileReminderMorningTitle;

  /// No description provided for @profileReminderMorningDetail.
  ///
  /// In en, this message translates to:
  /// **'Meditation & facial massage'**
  String get profileReminderMorningDetail;

  /// No description provided for @profileReminderEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening Reflection & Breath'**
  String get profileReminderEveningTitle;

  /// No description provided for @profileReminderEveningDetail.
  ///
  /// In en, this message translates to:
  /// **'Conscious breathing before sleep'**
  String get profileReminderEveningDetail;

  /// No description provided for @profileReminderSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title} reminder'**
  String profileReminderSemantics(String title);

  /// No description provided for @profilePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR DATA, TREATED WITH REVERENCE'**
  String get profilePrivacyTitle;

  /// No description provided for @profilePrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your facial photos and personal information stay with your account. Open Privacy to review what is kept.'**
  String get profilePrivacyBody;

  /// No description provided for @profilePrivacyOpenSemantics.
  ///
  /// In en, this message translates to:
  /// **'Open privacy settings'**
  String get profilePrivacyOpenSemantics;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get profilePrivacy;

  /// No description provided for @profileCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'30-DAY CYCLE'**
  String get profileCycleTitle;

  /// No description provided for @profileCycleInProgress.
  ///
  /// In en, this message translates to:
  /// **'Your journey is in progress'**
  String get profileCycleInProgress;

  /// No description provided for @profileCycleComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete your cycle'**
  String get profileCycleComplete;

  /// No description provided for @profileCycleUnlock.
  ///
  /// In en, this message translates to:
  /// **'At day {total}, you’ll unlock your new diagnosis and recalibrate your crystal, frequency and cymatic signature.'**
  String profileCycleUnlock(int total);

  /// No description provided for @profileCycleEnd.
  ///
  /// In en, this message translates to:
  /// **'END CYCLE'**
  String get profileCycleEnd;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'LIBRARY'**
  String get libraryTitle;

  /// No description provided for @librarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sacred knowledge for your journey'**
  String get librarySubtitle;

  /// No description provided for @libraryBackSemantics.
  ///
  /// In en, this message translates to:
  /// **'Back to library'**
  String get libraryBackSemantics;

  /// No description provided for @libraryChapterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter} other{{count} chapters}}'**
  String libraryChapterCount(int count);

  /// No description provided for @libraryReadingTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String libraryReadingTime(int minutes);

  /// No description provided for @libraryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get libraryFilterAll;

  /// No description provided for @libraryFilterAllSemantics.
  ///
  /// In en, this message translates to:
  /// **'Show all chapters'**
  String get libraryFilterAllSemantics;

  /// No description provided for @libraryFilterChapterSemantics.
  ///
  /// In en, this message translates to:
  /// **'Go to chapter {number}, {heading}'**
  String libraryFilterChapterSemantics(int number, String heading);

  /// No description provided for @libraryChapterLabel.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {number}'**
  String libraryChapterLabel(String number);

  /// No description provided for @libraryOpenChapterSemantics.
  ///
  /// In en, this message translates to:
  /// **'Open chapter {number}, {heading}'**
  String libraryOpenChapterSemantics(int number, String heading);

  /// No description provided for @libraryNextLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT IN LIBRARY'**
  String get libraryNextLabel;

  /// No description provided for @libraryNextSemantics.
  ///
  /// In en, this message translates to:
  /// **'Next in library, {label}'**
  String libraryNextSemantics(String label);

  /// No description provided for @libraryRead.
  ///
  /// In en, this message translates to:
  /// **'READ'**
  String get libraryRead;

  /// No description provided for @libraryTextCollectionName.
  ///
  /// In en, this message translates to:
  /// **'{id, select, merkaba{MERKABA} rituals{HIKARU RITUALS} other{}}'**
  String libraryTextCollectionName(String id);

  /// No description provided for @libraryTextCollectionDetail.
  ///
  /// In en, this message translates to:
  /// **'{id, select, merkaba{Geometry & Energy} rituals{Face & Body} jade{Balance\n& Harmony} whiteQuartz{Clarity\n& Renewal} redJasper{Vitality\n& Grounding} obsidian{Protection\n& Transformation} other{}}'**
  String libraryTextCollectionDetail(String id);

  /// No description provided for @libraryTextCollectionCategory.
  ///
  /// In en, this message translates to:
  /// **'{id, select, merkaba{SACRED GEOMETRY} rituals{RITUAL GUIDE} other{CRYSTAL GUIDE}}'**
  String libraryTextCollectionCategory(String id);

  /// No description provided for @libraryCrystalHeadingTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get libraryCrystalHeadingTemple;

  /// No description provided for @libraryCrystalHeadingPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get libraryCrystalHeadingPurpose;

  /// No description provided for @libraryCrystalHeadingSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get libraryCrystalHeadingSkin;

  /// No description provided for @libraryCrystalHeadingMeridians.
  ///
  /// In en, this message translates to:
  /// **'Meridians'**
  String get libraryCrystalHeadingMeridians;

  /// No description provided for @libraryCrystalHeadingFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get libraryCrystalHeadingFrequency;

  /// No description provided for @libraryCrystalHeadingEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get libraryCrystalHeadingEnvironment;

  /// No description provided for @libraryCrystalHeadingIntention.
  ///
  /// In en, this message translates to:
  /// **'Intention'**
  String get libraryCrystalHeadingIntention;

  /// No description provided for @libraryCrystalIntention.
  ///
  /// In en, this message translates to:
  /// **'{crystal, select, whiteQuartz{Clarity, Expansion, Radiance} jade{Harmony, Self-Love, Renewal} obsidian{Protection, Renewal, Transformation} redJasper{Vitality, Grounding} other{}}'**
  String libraryCrystalIntention(String crystal);

  /// No description provided for @libraryMerkabaHeadingDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get libraryMerkabaHeadingDuration;

  /// No description provided for @libraryMerkabaHeadingBreath.
  ///
  /// In en, this message translates to:
  /// **'Breath'**
  String get libraryMerkabaHeadingBreath;

  /// No description provided for @libraryMerkabaHeadingScenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get libraryMerkabaHeadingScenes;

  /// No description provided for @libraryMerkabaHeadingCues.
  ///
  /// In en, this message translates to:
  /// **'Cues'**
  String get libraryMerkabaHeadingCues;

  /// No description provided for @libraryMerkabaBreath.
  ///
  /// In en, this message translates to:
  /// **'Inhale 4 seconds. Hold 4 seconds. Exhale 6 seconds.\nEvery inhale creates. Every hold is organized. Every exhale reveals.\nBreath is the invisible architect. Air is the medium. Light is the material. Geometry is the result.'**
  String get libraryMerkabaBreath;

  /// No description provided for @libraryMerkabaScene1.
  ///
  /// In en, this message translates to:
  /// **'0:00–0:40 Human Blueprint. A figure of light with a pulsing heart traces the five-pointed star. Gyan Mudra. Presence and awareness.'**
  String get libraryMerkabaScene1;

  /// No description provided for @libraryMerkabaScene2.
  ///
  /// In en, this message translates to:
  /// **'0:40–1:30 Air Becomes the Vehicle. The star dissolves into ribbons of air that spiral with the breath. Vayu Mudra. Air, movement, and breath.'**
  String get libraryMerkabaScene2;

  /// No description provided for @libraryMerkabaScene3.
  ///
  /// In en, this message translates to:
  /// **'1:30–3:40 Breath Builds the Merkaba. The two interlocking tetrahedra are drawn edge by edge around the body. Lotus Mudra. Receiving and expansion.'**
  String get libraryMerkabaScene3;

  /// No description provided for @libraryMerkabaScene4.
  ///
  /// In en, this message translates to:
  /// **'3:40–4:30 Expansion Through Coherence. The triangles counter-rotate and the field expands with heart coherence. Akash Mudra. Spaciousness and consciousness.'**
  String get libraryMerkabaScene4;

  /// No description provided for @libraryMerkabaScene5.
  ///
  /// In en, this message translates to:
  /// **'4:30–5:00 The Heart Blossoms. The Merkaba slows, its lines soften and bloom into the Anahata heart mandala. Anjali. Integration and gratitude.'**
  String get libraryMerkabaScene5;

  /// No description provided for @libraryMerkabaCues.
  ///
  /// In en, this message translates to:
  /// **'One clear chime cues Inhale (4 seconds). A soft sustained shimmer cues Hold (4 seconds). A warm lower chime cues Exhale (6 seconds).'**
  String get libraryMerkabaCues;

  /// No description provided for @libraryRitualsHeadingSequence.
  ///
  /// In en, this message translates to:
  /// **'Sequence'**
  String get libraryRitualsHeadingSequence;

  /// No description provided for @libraryRitualsSequence.
  ///
  /// In en, this message translates to:
  /// **'01 The Merkaba Room. Breathing 4·4·6: inhale 4 seconds, hold 4 seconds, exhale 6 seconds. Mudras.\n02 Hikaru Massage Experience. Facial Gua Sha. The massage maps meridians, lymphatic drainage, fascia, and the 54 facial muscles.\n03 Hikaru Massage Experience. Body Gua Sha. Timer. Pressure: Light, Moderate, Firm.\n04 Frequency and cymatics. 528 Hz, Maestro Jorge Alfano. Locked until the Merkaba meditation and the Gua Sha massage are complete.'**
  String get libraryRitualsSequence;

  /// No description provided for @merkabaPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get merkabaPlay;

  /// No description provided for @merkabaPause.
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get merkabaPause;

  /// No description provided for @merkabaRepeat.
  ///
  /// In en, this message translates to:
  /// **'REPEAT'**
  String get merkabaRepeat;

  /// No description provided for @merkabaSceneOf.
  ///
  /// In en, this message translates to:
  /// **'SCENE {number} OF {total}'**
  String merkabaSceneOf(int number, int total);

  /// No description provided for @merkabaBreaths.
  ///
  /// In en, this message translates to:
  /// **'BREATHS'**
  String get merkabaBreaths;

  /// No description provided for @merkabaCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle {percent}%'**
  String merkabaCycle(int percent);

  /// No description provided for @merkabaBreathsSemantics.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} breaths. Cycle {percent} percent'**
  String merkabaBreathsSemantics(int done, int total, int percent);

  /// No description provided for @merkabaSessionProgress.
  ///
  /// In en, this message translates to:
  /// **'Session progress'**
  String get merkabaSessionProgress;

  /// No description provided for @merkabaPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String merkabaPercentValue(int percent);

  /// No description provided for @merkabaSilence.
  ///
  /// In en, this message translates to:
  /// **'Silence.'**
  String get merkabaSilence;

  /// No description provided for @merkabaWomanSemantics.
  ///
  /// In en, this message translates to:
  /// **'Seated woman in meditation'**
  String get merkabaWomanSemantics;

  /// No description provided for @merkabaPhaseInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get merkabaPhaseInhale;

  /// No description provided for @merkabaPhaseHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get merkabaPhaseHold;

  /// No description provided for @merkabaPhaseExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get merkabaPhaseExhale;

  /// No description provided for @merkabaScene1Title.
  ///
  /// In en, this message translates to:
  /// **'Human Blueprint'**
  String get merkabaScene1Title;

  /// No description provided for @merkabaScene1Purpose.
  ///
  /// In en, this message translates to:
  /// **'Presence and awareness'**
  String get merkabaScene1Purpose;

  /// No description provided for @merkabaScene2Title.
  ///
  /// In en, this message translates to:
  /// **'Air Becomes the Vehicle'**
  String get merkabaScene2Title;

  /// No description provided for @merkabaScene2Purpose.
  ///
  /// In en, this message translates to:
  /// **'Air, movement, and breath'**
  String get merkabaScene2Purpose;

  /// No description provided for @merkabaScene3Title.
  ///
  /// In en, this message translates to:
  /// **'Breath Builds the Merkaba'**
  String get merkabaScene3Title;

  /// No description provided for @merkabaScene3Purpose.
  ///
  /// In en, this message translates to:
  /// **'Receiving and expansion'**
  String get merkabaScene3Purpose;

  /// No description provided for @merkabaScene4Title.
  ///
  /// In en, this message translates to:
  /// **'Expansion Through Coherence'**
  String get merkabaScene4Title;

  /// No description provided for @merkabaScene4Purpose.
  ///
  /// In en, this message translates to:
  /// **'Spaciousness and consciousness'**
  String get merkabaScene4Purpose;

  /// No description provided for @merkabaScene5Title.
  ///
  /// In en, this message translates to:
  /// **'The Heart Blossoms'**
  String get merkabaScene5Title;

  /// No description provided for @merkabaScene5Purpose.
  ///
  /// In en, this message translates to:
  /// **'Integration and gratitude'**
  String get merkabaScene5Purpose;

  /// No description provided for @massageFaceTemple.
  ///
  /// In en, this message translates to:
  /// **'THE FACE TEMPLE'**
  String get massageFaceTemple;

  /// No description provided for @massageBodyTemple.
  ///
  /// In en, this message translates to:
  /// **'THE BODY TEMPLE'**
  String get massageBodyTemple;

  /// No description provided for @massageFaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'HIKARU LIFT RITUAL · FACE'**
  String get massageFaceSubtitle;

  /// No description provided for @massageBodySubtitle.
  ///
  /// In en, this message translates to:
  /// **'HIKARU LIFT RITUAL · BODY'**
  String get massageBodySubtitle;

  /// No description provided for @massageVideoPlaySemantics.
  ///
  /// In en, this message translates to:
  /// **'Play ritual video'**
  String get massageVideoPlaySemantics;

  /// No description provided for @massageVideoPauseSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pause ritual video'**
  String get massageVideoPauseSemantics;

  /// No description provided for @massageBackSemantics.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get massageBackSemantics;

  /// No description provided for @massageSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get massageSound;

  /// No description provided for @massageMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get massageMoreOptions;

  /// No description provided for @massageRitualSheet.
  ///
  /// In en, this message translates to:
  /// **'Ritual sheet'**
  String get massageRitualSheet;

  /// No description provided for @massageBreathe.
  ///
  /// In en, this message translates to:
  /// **'BREATHE'**
  String get massageBreathe;

  /// No description provided for @massageDuration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get massageDuration;

  /// No description provided for @massageInhale.
  ///
  /// In en, this message translates to:
  /// **'INHALE'**
  String get massageInhale;

  /// No description provided for @massageExhale.
  ///
  /// In en, this message translates to:
  /// **'EXHALE'**
  String get massageExhale;

  /// No description provided for @massagePreviousZone.
  ///
  /// In en, this message translates to:
  /// **'Previous zone'**
  String get massagePreviousZone;

  /// No description provided for @massageNextZone.
  ///
  /// In en, this message translates to:
  /// **'Next zone'**
  String get massageNextZone;

  /// No description provided for @massageRestart.
  ///
  /// In en, this message translates to:
  /// **'RESTART'**
  String get massageRestart;

  /// No description provided for @massageRestartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Restart ritual'**
  String get massageRestartSemantics;

  /// No description provided for @massageSessionLength.
  ///
  /// In en, this message translates to:
  /// **'SESSION LENGTH'**
  String get massageSessionLength;

  /// No description provided for @massageMinutesChip.
  ///
  /// In en, this message translates to:
  /// **'{minutes} MIN'**
  String massageMinutesChip(int minutes);

  /// No description provided for @ritualVideoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'RITUAL VIDEO'**
  String get ritualVideoPlaceholder;

  /// No description provided for @ritualVideoSemantics.
  ///
  /// In en, this message translates to:
  /// **'Ritual video'**
  String get ritualVideoSemantics;

  /// No description provided for @massageZoneJawline.
  ///
  /// In en, this message translates to:
  /// **'Jawline'**
  String get massageZoneJawline;

  /// No description provided for @massageZoneNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get massageZoneNeck;

  /// No description provided for @massageZoneCheeks.
  ///
  /// In en, this message translates to:
  /// **'Cheeks'**
  String get massageZoneCheeks;

  /// No description provided for @massageZoneNasolabial.
  ///
  /// In en, this message translates to:
  /// **'Nasolabial'**
  String get massageZoneNasolabial;

  /// No description provided for @massageZoneForehead.
  ///
  /// In en, this message translates to:
  /// **'Forehead'**
  String get massageZoneForehead;

  /// No description provided for @massageZoneGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get massageZoneGlutes;

  /// No description provided for @massageZoneLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get massageZoneLegs;

  /// No description provided for @massageZoneAbdomen.
  ///
  /// In en, this message translates to:
  /// **'Abdomen'**
  String get massageZoneAbdomen;

  /// No description provided for @massageZoneChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get massageZoneChest;

  /// No description provided for @massageInstructionJawline.
  ///
  /// In en, this message translates to:
  /// **'Place Hikaru beneath the ear, then glide upward along the jawline.'**
  String get massageInstructionJawline;

  /// No description provided for @massageInstructionNeck.
  ///
  /// In en, this message translates to:
  /// **'Glide Hikaru down the sides of the neck, from the jaw to the collarbone.'**
  String get massageInstructionNeck;

  /// No description provided for @massageInstructionCheeks.
  ///
  /// In en, this message translates to:
  /// **'Sweep Hikaru from the side of the nose outward across the cheekbones.'**
  String get massageInstructionCheeks;

  /// No description provided for @massageInstructionNasolabial.
  ///
  /// In en, this message translates to:
  /// **'Glide Hikaru from the corner of the mouth up toward the temple.'**
  String get massageInstructionNasolabial;

  /// No description provided for @massageInstructionForehead.
  ///
  /// In en, this message translates to:
  /// **'Glide Hikaru from the brows upward to the hairline, then out to the temples.'**
  String get massageInstructionForehead;

  /// No description provided for @massageInstructionGlutes.
  ///
  /// In en, this message translates to:
  /// **'Sweep Hikaru upward from the base of the glutes toward the hips.'**
  String get massageInstructionGlutes;

  /// No description provided for @massageInstructionLegs.
  ///
  /// In en, this message translates to:
  /// **'Glide Hikaru upward from the ankles toward the knees and thighs.'**
  String get massageInstructionLegs;

  /// No description provided for @massageInstructionAbdomen.
  ///
  /// In en, this message translates to:
  /// **'Trace slow clockwise circles around the navel.'**
  String get massageInstructionAbdomen;

  /// No description provided for @massageInstructionChest.
  ///
  /// In en, this message translates to:
  /// **'Glide Hikaru from the sternum outward toward the underarms.'**
  String get massageInstructionChest;

  /// No description provided for @authFaceIdSemantics.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Face ID'**
  String get authFaceIdSemantics;

  /// No description provided for @biometricFaceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get biometricFaceId;

  /// No description provided for @biometricTouchId.
  ///
  /// In en, this message translates to:
  /// **'Touch ID'**
  String get biometricTouchId;

  /// No description provided for @biometricFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get biometricFingerprint;

  /// No description provided for @biometricOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {method}'**
  String biometricOfferTitle(String method);

  /// No description provided for @biometricOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Next time Hikaru can open with {method}. The password stays on this phone.'**
  String biometricOfferBody(String method);

  /// No description provided for @biometricOfferAccept.
  ///
  /// In en, this message translates to:
  /// **'USE {method}'**
  String biometricOfferAccept(String method);

  /// No description provided for @biometricOfferDecline.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get biometricOfferDecline;

  /// No description provided for @biometricSignInReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to sign in to Hikaru'**
  String get biometricSignInReason;

  /// No description provided for @biometricEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to turn on {method}'**
  String biometricEnableReason(String method);

  /// Title of the language preference card on the profile screen.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get profileLanguageCardTitle;

  /// Helper text under the language preference card title.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the app.'**
  String get profileLanguageCardSubtitle;

  /// Label for the English option in the language selector.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Label for the Spanish option in the language selector.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// Accessibility label announcing the headphones note dialog.
  ///
  /// In en, this message translates to:
  /// **'Headphones recommended'**
  String get headphonesDialogSemanticsLabel;

  /// Small overline above the headphones dialog title.
  ///
  /// In en, this message translates to:
  /// **'FOR THE FULL HIKARU FREQUENCY EXPERIENCE'**
  String get headphonesDialogEyebrow;

  /// Main title of the headphones recommendation dialog.
  ///
  /// In en, this message translates to:
  /// **'Headphones recommended'**
  String get headphonesDialogTitle;

  /// Body copy of the headphones dialog, including the comfortable-volume reminder.
  ///
  /// In en, this message translates to:
  /// **'For a more immersive experience, we recommend headphones. Find a comfortable space, set a comfortable volume, and let the sound surround you.'**
  String get headphonesDialogBody;

  /// Primary button: continue with headphones ready.
  ///
  /// In en, this message translates to:
  /// **'I\'M READY'**
  String get headphonesDialogReady;

  /// Secondary button: continue without headphones.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE WITHOUT HEADPHONES'**
  String get headphonesDialogContinueWithout;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
