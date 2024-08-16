import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  final String className;
  final bool printCallingFunctionName;
  final bool printCallStack;
  final List<String> exludeLogsFromClasses;
  final String? showOnlyClass;

  SimpleLogPrinter(
      this.className, {
        this.printCallingFunctionName = true,
        this.printCallStack = false,
        this.exludeLogsFromClasses = const [],
        this.showOnlyClass,
      });

  @override
  List<String> log(LogEvent event) {
    var color = _getColor(event.level);
    var emoji = _getEmoji(event.level);
    var methodName = _getMethodName();

    var methodNameSection =
    printCallingFunctionName && methodName != null ? ' | $methodName ' : '';
    var stackLog = event.stackTrace.toString();
    var output =
        '$emoji $className$methodNameSection - ${event.message}${printCallStack ? '\nSTACKTRACE:\n$stackLog' : ''}';

    if (exludeLogsFromClasses
        .any((excludeClass) => className == excludeClass) ||
        (showOnlyClass != null && className != showOnlyClass)) return [];

    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    List<String> result = [];

    for (var line in output.split('\n')) {
      result.addAll(pattern.allMatches(line).map((match) {
        if (kReleaseMode) {
          return match.group(0)!;
        } else {
          return color(match.group(0)!);
        }
      }));
    }

    return result;
  }

  String? _getMethodName() {
    try {
      var currentStack = StackTrace.current;
      var formattedStacktrace = _formatStackTrace(currentStack, 3);

      var realFirstLine = formattedStacktrace
          ?.firstWhere((line) => line.contains(className), orElse: () => "");

      var methodName = realFirstLine?.replaceAll('$className.', '');
      return methodName;
    } catch (e) {
      // There's no deliberate function call from our code so we return null;
      return null;
    }
  }

  AnsiColor _getColor(Level level) {
    switch (level) {
      case Level.verbose:
        return AnsiColor.fg(AnsiColor.grey(0.5));
      case Level.debug:
        return AnsiColor.fg(AnsiColor.grey(0.75));
      case Level.info:
        return AnsiColor.fg(12); // Light blue
      case Level.warning:
        return AnsiColor.fg(208); // Orange
      case Level.error:
        return AnsiColor.fg(196); // Red
      case Level.wtf:
        return AnsiColor.fg(199); // Pink
      default:
        return AnsiColor.none();
    }
  }

  String _getEmoji(Level level) {
    switch (level) {
      case Level.verbose:
        return '🔍';
      case Level.debug:
        return '🐛';
      case Level.info:
        return '💡';
      case Level.warning:
        return '⚠️';
      case Level.error:
        return '🛑';
      case Level.wtf:
        return '😱';
      default:
        return '';
    }
  }
}

final stackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

List<String>? _formatStackTrace(StackTrace stackTrace, int methodCount) {
  var lines = stackTrace.toString().split('\n');

  var formatted = <String>[];
  var count = 0;
  for (var line in lines) {
    var match = stackTraceRegex.matchAsPrefix(line);
    if (match != null) {
      if (match.group(2)!.startsWith('package:logger')) {
        continue;
      }
      var newLine = "${match.group(1)}";
      formatted.add(newLine.replaceAll('<anonymous closure>', '()'));
      if (++count == methodCount) {
        break;
      }
    } else {
      formatted.add(line);
    }
  }

  if (formatted.isEmpty) {
    return null;
  } else {
    return formatted;
  }
}

class MultipleLoggerOutput extends LogOutput {
  final List<LogOutput> logOutputs;
  MultipleLoggerOutput(this.logOutputs);

  @override
  void output(OutputEvent event) {
    for (var logOutput in logOutputs) {
      try {
        logOutput.output(event);
      } catch (e) {
        print('Log output failed');
      }
    }
  }
}

Logger getLogger(
    String className, {
      bool printCallingFunctionName = true,
      bool printCallstack = false,
      List<String> exludeLogsFromClasses = const [],
      String? showOnlyClass,
    }) {
  return Logger(
    printer: SimpleLogPrinter(
      className,
      printCallingFunctionName: printCallingFunctionName,
      printCallStack: printCallstack,
      showOnlyClass: showOnlyClass,
      exludeLogsFromClasses: exludeLogsFromClasses,
    ),
    output: MultipleLoggerOutput([
      if (!kReleaseMode) ConsoleOutput(),
    ]),
  );
}
