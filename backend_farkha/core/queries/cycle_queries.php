<?php

final class CycleQueries {
    /**
     * إنشاء دورة جديدة
     */
    public static function insert(): string {
        return "INSERT INTO cycles (name, chick_count, space, breed, start_date_raw)
                VALUES (:name, :chick_count, :space, :breed, :start_date_raw)";
    }

    /**
     * إضافة مستخدم إلى دورة (owner أو member)
     */
    public static function insertCycleUser(): string {
        return "INSERT INTO cycle_users (user_id, cycle_id, role)
                VALUES (:user_id, :cycle_id, :role)";
    }

    /**
     * جلب جميع الدورات الخاصة بمستخدم معين مع الوفيات والمصاريف (الدورات النشطة فقط)
     */
    public static function fetchUserCycles(): string {
        return "SELECT 
                    c.id, 
                    c.name, 
                    c.chick_count, 
                    c.start_date_raw,
                    COALESCE(CAST((
                        SELECT SUM(CAST(TRIM(cd2.value) AS DECIMAL(10,2)))
                        FROM cycle_data cd2
                        WHERE cd2.cycle_id = c.id
                        AND cd2.label = 'عدد النافق'
                    ) AS UNSIGNED), 0) as mortality,
                    COALESCE(CAST((
                        SELECT SUM(ce2.value)
                        FROM cycle_expenses ce2
                        WHERE ce2.cycle_id = c.id
                    ) AS UNSIGNED), 0) as total_expenses
                FROM cycles c
                INNER JOIN cycle_users cu ON c.id = cu.cycle_id
                WHERE cu.user_id = :user_id AND c.status = 'active'
                ORDER BY c.id DESC";
    }

    /**
     * جلب تفاصيل دورة معينة مع التحقق من صلاحيات المستخدم
     */
    public static function fetchCycleDetails(): string {
        return "SELECT c.*, cu.role 
                FROM cycles c
                INNER JOIN cycle_users cu ON c.id = cu.cycle_id
                WHERE c.id = :cycle_id AND cu.user_id = :user_id
                LIMIT 1";
    }

    /**
     * التحقق من صلاحيات المستخدم على الدورة
     */
    public static function checkUserAccess(): string {
        return "SELECT role FROM cycle_users 
                WHERE cycle_id = :cycle_id AND user_id = :user_id
                LIMIT 1";
    }

    /**
     * إضافة بيانات للدورة
     */
    public static function insertCycleData(): string {
        return "INSERT INTO cycle_data (cycle_id, label, value)
                VALUES (:cycle_id, :label, :value)";
    }

    /**
     * جلب بيانات الدورة
     */
    public static function fetchCycleData(): string {
        return "SELECT * FROM cycle_data 
                WHERE cycle_id = :cycle_id
                ORDER BY entry_date DESC";
    }

    /**
     * إضافة مصروف للدورة
     */
    public static function insertCycleExpense(): string {
        return "INSERT INTO cycle_expenses (cycle_id, label, value)
                VALUES (:cycle_id, :label, :value)";
    }

    /**
     * جلب مصاريف الدورة
     */
    public static function fetchCycleExpenses(): string {
        return "SELECT * FROM cycle_expenses 
                WHERE cycle_id = :cycle_id
                ORDER BY entry_date DESC";
    }

    /**
     * تحديث بيانات الدورة
     */
    public static function updateCycle(): string {
        return "UPDATE cycles 
                SET name = :name, 
                    chick_count = :chick_count, 
                    space = :space, 
                    breed = :breed, 
                    start_date_raw = :start_date_raw
                WHERE id = :cycle_id";
    }

    /**
     * تحديث حالة الدورة (active/finished)
     */
    public static function updateCycleStatus(): string {
        return "UPDATE cycles 
                SET status = :status
                WHERE id = :cycle_id";
    }

    /**
     * حذف بيانات الدورة
     */
    public static function deleteCycleData(): string {
        return "DELETE FROM cycle_data WHERE cycle_id = :cycle_id";
    }

    /**
     * حذف مصاريف الدورة
     */
    public static function deleteCycleExpenses(): string {
        return "DELETE FROM cycle_expenses WHERE cycle_id = :cycle_id";
    }

    /**
     * حذف مستخدمي الدورة
     */
    public static function deleteCycleUsers(): string {
        return "DELETE FROM cycle_users WHERE cycle_id = :cycle_id";
    }

    /**
     * حذف دورة
     */
    public static function deleteCycle(): string {
        return "DELETE FROM cycles WHERE id = :cycle_id";
    }

    /**
     * حذف سجل واحد من cycle_data
     */
    public static function deleteCycleDataById(): string {
        return "DELETE FROM cycle_data WHERE id = :id AND cycle_id = :cycle_id";
    }

    /**
     * حذف جميع السجلات بنفس label من cycle_data
     */
    public static function deleteCycleDataByLabel(): string {
        return "DELETE FROM cycle_data WHERE cycle_id = :cycle_id AND label = :label";
    }

    /**
     * حذف سجل واحد من cycle_expenses
     */
    public static function deleteCycleExpenseById(): string {
        return "DELETE FROM cycle_expenses WHERE id = :id AND cycle_id = :cycle_id";
    }

    /**
     * حذف جميع السجلات بنفس label من cycle_expenses
     */
    public static function deleteCycleExpenseByLabel(): string {
        return "DELETE FROM cycle_expenses WHERE cycle_id = :cycle_id AND label = :label";
    }
}

?>

