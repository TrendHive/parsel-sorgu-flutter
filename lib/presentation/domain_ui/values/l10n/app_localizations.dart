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
  /// **'Aile'**
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
  /// **'Kişi seçin'**
  String get pickOwnerTitle;

  /// No description provided for @peopleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aile ağacı'**
  String get peopleTitle;

  /// No description provided for @addPersonButton.
  ///
  /// In tr, this message translates to:
  /// **'Kişi ekle'**
  String get addPersonButton;

  /// No description provided for @personDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişi'**
  String get personDialogTitle;

  /// No description provided for @parcelCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Parsel yok} =1{1 parsel} other{{count} parsel}}'**
  String parcelCount(int count);

  /// No description provided for @noPeople.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kişi yok. En büyük atadan başlayarak aileyi ekleyin.'**
  String get noPeople;

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

  /// No description provided for @undoButton.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undoButton;

  /// No description provided for @noticeUndone.
  ///
  /// In tr, this message translates to:
  /// **'Geri alındı.'**
  String get noticeUndone;

  /// No description provided for @undoBadge.
  ///
  /// In tr, this message translates to:
  /// **'geri alma'**
  String get undoBadge;

  /// No description provided for @confirmUndoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri alınsın mı?'**
  String get confirmUndoTitle;

  /// No description provided for @confirmUndoBody.
  ///
  /// In tr, this message translates to:
  /// **'\"{label}\" ve aynı işlemle değişen her kayıt önceki haline döner. Bu da geçmişe yazılır ve yine geri alınabilir.'**
  String confirmUndoBody(String label);

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

  /// No description provided for @pickOwnerEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Eklenecek kişi yok. Önce Aile sayfasından kişileri ekleyin.'**
  String get pickOwnerEmpty;

  /// No description provided for @childCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 çocuk} other{{count} çocuk}}'**
  String childCount(int count);

  /// No description provided for @parentLabel.
  ///
  /// In tr, this message translates to:
  /// **'Babası / annesi'**
  String get parentLabel;

  /// No description provided for @parentNone.
  ///
  /// In tr, this message translates to:
  /// **'Yok (ağacın başı)'**
  String get parentNone;

  /// No description provided for @spouseLabel.
  ///
  /// In tr, this message translates to:
  /// **'Eşi'**
  String get spouseLabel;

  /// No description provided for @spouseNone.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get spouseNone;

  /// No description provided for @spouseOf.
  ///
  /// In tr, this message translates to:
  /// **'eşi: {name}'**
  String spouseOf(String name);

  /// No description provided for @passesToChildrenLabel.
  ///
  /// In tr, this message translates to:
  /// **'Payı çocuklarına geçti'**
  String get passesToChildrenLabel;

  /// No description provided for @passesToChildrenHint.
  ///
  /// In tr, this message translates to:
  /// **'Açıkken bu kişinin payları çocukları arasında eşit bölünür.'**
  String get passesToChildrenHint;

  /// No description provided for @passedToChildren.
  ///
  /// In tr, this message translates to:
  /// **'{names} · kişi başı {share}'**
  String passedToChildren(String names, String share);

  /// No description provided for @passedOnBadge.
  ///
  /// In tr, this message translates to:
  /// **'çocuklarına geçti'**
  String get passedOnBadge;

  /// No description provided for @addChildButton.
  ///
  /// In tr, this message translates to:
  /// **'Çocuk ekle'**
  String get addChildButton;

  /// No description provided for @childrenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çocukları'**
  String get childrenTitle;

  /// No description provided for @childrenInheritTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mirasçıları (çocukları)'**
  String get childrenInheritTitle;

  /// No description provided for @holdingsPassedArea.
  ///
  /// In tr, this message translates to:
  /// **'Bıraktığı alan'**
  String get holdingsPassedArea;

  /// No description provided for @viaAncestor.
  ///
  /// In tr, this message translates to:
  /// **'{name} üzerinden'**
  String viaAncestor(String name);

  /// No description provided for @errorFamilyLoop.
  ///
  /// In tr, this message translates to:
  /// **'Bir kişi kendi soyundan birinin çocuğu olamaz.'**
  String get errorFamilyLoop;

  /// No description provided for @errorNothingToUndo.
  ///
  /// In tr, this message translates to:
  /// **'Geri alınacak bir değişiklik yok. Resmi kayıt sorguları ve geri alma özelliğinden önceki değişiklikler geri alınamaz.'**
  String get errorNothingToUndo;

  /// No description provided for @errorChangeSuperseded.
  ///
  /// In tr, this message translates to:
  /// **'Bu değişiklik geri alınamaz: kayıtlarından biri sonradan yeniden değiştirildi ya da değişiklik zaten geri alındı. Önce daha yeni değişikliği geri alın.'**
  String get errorChangeSuperseded;

  /// No description provided for @errorSpouseNotAllowed.
  ///
  /// In tr, this message translates to:
  /// **'Bu kişi eş olarak seçilemez: kendisi, kendi soyundan biri ya da başka biriyle evli.'**
  String get errorSpouseNotAllowed;

  /// No description provided for @errorRegistryRefusesWeb.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıt, web sitesinden yapılan sorguları kabul etmiyor. Yeni parsel sorgusunu masaüstü veya mobil uygulamadan yapın; kayıtlı parseller burada da görünür.'**
  String get errorRegistryRefusesWeb;

  /// No description provided for @searchParcel.
  ///
  /// In tr, this message translates to:
  /// **'Ada / parsel ile sorgula'**
  String get searchParcel;

  /// No description provided for @searchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Parsel sorgula'**
  String get searchTitle;

  /// No description provided for @searchNeighbourhood.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle'**
  String get searchNeighbourhood;

  /// No description provided for @searchNeighbourhoodCode.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle kodu'**
  String get searchNeighbourhoodCode;

  /// No description provided for @searchOther.
  ///
  /// In tr, this message translates to:
  /// **'Başka mahalle (kodunu gir)'**
  String get searchOther;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Listede daha önce sorgulanan parsellerin mahalleleri var. Yeni bir mahalle için önce haritada o mahalleden bir parsele dokunun ya da mahalle kodunu girin.'**
  String get searchHint;

  /// No description provided for @blockLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ada'**
  String get blockLabel;

  /// No description provided for @parcelNumberLabel.
  ///
  /// In tr, this message translates to:
  /// **'Parsel'**
  String get parcelNumberLabel;

  /// No description provided for @searchButton.
  ///
  /// In tr, this message translates to:
  /// **'Sorgula'**
  String get searchButton;

  /// No description provided for @colourBy.
  ///
  /// In tr, this message translates to:
  /// **'Aileye göre renklendir'**
  String get colourBy;

  /// No description provided for @colourOff.
  ///
  /// In tr, this message translates to:
  /// **'Sahibe göre'**
  String get colourOff;

  /// No description provided for @colourLevel.
  ///
  /// In tr, this message translates to:
  /// **'{level}. kuşak: {names}'**
  String colourLevel(int level, String names);

  /// No description provided for @colourShared.
  ///
  /// In tr, this message translates to:
  /// **'Ortak'**
  String get colourShared;

  /// No description provided for @colourUnassigned.
  ///
  /// In tr, this message translates to:
  /// **'Sahibi yok'**
  String get colourUnassigned;

  /// No description provided for @legendShow.
  ///
  /// In tr, this message translates to:
  /// **'Renklerin anlamını göster'**
  String get legendShow;

  /// No description provided for @legendHide.
  ///
  /// In tr, this message translates to:
  /// **'Renk açıklamasını gizle'**
  String get legendHide;

  /// No description provided for @assignOwner.
  ///
  /// In tr, this message translates to:
  /// **'Sahip ata'**
  String get assignOwner;

  /// No description provided for @assignOwnerWhichDrawing.
  ///
  /// In tr, this message translates to:
  /// **'Hangi gerçek sınıra?'**
  String get assignOwnerWhichDrawing;

  /// No description provided for @assignOwnerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kime ait?'**
  String get assignOwnerTitle;

  /// No description provided for @assignOwnerHint.
  ///
  /// In tr, this message translates to:
  /// **'Kişiye dokununca seçilir. Oku ile çocuklarına inebilirsiniz; payı çocuklarına geçmiş birini seçerseniz çocukları eşit paydaş görünür.'**
  String get assignOwnerHint;

  /// No description provided for @showChildren.
  ///
  /// In tr, this message translates to:
  /// **'Çocuklarını aç / kapat'**
  String get showChildren;

  /// No description provided for @splitButton.
  ///
  /// In tr, this message translates to:
  /// **'İkiye böl'**
  String get splitButton;

  /// No description provided for @splitEqualButton.
  ///
  /// In tr, this message translates to:
  /// **'Eşit böl'**
  String get splitEqualButton;

  /// No description provided for @splitHint.
  ///
  /// In tr, this message translates to:
  /// **'Kesme çizgisi için iki noktaya dokunun; çizgi bu iki noktadan geçer. Noktalar köşelere ve kenarlara kendiliğinden oturur.'**
  String get splitHint;

  /// No description provided for @splitMissesHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu çizgi parseli ikiye ayırmıyor. İki noktayı yeniden seçin.'**
  String get splitMissesHint;

  /// No description provided for @splitReady.
  ///
  /// In tr, this message translates to:
  /// **'İki parça: {first} ve {second}'**
  String splitReady(String first, String second);

  /// No description provided for @confirmSplit.
  ///
  /// In tr, this message translates to:
  /// **'Böl ve kaydet'**
  String get confirmSplit;

  /// No description provided for @splitEqualTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eşit böl'**
  String get splitEqualTitle;

  /// No description provided for @splitEqualToChildren.
  ///
  /// In tr, this message translates to:
  /// **'{name} çocuklarına: {count} eşit parça'**
  String splitEqualToChildren(String name, int count);

  /// No description provided for @splitEqualCount.
  ///
  /// In tr, this message translates to:
  /// **'Parça sayısı'**
  String get splitEqualCount;

  /// No description provided for @splitEqualByCount.
  ///
  /// In tr, this message translates to:
  /// **'Sayıya göre eşit parça (sahipler aynı kalır)'**
  String get splitEqualByCount;

  /// No description provided for @splitEqualAngle.
  ///
  /// In tr, this message translates to:
  /// **'Bölme yönü: {degrees}°'**
  String splitEqualAngle(int degrees);

  /// No description provided for @splitEqualAngleHint.
  ///
  /// In tr, this message translates to:
  /// **'Bölme çizgilerinin pusula açısı: 0° kuzey–güney, 90° doğu–batı. Önizlemedeki numaralar parçaların veriliş sırasıdır.'**
  String get splitEqualAngleHint;

  /// No description provided for @splitEqualAngleLess.
  ///
  /// In tr, this message translates to:
  /// **'1° sola çevir'**
  String get splitEqualAngleLess;

  /// No description provided for @splitEqualAngleMore.
  ///
  /// In tr, this message translates to:
  /// **'1° sağa çevir'**
  String get splitEqualAngleMore;

  /// No description provided for @mergeButton.
  ///
  /// In tr, this message translates to:
  /// **'Geri birleştir'**
  String get mergeButton;

  /// No description provided for @mergeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Parçaları birleştir'**
  String get mergeTitle;

  /// No description provided for @mergePick.
  ///
  /// In tr, this message translates to:
  /// **'Birleştirilecek komşu parçalara dokunun; tekrar dokunmak çıkarır.'**
  String get mergePick;

  /// No description provided for @mergeReady.
  ///
  /// In tr, this message translates to:
  /// **'{count} parça birleşiyor: {area}'**
  String mergeReady(int count, String area);

  /// No description provided for @mergeConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Birleştir'**
  String get mergeConfirm;

  /// No description provided for @mergeOwnerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Birleşen parsel kimin?'**
  String get mergeOwnerTitle;

  /// No description provided for @mergeOwnerHint.
  ///
  /// In tr, this message translates to:
  /// **'Parça sahiplerinin ortak atası önerilir. Soyağacında yukarı çıkabilir ya da başka birini seçebilirsiniz. Birleşen parçalar silinmez, arşivlenir; işlem geri alınabilir.'**
  String get mergeOwnerHint;

  /// No description provided for @mergeOwnerSuggested.
  ///
  /// In tr, this message translates to:
  /// **'Sahiplerin ortak atası'**
  String get mergeOwnerSuggested;

  /// No description provided for @mergeOwnerUp.
  ///
  /// In tr, this message translates to:
  /// **'Üst soya çık'**
  String get mergeOwnerUp;

  /// No description provided for @mergeOwnerChoose.
  ///
  /// In tr, this message translates to:
  /// **'Başka birini seç'**
  String get mergeOwnerChoose;

  /// No description provided for @mergeOwnerKeep.
  ///
  /// In tr, this message translates to:
  /// **'Sahipler olduğu gibi kalsın'**
  String get mergeOwnerKeep;

  /// No description provided for @splitEqualNote.
  ///
  /// In tr, this message translates to:
  /// **'Parsel, seçtiğiniz yönde eşit alanlı parçalara bölünür. Sonra her parçanın köşelerini düzeltebilirsiniz.'**
  String get splitEqualNote;

  /// No description provided for @errorDrawingOverlaps.
  ///
  /// In tr, this message translates to:
  /// **'Bu çizim başka bir çizimin üstüne biniyor. Köşeleri komşu sınıra yaklaştırın; kendiliğinden o sınıra oturur.'**
  String get errorDrawingOverlaps;

  /// No description provided for @errorSplitMisses.
  ///
  /// In tr, this message translates to:
  /// **'Parsel bölünemedi. Kesme çizgisini ya da parça sayısını kontrol edin.'**
  String get errorSplitMisses;

  /// No description provided for @errorMergeMisses.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen parçalar birbirine kenardan bitişmiyor, birleştirilemez.'**
  String get errorMergeMisses;

  /// No description provided for @noticeUseApp.
  ///
  /// In tr, this message translates to:
  /// **'Yeni parsel sorgusu web sitesinden yapılamıyor. Sorguyu telefondaki ya da bilgisayardaki Parsel Atlası uygulamasından yapın; sorgulanan parsel burada da hemen görünür.'**
  String get noticeUseApp;

  /// No description provided for @compareAdd.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırmaya ekle'**
  String get compareAdd;

  /// No description provided for @compareRemove.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırmadan çıkar'**
  String get compareRemove;

  /// No description provided for @compareOpen.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştır ({count})'**
  String compareOpen(int count);

  /// No description provided for @compareClear.
  ///
  /// In tr, this message translates to:
  /// **'Listeyi temizle'**
  String get compareClear;

  /// No description provided for @compareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Parsel karşılaştırma'**
  String get compareTitle;

  /// No description provided for @compareByOwner.
  ///
  /// In tr, this message translates to:
  /// **'Sahibe göre'**
  String get compareByOwner;

  /// No description provided for @compareParcels.
  ///
  /// In tr, this message translates to:
  /// **'Parseller'**
  String get compareParcels;

  /// No description provided for @compareReal.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek'**
  String get compareReal;

  /// No description provided for @compareRegistry.
  ///
  /// In tr, this message translates to:
  /// **'Tapu'**
  String get compareRegistry;

  /// No description provided for @compareDifference.
  ///
  /// In tr, this message translates to:
  /// **'Fark'**
  String get compareDifference;

  /// No description provided for @compareTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get compareTotal;

  /// No description provided for @compareEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırılacak parsel yok. Haritada bir parsel seçip \"Karşılaştırmaya ekle\" deyin.'**
  String get compareEmpty;

  /// No description provided for @compareNotDrawn.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek sınırı çizilmemiş'**
  String get compareNotDrawn;

  /// No description provided for @compareNoRegistry.
  ///
  /// In tr, this message translates to:
  /// **'Tapu kaydı yok'**
  String get compareNoRegistry;

  /// No description provided for @redivideButton.
  ///
  /// In tr, this message translates to:
  /// **'Komşuyla tapuya göre böl'**
  String get redivideButton;

  /// No description provided for @redivideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tapuya göre yeniden bölme'**
  String get redivideTitle;

  /// No description provided for @redividePick.
  ///
  /// In tr, this message translates to:
  /// **'Yan taraftaki komşu gerçek sınıra dokunun.'**
  String get redividePick;

  /// No description provided for @redivideNoDeed.
  ///
  /// In tr, this message translates to:
  /// **'İkisinin de tapu kaydı (resmi parseli) olmalı.'**
  String get redivideNoDeed;

  /// No description provided for @redivideSameDeed.
  ///
  /// In tr, this message translates to:
  /// **'İkisi aynı tapuya ait; tapu bunların nasıl bölüneceğini söylemiyor.'**
  String get redivideSameDeed;

  /// No description provided for @redivideNotNeighbours.
  ///
  /// In tr, this message translates to:
  /// **'Bu iki sınır ortak bir kenarı paylaşmıyor.'**
  String get redivideNotNeighbours;

  /// No description provided for @redivideReady.
  ///
  /// In tr, this message translates to:
  /// **'Aradaki çizgi tapu alanlarına göre kaydırıldı. Yeni şekiller haritada.'**
  String get redivideReady;

  /// No description provided for @redividePiece.
  ///
  /// In tr, this message translates to:
  /// **'{name}: {after} (tapu {deed}, şu an {now})'**
  String redividePiece(String name, String after, String deed, String now);

  /// No description provided for @redivideConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Yeni sınırları kaydet'**
  String get redivideConfirm;

  /// No description provided for @redivideSplitDeed.
  ///
  /// In tr, this message translates to:
  /// **'Bu tapulardan biri zaten birkaç gerçek sınıra bölünmüş; tapu alanının tamamı bu sınırın değil.'**
  String get redivideSplitDeed;
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
