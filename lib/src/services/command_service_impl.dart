import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:grpc/grpc.dart' as $grpc;
import 'package:moinsen_cli/src/generated/command.pb.dart' as pb;
import 'package:moinsen_cli/src/generated/command.pbgrpc.dart' as pbgrpc;

/// Eine mögliche Implementierung deines gRPC-Services.
/// Wir erben von [pbgrpc.CommandServiceBase] (aus command.pbgrpc.dart).
class CommandServiceImpl extends pbgrpc.CommandServiceBase {
  // Beispiel: globaler Prozess, den wir steuern
  Process? _currentProcess;

  // Ein StreamController, über den wir dem Client Daten schicken.
  // Du könntest das auch rein lokal in [streamCommand] halten,
  // wenn du pro Stream-Session einen eigenen Controller brauchst.
  StreamController<pb.CommandResponse>? _responseController;

  /// Wir überschreiben die Methode [streamCommand], die in CommandServiceBase
  /// definiert ist. Hier findet das bidirektionale Streaming statt.
  @override
  Stream<pb.CommandResponse> streamCommand(
    $grpc.ServiceCall call,
    Stream<pb.CommandRequest> request,
  ) async* {
    // Pro Streaming-Session einen neuen StreamController erzeugen
    _responseController = StreamController<pb.CommandResponse>();

    // Lausche auf eingehende Nachrichten vom Client (CommandRequest).
    request.listen(
      (cmdReq) async {
        final sessionId = cmdReq.sessionId; // aus command.proto => session_id
        final input = cmdReq.inputData; // aus command.proto => input_data
        final isInteractiveAnswer = cmdReq.isInteractiveAnswer;

        // Beispiel: START:someCommand => neuen Prozess starten
        if (input.startsWith('START:') && !isInteractiveAnswer) {
          final commandToRun = input.substring('START:'.length).trim();

          // Falls schon ein Prozess läuft, diesen evtl. beenden
          if (_currentProcess != null) {
            _currentProcess!.kill();
          }

          // Starte einen neuen Prozess
          _currentProcess = await Process.start(
            'bash',
            ['-c', commandToRun],
          );

          // Stdout-Stream abfangen und an den Response-Stream weiterleiten
          _currentProcess!.stdout
              .transform(const SystemEncoding().decoder)
              .transform(const LineSplitter())
              .listen((line) {
            // Nur als einfaches Beispiel:
            //Wir checken, ob die Zeile wie ein Prompt aussieht
            final isPrompt = line.contains('?(y/n)');

            // Schicke den Output an den Client
            _responseController?.add(
              pb.CommandResponse(
                sessionId: sessionId,
                outputData: line,
                isPrompt: isPrompt,
              ),
            );
            // Parallel in die lokale Konsole
            stdout.writeln(line);
          });

          // Stderr-Stream abfangen (Fehlermeldungen)
          _currentProcess!.stderr
              .transform(const SystemEncoding().decoder)
              .transform(const LineSplitter())
              .listen((line) {
            _responseController?.add(
              pb.CommandResponse(
                sessionId: sessionId,
                outputData: '[ERR] $line',
                isPrompt: false,
              ),
            );
            stderr.writeln(line);
          });
        } else if (isInteractiveAnswer && _currentProcess != null) {
          // Wenn es eine Antwort auf einen Prompt ist, an stdin weiterreichen
          _currentProcess!.stdin.writeln(input);
        } else {
          // Evtl. noch andere Kommandos implementieren, z.B. STOP o.ä.
          _responseController?.add(
            pb.CommandResponse(
              sessionId: sessionId,
              outputData: 'Unknown command or no process running.',
              isPrompt: false,
            ),
          );
        }
      },
      onDone: () {
        // Wenn der Client-Stream zu Ende ist
        _responseController?.close();
      },
      onError: (Object e, StackTrace st) {
        // Fehler beim Empfang vom Client
        _responseController?.addError(e, st);
      },
    );

    // Alle Nachrichten, die wir über _responseController senden,
    // geben wir in diesem async*-Generator weiter
    yield* _responseController!.stream;
  }
}