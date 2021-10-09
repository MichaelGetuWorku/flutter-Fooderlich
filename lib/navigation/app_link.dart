class AppLink {
  //The objective of this class is to parse the navigation configuration to and from a URL string.
  static const String kHomePath = '/home';
  static const String kOnboardingPath = '/onboarding';
  static const String kLoginPath = '/login';
  static const String kProfilePath = '/profile';
  static const String kItemPath = '/item';
  // parameters /home/tab or /id=2
  static const String kTabParam = 'tab';
  static const String kIdParam = 'id';
  // Store the path of the URL using location.
  String? location;
  // Use currentTab to store the tab you want to redirect the user to.
  int? currentTab;
  // Store the ID of the item you want to view in itemId.
  String? itemId;
  // Initialize the app link with the location and the two query parameters
  AppLink({
    this.location,
    this.currentTab,
    this.itemId,
  });

  static AppLink fromLocation(String? location) {
    ///  converts a URL string to an AppLink
    location = Uri.decodeFull(location ?? '');
    final uri = Uri.parse(location);
    final params = uri.queryParameters;
    //Extract the currentTab from the URL path if it exists.
    final currentTab = int.tryParse(params[AppLink.kTabParam] ?? '');
    // Extract the itemId
    final itemId = params[AppLink.kIdParam];
    // 5
    final link = AppLink(
      location: uri.path,
      currentTab: currentTab,
      itemId: itemId,
    );
    return link;
  }

  String toLocation() {
    /// converts AppLink back to a URI string
    String addKeyValPair({
      required String key,
      String? value,
    }) =>
        value == null ? '' : '$key=$value&';
    switch (location) {
      case kLoginPath:
        return kLoginPath;
      case kOnboardingPath:
        return kOnboardingPath;
      case kProfilePath:
        return kProfilePath;
      // If the path is kItemPath, return the right string path: /item, and if there are any parameters, append ?id=${id}.
      case kItemPath:
        var loc = '$kItemPath?';
        loc += addKeyValPair(
          key: kIdParam,
          value: itemId,
        );
        return Uri.encodeFull(loc);
      // If the path is invalid, default to the path /home. If the user selected a tab, append ?tab=${tabIndex}.
      default:
        var loc = '$kHomePath?';
        loc += addKeyValPair(
          key: kTabParam,
          value: currentTab.toString(),
        );
        return Uri.encodeFull(loc);
    }
  }
}
