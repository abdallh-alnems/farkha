<?php

require_once __DIR__ . '/../../config/bootstrap.php';

Auth::requirePost();
Auth::checkAppCheck();

$input = Validator::getJsonBody();
$token = $input['token'] ?? null;

Validator::required($token, 'Token');

try {
    $verifiedToken = Auth::verifyFirebaseToken($token);
    $uid = $verifiedToken->claims()->get('sub');
    $name = $verifiedToken->claims()->get('name') ?? 'مستخدم';
    $phone = $verifiedToken->claims()->get('phone_number');

    $user = UserModel::findByFirebaseUid($uid);

    if (!$user) {
        UserModel::create($uid, $name, $phone);
        $user = ['name' => $name, 'phone' => $phone];
    } else {
        UserModel::updateName($uid, $name);
        $user['name'] = $name;
    }

    Response::success([
        'user' => [
            'name' => $user['name'],
            'phone' => $user['phone'] ?? null,
        ],
    ]);
} catch (Exception $e) {
    error_log('Login error: ' . $e->getMessage());
    Response::error('Server error', 500);
}
