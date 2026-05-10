<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class TypesListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $categoryId = $this->getField('category_id');

            $where = "1=1";
            $params = [];

            if ($categoryId !== null) {
                $where .= " AND t.category_id = ?";
                $params[] = (int) $categoryId;
            }

            $types = Database::fetchAll(
                "SELECT t.*, pc.name AS category_name
                 FROM types t
                 LEFT JOIN product_categories pc ON pc.id = t.category_id
                 WHERE {$where}
                 ORDER BY t.id",
                $params
            );
            $this->success($types);
        }, 'types_list');
    }
}

new TypesListApi();
