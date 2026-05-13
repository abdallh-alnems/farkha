<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class UpdatePricesApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $type = $this->requireNumeric('type', 1);
            $higher = $this->requireNumeric('higher', 0);
            $lower = $this->getField('lower');
            $lowerValue = !empty($lower) ? Validator::numeric($lower, 'lower price', 0) : null;

            $exists = Database::fetchOne("SELECT id FROM types WHERE id = :id LIMIT 1", [':id' => (int) $type]);
            if (!$exists) {
                $this->error('Type not found', 404);
            }

            $result = PriceModel::updateLatest((int) $type, $higher, $lowerValue);
            if ($result > 0) {
                AdminAuth::logAction('price.update', 'price', $type, ['higher' => $higher, 'lower' => $lowerValue]);
                Cache::getInstance()->clear();
                $this->success(null);
            } else {
                $this->error('No price found to update', 404);
            }
        }, 'update_price');
    }
}

new UpdatePricesApi();
