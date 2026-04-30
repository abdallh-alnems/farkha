<?php
/**
 * Delete User Account
 */

require_once __DIR__ . '/../../core/connect.php';
require_once __DIR__ . '/../../core/firebase_verifier.php';
require_once __DIR__ . '/../../core/queries/queries.php';

checkAuthenticate();
requirePostMethod();

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['token'] ?? null;

$verifiedToken = requireValidToken($token);
$uid = $verifiedToken->claims()->get('sub');

try {
    $stmt = $con->prepare(Queries::findUserByFirebaseUidQuery());
    $stmt->execute([':firebase_uid' => $uid]);
    $user = $stmt->fetch();
    
    if (!$user) {
        echo json_encode([
            'status' => 'fail',
            'message' => 'User not found'
        ]);
        http_response_code(404);
        exit;
    }
    
    $con->beginTransaction();
    
    try {
        $stmt = $con->prepare("SELECT cycle_id, role FROM cycle_users WHERE user_id = :user_id");
        $stmt->execute([':user_id' => $user['id']]);
        $userCycles = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($userCycles as $cycleRow) {
            $cycleId = $cycleRow['cycle_id'];
            $role = $cycleRow['role'];
            
            if ($role === 'owner') {
                $stmt = $con->prepare(Queries::deleteCycleDataQuery());
                $stmt->execute([':cycle_id' => $cycleId]);
                
                $stmt = $con->prepare(Queries::deleteCycleExpensesQuery());
                $stmt->execute([':cycle_id' => $cycleId]);

                $stmt = $con->prepare(Queries::deleteCycleNotesQuery());
                $stmt->execute([':cycle_id' => $cycleId]);

                $stmt = $con->prepare(Queries::deleteCycleUsersQuery());
                $stmt->execute([':cycle_id' => $cycleId]);
                
                $stmt = $con->prepare(Queries::deleteCycleQuery());
                $stmt->execute([':cycle_id' => $cycleId]);
            } else {
                $stmt = $con->prepare("DELETE FROM cycle_users WHERE cycle_id = :cycle_id AND user_id = :user_id");
                $stmt->execute([':cycle_id' => $cycleId, ':user_id' => $user['id']]);
            }
        }
        
        try {
            $auth = getFirebaseAuth();
            $auth->deleteUser($uid);
        } catch (Exception $e) {
            error_log('Firebase delete error: ' . $e->getMessage());
        }
        
        $stmt = $con->prepare(Queries::deleteUserByFirebaseUidQuery());
        $stmt->execute([':firebase_uid' => $uid]);
        
        $con->commit();
        
        error_log("User deleted successfully: {$uid}");
        
        echo json_encode([
            'status' => 'success'
        ]);
        
    } catch (Exception $e) {
        $con->rollBack();
        throw $e;
    }
    
} catch (PDOException $e) {
    error_log('Delete account error: ' . $e->getMessage());
    echo json_encode([
        'status' => 'fail',
        'message' => 'Database error'
    ]);
    http_response_code(500);
} catch (Exception $e) {
    error_log('Delete account error: ' . $e->getMessage());
    echo json_encode([
        'status' => 'fail',
        'message' => 'Server error'
    ]);
    http_response_code(500);
}
