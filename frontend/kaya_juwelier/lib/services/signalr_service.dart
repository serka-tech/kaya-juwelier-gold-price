import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/models/gold_price_model.dart';
import 'package:kaya_juwelier/models/market_model.dart';

enum ConnectionStatus { connecting, live, reconnecting, demo, error }

class SignalRService {
  HubConnection? _connection;
  Timer? _reconnectTimer;
  Timer? _pollTimer;
  bool _disposed = false;
  DateTime? _lastReceived;

  final _priceController  = StreamController<GoldPriceModel>.broadcast();
  final _marketController = StreamController<MarketModel>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  Stream<GoldPriceModel>   get priceStream  => _priceController.stream;
  Stream<MarketModel>      get marketStream => _marketController.stream;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  Future<void> connect() async {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _statusController.add(ConnectionStatus.connecting);

    try {
      final msgHeaders = MessageHeaders();
      msgHeaders.setHeaderValue('ngrok-skip-browser-warning', 'true');

      _connection = HubConnectionBuilder()
          .withUrl(
            AppConstants.signalRHubUrl,
            options: HttpConnectionOptions(headers: msgHeaders),
          )
          .withAutomaticReconnect(retryDelays: AppConstants.reconnectDelays)
          .build();

      // Gold price handler
      _connection!.on('ReceiveGoldPrice', (args) {
        if (args == null || args.isEmpty) return;
        try {
          final dto = GoldPriceModel.fromJson(
              Map<String, dynamic>.from(args[0] as Map));
          _lastReceived = DateTime.now();
          _priceController.add(dto);
          _statusController.add(dto.isDemo ? ConnectionStatus.demo : ConnectionStatus.live);
        } catch (e) { debugPrint('[SignalR] Gold parse error: $e'); }
      });

      // Market prices handler
      _connection!.on('ReceiveMarketPrices', (args) {
        if (args == null || args.isEmpty) return;
        try {
          final dto = MarketModel.fromJson(
              Map<String, dynamic>.from(args[0] as Map));
          _marketController.add(dto);
        } catch (e) { debugPrint('[SignalR] Market parse error: $e'); }
      });

      _connection!.onreconnecting(({error}) {
        debugPrint('[SignalR] Reconnecting... $error');
        _statusController.add(ConnectionStatus.reconnecting);
      });

      _connection!.onreconnected(({connectionId}) {
        debugPrint('[SignalR] Reconnected: $connectionId');
        _statusController.add(ConnectionStatus.live);
        _connection!.invoke('GetCurrentPrice');
        _connection!.invoke('GetCurrentMarket');
      });

      _connection!.onclose(({error}) {
        debugPrint('[SignalR] Connection closed. $error');
        _statusController.add(ConnectionStatus.error);
        _scheduleReconnect();
      });

      await _connection!.start();
      debugPrint('[SignalR] Connected to ${AppConstants.signalRHubUrl}');
      await _connection!.invoke('GetCurrentPrice');
      await _connection!.invoke('GetCurrentMarket');

      _startFallbackPoller();
    } catch (e) {
      debugPrint('[SignalR] Connection failed: $e');
      _statusController.add(ConnectionStatus.error);
      await _fetchViaRest();
      await _fetchMarketViaRest();
      _scheduleReconnect();
    }
  }

  void _startFallbackPoller() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final last = _lastReceived;
      if (last == null || DateTime.now().difference(last).inSeconds > 10) {
        await _fetchViaRest();
        await _fetchMarketViaRest();
      }
    });
  }

  Future<void> _fetchViaRest() async {
    try {
      final res = await http
          .get(Uri.parse(AppConstants.currentPriceUrl),
              headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final dto = GoldPriceModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
        _lastReceived = DateTime.now();
        _priceController.add(dto);
        _statusController.add(dto.isDemo ? ConnectionStatus.demo : ConnectionStatus.live);
      }
    } catch (e) { debugPrint('[REST] Gold fallback failed: $e'); }
  }

  Future<void> _fetchMarketViaRest() async {
    try {
      final res = await http
          .get(Uri.parse(AppConstants.marketUrl),
              headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final dto = MarketModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
        _marketController.add(dto);
      }
    } catch (e) { debugPrint('[REST] Market fallback failed: $e'); }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_disposed) connect();
    });
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _pollTimer?.cancel();
    try { await _connection?.stop(); } catch (_) {}
    await _priceController.close();
    await _marketController.close();
    await _statusController.close();
  }
}
