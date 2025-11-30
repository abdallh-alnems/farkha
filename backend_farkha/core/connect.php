<?php 
require_once __DIR__ . '/env.php';
require_once __DIR__ . '/http/responses.php';
require_once __DIR__ . '/validation.php';
require_once __DIR__ . '/http/request.php';
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/cors.php';
require_once __DIR__ . '/../cache_system/cache_manager.php';
require_once __DIR__ . '/base_api.php';

class DatabaseConnection {
    private static $instance = null;
    private $connection;
    
    private function __construct() {
        $this->connect();
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    private function connect() {
        try {
            $dsn = DB_NAME;
            $user = DB_USER;
            $pass = DB_PASS;
            
            $options = [
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES UTF8",
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false
            ];
            
            $this->connection = new PDO($dsn, $user, $pass, $options);
            
            // Database connection established
            
        } catch (PDOException $e) {
            handleApiError($e, ['context' => 'database_connection']);
        }
    }

    
    public function getConnection() {
        return $this->connection;
    }
    
    public function query($sql, $params = []) {
        try {
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);
            
            // Query executed
            
            return $stmt;
        } catch (PDOException $e) {
            throw $e;
        }
    }
    
    public function fetchAll($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetchAll();
    }
    
    public function fetchOne($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetch();
    }
    
    public function execute($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->rowCount();
    }
    
    public function getLastInsertId() {
        return $this->connection->lastInsertId();
    }
}

// Initialize database connection
try {
    $db = DatabaseConnection::getInstance();
    $con = $db->getConnection();
    
    // Set CORS headers
    setCorsHeaders();
    
    
} catch (Exception $e) {
    handleApiError($e, ['context' => 'database_initialization']);
}
?>