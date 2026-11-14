import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Parsel Atlası'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Silinsin mi?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In tr, this message translates to:
  /// **'{name} kalıcı olarak silinecek. Bu geri alınamaz.'**
  String confirmDeleteBody(String name);

  /// No description provided for @signInTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Size verilen kullanıcı adı ve şifre ile giriş yapın.'**
  String get signInSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// No description provided for @signInButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get signInButton;

  /// No description provided for @layerOfficial.
  ///
  /// In tr, this message translates to:
  /// **'Resmi parseller'**
  String get layerOfficial;

  /// No description provided for @layerDrawn.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek sınırlar'**
  String get layerDrawn;

  /// No description provided for @baseSatellite.
  ///
  /// In tr, this message translates to:
  /// **'Uydu'**
  String get baseSatellite;

  /// No description provided for @baseStreet.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get baseStreet;

  /// No description provided for @menuPeople.
  ///
  /// In tr, this message translates to:
  /// **'Kişiler'**
  String get menuPeople;

  /// No description provided for @menuActivity.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get menuActivity;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  /// No description provided for @myLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumum'**
  String get myLocation;

  /// No description provided for @newDrawing.
  ///
  /// In tr, this message translates to:
  /// **'Yeni çizim'**
  String get newDrawing;

  /// No description provided for @noParcelStoredTitle.
  ///
  /// In tr, this message translates to:
  /// **'Burada kayıtlı parsel yok'**
  String get noParcelStoredTitle;

  /// No description provided for @noParcelStoredBody.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıttan sorgulamak günlük sorgu hakkından birini kullanır.'**
  String get noParcelStoredBody;

  /// No description provided for @queryRegistryButton.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıttan sorgula'**
  String get queryRegistryButton;

  /// No description provided for @querying.
  ///
  /// In tr, this message translates to:
  /// **'Sorgulanıyor…'**
  String get querying;

  /// No description provided for @officialParcelTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ada {block} · Parsel {parcel}'**
  String officialParcelTitle(String block, String parcel);

  /// No description provided for @officialBadge.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıt'**
  String get officialBadge;

  /// No description provided for @drawnBadge.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek sınır'**
  String get drawnBadge;

  /// No description provided for @cityLabel.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get cityLabel;

  /// No description provided for @districtLabel.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get districtLabel;

  /// No description provided for @neighborhoodLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle / Köy'**
  String get neighborhoodLabel;

  /// No description provided for @localityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mevkii'**
  String get localityLabel;

  /// No description provided for @qualityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Nitelik'**
  String get qualityLabel;

  /// No description provided for @sheetLabel.
  ///
  /// In tr, this message translates to:
  /// **'Pafta'**
  String get sheetLabel;

  /// No description provided for @landStatusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Zemin durumu'**
  String get landStatusLabel;

  /// No description provided for @registryAreaLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tapu alanı'**
  String get registryAreaLabel;

  /// No description provided for @inactiveParcel.
  ///
  /// In tr, this message translates to:
  /// **'Bu parsel resmi kayıtta pasif (tarihî) görünüyor.'**
  String get inactiveParcel;

  /// No description provided for @refreshButton.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıttan güncelle'**
  String get refreshButton;

  /// No description provided for @drawRealButton.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek sınırı çiz'**
  String get drawRealButton;

  /// No description provided for @officialReadOnlyNote.
  ///
  /// In tr, this message translates to:
  /// **'Resmi bilgiler değiştirilemez; yalnızca resmi kayıttan güncellenir.'**
  String get officialReadOnlyNote;

  /// No description provided for @queriedBy.
  ///
  /// In tr, this message translates to:
  /// **'İlk sorgulayan: {name} · {date}'**
  String queriedBy(String name, String date);

  /// No description provided for @refreshedBy.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: {name} · {date}'**
  String refreshedBy(String name, String date);

  /// No description provided for @correctionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu parselin gerçek sınırları'**
  String get correctionsTitle;

  /// No description provided for @measuredAreaLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ölçülen alan'**
  String get measuredAreaLabel;

  /// No description provided for @perimeterLabel.
  ///
  /// In tr, this message translates to:
  /// **'Çevre'**
  String get perimeterLabel;

  /// No description provided for @edgesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kenar uzunlukları'**
  String get edgesLabel;

  /// No description provided for @linkedOfficialLabel.
  ///
  /// In tr, this message translates to:
  /// **'Düzelttiği resmi parsel'**
  String get linkedOfficialLabel;

  /// No description provided for @areaDifference.
  ///
  /// In tr, this message translates to:
  /// **'Tapuya göre fark: {difference} ({percent})'**
  String areaDifference(String difference, String percent);

  /// No description provided for @ownersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sahipler'**
  String get ownersTitle;

  /// No description provided for @noOwners.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sahip eklenmedi.'**
  String get noOwners;

  /// No description provided for @sharesTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam pay: {total}'**
  String sharesTotal(String total);

  /// No description provided for @sharesIncomplete.
  ///
  /// In tr, this message translates to:
  /// **'Paylar toplamı 1 değil — bazı sahipler eksik olabilir.'**
  String get sharesIncomplete;

  /// No description provided for @editShape.
  ///
  /// In tr, this message translates to:
  /// **'Şekli düzenle'**
  String get editShape;

  /// No description provided for @editDetails.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri düzenle'**
  String get editDetails;

  /// No description provided for @createdBy.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturan: {name} · {date}'**
  String createdBy(String name, String date);

  /// No description provided for @updatedBy.
  ///
  /// In tr, this message translates to:
  /// **'Son değişiklik: {name} · {date}'**
  String updatedBy(String name, String date);

  /// No description provided for @noteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get noteLabel;

  /// No description provided for @viaGroup.
  ///
  /// In tr, this message translates to:
  /// **'{group} üzerinden'**
  String viaGroup(String group);

  /// No description provided for @drawingHint.
  ///
  /// In tr, this message translates to:
  /// **'Köşe eklemek için haritaya dokunun. Köşeleri sürükleyerek taşıyın, kenardaki + ile araya köşe ekleyin.'**
  String get drawingHint;

  /// No description provided for @crosshairHint.
  ///
  /// In tr, this message translates to:
  /// **'Haritayı kaydırıp nişangâhı noktaya getirin, sonra köşe ekleyin.'**
  String get crosshairHint;

  /// No description provided for @drawingCorners.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Köşe yok} =1{1 köşe} other{{count} köşe}}'**
  String drawingCorners(int count);

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In tr, this message translates to:
  /// **'İleri al'**
  String get redo;

  /// No description provided for @deleteCorner.
  ///
  /// In tr, this message translates to:
  /// **'Köşeyi sil'**
  String get deleteCorner;

  /// No description provided for @crosshairMode.
  ///
  /// In tr, this message translates to:
  /// **'Nişangâh'**
  String get crosshairMode;

  /// No description provided for @addCornerHere.
  ///
  /// In tr, this message translates to:
  /// **'Buraya köşe ekle'**
  String get addCornerHere;

  /// No description provided for @finishDrawing.
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get finishDrawing;

  /// No description provided for @cancelDrawing.
  ///
  /// In tr, this message translates to:
  /// **'Çizimi bırak'**
  String get cancelDrawing;

  /// No description provided for @saveDrawingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çizimi kaydet'**
  String get saveDrawingTitle;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get nameLabel;

  /// No description provided for @drawingNameDefault.
  ///
  /// In tr, this message translates to:
  /// **'{label} gerçek sınır'**
  String drawingNameDefault(String label);

  /// No description provided for @addOwner.
  ///
  /// In tr, this message translates to:
  /// **'Sahip ekle'**
  String get addOwner;

  /// No description provided for @shareLabel.
  ///
  /// In tr, this message translates to:
  /// **'Pay'**
  String get shareLabel;

  /// No description provided for @shareHint.
  ///
  /// In tr, this message translates to:
  /// **'örn. 1/4'**
  String get shareHint;

  /// No description provided for @invalidShare.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir pay yazın (örn. 1/4).'**
  String get invalidShare;

  /// No description provided for @pickOwnerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişi veya grup seçin'**
  String get pickOwnerTitle;

  /// No description provided for @peopleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişiler ve gruplar'**
  String get peopleTitle;

  /// No description provided for @peopleTab.
  ///
  /// In tr, this message translates to:
  /// **'Kişiler'**
  String get peopleTab;

  /// No description provided for @groupsTab.
  ///
  /// In tr, this message translates to:
  /// **'Gruplar'**
  String get groupsTab;

  /// No description provided for @addPersonButton.
  ///
  /// In tr, this message translates to:
  /// **'Kişi ekle'**
  String get addPersonButton;

  /// No description provided for @addGroupButton.
  ///
  /// In tr, this message translates to:
  /// **'Grup ekle'**
  String get addGroupButton;

  /// No description provided for @personDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişi'**
  String get personDialogTitle;

  /// No description provided for @groupDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Grup'**
  String get groupDialogTitle;

  /// No description provided for @groupMembersLabel.
  ///
  /// In tr, this message translates to:
  /// **'Üyeler'**
  String get groupMembersLabel;

  /// No description provided for @parcelCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Parsel yok} =1{1 parsel} other{{count} parsel}}'**
  String parcelCount(int count);

  /// No description provided for @memberCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Üye yok} =1{1 kişi} other{{count} kişi}}'**
  String memberCount(int count);

  /// No description provided for @noPeople.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kişi yok. Parsel sahiplerini buradan ekleyin.'**
  String get noPeople;

  /// No description provided for @noGroups.
  ///
  /// In tr, this message translates to:
  /// **'Henüz grup yok. Aynı yerleri paylaşan kişileri grup yapın.'**
  String get noGroups;

  /// No description provided for @holdingsParcels.
  ///
  /// In tr, this message translates to:
  /// **'Parsel'**
  String get holdingsParcels;

  /// No description provided for @holdingsTotalArea.
  ///
  /// In tr, this message translates to:
  /// **'Toplam parsel alanı'**
  String get holdingsTotalArea;

  /// No description provided for @holdingsOwnedArea.
  ///
  /// In tr, this message translates to:
  /// **'Sahip olunan alan'**
  String get holdingsOwnedArea;

  /// No description provided for @showOnMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritada göster'**
  String get showOnMap;

  /// No description provided for @holdingsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Atanmış parsel yok.'**
  String get holdingsEmpty;

  /// No description provided for @groupMembersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Grup üyeleri'**
  String get groupMembersTitle;

  /// No description provided for @memberOfGroups.
  ///
  /// In tr, this message translates to:
  /// **'Üye olduğu gruplar'**
  String get memberOfGroups;

  /// No description provided for @perMemberShare.
  ///
  /// In tr, this message translates to:
  /// **'Kişi başı {share}'**
  String perMemberShare(String share);

  /// No description provided for @activityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklik geçmişi'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz değişiklik yok.'**
  String get activityEmpty;

  /// No description provided for @actionQueried.
  ///
  /// In tr, this message translates to:
  /// **'resmi kayıttan sorguladı'**
  String get actionQueried;

  /// No description provided for @actionRefreshed.
  ///
  /// In tr, this message translates to:
  /// **'resmi kayıttan güncelledi'**
  String get actionRefreshed;

  /// No description provided for @actionCreated.
  ///
  /// In tr, this message translates to:
  /// **'oluşturdu'**
  String get actionCreated;

  /// No description provided for @actionUpdated.
  ///
  /// In tr, this message translates to:
  /// **'değiştirdi'**
  String get actionUpdated;

  /// No description provided for @actionDeleted.
  ///
  /// In tr, this message translates to:
  /// **'sildi'**
  String get actionDeleted;

  /// No description provided for @targetOfficial.
  ///
  /// In tr, this message translates to:
  /// **'Resmi parsel'**
  String get targetOfficial;

  /// No description provided for @targetDrawn.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek sınır'**
  String get targetDrawn;

  /// No description provided for @targetPerson.
  ///
  /// In tr, this message translates to:
  /// **'Kişi'**
  String get targetPerson;

  /// No description provided for @targetGroup.
  ///
  /// In tr, this message translates to:
  /// **'Grup'**
  String get targetGroup;

  /// No description provided for @noticeFromStore.
  ///
  /// In tr, this message translates to:
  /// **'Bu parsel zaten kayıtlı — sorgu hakkı harcanmadı.'**
  String get noticeFromStore;

  /// No description provided for @noticeQueried.
  ///
  /// In tr, this message translates to:
  /// **'Parsel resmi kayıttan alındı ve kaydedildi.'**
  String get noticeQueried;

  /// No description provided for @noticeRefreshed.
  ///
  /// In tr, this message translates to:
  /// **'Parsel resmi kayıttan güncellendi.'**
  String get noticeRefreshed;

  /// No description provided for @noticeDrawingSaved.
  ///
  /// In tr, this message translates to:
  /// **'Çizim kaydedildi.'**
  String get noticeDrawingSaved;

  /// No description provided for @noticeDrawingDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Çizim silindi.'**
  String get noticeDrawingDeleted;

  /// No description provided for @noticeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi.'**
  String get noticeSaved;

  /// No description provided for @errorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti. Lütfen tekrar deneyin.'**
  String get errorUnknown;

  /// No description provided for @errorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok ya da sunucu yanıt vermiyor.'**
  String get errorNetwork;

  /// No description provided for @errorBadResponse.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıt beklenmeyen bir yanıt verdi.'**
  String get errorBadResponse;

  /// No description provided for @errorQuota.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıt bugünkü sorgu sınırına ulaştı. Kayıtlı parseller çalışmaya devam eder; yeni sorgu yarın yapılabilir.'**
  String get errorQuota;

  /// No description provided for @errorNoParcel.
  ///
  /// In tr, this message translates to:
  /// **'Bu noktada resmi kayıtta parsel bulunamadı.'**
  String get errorNoParcel;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı veya şifre hatalı.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNotMember.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap aile listesinde değil.'**
  String get errorNotMember;

  /// No description provided for @errorAdminOnly.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlemi yalnızca ana hesap yapabilir.'**
  String get errorAdminOnly;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In tr, this message translates to:
  /// **'Önce giriş yapın.'**
  String get errorNotSignedIn;

  /// No description provided for @errorTooFewCorners.
  ///
  /// In tr, this message translates to:
  /// **'Bir alan için en az 3 köşe gerekir.'**
  String get errorTooFewCorners;

  /// No description provided for @errorRecordMissing.
  ///
  /// In tr, this message translates to:
  /// **'Bu kayıt başka bir cihazda silinmiş.'**
  String get errorRecordMissing;

  /// No description provided for @errorSharesExceed.
  ///
  /// In tr, this message translates to:
  /// **'Her pay 0 ile 1 arasında olmalı ve paylar toplamı 1\'i aşmamalı.'**
  String get errorSharesExceed;

  /// No description provided for @errorEmptyField.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan boş bırakılamaz.'**
  String get errorEmptyField;

  /// No description provided for @squareMeters.
  ///
  /// In tr, this message translates to:
  /// **'{value} m²'**
  String squareMeters(String value);

  /// No description provided for @meters.
  ///
  /// In tr, this message translates to:
  /// **'{value} m'**
  String meters(String value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
