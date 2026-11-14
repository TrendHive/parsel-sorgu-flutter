// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Parsel Atlası';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get close => 'Kapat';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get confirmDeleteTitle => 'Silinsin mi?';

  @override
  String confirmDeleteBody(String name) {
    return '$name kalıcı olarak silinecek. Bu geri alınamaz.';
  }

  @override
  String get signInTitle => 'Giriş yap';

  @override
  String get signInSubtitle =>
      'Size verilen kullanıcı adı ve şifre ile giriş yapın.';

  @override
  String get usernameLabel => 'Kullanıcı adı';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get signInButton => 'Giriş yap';

  @override
  String get layerOfficial => 'Resmi parseller';

  @override
  String get layerDrawn => 'Gerçek sınırlar';

  @override
  String get baseSatellite => 'Uydu';

  @override
  String get baseStreet => 'Harita';

  @override
  String get menuPeople => 'Kişiler';

  @override
  String get menuActivity => 'Geçmiş';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get myLocation => 'Konumum';

  @override
  String get newDrawing => 'Yeni çizim';

  @override
  String get noParcelStoredTitle => 'Burada kayıtlı parsel yok';

  @override
  String get noParcelStoredBody =>
      'Resmi kayıttan sorgulamak günlük sorgu hakkından birini kullanır.';

  @override
  String get queryRegistryButton => 'Resmi kayıttan sorgula';

  @override
  String get querying => 'Sorgulanıyor…';

  @override
  String officialParcelTitle(String block, String parcel) {
    return 'Ada $block · Parsel $parcel';
  }

  @override
  String get officialBadge => 'Resmi kayıt';

  @override
  String get drawnBadge => 'Gerçek sınır';

  @override
  String get cityLabel => 'İl';

  @override
  String get districtLabel => 'İlçe';

  @override
  String get neighborhoodLabel => 'Mahalle / Köy';

  @override
  String get localityLabel => 'Mevkii';

  @override
  String get qualityLabel => 'Nitelik';

  @override
  String get sheetLabel => 'Pafta';

  @override
  String get landStatusLabel => 'Zemin durumu';

  @override
  String get registryAreaLabel => 'Tapu alanı';

  @override
  String get inactiveParcel =>
      'Bu parsel resmi kayıtta pasif (tarihî) görünüyor.';

  @override
  String get refreshButton => 'Resmi kayıttan güncelle';

  @override
  String get drawRealButton => 'Gerçek sınırı çiz';

  @override
  String get officialReadOnlyNote =>
      'Resmi bilgiler değiştirilemez; yalnızca resmi kayıttan güncellenir.';

  @override
  String queriedBy(String name, String date) {
    return 'İlk sorgulayan: $name · $date';
  }

  @override
  String refreshedBy(String name, String date) {
    return 'Son güncelleme: $name · $date';
  }

  @override
  String get correctionsTitle => 'Bu parselin gerçek sınırları';

  @override
  String get measuredAreaLabel => 'Ölçülen alan';

  @override
  String get perimeterLabel => 'Çevre';

  @override
  String get edgesLabel => 'Kenar uzunlukları';

  @override
  String get linkedOfficialLabel => 'Düzelttiği resmi parsel';

  @override
  String areaDifference(String difference, String percent) {
    return 'Tapuya göre fark: $difference ($percent)';
  }

  @override
  String get ownersTitle => 'Sahipler';

  @override
  String get noOwners => 'Henüz sahip eklenmedi.';

  @override
  String sharesTotal(String total) {
    return 'Toplam pay: $total';
  }

  @override
  String get sharesIncomplete =>
      'Paylar toplamı 1 değil — bazı sahipler eksik olabilir.';

  @override
  String get editShape => 'Şekli düzenle';

  @override
  String get editDetails => 'Bilgileri düzenle';

  @override
  String createdBy(String name, String date) {
    return 'Oluşturan: $name · $date';
  }

  @override
  String updatedBy(String name, String date) {
    return 'Son değişiklik: $name · $date';
  }

  @override
  String get noteLabel => 'Not';

  @override
  String viaGroup(String group) {
    return '$group üzerinden';
  }

  @override
  String get drawingHint =>
      'Köşe eklemek için haritaya dokunun. Köşeleri sürükleyerek taşıyın, kenardaki + ile araya köşe ekleyin.';

  @override
  String get crosshairHint =>
      'Haritayı kaydırıp nişangâhı noktaya getirin, sonra köşe ekleyin.';

  @override
  String drawingCorners(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count köşe',
      one: '1 köşe',
      zero: 'Köşe yok',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Geri al';

  @override
  String get redo => 'İleri al';

  @override
  String get deleteCorner => 'Köşeyi sil';

  @override
  String get crosshairMode => 'Nişangâh';

  @override
  String get addCornerHere => 'Buraya köşe ekle';

  @override
  String get finishDrawing => 'Bitir';

  @override
  String get cancelDrawing => 'Çizimi bırak';

  @override
  String get saveDrawingTitle => 'Çizimi kaydet';

  @override
  String get nameLabel => 'Ad';

  @override
  String drawingNameDefault(String label) {
    return '$label gerçek sınır';
  }

  @override
  String get addOwner => 'Sahip ekle';

  @override
  String get shareLabel => 'Pay';

  @override
  String get shareHint => 'örn. 1/4';

  @override
  String get invalidShare => 'Geçerli bir pay yazın (örn. 1/4).';

  @override
  String get pickOwnerTitle => 'Kişi veya grup seçin';

  @override
  String get peopleTitle => 'Kişiler ve gruplar';

  @override
  String get peopleTab => 'Kişiler';

  @override
  String get groupsTab => 'Gruplar';

  @override
  String get addPersonButton => 'Kişi ekle';

  @override
  String get addGroupButton => 'Grup ekle';

  @override
  String get personDialogTitle => 'Kişi';

  @override
  String get groupDialogTitle => 'Grup';

  @override
  String get groupMembersLabel => 'Üyeler';

  @override
  String parcelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parsel',
      one: '1 parsel',
      zero: 'Parsel yok',
    );
    return '$_temp0';
  }

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi',
      one: '1 kişi',
      zero: 'Üye yok',
    );
    return '$_temp0';
  }

  @override
  String get noPeople => 'Henüz kişi yok. Parsel sahiplerini buradan ekleyin.';

  @override
  String get noGroups =>
      'Henüz grup yok. Aynı yerleri paylaşan kişileri grup yapın.';

  @override
  String get holdingsParcels => 'Parsel';

  @override
  String get holdingsTotalArea => 'Toplam parsel alanı';

  @override
  String get holdingsOwnedArea => 'Sahip olunan alan';

  @override
  String get showOnMap => 'Haritada göster';

  @override
  String get holdingsEmpty => 'Atanmış parsel yok.';

  @override
  String get groupMembersTitle => 'Grup üyeleri';

  @override
  String get memberOfGroups => 'Üye olduğu gruplar';

  @override
  String perMemberShare(String share) {
    return 'Kişi başı $share';
  }

  @override
  String get activityTitle => 'Değişiklik geçmişi';

  @override
  String get activityEmpty => 'Henüz değişiklik yok.';

  @override
  String get actionQueried => 'resmi kayıttan sorguladı';

  @override
  String get actionRefreshed => 'resmi kayıttan güncelledi';

  @override
  String get actionCreated => 'oluşturdu';

  @override
  String get actionUpdated => 'değiştirdi';

  @override
  String get actionDeleted => 'sildi';

  @override
  String get targetOfficial => 'Resmi parsel';

  @override
  String get targetDrawn => 'Gerçek sınır';

  @override
  String get targetPerson => 'Kişi';

  @override
  String get targetGroup => 'Grup';

  @override
  String get noticeFromStore =>
      'Bu parsel zaten kayıtlı — sorgu hakkı harcanmadı.';

  @override
  String get noticeQueried => 'Parsel resmi kayıttan alındı ve kaydedildi.';

  @override
  String get noticeRefreshed => 'Parsel resmi kayıttan güncellendi.';

  @override
  String get noticeDrawingSaved => 'Çizim kaydedildi.';

  @override
  String get noticeDrawingDeleted => 'Çizim silindi.';

  @override
  String get noticeSaved => 'Kaydedildi.';

  @override
  String get errorUnknown => 'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  @override
  String get errorNetwork =>
      'İnternet bağlantısı yok ya da sunucu yanıt vermiyor.';

  @override
  String get errorBadResponse => 'Resmi kayıt beklenmeyen bir yanıt verdi.';

  @override
  String get errorQuota =>
      'Resmi kayıt bugünkü sorgu sınırına ulaştı. Kayıtlı parseller çalışmaya devam eder; yeni sorgu yarın yapılabilir.';

  @override
  String get errorNoParcel => 'Bu noktada resmi kayıtta parsel bulunamadı.';

  @override
  String get errorInvalidCredentials => 'Kullanıcı adı veya şifre hatalı.';

  @override
  String get errorNotMember => 'Bu hesap aile listesinde değil.';

  @override
  String get errorAdminOnly => 'Bu işlemi yalnızca ana hesap yapabilir.';

  @override
  String get errorNotSignedIn => 'Önce giriş yapın.';

  @override
  String get errorTooFewCorners => 'Bir alan için en az 3 köşe gerekir.';

  @override
  String get errorRecordMissing => 'Bu kayıt başka bir cihazda silinmiş.';

  @override
  String get errorSharesExceed =>
      'Her pay 0 ile 1 arasında olmalı ve paylar toplamı 1\'i aşmamalı.';

  @override
  String get errorEmptyField => 'Bu alan boş bırakılamaz.';

  @override
  String squareMeters(String value) {
    return '$value m²';
  }

  @override
  String meters(String value) {
    return '$value m';
  }
}
