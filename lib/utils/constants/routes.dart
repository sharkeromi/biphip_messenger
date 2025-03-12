import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/view/auth/login/login.dart';
import 'package:biphip_messenger/view/home/homepage.dart';
import 'package:biphip_messenger/view/intro/splash_screen.dart';
import 'package:biphip_messenger/view/message/call_screen.dart';
import 'package:biphip_messenger/view/message/inbox.dart';
import 'package:biphip_messenger/view/message/message_screen.dart';
import 'package:biphip_messenger/view/message/ringing_screen.dart';

const String krSplashScreen = '/splash-screen';
const String krIntroductionScreen = '/introduction-screen';

const String krLogin = '/login';
const String krSavedUserLogin = '/saved-user-login';
const String krRegister = '/register';
const String krSelectBirthday = '/birthday';
const String krSelectGender = '/gender';
const String krSetEmail = '/set-email';
const String krSelectProfession = '/select-profession';
const String krSelectInterest = '/select-interest';
const String krUploadPicture = '/upload-picture';
const String krForgotPassword = '/forgot-password';
const String krResetPass = '/reset-pass';
const String krSetNewPass = '/set-new-pass';
const String krOTP = '/otp-verify';

const String krHome = '/home';
const String krChangePassword = '/change-password';
const String krChangeLanguage = '/change-language';
const String krHomePostDetails = '/home-post-details';
const String krGiftView = "/gift-view";

const String krMenu = '/menu';
const String krProfile = '/profile';
const String krEditBio = '/edit-bio';
const String krEditAboutInfo = '/edit-about-info';
const String krEdit = '/edit';
const String krEditProfile = '/edit-profile';
const String krEditRelationship = '/edit-relationship';
const String krEditBasicInfo = '/edit-basic-info';
const String krPhotoPreview = '/photo-preview';
const String krFriends = '/friends';
const String krAddFriend = '/add-friend';
const String krFamily = '/family';
const String krAddFamily = '/add-family';
const String krPhotos = '/photos';
const String krPhotoDetails = '/photo-details';
const String krViewPhoto = '/view-photo';
const String krVideos = '/videos';
const String krVideoDetails = '/video-details';
const String krSettings = '/settings';
const String krProfileDetails = '/profile-details';
const String krAddLanguage = '/add-language';

const String krCreatePost = '/create-post';
const String krSelectCategory = '/create-post/select-category';
const String krUploadedImageListPage = '/create-post/uploaded-image-list';
const String krAddKid = '/create-post/select-category/add-kid';
//*newly Added for gallery photos and videos
const String krGalleryPhotos = '/gallery-photos';
const String krGalleryVideos = '/gallery-videos';
const String krCreateAlbum = '/create-album';
const String krCreateAlbumLocation = '/create-album-add-location';
const String krCreateAlbumUploadImageList = '/create-album-upload-image-list';
//*Kids
const String krKidsPage = '/kids-page';
const String krEditKidPage = '/edit-kids-page';
const String krAddKidBasicInfo = '/add-kid-basic-info';
const String krAddKidContactInfo = '/add-kid-contact-info';
const String krAddKidSocialLinks = '/add-kid-social-links';
const String krAddKidUploadImage = '/add-kid-upload-image';

//*Quiz
const String krQuizPage = '/quiz-page';
const String krMyQuiz = '/my-quiz';

//*Store
const String krStore = '/store-page';
const String krAddStoreBasicInfo = '/add-store-basic-info';
const String krAddStoreContactInfo = '/add-store-contact-info';
const String krAddStoreSocialLinks = '/add-store-social-links';
const String krAddStoreDocuments = '/add-store-documents';
const String krAddStoreUploadImage = '/add-store-upload-image';
//*Pendent
const String krPendentPage = '/pendent-page';
const String krAllPendent = '/all-pendent';
//*Badges
const String krBadgesStarPage = '/badges-star-page';
const String krAllBadges = '/all-badges';
const String krPurchaseStar = '/purchase-star';
//* Birthday
const String krBirthdayPage = '/birthday-page';

//* Kid profile
const String krKidProfile = '/kid-profile';
const String krEditKidProfile = '/edit-kid-profile';
const String krKidPhotoPreview = '/kid-photo-profile';
const String krKidPhotoView = '/kid-photo-view';
const String krKidEditBio = '/kid-edit-bio';
const String krKidEditAboutInfo = '/kid-edit-about-info';
const String krSelectHobbiesPage = '/select-hobbies-page';
const String krKidEditPage = '/kid-edit-page';
const String krKidEditRelation = '/kid-edit-relation';
const String krKidAddLanguage = '/kid-add-language';
//*Awards
const String krAwardsPage = '/awards-page';
const String krAwardDetailsPage = '/award-details-page';
//* Search
const String krSearchPage = "/search-page";

//*Store profile
const String krStoreProfile = '/store-profile';
const String krEditStoreProfile = '/edit-store-profile';
const String krStoreEditAbout = '/store-edit-about';
const String krEditStorePhoneNumber = '/edit-store-phone-number';
const String krEditStoreEmail = '/edit-store-email';
const String krEditStorePrivacyLink = '/edit-store-privacy-link';
const String krEditStoreQrCode = '/edit-store-qr-code';
const String krEditStoreBIN = '/edit-store-bin';
const String krEditStoreLocation = '/edit-store-location';
const String krEditStoreCategory = '/edit-store-category';
const String krEditStoreSocialLink = '/edit-store-social-link';
const String krEditStorePayment = '/edit-store-payment';
const String krStoreAddLegalDocument = '/store-add-legal-document';
const String krStoreEditBio = '/store-edit-bio';
const String krStoreReview = '/store-review';
const String krStorePhotoPreview = '/store-photo-preview';
const String krStorePhotoView = '/store-photo-view';

//*Selfie
const String krSelfiePage = "/selfie-page";
const String krSelfiePrivacyPage = "/selfie-privacy-page";
const String krSelectPeoplePage = "/select-people-page";
const String krSelfieViewPage = "/selfie-view-page";

//* Messenger
const String krInbox = "/inbox";
//*Marketplace
const String krMarketPlacePage = "/marketplace-page";
const String krMarketPlaceCategoriesPage = "/marketplace-categories-page";
const String krMarketPlaceViewListingPage = "/marketplace-view-listing-page";
const String krMarketPlaceAccount = "/marketplace-account";
const String krMarketPlaceNotification = "/marketplace-notification";
const String krMarketPlaceRecentActivity = "/marketplace-recent-activity";
const String krMarketPlaceBiddingPage = "/marketplace-bidding-page";
const String krMarketPlaceSellingPage = "/marketplace-selling-page";
const String krMarketPlaceYourListingPage = "/marketplace-your-listing-page";
const String krMarketPlaceMarkSoldPage = "/marketplace-mark-sold-page";
const String krMarketPlaceBuyingPage = "/marketplace-buying-page";

//*chat
const String krMessages = "/messages";
const String krCallScreen = '/call-screen';
const String krRingingScreen = '/ringing-screen';

//*Notification
const String krNotificationPage = "/notification-page";

//*Dashboard
const String krDashboardOverview = "/dashboard-overview";
const String krDashboardOverviewContent = "/dashboard-overview-content";
const String krDashboardOverviewAudience = "/dashboard-overview-audience";
const String krDashboardFundTransfer = "/dashboard-fund-transfer";
const String krDashboardFundTransferDetails = "/dashboard-fund-transfer-details";
const String krDashboardSelectPeople = "/dashboard-select-people";
const String krDashboardFundTransferOtp = "/dashboard-fund-transfer-otp";
const String krDashboardDonation = "/dashboard-donation";
const String krDashboardDonatedPost = "/dashboard-donated-post";
const String krDashboardCheckInCalender = "/dashboard-check-in-calender";
const String krDashboardGift = "/dashboard-gift";
const String krDashboardGiftEarned = "/dashboard-gift-earned";
const String krDashboardStar = "/dashboard-star";
const String krDashboardStarHistory = "/dashboard-star-history";
const String krDashboardAward = "/dashboard-award";
const String krDashboardAllAwards = "/dashboard-all-awards";
const String krDashboardPerformance = "/dashboard-performance";
const String krDashboardQuiz = "/dashboard-quiz";
const String krDashboardPayout = "/dashboard-payout";
const String krDshboardPayoutWithdraw = "/dashboard-payout-withdraw";
//* payout settings
const String krPayoutManualLinkBankAccount = "/payout-manual-link-bank-account";
const String krPayoutAddCrypto = "/payout-add-crypto";
const String krPayoutAddDebitCard = "/payout-add-debit-card";
const String krPayoutTaxInfo = "/payout-tax-info";
const String krPayoutPassportVerification = "/payout-passport-verification";
const String krPayoutNidVerification = "/payout-nid-verification";
const String krPayoutStudentIdVerification = "/payout-student-id-verification";
const String krPayoutBankAccountTaxPassportInfoView = "/payout-tax-info-view";
const String krPayoutBusinessInfo = "/payout-business-info";

//* Profile view
const String krProfileView = "/profile-view";
const String krProfileViewAbout = "/profile-view-about";
const String krProfileViewFriend = "/profile-view-friend";
const String krProfileViewFamily = "/profile-view-family";
const String krProfileViewFollower = "/profile-view-follower";
const String krProfileViewCreateReview = "/profile-view-create-review";

//* Settings
const String krProfileDetailsPage = "/profile-details-page";
const String krPasswordAndSecurity = "/password-and-security";
const String krDefaultAudience = "/default-audience";
const String krReactionPreferences = "/reaction-preferences";
const String krDarkMode = "/dark-mode";
const String krLanguageAndRegion = "/language-and-region";
const String krHowPeopleWillFindYou = "/how_people_will_find_you_page.dart";
const String krPostsSettingsPage = "/posts-settings-page";
const String krSelfiesSettingsPage = "/selfies-settings-page";
const String krPollsSettingsPage = "/polls-settings-page";
const String krFollowersSettingsPage = "/followers-settings-page";
const String krBlocking = "/blocking_page.dart";
const String krActivityLog = "/activity_log_page.dart";
const String krTrash = "/trash_archive_page.dart";
const String krArchive = "/trash_archive_page.dart";
const String krNotifications = "/notifications.dart";
const String krProfileAndTaggingSettingsPage = "/profileAndTagging-settings-page";
const String krReviewPostsSettingsPage = "/review-posts-settings-page";
const String krLanguageListRadioPage = "/language-list-page-radio";
const String krLanguageListCheckboxPage = "/language-list-page-checkbox";
const String krSelectCustomAudience = "/select-custom-audience";

List<GetPage<dynamic>>? routes = [
  //* info:: auth screens
  GetPage(name: krLogin, page: () => Login(), transition: Transition.noTransition),
  //* info:: other screens
  GetPage(name: krSplashScreen, page: () => const SplashScreen(), transition: Transition.noTransition),
  //* home
  GetPage(name: krHome, page: () => HomePage(), transition: Transition.noTransition),
  //* Messenger
  GetPage(name: krInbox, page: () => Inbox(), transition: Transition.rightToLeft),
  GetPage(name: krMessages, page: () => MessageScreen(), transition: Transition.noTransition),
  GetPage(name: krRingingScreen, page: () => RingingScreen(), transition: Transition.noTransition),
  GetPage(name: krCallScreen, page: () => CallScreen(), transition: Transition.noTransition),
];
