// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageName => 'English';

  @override
  String get sanctuaryWelcome => 'Welcome to';

  @override
  String get sanctuaryTitle => 'HIKARU SANCTUARY';

  @override
  String get sanctuaryTagline => 'Where Beauty Meets Frequency.';

  @override
  String get sanctuaryEnter => 'ENTER THE SANCTUARY';

  @override
  String get discoveryRoomEyebrow => 'THE DISCOVERY ROOM';

  @override
  String get discoveryHeadline => 'Your Journey\nBegins With You';

  @override
  String get discoveryStepKnowYouTitle => 'GETTING TO KNOW YOU';

  @override
  String get discoveryStepKnowYouBody =>
      'A few details to make your Hikaru experience uniquely yours.';

  @override
  String get discoveryStepSkinTitle => 'YOUR SKIN JOURNEY';

  @override
  String get discoveryStepSkinBody =>
      'Optional photos to help you observe your progress over time.';

  @override
  String get discoveryStepPrivacyTitle => 'YOUR PRIVACY';

  @override
  String get discoveryStepPrivacyBody =>
      'Your information is yours. Your trust is our priority.';

  @override
  String get discoveryStepChoiceTitle => 'ALWAYS YOUR CHOICE';

  @override
  String get discoveryStepChoiceBody =>
      'You decide what to share and how to personalize your experience.';

  @override
  String get discoveryBegin => 'BEGIN MY DISCOVERY';

  @override
  String get discoveryFooter => 'BEAUTY MEETS FREQUENCY';

  @override
  String get ritualHeadline => 'Your Sanctuary\nAwaits';

  @override
  String get ritualSubtitle =>
      'Discover a new ritual; where beauty, intention and longevity come together.';

  @override
  String get ritualChoosePath => 'CHOOSE YOUR PATH';

  @override
  String get ritualPathNoHikaruTitle => 'I DON\'T HAVE\nMY HIKARU YET';

  @override
  String get ritualPathNoHikaruAction => 'DISCOVER HIKARU';

  @override
  String get ritualPathHaveHikaruTitle => 'I ALREADY HAVE\nMY HIKARU';

  @override
  String get ritualPathHaveHikaruAction => 'BEGIN MY RITUAL';

  @override
  String get ritualFooter =>
      'EVERY RITUAL BEGINS WITH INTENTION.\nYOU DESERVE THIS MOMENT.';

  @override
  String get storeTitle => 'HIKARU STORE';

  @override
  String get storeClose => 'Close store';

  @override
  String get storeLoadError =>
      'We couldn\'t reach the store. Check your connection and try again.';

  @override
  String get storeRetry => 'TRY AGAIN';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authEmailHintExample => 'you@domain.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authErrorEmailRequired => 'Enter your email';

  @override
  String get authErrorEmailInvalid => 'Enter a valid email';

  @override
  String get authErrorPasswordRequired => 'Enter your password';

  @override
  String get authErrorPasswordPolicy =>
      'Use 8 characters with upper, lower, number, and a symbol';

  @override
  String get authIdentityLabel => 'Email or username';

  @override
  String get authIdentityHint => 'username or you@domain.com';

  @override
  String get authErrorIdentityRequired => 'Enter your email or username';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerUsernameHint => 'Not your email';

  @override
  String get registerErrorUsernameRequired => 'Choose a username';

  @override
  String get registerErrorUsernameInvalid =>
      'Use letters and numbers, not an email';

  @override
  String get confirmSignUpTitle => 'Confirm your email';

  @override
  String get confirmSignUpSubtitle => 'Enter the code we sent you.';

  @override
  String get confirmSignUpCodeLabel => 'Verification code';

  @override
  String get confirmSignUpCodeHint => '123456';

  @override
  String get confirmSignUpAction => 'CONFIRM';

  @override
  String get confirmSignUpErrorCode => 'Enter the code';

  @override
  String get confirmSignUpResend => 'RESEND CODE';

  @override
  String confirmSignUpResendIn(String time) {
    return 'Resend code in $time';
  }

  @override
  String get confirmSignUpResent => 'We sent you a new code.';

  @override
  String get confirmSignUpTooMany =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get loginTitle => 'Welcome Home';

  @override
  String get loginSubtitle => 'YOUR JOURNEY TO RADIANT SKIN';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSignIn => 'SIGN IN';

  @override
  String get loginSessionExpired =>
      'Your session has ended. Sign in again to continue; your progress on this phone is kept.';

  @override
  String get loginOr => 'or';

  @override
  String get loginCreateAccount => 'CREATE ACCOUNT';

  @override
  String get registerTitle => 'Create Your\nSanctuary';

  @override
  String get registerSubtitle =>
      'Your journey to beauty, balance and longevity begins here.';

  @override
  String get registerFullNameLabel => 'Full Name';

  @override
  String get registerFullNameHint => 'Your full name';

  @override
  String get registerBirthdayLabel => 'Birthday';

  @override
  String get registerBirthdayHint => 'MM / DD / YYYY';

  @override
  String get registerBirthdayFormat => 'MM / dd / yyyy';

  @override
  String get registerErrorNameRequired => 'Enter your full name';

  @override
  String get registerErrorBirthdayRequired => 'Select your birthday';

  @override
  String get registerContinue => 'BEGIN YOUR JOURNEY';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLogIn => 'Log in';

  @override
  String get resetTitle => 'Reset Your\nPassword';

  @override
  String get resetSubtitle =>
      'We\'ll help you regain access\nto your sanctuary.';

  @override
  String get resetNewPasswordLabel => 'New Password';

  @override
  String get resetNewPasswordHint => 'Enter new password';

  @override
  String get resetConfirmLabel => 'Confirm Password';

  @override
  String get resetConfirmHint => 'Confirm your password';

  @override
  String get resetErrorNewPasswordRequired => 'Enter new password';

  @override
  String get resetErrorConfirmRequired => 'Confirm your password';

  @override
  String get resetErrorMismatch => 'Passwords do not match';

  @override
  String get resetButton => 'RESET PASSWORD';

  @override
  String get resetSendCode => 'SEND CODE';

  @override
  String get resetResend => 'RESEND CODE';

  @override
  String get resetCodeLabel => 'Verification code';

  @override
  String get resetCodeHint => '123456';

  @override
  String get resetCodeSent => 'We sent a code to your email.';

  @override
  String get resetErrorCode => 'Enter the code';

  @override
  String get resetRemember => 'Remember your password? ';

  @override
  String get resetSignIn => 'Sign in';

  @override
  String get resetNoAccount => 'Don\'t have an account? ';

  @override
  String get resetCreateAccount => 'Create account';

  @override
  String get commonBack => 'BACK';

  @override
  String get commonNext => 'NEXT';

  @override
  String get radiantFooter => 'A  MORE  RADIANT  YOU  AWAITS';

  @override
  String get crystalDisclaimer =>
      'Your crystal recommendation is symbolic and is not a medical diagnosis or a scientifically proven treatment for skin conditions.';

  @override
  String get listeningRoomTitle => 'The\nListening Room';

  @override
  String get listeningRoomTagline => 'A  SPACE  TO  LISTEN  WITHIN';

  @override
  String get listeningRoomDescription =>
      'Take a moment to connect with yourself.\nShare your needs and intentions so we can\nhelp you to create a personalized ritual\nfor your skin, body and energy.';

  @override
  String get listeningRoomBegin => 'BEGIN';

  @override
  String get listeningRoomFooter => 'LISTEN   ·   ALIGN   ·   RECEIVE';

  @override
  String get quizHeader => 'THE LISTENING ROOM';

  @override
  String get quizTagline => 'A  SPACE  TO  BE  HEARD';

  @override
  String quizProgressSemantics(int number, int total) {
    return 'Question $number of $total';
  }

  @override
  String get quizSelectOption => 'Select an option.';

  @override
  String get ritualReadyTitle => 'Your\nRitual Is Ready';

  @override
  String get ritualReadyBody =>
      'Inspired by your unique needs and intentions, your Hikaru Lift Ritual brings together: mindful touch, crystal energy, and frequencies to guide you toward beauty, balance and inner harmony.';

  @override
  String get ritualReadyEnter => 'ENTER YOUR RITUAL';

  @override
  String get quizQ1Prompt =>
      'What would you like to see reflected in the mirror today?';

  @override
  String get quizQ1Instruction => 'Select all that resonate with you';

  @override
  String get quizQ2Prompt => 'How does your skin feel today?';

  @override
  String get quizQ2Instruction => 'Listen to what your skin is telling you';

  @override
  String get quizQ3Prompt => 'Where does your skin need extra care?';

  @override
  String get quizQ4Prompt => 'Where do you notice the most facial tension?';

  @override
  String get quizQ4Instruction => 'Select the area you notice most';

  @override
  String get quizQ5Prompt => 'Which area would you like to focus?';

  @override
  String get quizQ6Prompt => 'How is your skin responding today?';

  @override
  String get quizQ7Prompt =>
      'How would you like to feel at the end of today\'s ritual?';

  @override
  String get quizQ8Prompt =>
      'What intention would you like to set for today\'s ritual?';

  @override
  String get quizQ9Prompt =>
      'What would you like to cultivate over the next 20 days?';

  @override
  String get quizQ10Prompt =>
      'How familiar are you with facial sculpting rituals?';

  @override
  String get quizOptionQ1ReducePuffiness => 'Reduce puffiness';

  @override
  String get quizOptionQ1DefineContours => 'Define facial contours';

  @override
  String get quizOptionQ1SmoothFineLines => 'Smooth fine lines';

  @override
  String get quizOptionQ1RestoreGlow => 'Restore glow/radiance';

  @override
  String get quizOptionQ1DeeplyHydrate => 'Deeply hydrate';

  @override
  String get quizOptionQ2ComfortableBalanced => 'Comfortable and balanced';

  @override
  String get quizOptionQ2Tight => 'Tight';

  @override
  String get quizOptionQ2Dry => 'Dry';

  @override
  String get quizOptionQ2Oily => 'Oily';

  @override
  String get quizOptionQ2Sensitive => 'Sensitive';

  @override
  String get quizOptionQ3Morning => 'In the morning';

  @override
  String get quizOptionQ3AfterTravel => 'After travel';

  @override
  String get quizOptionQ3LongWorkdays => 'After long workdays';

  @override
  String get quizOptionQ3HormonalChanges => 'During hormonal changes';

  @override
  String get quizOptionQ3RestlessNight => 'After a restless night';

  @override
  String get quizOptionQ4Jaw => 'Jaw';

  @override
  String get quizOptionQ4Cheeks => 'Cheeks';

  @override
  String get quizOptionQ4BetweenEyebrows => 'Between eyebrows';

  @override
  String get quizOptionQ4Forehead => 'Forehead';

  @override
  String get quizOptionQ4Neck => 'Neck';

  @override
  String get quizOptionQ5Jawline => 'Jawline';

  @override
  String get quizOptionQ5Cheekbones => 'Cheekbones';

  @override
  String get quizOptionQ5Neck => 'Neck';

  @override
  String get quizOptionQ5EyeArea => 'Eye area';

  @override
  String get quizOptionQ5OverallHarmony => 'Overall facial harmony';

  @override
  String get quizOptionQ6CalmBalanced => 'Calm and balanced';

  @override
  String get quizOptionQ6SlightlySensitive => 'Slightly sensitive';

  @override
  String get quizOptionQ6RedIrritated => 'Red or irritated';

  @override
  String get quizOptionQ6ActiveBreakout => 'Experiencing an active breakout';

  @override
  String get quizOptionQ6RecoveringTreatment =>
      'Recovering from a cosmetic treatment';

  @override
  String get quizOptionQ7MoreSculpted => 'More sculpted';

  @override
  String get quizOptionQ7MoreRadiant => 'More radiant';

  @override
  String get quizOptionQ7Refreshed => 'Refreshed';

  @override
  String get quizOptionQ7DeeplyRelaxed => 'Deeply relaxed';

  @override
  String get quizOptionQ7Grounded => 'Grounded';

  @override
  String get quizOptionQ8Clarity => 'Clarity';

  @override
  String get quizOptionQ8Harmony => 'Harmony';

  @override
  String get quizOptionQ8Grounding => 'Grounding';

  @override
  String get quizOptionQ8Protection => 'Protection';

  @override
  String get quizOptionQ8Vitality => 'Vitality';

  @override
  String get quizOptionQ9ClarityRenewal => 'Clarity and renewal';

  @override
  String get quizOptionQ9BalanceHarmony => 'Balance and harmony';

  @override
  String get quizOptionQ9GroundingProtection => 'Grounding and protection';

  @override
  String get quizOptionQ9VitalityConfidence => 'Vitality and confidence';

  @override
  String get quizOptionQ10FirstRitual => 'Today is my very first ritual';

  @override
  String get quizOptionQ10ExploredFewTimes => 'I\'ve explored it a few times';

  @override
  String get quizOptionQ10Routine => 'It is part of my regular routine';

  @override
  String get commonContinue => 'CONTINUE';

  @override
  String get commonPlay => 'Play';

  @override
  String get commonPause => 'Pause';

  @override
  String get commonExit => 'Exit';

  @override
  String get mirrorGardenEyebrow => 'THE MIRROR GARDEN';

  @override
  String get mirrorGardenTitle => 'Capture your beginning.';

  @override
  String get mirrorGardenSkip => 'SKIP FOR NOW';

  @override
  String get mirrorGardenUpload => 'UPLOAD A PHOTO';

  @override
  String get mirrorGardenOptional => '(Optional)';

  @override
  String get mirrorGardenHint =>
      'Take a photo to create a personal record of your 30-day Hikaru journey and observe your skin\'s evolution over time.\nYour photo is for your personal reflection.';

  @override
  String get mirrorTakePhoto => 'TAKE A PHOTO';

  @override
  String get mirrorTakePhotoSemantics => 'Take a photo';

  @override
  String get mirrorPhotoPreviewSemantics => 'Your face photo preview';

  @override
  String get mirrorPhotoError =>
      'Couldn\'t open the camera or photos. Check permissions and try again.';

  @override
  String get mirrorCameraHint => 'SWIPE UP TO TAKE THE PHOTO';

  @override
  String get mirrorCameraCaptureSemantics => 'Take photo';

  @override
  String get mirrorCameraCloseSemantics => 'Close camera';

  @override
  String get resonanceChamberTitle => 'THE RESONANCE CHAMBER';

  @override
  String get resonanceRevealTitle => 'Your Hikaru Journey';

  @override
  String get resonanceRevealSubtitle => 'Has Been Revealed';

  @override
  String get resonanceMissingCrystal =>
      'Complete the Listening Garden to receive your crystal and personalized protocol.';

  @override
  String get resonanceYourCrystal => 'YOUR CRYSTAL';

  @override
  String resonanceAssignedCrystalSemantics(String crystal) {
    return 'Assigned crystal $crystal';
  }

  @override
  String get resonanceRecommendedProtocol => 'YOUR RECOMMENDED PROTOCOL';

  @override
  String get resonanceProtocolCrystal => 'Crystal';

  @override
  String get resonanceProtocolIntention => 'Intention';

  @override
  String get resonanceProtocolSkinFocus => 'Skin-care focus';

  @override
  String get resonanceProtocolFacialRitual => 'Recommended facial ritual';

  @override
  String get resonanceProtocolDuration => 'Duration';

  @override
  String get resonanceProtocolTemple => 'Temple';

  @override
  String get resonanceProtocolHeadline =>
      'This Is Your Protocol\nFor The Next 30 Days';

  @override
  String get resonanceCrystalTouchHint => 'Touch the crystal to feel its light';

  @override
  String get resonanceDailyRitual => 'Your Daily Ritual';

  @override
  String get resonanceStepMerkaba => 'Merkaba';

  @override
  String get resonanceStepMerkabaDetail => '5 min';

  @override
  String get resonanceStepFacial => 'Facial ritual';

  @override
  String get resonanceStepBody => 'Body ritual';

  @override
  String get resonanceStepCrystal => 'Crystal & cymatics';

  @override
  String get resonanceStepCrystalDetail => 'Crystal Roller';

  @override
  String get resonanceEnterSanctuary => 'ENTER MY HIKARU SANCTUARY';

  @override
  String get resonanceYourFrequency => 'YOUR FREQUENCY';

  @override
  String get resonanceYourCymaticSignature => 'YOUR CYMATIC\nSIGNATURE';

  @override
  String get resonanceCymaticSignatureSemantics => 'Your cymatic signature';

  @override
  String get resonanceYourRitual => 'YOUR RITUAL';

  @override
  String get resonanceStepRegulationName => 'Regulation';

  @override
  String get resonanceStepRegulationSubtitle => 'The Merkaba Room';

  @override
  String get resonanceStepGuaShaName => 'Gua Sha';

  @override
  String get resonanceStepGuaShaSubtitle => 'Physical Massage';

  @override
  String get resonanceStepIntegrationName => 'Frequency & Cymatics Integration';

  @override
  String get resonanceStepIntegrationSubtitle => 'Closing Integration';

  @override
  String get crystalSceneSemanticsDefault => 'Your crystal in the garden';

  @override
  String crystalSceneSemantics(String crystal) {
    return '$crystal crystal';
  }

  @override
  String get cymaticSemantics => 'Cymatic';

  @override
  String get crystalChoose => 'CHOOSE THIS CRYSTAL';

  @override
  String get crystalIsYours => 'YOUR CRYSTAL';

  @override
  String crystalIsYoursSemantics(String crystal) {
    return '$crystal is your crystal';
  }

  @override
  String crystalChosenSnackbar(String crystal) {
    return '$crystal is now your crystal.';
  }

  @override
  String crystalTextName(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'WHITE QUARTZ',
      'jade': 'JADE',
      'obsidian': 'OBSIDIAN',
      'redJasper': 'RED JASPER',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextTemple(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'Temple of Illumination',
      'jade': 'Temple of Harmony',
      'obsidian': 'Temple of Transformation',
      'redJasper': 'Temple of Vitality',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextProtocol(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'Quartz Illumination Protocol',
      'jade': 'Jade Harmony Protocol',
      'obsidian': 'Obsidian Transformation Protocol',
      'redJasper': 'Jasper Vitality Protocol',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextFrequency(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'Cellular Coherence Frequency • 528 Hz',
      'jade': '528 Hz',
      'obsidian': '528 Hz',
      'redJasper': 'Vitality & Vascular Flow Frequency • 639 Hz',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextFrequencyDetail(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'Energy amplification & cellular coherence',
      'jade': 'Heart coherence, love & balance',
      'obsidian': 'Transformation, repair, deep healing & protection',
      'redJasper': 'Activates metabolic & vascular flow',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextFrequencyTagline(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'Cellular Coherence • Illumination • Expansion',
      'jade': 'Heart Coherence • Love • Balance',
      'obsidian': 'Deep Detox • Transformation • Protection',
      'redJasper': 'Metabolic Flow • Vitality • Grounding',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextPurpose(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz':
          'Cellular biohacking, longevity, mental clarity and expansion of consciousness.',
      'jade':
          'Nervous system regulation, emotional balance, recovery and deep calm.',
      'obsidian':
          'Release of stagnant emotions (anger, stress, guilt), protection and detoxification.',
      'redJasper': 'Vitality, physical strength, metabolic flow and grounding.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextSkinBenefit(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz':
          'Amplifies cellular energy, enhancing luminosity and your natural inner glow.',
      'jade': 'Soothes irritation and supports skin balance and health.',
      'obsidian': 'Supports intensive sculpting, drainage and skin renewal.',
      'redJasper':
          'Awakens circulation, strength and resilience of facial and body tissues.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextMeridians(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'Kidney · Governing Vessel',
      'jade': 'Heart · Pericardium · Lung',
      'obsidian': 'Liver · Gallbladder · Heart',
      'redJasper': 'Spleen · Stomach',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextEnvironment(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz':
          'A crystalline temple of white light, sacred geometry and DNA activation.',
      'jade':
          'An emerald temple surrounded by nature, reflective water and green energy currents.',
      'obsidian':
          'Volcanic landscapes, temples of black crystal and sacred fire.',
      'redJasper':
          'Earth and fire elements with golden-red currents of energy.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextSymbolicTitle(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'The Light of Clarity',
      'jade': 'The Garden of Harmony',
      'obsidian': 'The Mirror of the Unseen',
      'redJasper': 'The Earth of Vitality',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextRevelation(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz':
          'Your answers point toward clarity and renewal. White Quartz invites you to clear mental noise, welcome illumination, and restore your natural radiance.',
      'jade':
          'Your answers suggest a need for gentleness and balance. Jade invites you to soften, return to harmony, and care for your skin with mindful presence.',
      'obsidian':
          'Your answers suggest this may be a moment for deeper reflection. Obsidian invites you to look beyond the surface, listen to yourself, and create space for understanding.',
      'redJasper':
          'Your answers speak to grounding and renewed strength. Red Jasper invites you to reconnect with your body, release heaviness, and restore vitality.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextBenefitTitle(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'whiteQuartz0': 'Cellular Biohacking',
      'whiteQuartz1': 'Mental Clarity',
      'whiteQuartz2': 'Luminosity & Glow',
      'whiteQuartz3': 'Energetic Alignment',
      'whiteQuartz4': 'Daily Habit Rhythm',
      'jade0': 'Nervous System Regulation',
      'jade1': 'Heart-Mind Coherence',
      'jade2': 'Lymphatic Balance',
      'jade3': 'Natural Radiance',
      'jade4': 'Daily Habit Rhythm',
      'obsidian0': 'Emotional Release',
      'obsidian1': 'Deep Sculpt & Detox',
      'obsidian2': 'Cellular Renewal',
      'obsidian3': 'Energetic Protection',
      'obsidian4': 'Daily Habit Rhythm',
      'redJasper0': 'Metabolic & Vascular Flow',
      'redJasper1': 'Physical Grounding',
      'redJasper2': 'Tissue Resilience',
      'redJasper3': 'Vital Energy Activation',
      'redJasper4': 'Daily Habit Rhythm',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String crystalTextBenefitDetail(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'whiteQuartz0': 'Supports regeneration and healthy cellular aging',
      'whiteQuartz1': 'Expands consciousness and elevates focus',
      'whiteQuartz2': 'Amplifies skin energy and inner radiance',
      'whiteQuartz3': 'Harmonizes kidney and governing vessel meridians',
      'whiteQuartz4': 'Builds a transformative 30-day ritual rhythm',
      'jade0': 'Calms stress and restores deep inner balance',
      'jade1': 'Promotes emotional harmony and heart connection',
      'jade2': 'Calms inflammation and supports healthy skin tone',
      'jade3': 'Enhances natural glow and overall skin wellness',
      'jade4': 'Deepens consistency and long-term vitality',
      'obsidian0': 'Transforms stress, guilt, and stagnant emotions',
      'obsidian1': 'Promotes intense lymphatic fluid drainage',
      'obsidian2': 'Releases stagnant energy and invites restoration',
      'obsidian3': 'Shields and harmonizes liver and gallbladder pathways',
      'obsidian4': 'Anchors a profound 30-day transformation practice',
      'redJasper0': 'Awakens circulation and facial blood flow',
      'redJasper1': 'Anchors energy and restores physical stamina',
      'redJasper2': 'Enhances skin firmness and muscle tone',
      'redJasper3': 'Stimulates spleen and stomach energy channels',
      'redJasper4': 'Sustains daily strength and long-term resilience',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get recIntentionSelfAwareness => 'Self-awareness and reflection';

  @override
  String get recIntentionMentalClarity => 'Mental clarity and radiance';

  @override
  String get recIntentionCalmComfort => 'Calm, comfort, and mindful skin care';

  @override
  String get recIntentionVitality => 'Vitality and reconnection with the body';

  @override
  String get recIntentionInnerIllumination => 'Clarity and inner illumination';

  @override
  String get recIntentionHarmony => 'Harmony and gentle balance';

  @override
  String get recIntentionGrounding => 'Grounding and inner strength';

  @override
  String get recSkinFocusSoothing => 'Soothing comfort and calming facial care';

  @override
  String get recSkinFocusHydration => 'Hydration and gentle facial care';

  @override
  String get recSkinFocusLift => 'Lift, firmness, and depuffing support';

  @override
  String get recSkinFocusRadiance => 'Radiance and renewed vitality';

  @override
  String get recRitualSoothing => 'Soothing Comfort Protocol';

  @override
  String get recRitualHydration => 'Hydration Protocol';

  @override
  String get recRitualLift => 'Lift & Sculpt Protocol';

  @override
  String get recRitualRadiance => 'Radiance Protocol';

  @override
  String recDuration(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navJourney => 'Journey';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSettings => 'Settings';

  @override
  String get navSanctuary => 'Sanctuary';

  @override
  String get homeGardenTitle => 'THE HARMONY GARDEN';

  @override
  String get homeGardenSubtitle => 'Your Journey Begins Within';

  @override
  String get ritualStepMerkaba => 'Merkaba';

  @override
  String get ritualStepFacial => 'Facial ritual';

  @override
  String get ritualStepBody => 'Body ritual';

  @override
  String get ritualStepCrystal => 'Crystal & cymatics';

  @override
  String homeProgressCongrats(int day) {
    return 'Congratulations, you reached day $day!';
  }

  @override
  String homeProgressDay(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get homeProgressPending => 'Still waiting for you today:';

  @override
  String homeProgressPendingStepSemantics(String step) {
    return 'Pending today: $step';
  }

  @override
  String get celebrationStepTitle => 'Well done';

  @override
  String celebrationStepBody(String step) {
    return 'Completed today: $step.';
  }

  @override
  String celebrationNextStep(String step) {
    return 'Next: $step';
  }

  @override
  String get celebrationDayTitle => 'Today\'s ritual is complete';

  @override
  String celebrationDayBody(int day, int total) {
    return 'Congratulations, you completed day $day of $total. Your light grows a little more every day.';
  }

  @override
  String get celebrationContinue => 'CONTINUE';

  @override
  String get celebrationLibraryEyebrow => 'FROM THE LIBRARY';

  @override
  String get celebrationLibraryMerkaba => 'Explore the meaning of the Merkaba';

  @override
  String get celebrationLibraryFacial =>
      'Discover the science behind your facial ritual';

  @override
  String get celebrationLibraryBody => 'Discover how your body ritual works';

  @override
  String get celebrationLibraryCrystal => 'Explore the meaning of your crystal';

  @override
  String get homeProgressDone => 'Today\'s ritual is complete.';

  @override
  String homeProgressStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String get homeProgressSeeHistory => 'SEE HISTORY';

  @override
  String get homeThanks1 => 'Thank you for showing up for yourself today.';

  @override
  String get homeThanks2 => 'Your light grew a little more today. Rest well.';

  @override
  String get homeThanks3 => 'Every ritual is an act of self-love. Well done.';

  @override
  String get homeThanks4 =>
      'Your skin and your energy thank you. See you tomorrow.';

  @override
  String get homeThanks5 => 'Consistency is your glow. Keep shining.';

  @override
  String get homeThanksWeekOne =>
      'One week of rituals. Your new habit is taking root.';

  @override
  String get homeThanksWeekTwo =>
      'Two weeks of care. Your glow is becoming visible.';

  @override
  String get homeThanksWeekThree =>
      'Three weeks. This ritual is now part of you.';

  @override
  String get homeThanksCycleComplete =>
      'You completed your 30-day journey. Thank you for trusting the process.';

  @override
  String homeProgressTodayCount(int count) {
    return '$count/4 TODAY';
  }

  @override
  String get homeProgressShortMerkaba => 'Merkaba';

  @override
  String get homeProgressShortFace => 'Face';

  @override
  String get homeProgressShortBody => 'Body';

  @override
  String get homeProgressShortCrystal => 'Crystal';

  @override
  String homeProgressCompletedStepSemantics(String step) {
    return 'Completed today: $step';
  }

  @override
  String get homeProgressYesterdayComplete =>
      'Yesterday\'s ritual was complete';

  @override
  String homeProgressYesterdayMissing(String steps) {
    return 'Yesterday missing: $steps';
  }

  @override
  String get historyTitle => 'YOUR RITUAL HISTORY';

  @override
  String get historySubtitle => 'Tap a day to see what you completed.';

  @override
  String get historyLegendComplete => 'Complete';

  @override
  String get historyLegendPartial => 'Partial';

  @override
  String get historyLegendNone => 'Not done';

  @override
  String historyDayTitle(int day) {
    return 'Day $day';
  }

  @override
  String get historyUpcoming => 'This day has not arrived yet.';

  @override
  String get historyStepDone => 'Done';

  @override
  String get historyStepPending => 'Pending';

  @override
  String historyCompletedDays(int count, int total) {
    return '$count of $total days complete';
  }

  @override
  String get historyNoCycle =>
      'Your history appears once you begin your first ritual.';

  @override
  String get cycleEndTitle => 'You completed your\n30-day journey';

  @override
  String cycleEndSummary(int count, int total) {
    return '$count of $total days with your full ritual. How would you like to continue?';
  }

  @override
  String get cycleEndRepeatTest => 'REPEAT THE TEST';

  @override
  String get cycleEndChooseCrystal => 'CHOOSE A NEW CRYSTAL';

  @override
  String get cycleEndLater => 'Decide later';

  @override
  String get homeYourCrystal => 'YOUR CRYSTAL';

  @override
  String get homeYourCrystalSemantics => 'Your crystal';

  @override
  String homeYourCrystalNamedSemantics(String crystal) {
    return 'Your crystal $crystal';
  }

  @override
  String get homeLibrary => 'LIBRARY';

  @override
  String get homeLibrarySemantics => 'Library';

  @override
  String get homeRitualBody => 'HIKARU RITUAL\nBODY';

  @override
  String get homeRitualBodySemantics => 'Hikaru Ritual Body';

  @override
  String get homeRitualFace => 'HIKARU RITUAL\nFACE';

  @override
  String get homeRitualFaceSemantics => 'Hikaru Ritual Face';

  @override
  String get templesTitle => 'THE FOUR TEMPLES';

  @override
  String get templesSubtitle => 'Four paths. One transformation.';

  @override
  String get templesChoose => 'CHOOSE YOUR TEMPLE';

  @override
  String get templesRecommended => 'RECOMMENDED';

  @override
  String get templesSelected => 'SELECTED';

  @override
  String get templesSemanticsRecommended => 'recommended for you';

  @override
  String get templesSemanticsSelected => 'currently selected';

  @override
  String commonDayOfTotal(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get journeyTitle => 'JOURNEY';

  @override
  String get journeySubtitle => 'Your 30-day evolution';

  @override
  String get journeyCaption => 'Small daily rituals. Profound transformation.';

  @override
  String get journeyChooseCrystal => 'Choose your crystal';

  @override
  String journeyActiveCrystalSemantics(String crystal) {
    return 'Your active crystal, $crystal';
  }

  @override
  String get journeyActiveCrystalLabel => 'YOUR ACTIVE CRYSTAL';

  @override
  String get journeyChooseTemple => 'Choose your temple';

  @override
  String get journeyChooseTempleHint =>
      'Select a crystal to begin your 30-day resonance.';

  @override
  String get journeyStreakTitle => 'DAILY STREAK';

  @override
  String get journeyStreakDaysInARow => 'Days in a row';

  @override
  String get journeyPhotosTitle => 'PROGRESS PHOTOS';

  @override
  String get journeyPhotosViewAll => 'View all';

  @override
  String get journeyPhotosViewAllSemantics => 'View all progress photos';

  @override
  String get journeyPhotosSubtitle => 'See your evolution over time';

  @override
  String journeyPhotoDay(int day) {
    return 'DAY $day';
  }

  @override
  String get journeyPhotoBefore => 'Before';

  @override
  String get journeyPhotoCurrent => 'Current';

  @override
  String journeyPhotoBeforeSemantics(String day) {
    return 'Before photo, $day';
  }

  @override
  String journeyPhotoCurrentSemantics(String day) {
    return 'Current photo, $day';
  }

  @override
  String get journeyPhotoCaptureSemantics => 'Take today\'s progress photo';

  @override
  String get journeyPhotosEmpty =>
      'Your photos will appear here as the cycle unfolds.';

  @override
  String journeyPhotoGallerySemantics(String day) {
    return 'Progress photo, $day';
  }

  @override
  String get journeyContinuesTitle => 'YOUR JOURNEY CONTINUES';

  @override
  String journeyContinuesSemantics(String title) {
    return 'Your journey continues, $title';
  }

  @override
  String get journeyContinuesSubtitle =>
      'Frequency · Cymatic Signature · Daily Ritual';

  @override
  String get profileTitle => 'SANCTUARY PROFILE';

  @override
  String get profileSubtitle =>
      'Personal details, daily ritual reminders & progress privacy';

  @override
  String profileMemberSemantics(String name, int day, int total) {
    return '$name, sanctuary member, day $day of $total';
  }

  @override
  String profileMemberLabel(int day, int total) {
    return 'SANCTUARY MEMBER — DAY $day OF $total';
  }

  @override
  String get profileAccountEdit => 'EDIT';

  @override
  String get profileAccountTitle => 'YOUR DETAILS';

  @override
  String get profileAccountSubtitle => 'Photo and name for your sanctuary.';

  @override
  String get profileAccountName => 'NAME';

  @override
  String get profileAccountNameHint => 'Your name';

  @override
  String get profileAccountSave => 'SAVE';

  @override
  String get profileAccountClose => 'CLOSE';

  @override
  String get profileAccountPhotoSemantics => 'Your profile photo';

  @override
  String get profileRecommendationTitle => 'YOUR HIKARU RECOMMENDATION';

  @override
  String get profileRecommendationFacialRitual => 'Facial ritual';

  @override
  String get profileRemindersTitle => 'RITUAL ALARMS & REMINDERS';

  @override
  String get profileReminderMorningTitle => 'Morning Sacred Ritual';

  @override
  String get profileReminderMorningDetail => 'Meditation & facial massage';

  @override
  String get profileReminderEveningTitle => 'Evening Reflection & Breath';

  @override
  String get profileReminderEveningDetail => 'Conscious breathing before sleep';

  @override
  String get notificationMorningTitle => 'Your morning ritual awaits';

  @override
  String get notificationMorningBody =>
      'Merkaba, facial and body ritual, and your crystal. A few minutes just for you.';

  @override
  String get notificationEveningTitle => 'Evening reflection';

  @override
  String get notificationEveningBody =>
      'Breathe slowly and close your day with calm.';

  @override
  String profileReminderTimeSemantics(String title, String time) {
    return '$title time, $time. Double tap to change';
  }

  @override
  String get profileDefaultAvatarSemantics => 'Profile photo not set';

  @override
  String profileReminderSemantics(String title) {
    return '$title reminder';
  }

  @override
  String get profilePrivacyTitle => 'YOUR DATA, TREATED WITH REVERENCE';

  @override
  String get profilePrivacyBody =>
      'Your facial photos and personal information stay with your account. Open Privacy to review what is kept.';

  @override
  String get profilePrivacyOpenSemantics => 'Open privacy settings';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get privacyScreenTitle => 'PRIVACY';

  @override
  String get privacyScreenSubtitle => 'What Hikaru keeps, and why.';

  @override
  String get privacyPhotoTitle => 'Your face photo';

  @override
  String get privacyPhotoBody =>
      'Used to personalize your facial ritual and your profile picture. You can replace it any time from your details.';

  @override
  String get privacyProfileTitle => 'Your name and profile';

  @override
  String get privacyProfileBody =>
      'Shown only inside your sanctuary to greet you.';

  @override
  String get privacyJourneyTitle => 'Your journey';

  @override
  String get privacyJourneyBody =>
      'Your crystal, protocol and daily progress, so your 30-day cycle is here when you return.';

  @override
  String get privacyRemindersTitle => 'Your reminders';

  @override
  String get privacyRemindersBody =>
      'Reminder times are used only to notify you of your rituals.';

  @override
  String get profileCycleTitle => '30-DAY CYCLE';

  @override
  String get profileCycleInProgress => 'Your journey is in progress';

  @override
  String get profileCycleComplete => 'Complete your cycle';

  @override
  String profileCycleUnlock(int total) {
    return 'At day $total, you’ll unlock your new diagnosis and recalibrate your crystal, frequency and cymatic signature.';
  }

  @override
  String get profileCycleEnd => 'END CYCLE';

  @override
  String get profileSignOut => 'SIGN OUT';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody =>
      'Your progress is saved to your account and will be here when you sign in again.';

  @override
  String get profileSignOutCancel => 'STAY';

  @override
  String get profileSignOutConfirm => 'SIGN OUT';

  @override
  String get profileSignOutError =>
      'We couldn\'t sign you out. Check your connection and try again.';

  @override
  String get libraryTitle => 'LIBRARY';

  @override
  String get librarySubtitle => 'Sacred knowledge for your journey';

  @override
  String get libraryBackSemantics => 'Back to library';

  @override
  String libraryChapterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String libraryReadingTime(int minutes) {
    return '$minutes min read';
  }

  @override
  String get libraryFilterAll => 'ALL';

  @override
  String get libraryFilterAllSemantics => 'Show all chapters';

  @override
  String libraryFilterChapterSemantics(int number, String heading) {
    return 'Go to chapter $number, $heading';
  }

  @override
  String libraryChapterLabel(String number) {
    return 'CHAPTER $number';
  }

  @override
  String libraryOpenChapterSemantics(int number, String heading) {
    return 'Open chapter $number, $heading';
  }

  @override
  String get libraryNextLabel => 'NEXT IN LIBRARY';

  @override
  String libraryNextSemantics(String label) {
    return 'Next in library, $label';
  }

  @override
  String get libraryRead => 'READ';

  @override
  String get libraryReadMore => 'READ MORE';

  @override
  String get libraryReadLess => 'READ LESS';

  @override
  String libraryTextCollectionName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'merkaba': 'MERKABA',
      'rituals': 'HIKARU RITUALS',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String libraryTextCollectionDetail(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'merkaba': 'Geometry & Energy',
      'rituals': 'Face & Body',
      'jade': 'Balance\n& Harmony',
      'whiteQuartz': 'Clarity\n& Renewal',
      'redJasper': 'Vitality\n& Grounding',
      'obsidian': 'Protection\n& Transformation',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String libraryTextCollectionCategory(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'merkaba': 'SACRED GEOMETRY',
      'rituals': 'RITUAL GUIDE',
      'other': 'CRYSTAL GUIDE',
    });
    return '$_temp0';
  }

  @override
  String get libraryCrystalHeadingTemple => 'Temple';

  @override
  String get libraryCrystalHeadingPurpose => 'Purpose';

  @override
  String get libraryCrystalHeadingSkin => 'Skin';

  @override
  String get libraryCrystalHeadingMeridians => 'Meridians';

  @override
  String get libraryCrystalHeadingFrequency => 'Frequency';

  @override
  String get libraryCrystalHeadingEnvironment => 'Environment';

  @override
  String get libraryCrystalHeadingIntention => 'Intention';

  @override
  String libraryCrystalIntention(String crystal) {
    String _temp0 = intl.Intl.selectLogic(crystal, {
      'whiteQuartz': 'Clarity, Expansion, Radiance',
      'jade': 'Harmony, Self-Love, Renewal',
      'obsidian': 'Protection, Renewal, Transformation',
      'redJasper': 'Vitality, Grounding',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get libraryMerkabaHeadingDuration => 'Duration';

  @override
  String get libraryMerkabaHeadingBreath => 'Breath';

  @override
  String get libraryMerkabaHeadingScenes => 'Scenes';

  @override
  String get libraryMerkabaHeadingCues => 'Cues';

  @override
  String get libraryMerkabaBreath =>
      'Inhale 4 seconds. Hold 4 seconds. Exhale 6 seconds.\nEvery inhale creates. Every hold is organized. Every exhale reveals.\nBreath is the invisible architect. Air is the medium. Light is the material. Geometry is the result.';

  @override
  String get libraryMerkabaScene1 =>
      '0:00–0:40 Human Blueprint. A figure of light with a pulsing heart traces the five-pointed star. Gyan Mudra. Presence and awareness.';

  @override
  String get libraryMerkabaScene2 =>
      '0:40–1:30 Air Becomes the Vehicle. The star dissolves into ribbons of air that spiral with the breath. Vayu Mudra. Air, movement, and breath.';

  @override
  String get libraryMerkabaScene3 =>
      '1:30–3:40 Breath Builds the Merkaba. The two interlocking tetrahedra are drawn edge by edge around the body. Lotus Mudra. Receiving and expansion.';

  @override
  String get libraryMerkabaScene4 =>
      '3:40–4:30 Expansion Through Coherence. The triangles counter-rotate and the field expands with heart coherence. Akash Mudra. Spaciousness and consciousness.';

  @override
  String get libraryMerkabaScene5 =>
      '4:30–5:00 The Heart Blossoms. The Merkaba slows, its lines soften and bloom into the Anahata heart mandala. Anjali. Integration and gratitude.';

  @override
  String get libraryMerkabaCues =>
      'A soft breath and a golden circle of light cue Inhale (4 seconds). The light rests and shimmers on Hold (4 seconds). The circle gently shrinks on Exhale (6 seconds).';

  @override
  String get libraryRitualsHeadingSequence => 'Sequence';

  @override
  String get libraryRitualsSequence =>
      '01 The Merkaba Room. Breathing 4·4·6: inhale 4 seconds, hold 4 seconds, exhale 6 seconds. Mudras.\n02 Hikaru Massage Experience. Facial Gua Sha. The massage maps meridians, lymphatic drainage, fascia, and the 54 facial muscles.\n03 Hikaru Massage Experience. Body Gua Sha. Timer. Pressure: Light, Moderate, Firm.\n04 Frequency and cymatics. 528 Hz, Maestro Jorge Alfano. Locked until the Merkaba meditation and the Gua Sha massage are complete.';

  @override
  String get merkabaPlay => 'PLAY';

  @override
  String get merkabaPause => 'PAUSE';

  @override
  String get merkabaRepeat => 'REPEAT';

  @override
  String merkabaSceneOf(int number, int total) {
    return 'SCENE $number OF $total';
  }

  @override
  String get merkabaBreaths => 'BREATHS';

  @override
  String get merkabaRemaining => 'REMAINING';

  @override
  String merkabaCycle(int percent) {
    return 'Cycle $percent%';
  }

  @override
  String merkabaBreathsSemantics(int done, int total, int percent) {
    return '$done of $total breaths. Cycle $percent percent';
  }

  @override
  String get merkabaSessionProgress => 'Session progress';

  @override
  String merkabaPercentValue(int percent) {
    return '$percent percent';
  }

  @override
  String get merkabaSilence => 'Silence.';

  @override
  String get merkabaWomanSemantics => 'Seated woman in meditation';

  @override
  String merkabaTimeRemaining(String time) {
    return '$time remaining';
  }

  @override
  String get merkabaSessionLength => 'TIME IN THE ROOM';

  @override
  String get merkabaPreparing => 'Preparing the room';

  @override
  String get merkabaSaving => 'Saving today\'s progress';

  @override
  String get merkabaSaved => 'Today\'s Merkaba is saved';

  @override
  String get merkabaSavedOnDevice => 'Saved on this device';

  @override
  String merkabaCycleDay(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String merkabaDaysPracticed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days of Merkaba',
      one: '1 day of Merkaba',
    );
    return '$_temp0';
  }

  @override
  String get merkabaPhaseInhale => 'Inhale';

  @override
  String get merkabaPhaseHold => 'Hold';

  @override
  String get merkabaPhaseExhale => 'Exhale';

  @override
  String get merkabaScene1Title => 'Human Blueprint';

  @override
  String get merkabaScene1Purpose => 'Presence and awareness';

  @override
  String get merkabaScene2Title => 'Air Becomes the Vehicle';

  @override
  String get merkabaScene2Purpose => 'Air, movement, and breath';

  @override
  String get merkabaScene3Title => 'Breath Builds the Merkaba';

  @override
  String get merkabaScene3Purpose => 'Receiving and expansion';

  @override
  String get merkabaScene4Title => 'Expansion Through Coherence';

  @override
  String get merkabaScene4Purpose => 'Spaciousness and consciousness';

  @override
  String get merkabaScene5Title => 'The Heart Blossoms';

  @override
  String get merkabaScene5Purpose => 'Integration and gratitude';

  @override
  String get massageTutorialTemple => 'THE CRYSTAL TUTORIAL';

  @override
  String get massageTutorialSubtitle => 'HIKARU LIFT RITUAL · TUTORIAL';

  @override
  String get massageZoneTutorial => 'Tutorial';

  @override
  String get massageInstructionTutorial =>
      'Watch how to glide the crystal before you begin your frequency.';

  @override
  String get massageFaceTemple => 'THE FACE TEMPLE';

  @override
  String get massageBodyTemple => 'THE BODY TEMPLE';

  @override
  String get massageFaceSubtitle => 'HIKARU LIFT RITUAL · FACE';

  @override
  String get massageBodySubtitle => 'HIKARU LIFT RITUAL · BODY';

  @override
  String get massageVideoPlaySemantics => 'Play ritual video';

  @override
  String get massageVideoPauseSemantics => 'Pause ritual video';

  @override
  String get massageBackSemantics => 'Back';

  @override
  String get massageSound => 'Sound';

  @override
  String get massageMoreOptions => 'More options';

  @override
  String get massageRitualSheet => 'Ritual sheet';

  @override
  String get massageBreathe => 'BREATHE';

  @override
  String get massageDuration => 'DURATION';

  @override
  String get massageInhale => 'INHALE';

  @override
  String get massageExhale => 'EXHALE';

  @override
  String get massagePreviousZone => 'Previous zone';

  @override
  String get massageNextZone => 'Next zone';

  @override
  String get massageRestart => 'RESTART';

  @override
  String get massageRestartSemantics => 'Restart ritual';

  @override
  String get massageSessionLength => 'SESSION LENGTH';

  @override
  String massageMinutesChip(int minutes) {
    return '$minutes MIN';
  }

  @override
  String get ritualVideoPlaceholder => 'RITUAL VIDEO';

  @override
  String get ritualVideoSemantics => 'Ritual video';

  @override
  String get massageZoneJawline => 'Jawline';

  @override
  String get massageZoneNeck => 'Neck';

  @override
  String get massageZoneCheeks => 'Cheeks';

  @override
  String get massageZoneNasolabial => 'Nasolabial';

  @override
  String get massageZoneForehead => 'Forehead';

  @override
  String get massageZoneBody => 'Body';

  @override
  String get massageZoneLegs => 'Legs';

  @override
  String get massageZoneAbdomen => 'Abdomen';

  @override
  String get massageZoneChest => 'Chest';

  @override
  String get massageInstructionJawline =>
      'Place Hikaru beneath the ear, then glide upward along the jawline.';

  @override
  String get massageInstructionNeck =>
      'Glide Hikaru down the sides of the neck, from the jaw to the collarbone.';

  @override
  String get massageInstructionCheeks =>
      'Sweep Hikaru from the side of the nose outward across the cheekbones.';

  @override
  String get massageInstructionNasolabial =>
      'Glide Hikaru from the corner of the mouth up toward the temple.';

  @override
  String get massageInstructionForehead =>
      'Glide Hikaru from the brows upward to the hairline, then out to the temples.';

  @override
  String get massageInstructionBody =>
      'Sweep Hikaru upward along the arms and hips, one side at a time.';

  @override
  String get massageInstructionLegs =>
      'Glide Hikaru upward from the ankles toward the knees and thighs.';

  @override
  String get massageInstructionAbdomen =>
      'Trace slow clockwise circles around the navel.';

  @override
  String get massageInstructionChest =>
      'Glide Hikaru from the sternum outward toward the underarms.';

  @override
  String get authFaceIdSemantics => 'Sign in with Face ID';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricTouchId => 'Touch ID';

  @override
  String get biometricFingerprint => 'Fingerprint';

  @override
  String biometricOfferTitle(String method) {
    return 'Enable $method';
  }

  @override
  String biometricOfferBody(String method) {
    return 'Open Hikaru next time with $method. Your password stays on this phone.';
  }

  @override
  String biometricOfferAccept(String method) {
    return 'Enable $method';
  }

  @override
  String get biometricOfferDecline => 'NOT NOW';

  @override
  String get biometricSignInReason => 'Confirm to sign in to Hikaru';

  @override
  String biometricEnableReason(String method) {
    return 'Confirm to turn on $method';
  }

  @override
  String get profileLanguageCardTitle => 'LANGUAGE';

  @override
  String get profileLanguageCardSubtitle => 'Choose the language for the app.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get headphonesDialogSemanticsLabel => 'Headphones recommended';

  @override
  String get headphonesDialogEyebrow => 'AWAKEN YOUR SENSES';

  @override
  String get headphonesDialogBody =>
      'Put on your headphones and let the frequency surround you.';

  @override
  String get headphonesDialogReady => 'ACTIVATE MY FREQUENCY';

  @override
  String get headphonesDialogContinueWithout => 'CONTINUE WITHOUT HEADPHONES';

  @override
  String get crystalTutorialButton => 'VIDEO TUTORIAL';

  @override
  String get crystalStartFrequencyButton => 'START YOUR FREQUENCY';

  @override
  String get crystalYourCrystalLibraryButton => 'YOUR CRYSTAL';

  @override
  String get crystalTutorialPendingNote => 'Tutorial video coming soon';

  @override
  String get crystalTutorialReadyTitle =>
      'Your crystal ritual is ready. Now enter the frequency.';

  @override
  String get crystalContinueToResonance => 'CONTINUE TO RESONANCE';

  @override
  String get crystalTutorialReminderBody =>
      'Have you watched the video tutorial? It shows how to use your roller during the resonance.';

  @override
  String get crystalWatchTutorial => 'WATCH TUTORIAL';

  @override
  String get tutorialPause => 'Pause';

  @override
  String get tutorialResume => 'Resume';

  @override
  String get tutorialReplay => 'Replay';

  @override
  String get tutorialClose => 'Close';

  @override
  String get cymaticRewind => 'Back 10 seconds';

  @override
  String get cymaticProgress => 'Frequency progress';

  @override
  String cymaticProgressValue(String elapsed, String total) {
    return '$elapsed of $total';
  }

  @override
  String get cymaticStop => 'Stop';

  @override
  String get resonanceReturnTitle => 'RETURN TO COHERENCE';

  @override
  String get resonanceReturnSubtitle => 'Carry this moment of harmony with you';

  @override
  String get resonanceCompleteRitual => 'COMPLETE MY RITUAL';

  @override
  String get resonanceExploreMeaning => 'Explore the meaning of crystals';

  @override
  String get templesChangeTitle => 'Change your crystal?';

  @override
  String templesChangeBody(String from, String to) {
    return 'Your ritual will move from $from to $to.';
  }

  @override
  String get templesChangeConfirm => 'CHANGE CRYSTAL';

  @override
  String templesChangeCancel(String current) {
    return 'Keep $current';
  }

  @override
  String get resonanceExploreAnotherTemple => 'EXPLORE ANOTHER TEMPLE';

  @override
  String get libraryCrystalHeadingWhyRecommended =>
      'Why we recommended this crystal';

  @override
  String get resonanceDiscoverInLibraryLink =>
      'Discover this crystal in the Library';

  @override
  String crystalTrackDurationSemantics(String duration) {
    return 'Track length $duration';
  }
}
