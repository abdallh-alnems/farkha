<?php
$host = '127.0.0.1';
$port = 8889;
$dbname = 'farkha';
$user = 'root';
$pass = 'root';

try {
    $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8";
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    
    echo "✅ Connected to MySQL successfully!\n\n";
    
    // Show tables
    $stmt = $pdo->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "📊 Tables in database '$dbname':\n";
    echo str_repeat("-", 40) . "\n";
    foreach ($tables as $table) {
        // Get row count
        $countStmt = $pdo->query("SELECT COUNT(*) FROM `$table`");
        $count = $countStmt->fetchColumn();
        echo "  • $table ($count rows)\n";
    }
    
    echo "\n";
    
    // Show users table data as example
    if (in_array('users', $tables)) {
        echo "👤 Users table (first 5):\n";
        echo str_repeat("-", 40) . "\n";
        $stmt = $pdo->query("SELECT * FROM users LIMIT 5");
        $users = $stmt->fetchAll();
        print_r($users);
    }
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
