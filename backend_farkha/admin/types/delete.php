<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class TypesDeleteApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $id = (int) $this->requireNumeric('id', 1);

            $pricesCount = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM prices WHERE type = ?",
                [$id]
            )['c'];

            if ($pricesCount > 0) {
                $this->error("Cannot delete: type has {$pricesCount} price records", 400);
            }

            $result = Database::execute("DELETE FROM types WHERE id = ?", [$id]);
            if ($result === 0) {
                $this->error('Type not found', 404);
            }

            AdminAuth::logAction('type.delete', 'type', $id);
            $this->success(null);
        }, 'type_delete');
    }
}

new TypesDeleteApi();
