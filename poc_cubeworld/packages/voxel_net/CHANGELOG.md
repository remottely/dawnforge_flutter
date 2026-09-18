# Changelog

## 0.0.0

First version, not published.

- `NetHost`: a TCP host that numbers clients and broadcasts.
- `NetConnection`: newline-delimited JSON messages, by listener or one at a time.
- `connectToHost` for clients.
- The host closes its end of a client's socket when the client leaves.
