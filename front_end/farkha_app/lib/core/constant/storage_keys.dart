class StorageKeys {
  StorageKeys._();

  // ── Auth ──
  static const String isLoggedIn = 'is_logged_in';
  static const String userName = 'user_name';
  static const String userPhone = 'user_phone';
  static const String phoneVerified = 'phone_verified';

  // ── Onboarding ──
  static const String step = 'step';

  // ── Theme ──
  static const String themeMode = 'theme_mode';

  // ── Cycle ──
  static const String cycles = 'cycles';
  static const String deletedCycles = 'deleted_cycles';
  static const String expensesPrefix = 'expenses_';
  static const String notesPrefix = 'notes_';
  static const String customDataPrefix = 'custom_data_';

  // ── Prices ──
  static const String selectedPriceTypes = 'selected_price_types';
  static const String typeNames = 'type_names';
  static const String notificationEnabledTypes = 'notification_enabled_types';

  // ── Notifications ──
  static const String notificationsEnabled = 'notifications_enabled';
  static const String pendingDarknessAlarm = 'pending_darkness_alarm';

  // ── Darkness Schedule ──
  static const String darknessDayStartHour = 'darkness_day_start_hour';
  static const String darknessAlertMinutesBefore = 'darkness_alert_minutes_before';
  static const String darknessNotificationsEnabled = 'darkness_notifications_enabled';
  static const String darknessPausedEndTime = 'darkness_paused_end_time';
  static const String darknessPhaseReminderHours = 'darkness_phase_reminder_hours';
  static const String darknessPhaseReminderMinutes = 'darkness_phase_reminder_minutes';
  static const String darknessAlarmShownPrefix = 'darkness_alarm_shown_';
  static const String darknessPhasesDonePrefix = 'darkness_phases_done_';
  static const String darknessSuggestionShown = 'darkness_suggestion_shown';

  // ── Location ──
  static const String locationEnabled = 'location_enabled';

  // ── Tools ──
  static const String favoriteToolsOrder = 'favorite_tools_order';

  // ── Permissions Intro ──
  static const String permissionsIntroLocationShown = 'permissions_intro_location_shown';
  static const String permissionsIntroNotificationShown = 'permissions_intro_notification_shown';
  static const String permissionsIntroThemeShown = 'permissions_intro_theme_shown';

  // ── Tutorials ──
  static const String homeTutorialSeen = 'home_tutorial_seen';
  static const String feasibilityTutorialSeen = 'feasibility_tutorial_seen';
  static const String customizePricesTutorialSeen = 'customize_prices_tutorial_seen';

  // ── Usage Tips ──
  static const String feasibilityStudyDialog = 'feasibilityStudyDialog';
  static const String chickenDensityDialog = 'chickenDensityDialog';

  // ── App Review ──
  static const String firstLaunchAt = 'first_launch_at';
  static const String lastActiveDate = 'last_active_date';
  static const String uniqueActiveDaysCount = 'unique_active_days_count';
  static const String reviewPromptDismissedAt = 'review_prompt_dismissed_at';

  // ── Cycle Feedback ──
  static const String cycleFbFirstCycleOpen = 'cycle_fb_first_cycle_open';
  static const String cycleFbLastShown = 'cycle_fb_last_shown';
  static const String cycleFbOpensSinceLast = 'cycle_fb_opens_since_last';

  // ── Phone Verification ──
  static const String phoneCooldownUntilMs = 'phone_cooldown_until_ms';
  static const String phoneCooldownPhone = 'phone_cooldown_phone';
}
