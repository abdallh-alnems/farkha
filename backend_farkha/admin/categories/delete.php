<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CategoriesDeleteApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $id = (int) $this->requireNumeric('id', 1);

            $typesCount = (int) Database::fetchOne(
                "SELECT COUNT(*) c FROM types WHERE category_id = ?",
                [$id]
            )['c'];

            if ($typesCount > 0) {
                $this->error("Cannot delete: category has {$typesCount} types", 400);
            }

            $result = Database::execute("DELETE FROM product_categories WHERE id = ?", [$id]);
            if ($result === 0) {
                $this->error('Category not found', 404);
            }

            AdminAuth::logAction('category.delete', 'category', $id);
            $this->success(null);
        }, 'category_delete');
    }
}

new CategoriesDeleteApi();
