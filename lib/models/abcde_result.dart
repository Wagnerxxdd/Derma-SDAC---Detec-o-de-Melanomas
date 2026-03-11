class AbcdeResult {
  final bool isAsymmetric;
  final double asymmetryValue;
  final bool irregularBorders;
  final double fourierFactor;
  final double compactness;
  final double convexity;
  final bool multipleColors;
  final double averageContrast;
  final double averageHomogeneity;
  final bool diameterGreaterThan6mm;
  final bool hasEvolution;

  AbcdeResult({
    required this.isAsymmetric,
    required this.asymmetryValue,
    required this.irregularBorders,
    required this.fourierFactor,
    required this.compactness,
    required this.convexity,
    required this.multipleColors,
    required this.averageContrast,
    required this.averageHomogeneity,
    required this.diameterGreaterThan6mm,
    required this.hasEvolution,
  });

  int get suspiciousCriteriaCount {
    int count = 0;
    if (isAsymmetric) count++;
    if (irregularBorders) count++;
    if (multipleColors) count++;
    if (diameterGreaterThan6mm) count++;
    if (hasEvolution) count++;
    return count;
  }

  String get riskLevel {
    int count = suspiciousCriteriaCount;
    if (count >= 3) return "Alto";
    if (count >= 1) return "Médio";
    return "Baixo";
  }
}
