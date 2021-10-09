import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/screens.dart';
import 'app_link.dart';

class AppRouter extends RouterDelegate<AppLink>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppStateManager appStateManager;
  final GroceryManager groceryManager;
  final ProfileManager profileManager;

  AppRouter({
    required this.appStateManager,
    required this.groceryManager,
    required this.profileManager,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    // Determines the state of the app. It manages whether the app initialized login and if the user completed the onboarding.
    appStateManager.addListener(notifyListeners);
    groceryManager.addListener(notifyListeners);
    profileManager.addListener(notifyListeners);
  }

  @override
  void dispose() {
    appStateManager.removeListener(notifyListeners);
    groceryManager.removeListener(notifyListeners);
    profileManager.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _handlePopPage,
      pages: [
        if (!appStateManager.isInitialized) SplashScreen.page(),
        if (appStateManager.isInitialized && !appStateManager.isLoggedIn)
          LoginScreen.page(),
        if (appStateManager.isLoggedIn && !appStateManager.isOnboardingComplete)
          OnboardingScreen.page(),
        if (appStateManager.isOnboardingComplete)
          Home.page(appStateManager.getSelectedTab),
        if (groceryManager.isCreatingNewItem)
          GroceryItemScreen.page(
            onCreate: (item) {
              groceryManager.addItem(item);
            },
            onUpdate: (item, index) {
              // No update
            },
          ),
        if (groceryManager.selectedIndex != -1)
          GroceryItemScreen.page(
            item: groceryManager.selectedGroceryItem,
            index: groceryManager.selectedIndex,
            onUpdate: (item, index) {
              groceryManager.updateItem(item, index);
            },
            onCreate: (_) {
              // No create
            },
          ),
        if (profileManager.didSelectUser)
          ProfileScreen.page(
            profileManager.getUser,
          ),
        if (profileManager.didTapOnRaywenderlich) WebViewScreen.page(),
      ],
    );
  }

// When the user taps the Back button or triggers a system back button event, it fires a helper method, onPopPage.
  bool _handlePopPage(Route<dynamic> route, result) {
    if (!route.didPop(result)) {
      return false;
    }

    if (route.settings.name == FooderlichPages.onboardingPath) {
      appStateManager.logout();
    }

    if (route.settings.name == FooderlichPages.groceryItemDetails) {
      groceryManager.groceryItemTapped(-1);
      // ensures that the appropriate state is reset when the user taps the back button from the Grocery Item screen.
    }
    if (route.settings.name == FooderlichPages.profilePath) {
      profileManager.tapOnProfile(false);
    }
    if (route.settings.name == FooderlichPages.raywenderlich) {
      profileManager.tapOnRaywenderlich(false);
    }

    return true;
  }

  AppLink getCurrentPath() {
    // converts the app state to an AppLink object.
    if (!appStateManager.isLoggedIn) {
      return AppLink(location: AppLink.kLoginPath);
    } else if (!appStateManager.isOnboardingComplete) {
      return AppLink(location: AppLink.kOnboardingPath);
    } else if (profileManager.didSelectUser) {
      return AppLink(location: AppLink.kProfilePath);
    } else if (groceryManager.isCreatingNewItem) {
      return AppLink(location: AppLink.kItemPath);
    } else if (groceryManager.selectedGroceryItem != null) {
      final id = groceryManager.selectedGroceryItem?.id;
      return AppLink(location: AppLink.kItemPath, itemId: id);
    } else {
      return AppLink(
          location: AppLink.kHomePath,
          currentTab: appStateManager.getSelectedTab);
    }
  }

  @override
  AppLink get currentConfiguration => getCurrentPath();

  @override
  Future<void> setNewRoutePath(AppLink newLink) async {
    //convert app link to app state
    switch (newLink.location) {
      case AppLink.kProfilePath:
        profileManager.tapOnProfile(true);
        break;
      case AppLink.kItemPath:
        final itemId = newLink.itemId;
        if (itemId != null) {
          groceryManager.setSelectedGroceryItem(itemId);
        } else {
          groceryManager.createNewItem();
        }
        profileManager.tapOnProfile(false);
        break;
      case AppLink.kHomePath:
        appStateManager.goToTab(newLink.currentTab ?? 0);
        profileManager.tapOnProfile(false);
        groceryManager.groceryItemTapped(-1);
        break;
      default: //If the location does not exist, do nothing.
        break;
    }
  }
  //for flutter web
}
