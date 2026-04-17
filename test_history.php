<?php
require_once __DIR__ . '/backend_farkha/core/connect.php';
require_once __DIR__ . '/backend_farkha/core/queries/queries.php';

try {
    $userId = 3;
    $limit = 5;
    $offset = 0;

    $query = Queries::fetchUserHistoryCyclesQuery(false, false, false);
    
    $stmt = $con->prepare($query);
    $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
    
    $stmt->execute();
    $cycles = $stmt->fetchAll(PDO::FETCH_ASSOC);

    print_r(['status' => 'success', 'count' => count($cycles), 'cycles' => $cycles]);
} catch (Exception $e) {
    print_r(['error' => $e->getMessage()]);
}
?>
