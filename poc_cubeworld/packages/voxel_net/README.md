# voxel_net

The network layer for voxel games: one host and its clients over TCP,
sending JSON messages, one per line. Pure Dart (`dart:io`). `voxel_game`
uses it to host and join worlds.

> **Status: 0.0.0.** The API can still change. Not published yet.

## Features

- `NetHost`: listens on a port, numbers each client (the host is 1, clients start at 2), `broadcast`s.
- `NetConnection`: `send`, `next` (wait for one message) or `listen` (every message, in order).
- `connectToHost(address)`: a client's connection.
- A message is a `Map<String, Object?>` whose `t` names its type.

## Install

`voxel_net` is at 0.0.0 and not on pub.dev yet. Depend on it by path (or by git):

```yaml
dependencies:
  voxel_net:
    path: ../packages/voxel_net
```

Dart SDK `^3.13.0`.

On macOS, a Flutter app needs the `com.apple.security.network.server` and
`com.apple.security.network.client` entitlements.

## Usage

1. **Host.**

   ```dart
   final host = await NetHost.bind(port: 7777);
   host
     ..onJoin = ((peer) => print('player ${peer.id} joined'))
     ..onMessage = ((peer, message) => host.broadcast(message, except: peer.id))
     ..onLeave = ((peer) => print('player ${peer.id} left'));
   ```

2. **Join** from another app or machine.

   ```dart
   final client = await connectToHost('192.168.0.10', port: 7777);
   ```

3. **Talk.** Messages are JSON objects; `t` says what they are.

   ```dart
   client.send({'t': 'pose', 'p': [12.5, 64.0, -3.0]});
   client.listen((message) => print(message['t']));
   ```

4. **Leave.** `await client.close();` The host's `onLeave` runs, and
   `await host.close();` drops everyone.

## Example

```sh
dart run example/voxel_net_example.dart
```

[`example/voxel_net_example.dart`](example/voxel_net_example.dart) runs a host
and a client in one process over localhost.
