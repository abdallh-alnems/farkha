<?php

include_once __DIR__ . "/price_queries.php";
include_once __DIR__ . "/type_queries.php";
include_once __DIR__ . "/article_queries.php";
include_once __DIR__ . "/analytics_queries.php";
include_once __DIR__ . "/suggestion_queries.php";

final class Queries {
    public static function getFeasibilityStudyPrices(): string {
        return PriceQueries::fetchFeasibilityStudy();
    }

    public static function getPricesStreamWithTypeFilterQuery(array $typeIds): string {
        return PriceQueries::fetchStream($typeIds);
    }

    public static function getPricesByTypeQuery(): string {
        return PriceQueries::fetchByType();
    }

    public static function getTodayPricesQuery(): string {
        return PriceQueries::fetchToday();
    }

    public static function updatePriceQuery(): string {
        return PriceQueries::updateLatest();
    }

    public static function deletePriceWithValidationQuery(): string {
        return PriceQueries::deleteLatestWithValidation();
    }

    public static function getMainCategoriesQuery(): string {
        return TypeQueries::fetchMainCategories();
    }

    public static function getTypesListQuery(): string {
        return TypeQueries::fetchTypesList();
    }

    public static function getArticleDetailQuery(): string {
        return ArticleQueries::fetchDetail();
    }

    public static function getArticlesListQuery(): string {
        return ArticleQueries::fetchList();
    }

    public static function insertArticleQuery(): string {
        return ArticleQueries::insert();
    }

    public static function updateArticleWithValidationQuery(): string {
        return ArticleQueries::updateWithValidation();
    }

    public static function recordToolsUsageUpsertQuery(): string {
        return AnalyticsQueries::upsertToolsUsage();
    }

    public static function getUnifiedToolsUsageAnalyticsQuery(): string {
        return AnalyticsQueries::fetchUnifiedToolsUsageAnalytics();
    }

    public static function insertSuggestionQuery(): string {
        return SuggestionQueries::insert();
    }

    public static function getSuggestionsListQuery(): string {
        return SuggestionQueries::fetchList();
    }
}

?>