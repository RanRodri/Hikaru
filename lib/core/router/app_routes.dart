abstract final class AppRoutes {
  static const String splash = '/';
  static const String sanctuary = '/sanctuary';
  static const String discovery = '/discovery';
  static const String ritual = '/ritual';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String listeningRoom = '/listening-room';
  static const String listeningRoomQuiz = '/listening-room/quiz';
  static const String ritualReady = '/listening-room/ritual-ready';
  static const String mirrorGarden = '/mirror-garden';
  static const String resonanceChamber = '/resonance-chamber';
  static const String crystalResonanceParam = 'crystal';
  static const String crystalResonance =
      '$resonanceChamber/:$crystalResonanceParam';

  static String crystalResonanceFor(String crystal) =>
      '$resonanceChamber/$crystal';
  static const String home = '/home';
  static const String fourTemples = '/home/four-temples';
  static const String profile = '/home/profile';
  static const String journey = '/home/journey';
  static const String library = '/home/library';
  static const String merkaba = '$home/merkaba';
  static const String ritualFace = '$home/ritual-face';
  static const String ritualBody = '$home/ritual-body';
  static const String libraryTopicParam = 'topic';
  static const String libraryTopic = '$library/:$libraryTopicParam';

  static String libraryTopicFor(String topic) => '$library/$topic';
}
