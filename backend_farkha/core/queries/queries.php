<?php

include_once __DIR__ . "/price_queries.php";
include_once __DIR__ . "/type_queries.php";
include_once __DIR__ . "/article_queries.php";
include_once __DIR__ . "/analytics_queries.php";
include_once __DIR__ . "/suggestion_queries.php";
include_once __DIR__ . "/user_queries.php";
include_once __DIR__ . "/cycle_queries.php";

final class Queries {
    public static function getFeasibilityStudyPrices(): string {
        return PriceQueries::fetchFeasibilityStudy();
    }

    public static function getCyclePrice(): string {
        return PriceQueries::fetchCyclePrice();
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

    // User Queries
    public static function findUserByFirebaseUidQuery(): string {
        return UserQueries::findByFirebaseUid();
    }

    public static function insertUserQuery(): string {
        return UserQueries::insert();
    }

    public static function updateUserNameQuery(): string {
        return UserQueries::updateName();
    }

    public static function updateUserPhoneQuery(): string {
        return UserQueries::updatePhone();
    }

    public static function deleteUserByFirebaseUidQuery(): string {
        return UserQueries::deleteByFirebaseUid();
    }

    // Cycle Queries
    public static function insertCycleQuery(): string {
        return CycleQueries::insert();
    }

    public static function insertCycleUserQuery(): string {
        return CycleQueries::insertCycleUser();
    }

    public static function fetchUserCyclesQuery(): string {
        return CycleQueries::fetchUserCycles();
    }

    public static function fetchCycleDetailsQuery(): string {
        return CycleQueries::fetchCycleDetails();
    }

    public static function checkUserAccessQuery(): string {
        return CycleQueries::checkUserAccess();
    }

    public static function insertCycleDataQuery(): string {
        return CycleQueries::insertCycleData();
    }

    public static function fetchCycleDataQuery(): string {
        return CycleQueries::fetchCycleData();
    }

    public static function insertCycleExpenseQuery(): string {
        return CycleQueries::insertCycleExpense();
    }

    public static function fetchCycleExpensesQuery(): string {
        return CycleQueries::fetchCycleExpenses();
    }

    public static function updateCycleQuery(): string {
        return CycleQueries::updateCycle();
    }

    public static function updateCycleStatusQuery(): string {
        return CycleQueries::updateCycleStatus();
    }

    public static function deleteCycleDataQuery(): string {
        return CycleQueries::deleteCycleData();
    }

    public static function deleteCycleExpensesQuery(): string {
        return CycleQueries::deleteCycleExpenses();
    }

    public static function deleteCycleUsersQuery(): string {
        return CycleQueries::deleteCycleUsers();
    }

    public static function deleteCycleQuery(): string {
        return CycleQueries::deleteCycle();
    }

    public static function deleteCycleDataByIdQuery(): string {
        return CycleQueries::deleteCycleDataById();
    }

    public static function deleteCycleDataByLabelQuery(): string {
        return CycleQueries::deleteCycleDataByLabel();
    }

    public static function deleteCycleExpenseByIdQuery(): string {
        return CycleQueries::deleteCycleExpenseById();
    }

    public static function deleteCycleExpenseByLabelQuery(): string {
        return CycleQueries::deleteCycleExpenseByLabel();
    }
}

?>