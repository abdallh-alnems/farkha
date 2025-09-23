import '../../../core/class/crud.dart';
import '../../../core/constant/id/api.dart';

class SuggestionData {
  Crud crud;
  SuggestionData(this.crud);
  Future<Object> addSuggestion(String suggestionText) async {
    var response = await crud.postData(Api.suggestion, {
      "suggestion": suggestionText,
    });
    return response.fold((l) => l, (r) => r);
  }
}
