<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class TypesAddApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $name = $this->getField('name');
            $categoryId = (int) $this->requireNumeric('category_id', 1);

            Validator::required($name, 'name');

            $cat = Database::fetchOne("SELECT id FROM product_categories WHERE id = ? LIMIT 1", [$categoryId]);
            if (!$cat) {
                $this->error('Category not found', 404);
            }

            Database::execute("INSERT INTO types (name, category_id) VALUES (?, ?)", [$name, $categoryId]);
            $id = Database::lastInsertId();

            AdminAuth::logAction('type.add', 'type', $id, ['name' => $name, 'category_id' => $categoryId]);
            $this->success(['id' => (int) $id]);
        }, 'type_add');
    }
}

new TypesAddApi();
