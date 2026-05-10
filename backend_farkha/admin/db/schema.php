<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DbSchemaApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $tables = Database::fetchAll("SHOW TABLES");
            $result = [];

            foreach ($tables as $row) {
                $tableName = array_values($row)[0];
                $count = Database::fetchOne("SELECT COUNT(*) c FROM `{$tableName}`")['c'];
                $result[] = [
                    'name' => $tableName,
                    'row_count' => (int) $count,
                ];
            }

            $this->success($result);
        }, 'db_schema');
    }
}

new DbSchemaApi();
