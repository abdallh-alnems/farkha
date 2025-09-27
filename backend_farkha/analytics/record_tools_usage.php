<?php

include "../connect.php"; 
include "../queries.php";

// Check authentication
checkAuthenticate(); 

class ToolsUsageAPI extends BaseAPI {

 
    public function recordUsage($toolId) {
        $toolId = (int) $toolId;
        
        $db = DatabaseConnection::getInstance();
        $existingRecord = $db->fetchOne(Queries::getToolsUsageRecordQuery(), [$toolId]);
        
        if ($existingRecord) {
            $db->query(Queries::updateToolsUsageCountQuery(), [$toolId]);
        } else {
            $db->query(Queries::insertToolsUsageRecordQuery(), [$toolId]);
        }
        
        ApiResponse::success(null, 200);
    }
}

$toolId = filterRequest('tool_id', 0);
$api = new ToolsUsageAPI();
$api->recordUsage($toolId);

?>