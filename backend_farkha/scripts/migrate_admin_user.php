<?php

$mampHost = 'localhost';
$mampPort = '8889';
$mampDb   = 'farkha';
$mampUser = 'root';
$mampPass = 'root';

$hostDsn  = 'mysql:host=localhost;dbname=u869543217_farkha;charset=utf8mb4';
$hostUser = 'u869543217_NiMs_farkha';
$hostPass = 'Abdallh29512A';

try {
    $localPdo = new PDO(
        "mysql:host={$mampHost};port={$mampPort};dbname={$mampDb};charset=utf8mb4",
        $mampUser,
        $mampPass,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    echo "[OK] Connected to MAMP local database\n";
} catch (PDOException $e) {
    die("[ERROR] Cannot connect to MAMP: " . $e->getMessage() . "\n");
}

try {
    $hostPdo = new PDO($hostDsn, $hostUser, $hostPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
    echo "[OK] Connected to hosted database\n";
} catch (PDOException $e) {
    die("[ERROR] Cannot connect to hosted DB: " . $e->getMessage() . "\n");
}

$stmt = $localPdo->query("SELECT * FROM admin_users ORDER BY id");
$admins = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($admins)) {
    die("[ERROR] No admin_users found in MAMP database\n");
}

echo "[INFO] Found " . count($admins) . " admin account(s) in MAMP:\n";
foreach ($admins as $a) {
    echo "  - ID: {$a['id']}, Username: {$a['username']}, Role: {$a['role']}, Active: {$a['is_active']}\n";
}

$insertSql = "INSERT INTO admin_users (id, username, password_hash, display_name, role, last_login_at, last_login_ip, is_active, created_at)
              VALUES (:id, :username, :password_hash, :display_name, :role, :last_login_at, :last_login_ip, :is_active, :created_at)
              ON DUPLICATE KEY UPDATE
                  password_hash = VALUES(password_hash),
                  display_name = VALUES(display_name),
                  role = VALUES(role),
                  is_active = VALUES(is_active)";

$insertStmt = $hostPdo->prepare($insertSql);

$migrated = 0;
foreach ($admins as $admin) {
    try {
        $insertStmt->execute([
            ':id'            => $admin['id'],
            ':username'      => $admin['username'],
            ':password_hash' => $admin['password_hash'],
            ':display_name'  => $admin['display_name'],
            ':role'          => $admin['role'],
            ':last_login_at' => $admin['last_login_at'],
            ':last_login_ip' => $admin['last_login_ip'],
            ':is_active'     => $admin['is_active'],
            ':created_at'    => $admin['created_at'],
        ]);
        $migrated++;
        echo "[OK] Migrated admin: {$admin['username']} (role: {$admin['role']})\n";
    } catch (PDOException $e) {
        echo "[ERROR] Failed to migrate {$admin['username']}: " . $e->getMessage() . "\n";
    }
}

echo "\n[DONE] Migrated {$migrated} / " . count($admins) . " admin account(s)\n";
