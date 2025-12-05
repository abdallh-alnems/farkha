import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class ArticlesData {
  Crud crud;
  ArticlesData(this.crud);
  Future<Object> getArticlesList() async {
    var response = await crud.postData(Api.articlesList, {});
    return response.fold((l) => l, (r) => r);
  }
}

class ArticleDetailData {
  Crud crud;
  ArticleDetailData(this.crud);
  Future<Object> getArticleDetail(String articleId) async {
    final urlWithId = '${Api.articleDetail}?id=$articleId';
    var response = await crud.postData(urlWithId, {});
    return response.fold((l) => l, (r) => r);
  }
}
