<?php

class ApiResponse {
    public static function success($data = null, $code = 200, $source = null) {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');

        $response = [
            'status' => 'success'
        ];

        if ($source !== null) {
            $response['data_source'] = $source;
        }

        if ($data !== null) {
            $response['data'] = $data;
        }

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error($message = 'Error', $code = 400, $details = null) {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');

        $response = [
            'status' => 'error',
            'code' => $code,
            'message' => $message
        ];

        if ($details !== null) {
            error_log('API Error details: ' . json_encode($details));
        }

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function fail($message = 'Failed', $code = 400) {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');

        $response = [
            'status' => 'fail',
            'code' => $code,
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s'),
            'version' => API_VERSION
        ];

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }
}

?>


