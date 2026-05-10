<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class DbSqlSelectApi extends AdminBaseApi {
    protected ?string $minRole = 'superadmin';

    private const BLOCKED_KEYWORDS = [
        'INTO OUTFILE', 'INTO DUMPFILE', 'INSERT', 'UPDATE', 'DELETE',
        'DROP', 'ALTER', 'CREATE', 'TRUNCATE', 'LOAD_FILE',
        'INFORMATION_SCHEMA', 'UNION', 'EXEC', 'EXECUTE',
        'GRANT', 'REVOKE', 'REPLACE', 'RENAME', 'CALL',
    ];

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $sql = trim($this->getField('sql', ''));

            if (strlen($sql) > 5000) {
                $this->error('SQL too long (max 5000 chars)', 400);
            }

            if (strpos($sql, ';') !== false) {
                $this->error('Multi-statement not allowed', 400);
            }

            $upperSql = strtoupper(preg_replace('/\s+/', ' ', $sql));
            if (strpos($upperSql, 'SELECT') !== 0) {
                $this->error('Only SELECT queries allowed', 400);
            }

            foreach (self::BLOCKED_KEYWORDS as $keyword) {
                if (strpos($upperSql, $keyword) !== false) {
                    Response::fail('Forbidden keyword in query', 403);
                }
            }

            if (stripos($upperSql, '--') !== false || stripos($upperSql, '/*') !== false || stripos($upperSql, '#') !== false) {
                $this->error('Comments not allowed in query', 400);
            }

            AdminAuth::logAction('db.sql_select', 'sql', null, ['sql' => $sql]);

            $rows = Database::fetchAll($sql);

            $this->success([
                'rows' => $rows,
                'count' => count($rows),
            ]);
        }, 'db_sql_select');
    }
}

new DbSqlSelectApi();
