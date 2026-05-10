<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CategoriesUpdateApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $id = (int) $this->requireNumeric('id', 1);
            $name = $this->getField('name');
            Validator::required($name, 'name');

            $result = Database::execute("UPDATE product_categories SET name = ? WHERE id = ?", [$name, $id]);
            if ($result === 0) {
                $this->error('Category not found', 404);
            }

            AdminAuth::logAction('category.update', 'category', $id, ['name' => $name]);
            $this->success(null);
        }, 'category_update');
    }
}

new CategoriesUpdateApi();
