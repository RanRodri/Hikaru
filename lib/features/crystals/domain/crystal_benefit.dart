/// Concept the benefit icon stands for. The chamber maps each to artwork.
enum BenefitIcon { mind, heart, flow, glow, rhythm }

class CrystalBenefit {
  const CrystalBenefit({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final BenefitIcon icon;
}
