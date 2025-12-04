import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Love Kitchen'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @unbindPartner.
  ///
  /// In en, this message translates to:
  /// **'Unbind Partner'**
  String get unbindPartner;

  /// No description provided for @chef.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get chef;

  /// No description provided for @foodie.
  ///
  /// In en, this message translates to:
  /// **'Foodie'**
  String get foodie;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @moments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get moments;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nLove Kitchen'**
  String get welcome;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccount;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @todaysSpecial.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Special'**
  String get todaysSpecial;

  /// No description provided for @noDishes.
  ///
  /// In en, this message translates to:
  /// **'Chef hasn\'t added any dishes yet!'**
  String get noDishes;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @intimacy.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get intimacy;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders here'**
  String get noOrders;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get whoAreYou;

  /// No description provided for @enterNickname.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname'**
  String get enterNickname;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLength;

  /// No description provided for @chefSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I cook with love'**
  String get chefSubtitle;

  /// No description provided for @foodieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I eat with joy'**
  String get foodieSubtitle;

  /// No description provided for @startKitchen.
  ///
  /// In en, this message translates to:
  /// **'Start My Kitchen'**
  String get startKitchen;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get selectRole;

  /// No description provided for @connectPartner.
  ///
  /// In en, this message translates to:
  /// **'Connect Partner'**
  String get connectPartner;

  /// No description provided for @yourCode.
  ///
  /// In en, this message translates to:
  /// **'Your Invitation Code'**
  String get yourCode;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code with your Foodie to connect!'**
  String get shareCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Invitation Code'**
  String get enterCode;

  /// No description provided for @enterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code from Chef'**
  String get enterCodeHint;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected with your partner! ❤️'**
  String get connected;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Invalid code or connection failed.'**
  String get connectionFailed;

  /// No description provided for @postComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Post feature coming soon!'**
  String get postComingSoon;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @menuManagement.
  ///
  /// In en, this message translates to:
  /// **'Menu Management'**
  String get menuManagement;

  /// No description provided for @foodieStatus.
  ///
  /// In en, this message translates to:
  /// **'Foodie Status'**
  String get foodieStatus;

  /// No description provided for @hungry.
  ///
  /// In en, this message translates to:
  /// **'Hungry'**
  String get hungry;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @addNewDish.
  ///
  /// In en, this message translates to:
  /// **'Add New Dish'**
  String get addNewDish;

  /// No description provided for @tapToAddImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get tapToAddImage;

  /// No description provided for @dishName.
  ///
  /// In en, this message translates to:
  /// **'Dish Name'**
  String get dishName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @intimacyPrice.
  ///
  /// In en, this message translates to:
  /// **'Intimacy Price'**
  String get intimacyPrice;

  /// No description provided for @addToMenu.
  ///
  /// In en, this message translates to:
  /// **'Add to Menu'**
  String get addToMenu;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @addLove.
  ///
  /// In en, this message translates to:
  /// **'Add Love'**
  String get addLove;

  /// No description provided for @reduceLove.
  ///
  /// In en, this message translates to:
  /// **'Reduce Love'**
  String get reduceLove;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @penalty.
  ///
  /// In en, this message translates to:
  /// **'Penalty'**
  String get penalty;

  /// No description provided for @intimacyCenter.
  ///
  /// In en, this message translates to:
  /// **'Intimacy Center'**
  String get intimacyCenter;

  /// No description provided for @currentIntimacy.
  ///
  /// In en, this message translates to:
  /// **'Current Intimacy'**
  String get currentIntimacy;

  /// No description provided for @add10.
  ///
  /// In en, this message translates to:
  /// **'Add 10'**
  String get add10;

  /// No description provided for @reduce5.
  ///
  /// In en, this message translates to:
  /// **'Reduce 5'**
  String get reduce5;

  /// No description provided for @startDeliciousMoments.
  ///
  /// In en, this message translates to:
  /// **'Start Delicious Moments Together'**
  String get startDeliciousMoments;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email / Phone Number'**
  String get emailOrPhone;

  /// No description provided for @enterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number'**
  String get enterEmailOrPhone;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get orLoginWith;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account? Register now'**
  String get noAccountRegister;

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found'**
  String get recipeNotFound;

  /// No description provided for @intimacyBalance.
  ///
  /// In en, this message translates to:
  /// **'Intimacy Balance'**
  String get intimacyBalance;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @washDishes.
  ///
  /// In en, this message translates to:
  /// **'Wash Dishes'**
  String get washDishes;

  /// No description provided for @dishWashingDiscount.
  ///
  /// In en, this message translates to:
  /// **'Dish Washing Discount (-20%)'**
  String get dishWashingDiscount;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient intimacy balance'**
  String get insufficientBalance;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @checkoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get checkoutSuccess;

  /// No description provided for @itemsInCart.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsInCart(int count);

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Task Description'**
  String get taskDescription;

  /// No description provided for @rewardPoints.
  ///
  /// In en, this message translates to:
  /// **'Reward Points'**
  String get rewardPoints;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @coupleTasks.
  ///
  /// In en, this message translates to:
  /// **'Couple Tasks'**
  String get coupleTasks;

  /// No description provided for @taskMarket.
  ///
  /// In en, this message translates to:
  /// **'Task Market'**
  String get taskMarket;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @noCoupleFound.
  ///
  /// In en, this message translates to:
  /// **'No couple connection found'**
  String get noCoupleFound;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks available yet'**
  String get noTasksYet;

  /// No description provided for @noActiveTasks.
  ///
  /// In en, this message translates to:
  /// **'No active tasks'**
  String get noActiveTasks;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
