import 'package:serverpod/serverpod.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

// TODO: !!! CORS 방지 처리 필요(upbit, bybit, 환율 도메인)

// This is the starting point of your Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // Start the server.
  await pod.start();
}
