// Copyright 2023 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:js_interop';
import 'package:web/helpers.dart' as html;
import 'package:web/web.dart';
import 'dart:typed_data';

import '../../extensions.dart';
import '../../logger.dart';
import '../websocket.dart';

// ignore: avoid_web_libraries_in_flutter

Future<LiveKitWebSocketWeb> lkWebSocketConnect(
  Uri uri, [
  WebSocketEventHandlers? options,
]) =>
    LiveKitWebSocketWeb.connect(uri, options);

class LiveKitWebSocketWeb extends LiveKitWebSocket {
  final html.WebSocket _ws;
  final WebSocketEventHandlers? options;

  LiveKitWebSocketWeb._(
    this._ws, [
    this.options,
  ]) {
    _ws.binaryType = 'arraybuffer';
    _ws.onmessage = (html.MessageEvent event) {
      if (isDisposed) {
        logger.warning('$objectId already disposed, ignoring received data.');
        return;
      }
      print(
          'received data: ${event.data}, ${event.data.runtimeType}, JSArrayBuffer: ${event.data is JSArrayBuffer}');
      dynamic data = event.data is JSArrayBuffer
          ? (event.data as JSArrayBuffer).toDart.asUint8List()
          : event.data;
      options?.onData?.call(data);
    }.toJS;
    _ws.onclose = (html.CloseEvent _) async {
      options?.onDispose?.call();
    }.toJS;

    onDispose(() async {
      if (_ws.readyState != html.WebSocket.CLOSED) {
        _ws.close();
      }
    });
  }

  @override
  void send(List<int> data) => _ws.send(data.jsify()!);

  static Future<LiveKitWebSocketWeb> connect(
    Uri uri, [
    WebSocketEventHandlers? options,
  ]) async {
    final completer = Completer<LiveKitWebSocketWeb>();
    final ws = html.WebSocket(uri.toString());
    ws.onopen = ((html.Event _) =>
        completer.complete(LiveKitWebSocketWeb._(ws, options))).toJS;
    ws.onerror = ((html.Event _) =>
        completer.completeError(WebSocketException.connect())).toJS;
    final response = await completer.future;
    return response;
  }
}
