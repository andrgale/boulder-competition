enum LiberatoriaMode {
  nessuna('nessuna'),
  cartacea('cartacea'),
  digitale('digitale');

  final String dbValue;
  const LiberatoriaMode(this.dbValue);

  static LiberatoriaMode fromDb(String? value) {
    return LiberatoriaMode.values.firstWhere(
      (m) => m.dbValue == value,
      orElse: () => LiberatoriaMode.nessuna,
    );
  }
}