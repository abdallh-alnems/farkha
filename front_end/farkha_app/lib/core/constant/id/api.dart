import '../../services/env.dart';

class Api {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================ API MAIN =================================
  static final String _read = '$_serverName/app/read';
  static final String _cardPrices = '$_read/card_prices';
  static final String _articles = '$_read/articles';
  static final String _auth = '$_serverName/app/auth';
  static final String _cycle = '$_serverName/app/cycles';
  static final String _cycleNotes = '$_cycle/notes';

  // ================================= prices ==================================
  static String mainTypes = '$_read/main_types.php';
  static String pricesByType = '$_read/prices_by_type.php';
  static String priceHistory = '$_read/price_history.php';

  // ! feasibility study
  static String feasibilityStudy = '$_read/feasibility_study.php';

  // ! card prices
  static String pricesCard = '$_cardPrices/card_prices.php';
  static String types = '$_cardPrices/types.php';

  // =============================== suggestion ================================
  static String suggestion = '$_read/suggestions.php';

  // ============================== app reviews ================================
  static final String _appReviews = '$_serverName/app/app_reviews';
  static String upsertAppReview = '$_appReviews/upsert_review.php';
  static String getMyAppReview = '$_appReviews/get_my_review.php';

  // ================================ articles =================================
  static String articleDetail = '$_articles/article_detail.php';
  static String articlesList = '$_articles/articles_list.php';

  // ============================== authentication =============================
  static String login = '$_auth/login.php';
  static String updateName = '$_auth/update_name.php';
  static String updatePhone = '$_auth/update_phone.php';
  static String updateFcmToken = '$_auth/update_fcm_token.php';
  static String deleteAccount = '$_auth/delete_account.php';

  // ================================== cycle ==================================
  static String broilerChicken = '$_cycle/broiler_chicken.php';
  static String createCycle = '$_cycle/create.php';
  static String deleteCycle = '$_cycle/delete.php';
  static String leaveCycle = '$_cycle/leave_cycle.php';
  static String addData = '$_cycle/add_data.php';
  static String addExpense = '$_cycle/add_expense.php';
  static String addSale = '$_cycle/add_sale.php';
  static String getCycles = '$_cycle/get_cycles.php';
  static String getCycleDetails = '$_cycle/get_cycle_details.php';
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
  static String getInvitations = '$_cycle/get_my_invitations.php';
  static String respondToInvitation = '$_cycle/respond_to_invitation.php';
}
