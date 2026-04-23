import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/models/gold_price_model.dart';

enum ConnectionStatus { connecting, live, reconnecting, demo, error }

class SignalRService {
  late HubConnection _connection;
  final _priceController = StreamController<GoldPriceModel>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  Stream<GoldPriceModel>    get priceStream  => _priceController.stream;
  Stream<ConnectionStatus>  get statusStream => _statusController.stream;

  Future<void> connect() async {
    _statusController.add(ConnectionStatus.connecting);

    _connection = HubConnectionBuilder()
        .withUrl(AppConstants.signalRHubUrl)
        .withAutomaticReconnect(
          retryDelays: AppConstants.reconnectDelays,
        )
        .build();

    _connection.on('ReceiveGoldPrice', (args) {
      if (args == null || args.isEmpty) return;
      try {
        final dto = GoldPriceModel.fromJson(
          Map<String, dynamic>.from(args[0] as Map),
        );
        _priceController.add(dto);
        _statusController.add(dto.isDemo
            ? ConnectionStatus.demo
            : ConnectionStatus.live);
      } catch (_) {}
    });

    _connection.onreconnecting(({error}) {
      _statusController.add(ConnectionStatus.reconnecting);
    });

    _connection.onreconnected(({connectionId}) {
      _connection.invoke('GetCurrentPrice');
      _statusController.add(ConnectionStatus.live);
    });

    _connection.onclose(({error}) {
      _statusController.add(ConnectionStatus.error);
    });

    try {
      await _connection.start();
      await _connection.invoke('GetCurrentPrice');
    } catch (_) {
      _statusController.add(ConnectionStatus.error);
    }
  }

  Future<void> dispose() async {
    await _connection.stop();
    await _priceController.close();
    await _statusController.close();
  }
}
