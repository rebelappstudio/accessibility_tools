/// Log level for the accessibility tools.
///
/// By default it prints all available info about found issues and suggested
/// solutions.
enum LogLevel {
  /// Print found issues and suggested solutions.
  verbose,

  /// Print info about found issues but not resolution guidance.
  warning,

  /// Don't print anything to the logs. Useful when you don't want logs to be
  /// polluted with too many messages (during app development or only using
  /// accessibility tools UI to perform manual checks).
  none,
}
