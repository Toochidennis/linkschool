import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookAnalyticsService {
  static final FacebookAppEvents facebookAppEvents = FacebookAppEvents();
  
  static Future<void> initialize() async {
    print('Facebook App Events initialized');
  }
  
  static Future<void> logAppLaunch() async {
    await facebookAppEvents.logEvent(name: 'app_launch');
    print('Logged app launch event');
  }
  
  static Future<void> logCustomEvent(String eventName, 
      {Map<String, dynamic>? parameters}) async {
    await facebookAppEvents.logEvent(
      name: eventName,
      parameters: parameters,
    );
    print('Logged custom event: $eventName');
  }
  
  static Future<void> logPurchase({
    required double amount,
    required String currency,
    Map<String, dynamic>? parameters,
  }) async {
    await facebookAppEvents.logPurchase(
      amount: amount,
      currency: currency,
      parameters: parameters,
    );
    print('Logged purchase event: $amount $currency');
  }
  
  static Future<void> setUserData({
    String? email,
    String? phone,
    String? userId,
  }) async {
    Map<String, dynamic> userData = {};
    
    if (email != null) userData['email'] = email;
    if (phone != null) userData['phone'] = phone;
    if (userId != null) userData['external_id'] = userId;
    
    
     await facebookAppEvents.setUserData(
  email: email,
  phone: phone,
);
    
    print('Set user data for Facebook');
  }
}