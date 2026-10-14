import 'crystal_benefit.dart';

export 'crystal_benefit.dart';

enum Crystal {
  whiteQuartz(
    displayName: 'WHITE QUARTZ',
    temple: 'Temple of Illumination',
    imageAsset: 'assets/images/temple_white_quartz.png',
    audioAsset: 'audio/white_quartz.m4a',
    protocol: 'Quartz Illumination Protocol — Maestro Jorge Alfano',
    frequency: 'Cellular Coherence Frequency • 528 Hz',
    frequencyDetail: 'Energy amplification & cellular coherence',
    hertz: 528,
    frequencyTagline: 'Cellular Coherence • Illumination • Expansion',
    benefits: [
      CrystalBenefit(
        title: 'Cellular Biohacking',
        detail: 'Supports regeneration and healthy cellular aging',
        icon: BenefitIcon.flow,
      ),
      CrystalBenefit(
        title: 'Mental Clarity',
        detail: 'Expands consciousness and elevates focus',
        icon: BenefitIcon.mind,
      ),
      CrystalBenefit(
        title: 'Luminosity & Glow',
        detail: 'Amplifies skin energy and inner radiance',
        icon: BenefitIcon.glow,
      ),
      CrystalBenefit(
        title: 'Energetic Alignment',
        detail: 'Harmonizes kidney and governing vessel meridians',
        icon: BenefitIcon.flow,
      ),
      CrystalBenefit(
        title: 'Daily Habit Rhythm',
        detail: 'Builds a transformative 30-day ritual rhythm',
        icon: BenefitIcon.rhythm,
      ),
    ],
    purpose:
        'Cellular biohacking, longevity, mental clarity and expansion of '
        'consciousness.',
    skinBenefit:
        'Amplifies cellular energy, enhancing luminosity and your natural '
        'inner glow.',
    meridians: 'Kidney · Governing Vessel',
    environment:
        'A crystalline temple of white light, sacred geometry and DNA '
        'activation.',
  ),
  jade(
    displayName: 'JADE',
    temple: 'Temple of Harmony',
    imageAsset: 'assets/images/temple_jade.png',
    audioAsset: 'audio/jade.m4a',
    protocol: 'Jade Harmony Protocol',
    frequency: '528 Hz',
    frequencyDetail: 'Heart coherence, love & balance',
    hertz: 528,
    frequencyTagline: 'Heart Coherence • Love • Balance',
    benefits: [
      CrystalBenefit(
        title: 'Nervous System Regulation',
        detail: 'Calms stress and restores deep inner balance',
        icon: BenefitIcon.mind,
      ),
      CrystalBenefit(
        title: 'Heart-Mind Coherence',
        detail: 'Promotes emotional harmony and heart connection',
        icon: BenefitIcon.heart,
      ),
      CrystalBenefit(
        title: 'Lymphatic Balance',
        detail: 'Calms inflammation and supports healthy skin tone',
        icon: BenefitIcon.flow,
      ),
      CrystalBenefit(
        title: 'Natural Radiance',
        detail: 'Enhances natural glow and overall skin wellness',
        icon: BenefitIcon.glow,
      ),
      CrystalBenefit(
        title: 'Daily Habit Rhythm',
        detail: 'Deepens consistency and long-term vitality',
        icon: BenefitIcon.rhythm,
      ),
    ],
    purpose:
        'Nervous system regulation, emotional balance, recovery and deep '
        'calm.',
    skinBenefit: 'Soothes irritation and supports skin balance and health.',
    meridians: 'Heart · Pericardium · Lung',
    environment:
        'An emerald temple surrounded by nature, reflective water and green '
        'energy currents.',
  ),
  obsidian(
    displayName: 'OBSIDIAN',
    temple: 'Temple of Transformation',
    imageAsset: 'assets/images/temple_obsidian.png',
    audioAsset: 'audio/obsidian.m4a',
    protocol: 'Obsidian Transformation Protocol',
    frequency: '528 Hz',
    frequencyDetail: 'Transformation, repair, deep healing & protection',
    hertz: 528,
    frequencyTagline: 'Deep Detox • Transformation • Protection',
    benefits: [
      CrystalBenefit(
        title: 'Emotional Release',
        detail: 'Transforms stress, guilt, and stagnant emotions',
        icon: BenefitIcon.heart,
      ),
      CrystalBenefit(
        title: 'Deep Sculpt & Detox',
        detail: 'Promotes intense lymphatic fluid drainage',
        icon: BenefitIcon.glow,
      ),
      CrystalBenefit(
        title: 'Cellular Renewal',
        detail: 'Releases stagnant energy and invites restoration',
        icon: BenefitIcon.flow,
      ),
      CrystalBenefit(
        title: 'Energetic Protection',
        detail: 'Shields and harmonizes liver and gallbladder pathways',
        icon: BenefitIcon.mind,
      ),
      CrystalBenefit(
        title: 'Daily Habit Rhythm',
        detail: 'Anchors a profound 30-day transformation practice',
        icon: BenefitIcon.rhythm,
      ),
    ],
    purpose:
        'Release of stagnant emotions (anger, stress, guilt), protection and '
        'detoxification.',
    skinBenefit: 'Supports intensive sculpting, drainage and skin renewal.',
    meridians: 'Liver · Gallbladder · Heart',
    environment:
        'Volcanic landscapes, temples of black crystal and sacred fire.',
  ),
  redJasper(
    displayName: 'RED JASPER',
    temple: 'Temple of Vitality',
    imageAsset: 'assets/images/temple_red_jasper.png',
    audioAsset: 'audio/red_jasper.m4a',
    protocol: 'Jasper Vitality Protocol — Maestro Jorge Alfano',
    frequency: 'Vitality & Vascular Flow Frequency • 639 Hz',
    frequencyDetail: 'Activates metabolic & vascular flow',
    hertz: 639,
    frequencyTagline: 'Metabolic Flow • Vitality • Grounding',
    benefits: [
      CrystalBenefit(
        title: 'Metabolic & Vascular Flow',
        detail: 'Awakens circulation and facial blood flow',
        icon: BenefitIcon.heart,
      ),
      CrystalBenefit(
        title: 'Physical Grounding',
        detail: 'Anchors energy and restores physical stamina',
        icon: BenefitIcon.flow,
      ),
      CrystalBenefit(
        title: 'Tissue Resilience',
        detail: 'Enhances skin firmness and muscle tone',
        icon: BenefitIcon.glow,
      ),
      CrystalBenefit(
        title: 'Vital Energy Activation',
        detail: 'Stimulates spleen and stomach energy channels',
        icon: BenefitIcon.mind,
      ),
      CrystalBenefit(
        title: 'Daily Habit Rhythm',
        detail: 'Sustains daily strength and long-term resilience',
        icon: BenefitIcon.rhythm,
      ),
    ],
    purpose: 'Vitality, physical strength, metabolic flow and grounding.',
    skinBenefit:
        'Awakens circulation, strength and resilience of facial and body '
        'tissues.',
    meridians: 'Spleen · Stomach',
    environment: 'Earth and fire elements with golden-red currents of energy.',
  );

  const Crystal({
    required this.displayName,
    required this.temple,
    required this.imageAsset,
    required this.audioAsset,
    required this.protocol,
    required this.frequency,
    required this.frequencyDetail,
    required this.purpose,
    required this.skinBenefit,
    required this.meridians,
    required this.environment,
    required this.hertz,
    required this.frequencyTagline,
    required this.benefits,
  });

  static const String composer = 'Maestro Jorge Alfano';
  static const String compositionCredit =
      'Composed by $composer with Japanese instruments';
  static const String sessionLength = '20 min';

  final String displayName;
  final String temple;
  final String imageAsset;
  final String audioAsset;
  final String protocol;
  final String frequency;
  final String frequencyDetail;
  final String purpose;
  final String skinBenefit;
  final String meridians;
  final String environment;
  final int hertz;
  final String frequencyTagline;
  final List<CrystalBenefit> benefits;

  String get hertzLabel => '$hertz Hz';

  static Crystal? fromName(String? value) => values.asNameMap()[value];
}
