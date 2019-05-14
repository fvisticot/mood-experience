import 'package:flutter_app/user_utils.dart';

enum AuthState{ LOGGED_IN, LOGGED_OUT }

abstract class AuthStateListener {
  void onAuthStateChanged(AuthState state);
}

class AuthStateProvider {
  static final AuthStateProvider _instance = new AuthStateProvider.internal();

  List<AuthStateListener> _subscribers;

  factory AuthStateProvider() => _instance;
  AuthStateProvider.internal() {
    _subscribers = new List<AuthStateListener>();
    initState();
  }

  void initState() async {
    var isLoggedIn = await new UserUtils().isLogged();
    print('isLoggedIn: ${isLoggedIn}');
    if(isLoggedIn=='true')
      notify(AuthState.LOGGED_IN);
    else
      notify(AuthState.LOGGED_OUT);
  }

  void subscribe(AuthStateListener listener) {
    _subscribers.add(listener);
  }

  void dispose(AuthStateListener listener) {
    for(var l in _subscribers) {
      if(l == listener)
        _subscribers.remove(l);
    }
  }

  void notify(AuthState state) {
    print('Notify clients');
    _subscribers.forEach((AuthStateListener s) => s.onAuthStateChanged(state));
  }
}
