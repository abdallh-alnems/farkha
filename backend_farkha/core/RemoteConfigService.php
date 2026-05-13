<?php

require_once __DIR__ . '/../config/firebase.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\RemoteConfig\Parameter;
use Kreait\Firebase\RemoteConfig\DefaultValue;
use Kreait\Firebase\RemoteConfig\Template;

final class RemoteConfigService {
    private static $rc = null;

    private static function client() {
        if (self::$rc === null) {
            $cred = __DIR__ . '/firebase_credentials.json';
            self::$rc = (new Factory)->withServiceAccount($cred)->createRemoteConfig();
        }
        return self::$rc;
    }

    private static function extractValue($defaultValue): ?string {
        if ($defaultValue === null) return null;
        if (method_exists($defaultValue, 'value')) return (string) $defaultValue->value();
        if (method_exists($defaultValue, 'toArray')) {
            $arr = $defaultValue->toArray();
            if (!is_array($arr) || !isset($arr['value'])) return null;
            return is_string($arr['value']) ? $arr['value'] : (string) $arr['value'];
        }
        return null;
    }

    public static function getAll(): array {
        $tpl = self::client()->get();
        $out = ['parameters' => [], 'version' => null];

        foreach ($tpl->parameters() as $p) {
            $name = $p->name();
            $out['parameters'][] = [
                'name' => $name,
                'description' => $p->description() ?? '',
                'default_value' => self::extractValue($p->defaultValue()),
            ];
        }

        $version = $tpl->version();
        if ($version) {
            $out['version'] = [
                'number' => method_exists($version, 'versionNumber') ? $version->versionNumber() : null,
                'updated_at' => method_exists($version, 'updatedAt') ? $version->updatedAt()->format('c') : null,
                'updated_by' => method_exists($version, 'user') && $version->user() ? $version->user()->email() : null,
                'description' => method_exists($version, 'description') ? $version->description() : null,
            ];
        }
        return $out;
    }

    public static function setParameter(string $name, string $value, string $description = ''): array {
        $tpl = self::client()->get();

        $oldValue = null;
        foreach ($tpl->parameters() as $p) {
            if ($p->name() === $name) {
                $oldValue = self::extractValue($p->defaultValue());
                break;
            }
        }

        $param = Parameter::named($name)
            ->withDefaultValue(DefaultValue::with($value));
        if ($description) {
            $param = $param->withDescription($description);
        }

        $tpl = $tpl->withParameter($param);
        self::client()->publish($tpl);

        AdminAuth::logAction('remote_config.update', 'remote_config_param', $name, [
            'old_value' => $oldValue,
            'new_value' => $value,
        ]);

        return self::getAll();
    }

    public static function deleteParameter(string $name): array {
        $tpl = self::client()->get();

        if (method_exists($tpl, 'withRemovedParameter')) {
            $tpl = $tpl->withRemovedParameter($name);
            self::client()->publish($tpl);
            AdminAuth::logAction('remote_config.delete', 'remote_config_param', $name);
        } else {
            throw new RuntimeException('SDK version does not support removing parameters');
        }

        return self::getAll();
    }
}
