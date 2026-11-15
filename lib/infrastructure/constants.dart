/// Addresses and limits of the services infrastructure talks to.
///
/// [baseURL] and [api] are the official land registry (TKGM) parcel query
/// service (see `docs/tkgm-api.md`). [parcelAtPoint] is
/// `parsel/{lat}/{lng}/` and [parcelByNumber] `parsel/{neighbourhood}/{block}/
/// {parcel}`; both answer one GeoJSON feature. [quotaStatus] is the status the
/// registry answers with once a connection's daily allowance is spent, and
/// [notFoundStatus] a point with no parcel.
///
/// [memberEmailDomain] turns a member's short username into the e-mail-shaped
/// login Firebase Auth needs; nobody ever sees or types it.
class InfrastructureConstants {
  static const String api = "/megsiswebapi.v3.1/api";
  static const String baseURL = "https://cbsapi.tkgm.gov.tr";
  static const String parcelAtPoint = "/parsel";
  static const String parcelByNumber = "/parsel";
  static const int quotaStatus = 403;
  static const int notFoundStatus = 404;
  static const Duration registryTimeout = Duration(seconds: 20);

  static const String memberEmailDomain = "members.parcel-atlas.app";
}
