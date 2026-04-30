import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class ArticlesData extends BaseRemoteData {
  ArticlesData(super.crud);
  Future<dynamic> getArticlesList() => request(url: Api.articlesList);
}

class ArticleDetailData extends BaseRemoteData {
  ArticleDetailData(super.crud);
  Future<dynamic> getArticleDetail(String articleId) =>
      request(url: '${Api.articleDetail}?id=$articleId');
}
