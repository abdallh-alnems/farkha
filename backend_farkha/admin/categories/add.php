<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class CategoriesAddApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $name = $this->getField('name');
            Validator::required($name, 'name');
            Validator::maxLength($name, 100, 'name');

            Database::execute("INSERT INTO product_categories (name) VALUES (?)", [$name]);
            $id = Database::lastInsertId();

            AdminAuth::logAction('category.add', 'category', $id, ['name' => $name]);
            $this->success(['id' => (int) $id]);
        }, 'category_add');
    }
}

new CategoriesAddApi();
