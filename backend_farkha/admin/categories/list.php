<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CategoriesListApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $categories = Database::fetchAll(
                "SELECT pc.*, (SELECT COUNT(*) FROM types t WHERE t.category_id = pc.id) AS types_count
                 FROM product_categories pc ORDER BY pc.id"
            );
            $this->success($categories);
        }, 'categories_list');
    }
}

new CategoriesListApi();
