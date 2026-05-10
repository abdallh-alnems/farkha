<?php

require_once __DIR__ . '/../../config/bootstrap.php';

class LogsListApi extends AdminBaseApi {
    protected ?string $minRole = 'admin';

    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $lines = max(1, min(500, (int) ($this->getField('lines') ?? 100)));
            $offset = max(0, (int) ($this->getField('offset') ?? 0));

            $logPath = ini_get('error_log') ?: '/var/log/php/error_log';
            if (empty($logPath) || !file_exists($logPath)) {
                $candidates = [
                    __DIR__ . '/../../error_log',
                    __DIR__ . '/../../../error_log',
                    '/var/log/apache2/error.log',
                    '/var/log/nginx/error.log',
                    '/Applications/MAMP/logs/php_error.log',
                ];
                foreach ($candidates as $path) {
                    if (file_exists($path)) {
                        $logPath = $path;
                        break;
                    }
                }
            }

            if (!file_exists($logPath) || !is_readable($logPath)) {
                $this->success(['entries' => [], 'total' => 0, 'log_path' => $logPath]);
                return;
            }

            $file = new SplFileObject($logPath);
            $file->seek(PHP_INT_MAX);
            $totalLines = $file->key();

            $start = max(0, $totalLines - $lines - $offset);
            $file->seek($start);

            $entries = [];
            $count = 0;
            while (!$file->eof() && $count < $lines) {
                $line = $file->current();
                if ($line !== false && trim($line) !== '') {
                    $entries[] = trim($line);
                    $count++;
                }
                $file->next();
            }

            $this->success([
                'entries' => array_reverse($entries),
                'total' => $totalLines,
                'log_path' => $logPath,
                'file_size' => filesize($logPath),
            ]);
        }, 'logs_list');
    }
}

new LogsListApi();
