enum Crystal {
  whiteQuartz(
    displayName: 'WHITE QUARTZ',
    temple: 'Temple of Illumination',
    imageAsset: 'assets/images/temple_white_quartz.png',
    audioAsset: 'audio/white_quartz.m4a',
    protocol: 'Quartz Illumination Protocol',
    frequency: 'Resonance tones',
    frequencyDetail: 'Energy amplification & cellular coherence',
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
    protocol: 'Jasper Vitality Protocol',
    frequency: 'Physical alignment',
    frequencyDetail: 'Activates metabolic & vascular flow',
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
  });

  static const String composer = 'Maestro Jorge Alfano';
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

  static Crystal? fromName(String? value) => values.asNameMap()[value];
}
