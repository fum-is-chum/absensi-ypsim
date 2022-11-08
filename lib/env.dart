enum BuildFlavor { production, staging }

class Environment {
  Environment._sharedInstance();
  static final Environment _shared = Environment._sharedInstance();
  factory Environment() => _shared;

  static late String _baseUrl;
  static late BuildFlavor _flavor;

  static get baseUrl => _baseUrl;
  static get flavor => _flavor;
  
  static void init({required BuildFlavor flavor}) {
    _flavor = flavor;
    if(_flavor == BuildFlavor.staging) {
      _baseUrl = 'https://staging-presensi.ypsimlibrary.com';
    } else if(_flavor == BuildFlavor.production) {
      _baseUrl = 'https://presensi.ypsimlibrary.com';
    }
  }
}