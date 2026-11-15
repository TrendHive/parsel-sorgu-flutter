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
  String get menuPeople => 'Aile';

  @override
  String get menuActivity => 'Geçmiş';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get myLocation => 'Konumum';

  @override
  String get newDrawing => 'Yeni çizim';

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
  String get pickOwnerTitle => 'Kişi seçin';

  @override
  String get peopleTitle => 'Aile ağacı';

  @override
  String get addPersonButton => 'Kişi ekle';

  @override
  String get personDialogTitle => 'Kişi';

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
  String get noPeople =>
      'Henüz kişi yok. En büyük atadan başlayarak aileyi ekleyin.';

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

  @override
  String get pickOwnerEmpty =>
      'Eklenecek kişi yok. Önce Aile sayfasından kişileri ekleyin.';

  @override
  String childCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çocuk',
      one: '1 çocuk',
    );
    return '$_temp0';
  }

  @override
  String get parentLabel => 'Babası / annesi';

  @override
  String get parentNone => 'Yok (ağacın başı)';

  @override
  String get passesToChildrenLabel => 'Payı çocuklarına geçti';

  @override
  String get passesToChildrenHint =>
      'Açıkken bu kişinin payları çocukları arasında eşit bölünür.';

  @override
  String passedToChildren(String names, String share) {
    return '$names · kişi başı $share';
  }

  @override
  String get passedOnBadge => 'çocuklarına geçti';

  @override
  String get addChildButton => 'Çocuk ekle';

  @override
  String get childrenTitle => 'Çocukları';

  @override
  String get childrenInheritTitle => 'Mirasçıları (çocukları)';

  @override
  String get holdingsPassedArea => 'Bıraktığı alan';

  @override
  String viaAncestor(String name) {
    return '$name üzerinden';
  }

  @override
  String get errorFamilyLoop =>
      'Bir kişi kendi soyundan birinin çocuğu olamaz.';

  @override
  String get errorRegistryRefusesWeb =>
      'Resmi kayıt, web sitesinden yapılan sorguları kabul etmiyor. Yeni parsel sorgusunu masaüstü veya mobil uygulamadan yapın; kayıtlı parseller burada da görünür.';

  @override
  String get searchParcel => 'Ada / parsel ile sorgula';

  @override
  String get searchTitle => 'Parsel sorgula';

  @override
  String get searchNeighbourhood => 'Mahalle';

  @override
  String get searchNeighbourhoodCode => 'Mahalle kodu';

  @override
  String get searchOther => 'Başka mahalle (kodunu gir)';

  @override
  String get searchHint =>
      'Listede daha önce sorgulanan parsellerin mahalleleri var. Yeni bir mahalle için önce haritada o mahalleden bir parsele dokunun ya da mahalle kodunu girin.';

  @override
  String get blockLabel => 'Ada';

  @override
  String get parcelNumberLabel => 'Parsel';

  @override
  String get searchButton => 'Sorgula';

  @override
  String get colourBy => 'Aileye göre renklendir';

  @override
  String get colourOff => 'Sahibe göre';

  @override
  String colourLevel(int level, String names) {
    return '$level. kuşak: $names';
  }

  @override
  String get colourShared => 'Ortak';

  @override
  String get colourUnassigned => 'Sahibi yok';

  @override
  String get assignOwner => 'Sahip ata';

  @override
  String get assignOwnerWhichDrawing => 'Hangi gerçek sınıra?';

  @override
  String get assignOwnerTitle => 'Kime ait?';

  @override
  String get assignOwnerHint =>
      'Kişiye dokununca seçilir. Oku ile çocuklarına inebilirsiniz; payı çocuklarına geçmiş birini seçerseniz çocukları eşit paydaş görünür.';

  @override
  String get showChildren => 'Çocuklarını aç / kapat';

  @override
  String get splitButton => 'İkiye böl';

  @override
  String get splitEqualButton => 'Eşit böl';

  @override
  String get splitHint =>
      'Kesme çizgisi için iki noktaya dokunun; çizgi bu iki noktadan geçer. Noktalar köşelere ve kenarlara kendiliğinden oturur.';

  @override
  String get splitMissesHint =>
      'Bu çizgi parseli ikiye ayırmıyor. İki noktayı yeniden seçin.';

  @override
  String splitReady(String first, String second) {
    return 'İki parça: $first ve $second';
  }

  @override
  String get confirmSplit => 'Böl ve kaydet';

  @override
  String get splitEqualTitle => 'Eşit böl';

  @override
  String splitEqualToChildren(String name, int count) {
    return '$name çocuklarına: $count eşit parça';
  }

  @override
  String get splitEqualCount => 'Parça sayısı';

  @override
  String get splitEqualByCount =>
      'Sayıya göre eşit parça (sahipler aynı kalır)';

  @override
  String get splitEqualNote =>
      'Parsel, uzun ekseni boyunca eşit alanlı parçalara bölünür. Sonra her parçanın köşelerini düzeltebilirsiniz.';

  @override
  String get errorDrawingOverlaps =>
      'Bu çizim başka bir çizimin üstüne biniyor. Köşeleri komşu sınıra yaklaştırın; kendiliğinden o sınıra oturur.';

  @override
  String get errorSplitMisses =>
      'Parsel bölünemedi. Kesme çizgisini ya da parça sayısını kontrol edin.';

  @override
  String get noticeUseApp =>
      'Yeni parsel sorgusu web sitesinden yapılamıyor. Sorguyu telefondaki ya da bilgisayardaki Parsel Atlası uygulamasından yapın; sorgulanan parsel burada da hemen görünür.';

  @override
  String get compareAdd => 'Karşılaştırmaya ekle';

  @override
  String get compareRemove => 'Karşılaştırmadan çıkar';

  @override
  String compareOpen(int count) {
    return 'Karşılaştır ($count)';
  }

  @override
  String get compareClear => 'Listeyi temizle';

  @override
  String get compareTitle => 'Parsel karşılaştırma';

  @override
  String get compareByOwner => 'Sahibe göre';

  @override
  String get compareParcels => 'Parseller';

  @override
  String get compareReal => 'Gerçek';

  @override
  String get compareRegistry => 'Tapu';

  @override
  String get compareDifference => 'Fark';

  @override
  String get compareTotal => 'Toplam';

  @override
  String get compareEmpty =>
      'Karşılaştırılacak parsel yok. Haritada bir parsel seçip \"Karşılaştırmaya ekle\" deyin.';

  @override
  String get compareNotDrawn => 'Gerçek sınırı çizilmemiş';

  @override
  String get compareNoRegistry => 'Tapu kaydı yok';

  @override
  String get redivideButton => 'Komşuyla tapuya göre böl';

  @override
  String get redivideTitle => 'Tapuya göre yeniden bölme';

  @override
  String get redividePick => 'Yan taraftaki komşu gerçek sınıra dokunun.';

  @override
  String get redivideNoDeed => 'İkisinin de tapu kaydı (resmi parseli) olmalı.';

  @override
  String get redivideSameDeed =>
      'İkisi aynı tapuya ait; tapu bunların nasıl bölüneceğini söylemiyor.';

  @override
  String get redivideNotNeighbours =>
      'Bu iki sınır ortak bir kenarı paylaşmıyor.';

  @override
  String get redivideReady =>
      'Aradaki çizgi tapu alanlarına göre kaydırıldı. Yeni şekiller haritada.';

  @override
  String redividePiece(String name, String after, String deed, String now) {
    return '$name: $after (tapu $deed, şu an $now)';
  }

  @override
  String get redivideConfirm => 'Yeni sınırları kaydet';
}
