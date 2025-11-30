<?php

require_once __DIR__ . '/../core/connect.php';
include "../core/queries/queries.php";

class ToolsUsageAPI extends BaseAPI {

 
    public function recordUsage($toolId) {
        $toolId = (int) $toolId;
        
        // Single query to record usage with upsert
        $query = Queries::recordToolsUsageUpsertQuery();
        $this->db->query($query, [$toolId]);
        
        ApiResponse::success(null, 200);
    }
}

$toolId = RequestHelper::getField('tool_id', 0);
$api = new ToolsUsageAPI();
$api->recordUsage($toolId);

?>