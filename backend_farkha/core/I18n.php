<?php

final class I18n {
    private static array $strings = [];

    public static function load(string $locale = 'ar'): void {
        $file = __DIR__ . '/../lang/' . $locale . '.php';
        if (file_exists($file)) {
            self::$strings[$locale] = require $file;
        } else {
            self::$strings[$locale] = require __DIR__ . '/../lang/ar.php';
        }
    }

    public static function get(string $key, array $params = [], string $locale = 'ar'): string {
        if (empty(self::$strings[$locale])) {
            self::load($locale);
        }

        $text = self::$strings[$locale][$key] ?? $key;

        foreach ($params as $k => $v) {
            $text = str_replace('{' . $k . '}', (string) $v, $text);
        }

        return $text;
    }

    public static function userLocale(PDO $con, int $userId): string {
        static $cache = [];
        if (isset($cache[$userId])) {
            return $cache[$userId];
        }

        $stmt = $con->prepare("SELECT locale FROM users WHERE id = ? LIMIT 1");
        $stmt->execute([$userId]);
        $row = $stmt->fetch();
        $locale = ($row && !empty($row['locale'])) ? $row['locale'] : 'ar';
        $cache[$userId] = $locale;
        return $locale;
    }
}
