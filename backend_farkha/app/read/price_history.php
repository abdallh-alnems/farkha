<?php

require_once __DIR__ . '/../../core/connect.php';
include __DIR__ . '/../../core/queries/queries.php';

class PriceHistoryAPI extends BaseAPI {

    private const DEFAULT_LIMIT = 30;
    private const MAX_LIMIT = 1000;

    public function __construct() {
        parent::__construct();
        $this->handleRequest();
    }

    private function handleRequest() {
        $this->handleApiRequest(function() {
            $this->getPriceHistory();
        }, 'price_history_api');
    }

    private function getTypeId(): ?int {
        $raw = RequestHelper::getField('type_id');
        if ($raw === null || $raw === '') {
            return null;
        }
        $id = (int) $raw;
        return $id > 0 ? $id : null;
    }

    private function getLimit(): int {
        $raw = RequestHelper::getField('limit');
        if ($raw === null || $raw === '' || !is_numeric($raw)) {
            return self::DEFAULT_LIMIT;
        }
        $limit = (int) $raw;
        return max(1, min(self::MAX_LIMIT, $limit));
    }

    private function getBeforeDate(): ?string {
        $raw = RequestHelper::getField('before_date');
        if ($raw === null || $raw === '') {
            return null;
        }
        $trimmed = trim($raw);
        return $trimmed !== '' ? $trimmed : null;
    }

    public function getPriceHistory() {
        $typeId = $this->getTypeId();

        if ($typeId === null) {
            $this->handleError(400, 'يجب تحديد معرف النوع (type_id)');
            return;
        }

        $typeRow = $this->db->fetchOne(Queries::getTypeByIdQuery(), [$typeId]);
        if (empty($typeRow)) {
            $this->handleError(404, 'النوع غير موجود');
            return;
        }

        $limit = $this->getLimit();
        $beforeDate = $this->getBeforeDate();
        $query = Queries::getPriceHistoryByTypeQuery($limit, $beforeDate);

        $params = $beforeDate !== null ? [$typeId, $beforeDate] : [$typeId];
        $history = $this->db->fetchAll($query, $params);

        $this->sendSuccess($history);
    }
}

try {
    new PriceHistoryAPI();
} catch (Exception $e) {
    handleApiError($e, ['context' => 'price_history_api']);
}
?>
