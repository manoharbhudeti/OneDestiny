import 'dart:async';
import 'package:flutter/foundation.dart';

/// Centralized bus for application-wide network and authentication state notifications.
class NetworkStateHandler {
  NetworkStateHandler._();
  static final NetworkStateHandler instance = NetworkStateHandler._();

  final _sessionExpiredController = StreamController<void>.broadcast();
  final _connectivityController = StreamController<bool>.broadcast();
  final _slowNetworkController = StreamController<bool>.broadcast();

  bool _isSessionExpiredTriggered = false;
  bool _isOnline = true;
  bool _isSlowNetwork = false;

  /// Stream of 401 session expiration events.
  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  /// Stream of connectivity state changes (true = online, false = offline).
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Stream of slow network flags (true = delayed request in flight).
  Stream<bool> get slowNetworkStream => _slowNetworkController.stream;

  bool get isOnline => _isOnline;
  bool get isSlowNetwork => _isSlowNetwork;
  bool get isSessionExpiredTriggered => _isSessionExpiredTriggered;

  /// Broadcasts a 401 session expiration event with debouncing to prevent multiple dialogs.
  void notifySessionExpired() {
    if (_isSessionExpiredTriggered) return;
    _isSessionExpiredTriggered = true;
    debugPrint('[NetworkStateHandler] Session expired detected. Broadcasting.');
    _sessionExpiredController.add(null);
  }

  /// Resets the session expiration guard when the user re-authenticates.
  void resetSessionExpiredGuard() {
    _isSessionExpiredTriggered = false;
  }

  /// Updates online/offline status and notifies listeners if state changed.
  void setConnectivity(bool online) {
    if (_isOnline == online) return;
    _isOnline = online;
    _connectivityController.add(online);
  }

  /// Sets whether a request is currently experiencing significant latency.
  void setSlowNetwork(bool slow) {
    if (_isSlowNetwork == slow) return;
    _isSlowNetwork = slow;
    _slowNetworkController.add(slow);
  }

  void dispose() {
    _sessionExpiredController.close();
    _connectivityController.close();
    _slowNetworkController.close();
  }
}
