<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class TypesUpdateApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $id = (int) $this->requireNumeric('id', 1);
            $name = $this->getField('name');
            $categoryId = $this->getField('category_id');

            Validator::required($name, 'name');

            $sets = ["name = ?"];
            $params = [$name];

            if ($categoryId !== null) {
                $sets[] = "category_id = ?";
                $params[] = (int) $categoryId;
            }

            $params[] = $id;
            $result = Database::execute(
                "UPDATE types SET " . implode(', ', $sets) . " WHERE id = ?",
                $params
            );

            if ($result === 0) {
                $this->error('Type not found', 404);
            }

            AdminAuth::logAction('type.update', 'type', $id, ['name' => $name]);
            $this->success(null);
        }, 'type_update');
    }
}

new TypesUpdateApi();
