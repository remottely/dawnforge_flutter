/// Typography constants for consistent text styling across the application
/// Following Flutter naming conventions for design system constants
///
/// This class centralizes:
/// - Font sizes by hierarchy (Display, Headline, Body, Caption, Small, Tiny)
/// - Font families used throughout the game
/// - Text styling constants for consistency
class TypographyConstants {
  // Private constructor to prevent instantiation
  TypographyConstants._();

  // Font Sizes by Hierarchy
  /// Large titles and main headings (30.0)
  static const double kDisplayFontSize = 30.0;

  /// Section headings and subtitles (24.0)
  static const double kHeadlineFontSize = 24.0;

  /// Normal body text and content (20.0)
  static const double kBodyFontSize = 20.0;

  /// Buttons, captions, and secondary text (16.0)
  static const double kCaptionFontSize = 16.0;

  /// HUD elements and small UI text (14.0)
  static const double kSmallFontSize = 14.0;

  /// Footer, credits, and minimal text (12.0)
  static const double kTinyFontSize = 12.0;

  // Font Families
  /// Primary font family used throughout the game
  static const String kPrimaryFontFamily = 'Normal';
}
