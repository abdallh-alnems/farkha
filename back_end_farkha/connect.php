<?php 
include "function.php";

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
            
            ApiLogger::info('Database connection established');
            
        } catch (PDOException $e) {
            ApiLogger::error('Database connection failed', [
                'error' => $e->getMessage(),
                'dsn' => $dsn
            ]);
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
            
            ApiLogger::info('Query executed', [
                'sql' => $sql,
                'params' => $params
            ]);
            
            return $stmt;
        } catch (PDOException $e) {
            ApiLogger::error('Query execution failed', [
                'sql' => $sql,
                'params' => $params,
                'error' => $e->getMessage()
            ]);
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
}

// Initialize database connection
try {
    $db = DatabaseConnection::getInstance();
    $con = $db->getConnection();
    
    // Set CORS headers
    setCorsHeaders();
    
     //  checkAuthenticate();
    
} catch (Exception $e) {
    handleApiError($e, ['context' => 'database_initialization']);
}
?>