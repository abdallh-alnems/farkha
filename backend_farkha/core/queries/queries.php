<?php

include_once __DIR__ . "/price_queries.php";
include_once __DIR__ . "/type_queries.php";
include_once __DIR__ . "/article_queries.php";
include_once __DIR__ . "/analytics_queries.php";
include_once __DIR__ . "/suggestion_queries.php";
include_once __DIR__ . "/user_queries.php";
include_once __DIR__ . "/cycle_queries.php";
include_once __DIR__ . "/app_review_queries.php";

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

    public static function getPriceHistoryByTypeQuery(int $limit = 30, ?string $beforeDate = null): string {
        return PriceQueries::fetchPriceHistoryByType($limit, $beforeDate);
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

    public static function getTypeByIdQuery(): string {
        return TypeQueries::fetchTypeById();
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

    public static function insertCycleUserQuery(string $status = 'accepted'): string {
        return CycleQueries::insertCycleUser($status);
    }

    public static function fetchUserCyclesQuery(): string {
        return CycleQueries::fetchUserCycles();
    }

    public static function fetchUserHistoryCyclesQuery(bool $hasSearch = false, bool $hasDateFrom = false, bool $hasDateTo = false): string {
        return CycleQueries::fetchUserHistoryCycles($hasSearch, $hasDateFrom, $hasDateTo);
    }

    public static function fetchCycleDetailsQuery(): string {
        return CycleQueries::fetchCycleDetails();
    }

    public static function checkUserAccessQuery(): string {
        return CycleQueries::checkUserAccess();
    }

    public static function leaveCycleQuery(): string {
        return CycleQueries::leaveCycleQuery();
    }

    public static function fetchCycleMembersQuery(): string {
        return CycleQueries::fetchCycleMembers();
    }

    public static function fetchUserInvitationsQuery(): string {
        return CycleQueries::fetchUserInvitations();
    }

    public static function acceptInvitationQuery(): string {
        return CycleQueries::acceptInvitation();
    }

    public static function rejectInvitationQuery(): string {
        return CycleQueries::rejectInvitation();
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

    public static function fetchCycleDataChronologicalQuery(): string {
        return CycleQueries::fetchCycleDataChronological();
    }

    public static function fetchCycleExpensesChronologicalQuery(): string {
        return CycleQueries::fetchCycleExpensesChronological();
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

    // Cycle Sales Queries
    public static function insertCycleSaleQuery(): string {
        return CycleQueries::insertCycleSale();
    }

    public static function fetchCycleSalesQuery(): string {
        return CycleQueries::fetchCycleSales();
    }

    public static function deleteCycleSaleByIdQuery(): string {
        return CycleQueries::deleteCycleSaleById();
    }

    // Cycle Notes Queries
    public static function insertCycleNoteQuery(): string {
        return CycleQueries::insertCycleNote();
    }

    public static function fetchCycleNotesQuery(): string {
        return CycleQueries::fetchCycleNotes();
    }

    public static function deleteCycleNoteByIdQuery(): string {
        return CycleQueries::deleteCycleNoteById();
    }

    public static function deleteCycleNotesQuery(): string {
        return CycleQueries::deleteCycleNotes();
    }

    public static function updateCycleNoteQuery(): string {
        return CycleQueries::updateCycleNote();
    }

    // Inventory Queries
    public static function insertCycleInventoryQuery(): string {
        return CycleQueries::insertCycleInventory();
    }

    public static function fetchCycleInventoryQuery(): string {
        return CycleQueries::fetchCycleInventory();
    }

    public static function fetchCycleInventorySummaryQuery(): string {
        return CycleQueries::fetchCycleInventorySummary();
    }

    public static function deleteCycleInventoryByIdQuery(): string {
        return CycleQueries::deleteCycleInventoryById();
    }

    public static function deleteCycleInventoryByItemNameQuery(): string {
        return CycleQueries::deleteCycleInventoryByItemName();
    }

    public static function deleteCycleInventoryQuery(): string {
        return CycleQueries::deleteCycleInventory();
    }

    // ============================ Phone Verification ============================
    public static function countPendingVerificationsByUser(): string {
        return UserQueries::countPendingVerificationsByUser();
    }

    public static function expireStalePhoneVerifications(): string {
        return UserQueries::expireStalePhoneVerifications();
    }

    public static function insertPhoneVerification(): string {
        return UserQueries::insertPhoneVerification();
    }

    public static function findActivePhoneVerificationBySession(): string {
        return UserQueries::findActivePhoneVerificationBySession();
    }

    public static function findLatestPendingByUserPhone(): string {
        return UserQueries::findLatestPendingByUserPhone();
    }

    public static function findLatestPendingByUser(): string {
        return UserQueries::findLatestPendingByUser();
    }

    public static function findPhoneVerificationByVerifiedToken(): string {
        return UserQueries::findPhoneVerificationByVerifiedToken();
    }

    public static function updatePhoneVerificationAttempts(): string {
        return UserQueries::updatePhoneVerificationAttempts();
    }

    public static function updatePhoneVerificationStatus(): string {
        return UserQueries::updatePhoneVerificationStatus();
    }

    public static function updatePhoneVerificationResend(): string {
        return UserQueries::updatePhoneVerificationResend();
    }

    public static function updatePhoneVerified(): string {
        return UserQueries::updatePhoneVerified();
    }

    public static function clearPhoneForOtherUsers(): string {
        return UserQueries::clearPhoneForOtherUsers();
    }

    public static function consumeVerifiedToken(): string {
        return UserQueries::consumeVerifiedToken();
    }

    // App Review queries
    public static function upsertAppReviewQuery(): string {
        return AppReviewQueries::upsert();
    }

    public static function fetchAppReviewByUserIdQuery(): string {
        return AppReviewQueries::fetchByUserId();
    }

    public static function fetchAppReviewIdByUserIdQuery(): string {
        return AppReviewQueries::fetchIdByUserId();
    }
}

?>