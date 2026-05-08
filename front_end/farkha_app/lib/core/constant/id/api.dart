import '../../services/environment_service.dart';

class Api {
  static final String _serverName = EnvService.linkServerName;

  // ============================ paths roots ==============================
  static final String _prices = '$_serverName/app/prices';
  static final String _cardPrices = '$_prices/card_prices';
  static final String _articles = '$_serverName/app/articles';
  static final String _tools = '$_serverName/app/tools';
  static final String _auth = '$_serverName/app/auth';
  static final String _cycle = '$_serverName/app/cycles';
  static final String _cycleNotes = '$_cycle/notes';

  // ================================= prices ==================================
  static String mainTypes = '$_prices/main_types.php';
  static String pricesByType = '$_prices/by_type.php';
  static String priceHistory = '$_prices/history.php';
  static String broilerChicken = '$_prices/broiler_latest.php';

  // ! card prices
  static String pricesCard = '$_cardPrices/cards.php';
  static String types = '$_cardPrices/types.php';

  // ================================== tools ==================================
  static String feasibilityStudy = '$_tools/feasibility_study.php';

  // ================================ articles =================================
  static String articleDetail = '$_articles/detail.php';
  static String articlesList = '$_articles/list.php';

  // ============================== app reviews ================================
  static final String _appReviews = '$_serverName/app/app_reviews';
  static String upsertAppReview = '$_appReviews/upsert_review.php';

  // ============================ cycle feedbacks =============================
  static final String _cycleFeedbacks = '$_serverName/app/cycle_feedbacks';
  static String submitCycleFeedback = '$_cycleFeedbacks/submit_feedback.php';

  // =============================== analytics ================================
  static final String _analytics = '$_serverName/analytics';
  static String recordToolsUsage = '$_analytics/record_tools_usage.php';

  // ============================== authentication =============================
  static String login = '$_auth/login.php';
  static String updateName = '$_auth/update_name.php';
  static String updatePhone = '$_auth/update_phone.php';
  static String updateFcmToken = '$_auth/update_fcm_token.php';
  static String deleteAccount = '$_auth/delete_account.php';
  static String sendOtp = '$_auth/send_otp.php';
  static String verifyOtp = '$_auth/verify_otp.php';
  static String resendOtp = '$_auth/resend_otp.php';
  static String phoneVerificationStatus = '$_auth/phone_verification_status.php';

  // ================================== cycle ==================================
  static String createCycle = '$_cycle/create.php';
  static String deleteCycle = '$_cycle/delete.php';
  static String leaveCycle = '$_cycle/leave_cycle.php';
  static String addData = '$_cycle/add_data.php';
  static String addExpense = '$_cycle/add_expense.php';
  static String addSale = '$_cycle/add_sale.php';
  static String getCycles = '$_cycle/get_cycles.php';
  static String getCycleDetails = '$_cycle/get_cycle_details.php';
  static String updateCycle = '$_cycle/update_cycle.php';
  static String deleteCycleItem = '$_cycle/delete_cycle_item.php';
  static String updateStatus = '$_cycle/update_status.php';
  static String getHistory = '$_cycle/get_history.php';
  static String addMember = '$_cycle/add_member.php';
  static String createInvitation = '$_cycle/create_invitation.php';
  static String joinByCode = '$_cycle/join_by_code.php';
  static String searchUsers = '$_cycle/search_users.php';
  static String removeMember = '$_cycle/remove_member.php';
  static String updateMemberRole = '$_cycle/update_member_role.php';

  // !! notes
  static String addNote = '$_cycleNotes/add_note.php';
  static String getNotes = '$_cycleNotes/get_notes.php';
  static String deleteNote = '$_cycleNotes/delete_note.php';
  static String updateNote = '$_cycleNotes/update_note.php';

  // !! invitations
  static String getInvitations = '$_cycle/get_my_invitations.php';
  static String respondToInvitation = '$_cycle/respond_to_invitation.php';
}
