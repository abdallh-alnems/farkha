import '../../../core/class/crud.dart';
import '../../../core/constant/id/link_api.dart';

class SuggestionData {
  Crud crud;
  SuggestionData(this.crud);
  addSuggestion(String suggestionText) async {
    var response = await crud
        .postData(ApiLinks.linkSuggestion, {"suggestion": suggestionText});
    return response.fold((l) => l, (r) => r);
  }
}
