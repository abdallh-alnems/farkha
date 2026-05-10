<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class AccountDeletionsStatsApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $total = (int) Database::fetchOne("SELECT COUNT(*) c FROM account_deletions")['c'];
            $avgAge = (float) (Database::fetchOne("SELECT AVG(account_age_days) a FROM account_deletions")['a'] ?? 0);
            $reasons = Database::fetchAll(
                "SELECT reason, COUNT(*) c FROM account_deletions GROUP BY reason ORDER BY c DESC"
            );
            $platforms = Database::fetchAll(
                "SELECT last_platform, COUNT(*) c FROM account_deletions GROUP BY last_platform ORDER BY c DESC"
            );
            $timeline = Database::fetchAll(
                "SELECT DATE(deleted_at) d, COUNT(*) c FROM account_deletions
                 WHERE deleted_at >= NOW() - INTERVAL 90 DAY
                 GROUP BY DATE(deleted_at) ORDER BY d"
            );

            $this->success([
                'total' => $total,
                'avg_account_age_days' => round($avgAge, 1),
                'reasons' => $reasons,
                'platforms' => $platforms,
                'timeline_90d' => $timeline,
            ]);
        }, 'account_deletions_stats');
    }
}

new AccountDeletionsStatsApi();
