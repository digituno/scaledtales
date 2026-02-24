enum AcquisitionSource {
  breeder('BREEDER'),
  petShop('PET_SHOP'),
  private_('PRIVATE'),
  rescued('RESCUED'),
  bred('BRED'),
  other('OTHER');

  const AcquisitionSource(this.value);
  final String value;

  static AcquisitionSource fromValue(String value) {
    return AcquisitionSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AcquisitionSource.other,
    );
  }
}
