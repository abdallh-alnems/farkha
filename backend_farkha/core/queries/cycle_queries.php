<?php

final class CycleQueries {
    /**
     * إنشاء دورة جديدة
     */
    public static function insert(): string {
        return "INSERT INTO cycles (name, chick_count, space, breed, system_type, start_date_raw)
                VALUES (:name, :chick_count, :space, :breed, :system_type, :start_date_raw)";
    }

    /**
     * إضافة مستخدم إلى دورة (owner أو member)
     */
    public static function insertCycleUser(string $status = 'accepted'): string {
        $allowedStatuses = ['accepted', 'pending'];
        if (!in_array($status, $allowedStatuses)) {
            $status = 'pending';
        }
        return "INSERT INTO cycle_users (user_id, cycle_id, role, status)
                VALUES (:user_id, :cycle_id, :role, :status)";
    }

    public static function leaveCycleQuery(): string {
        return "DELETE FROM cycle_users WHERE cycle_id = :cycle_id AND user_id = :user_id";
    }

    /**
     * جلب جميع الدورات الخاصة بمستخدم معين مع الوفيات والمصاريف (الدورات النشطة فقط)
     */
    public static function fetchUserCycles(): string {
        return "SELECT 
                    c.id, 
                    c.name,
                    c.chick_count,  
                    c.system_type,
                    c.start_date_raw,
                    c.end_date_raw,
                    cu.role,

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
                WHERE cu.user_id = :user_id AND c.end_date_raw IS NULL AND cu.status = 'accepted'
                ORDER BY c.id DESC";
    }

    /**
     * جلب سجل الدورات الخاصة بالمستخدم (الدورات المنتهية) مع التصفح
     */
    public static function fetchUserHistoryCycles(bool $hasSearch = false, bool $hasDateFrom = false, bool $hasDateTo = false): string {
        $searchQuery = $hasSearch ? " AND c.name LIKE :search " : "";
        $dateQuery = "";
        if ($hasDateFrom) $dateQuery .= " AND DATE(c.start_date_raw) >= :date_from ";
        if ($hasDateTo) $dateQuery .= " AND DATE(c.start_date_raw) <= :date_to ";

        return "SELECT 
                    c.id, 
                    c.name, 
                    c.chick_count,
                    c.space,
                    c.breed,
                    c.system_type,
                    c.start_date_raw,
                    c.end_date_raw,
                    cu.role,
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
                    ) AS UNSIGNED), 0) as total_expenses,
                    COALESCE(CAST((
                        SELECT SUM(CAST(TRIM(cd2.value) AS DECIMAL(10,2)))
                        FROM cycle_data cd2
                        WHERE cd2.cycle_id = c.id
                        AND cd2.label = 'استهلاك العلف'
                    ) AS UNSIGNED), 0) as total_feed,
                    COALESCE(CAST((
                        SELECT cd3.value
                        FROM cycle_data cd3
                        WHERE cd3.cycle_id = c.id
                        AND cd3.label = 'متوسط وزن القطيع'
                        ORDER BY cd3.entry_date DESC
                        LIMIT 1
                    ) AS DECIMAL(10,3)), 0) as average_weight,
                    COALESCE((
                        SELECT SUM(total_price)
                        FROM cycle_sales cs2
                        WHERE cs2.cycle_id = c.id
                    ), 0) as total_sales
                FROM cycles c
                INNER JOIN cycle_users cu ON c.id = cu.cycle_id
                WHERE cu.user_id = :user_id AND c.end_date_raw IS NOT NULL AND cu.status = 'accepted'
                $searchQuery
                $dateQuery
                ORDER BY c.end_date_raw DESC, c.id DESC
                LIMIT :limit OFFSET :offset";
    }

    /**
     * جلب تفاصيل دورة معينة مع التحقق من صلاحيات المستخدم
     */
    public static function fetchCycleDetails(): string {
        return "SELECT c.*, cu.role 
                FROM cycles c
                INNER JOIN cycle_users cu ON c.id = cu.cycle_id
                WHERE c.id = :cycle_id AND cu.user_id = :user_id AND cu.status = 'accepted'
                LIMIT 1";
    }

    /**
     * جلب أعضاء الدورة (المقبولين والمعلقين)
     */
    public static function fetchCycleMembers(): string {
        return "SELECT u.id, u.name, u.phone, cu.role, cu.status
                FROM cycle_users cu
                INNER JOIN users u ON cu.user_id = u.id
                WHERE cu.cycle_id = :cycle_id";
    }

    /**
     * التحقق من صلاحيات المستخدم على الدورة (قراءة فقط)
     */
    public static function checkUserReadAccess(): string {
        return "SELECT role FROM cycle_users 
                WHERE cycle_id = :cycle_id AND user_id = :user_id AND status = 'accepted'
                LIMIT 1";
    }

    /**
     * التحقق من صلاحيات المستخدم على الدورة (كتابة)
     */
    public static function checkUserWriteAccess(): string {
        return "SELECT role FROM cycle_users 
                WHERE cycle_id = :cycle_id AND user_id = :user_id 
                AND status = 'accepted' AND role IN ('owner', 'admin')
                LIMIT 1";
    }

    /**
     * @deprecated Use checkUserReadAccess() or checkUserWriteAccess() instead
     */
    public static function checkUserAccess(): string {
        return self::checkUserReadAccess();
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
     * جلب الدعوات المعلقة للمستخدم
     */
    public static function fetchUserInvitations(): string {
        return "SELECT c.id as cycle_id, c.name as cycle_name, c.start_date_raw, cu.role, u_owner.name as inviter_name
                FROM cycles c
                INNER JOIN cycle_users cu ON c.id = cu.cycle_id
                INNER JOIN cycle_users cu_owner ON c.id = cu_owner.cycle_id AND cu_owner.role = 'owner'
                INNER JOIN users u_owner ON cu_owner.user_id = u_owner.id
                WHERE cu.user_id = :user_id AND cu.status = 'pending'
                ORDER BY c.created_at DESC";
    }

    /**
     * قبول الدعوة
     */
    public static function acceptInvitation(): string {
        return "UPDATE cycle_users SET status = 'accepted' 
                WHERE cycle_id = :cycle_id AND user_id = :user_id AND status = 'pending'";
    }

    /**
     * رفض الدعوة (حذف السجل)
     */
    public static function rejectInvitation(): string {
        return "DELETE FROM cycle_users 
                WHERE cycle_id = :cycle_id AND user_id = :user_id AND status = 'pending'";
    }

    /**
     * إضافة مصروف للدورة
     */
    public static function insertCycleExpense(): string {
        return "INSERT INTO cycle_expenses (cycle_id, label, value)
                VALUES (:cycle_id, :label, :value)";
    }

    /**
     * جلب بيانات الدورة مرتبة تصاعدياً (للسجل اليومي والتايملاين)
     */
    public static function fetchCycleDataChronological(): string {
        return "SELECT id, cycle_id, label, value, entry_date
                FROM cycle_data 
                WHERE cycle_id = :cycle_id
                ORDER BY entry_date ASC";
    }

    /**
     * جلب مصاريف الدورة مرتبة تصاعدياً (للعرض التفصيلي)
     */
    public static function fetchCycleExpensesChronological(): string {
        return "SELECT id, cycle_id, label, value, entry_date
                FROM cycle_expenses 
                WHERE cycle_id = :cycle_id
                ORDER BY entry_date ASC";
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
                    system_type = :system_type, 
                    start_date_raw = :start_date_raw
                WHERE id = :cycle_id";
    }

    /**
     * تحديث تاريخ انتهاء الدورة
     */
    public static function updateCycleStatus(): string {
        return "UPDATE cycles 
                SET end_date_raw = CASE 
                    WHEN :status = 'finished' THEN COALESCE(:end_date, CURRENT_DATE())
                    ELSE NULL 
                END
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

    /**
     * إضافة ملاحظة للدورة
     */
    public static function insertCycleNote(): string {
        return "INSERT INTO cycle_notes (cycle_id, content)
                VALUES (:cycle_id, :content)";
    }

    /**
     * جلب ملاحظات الدورة
     */
    public static function fetchCycleNotes(): string {
        return "SELECT * FROM cycle_notes 
                WHERE cycle_id = :cycle_id
                ORDER BY entry_date DESC";
    }

    /**
     * حذف ملاحظة واحدة من cycle_notes
     */
    public static function deleteCycleNoteById(): string {
        return "DELETE FROM cycle_notes WHERE id = :id AND cycle_id = :cycle_id";
    }

    /**
     * حذف جميع ملاحظات الدورة
     */
    public static function deleteCycleNotes(): string {
        return "DELETE FROM cycle_notes WHERE cycle_id = :cycle_id";
    }

    /**
     * تعديل ملاحظة
     */
    public static function updateCycleNote(): string {
        return "UPDATE cycle_notes SET content = :content WHERE id = :id AND cycle_id = :cycle_id";
    }

    /**
     * إضافة عملية بيع للدورة
     */
    public static function insertCycleSale(): string {
        return "INSERT INTO cycle_sales (cycle_id, quantity, total_weight, price_per_kg, total_price, sale_date)
                VALUES (:cycle_id, :quantity, :total_weight, :price_per_kg, :total_price, :sale_date)";
    }

    /**
     * جلب مبيعات الدورة
     */
    public static function fetchCycleSales(): string {
        return "SELECT * FROM cycle_sales 
                WHERE cycle_id = :cycle_id
                ORDER BY sale_date DESC";
    }

    /**
     * حذف عملية بيع
     */
    public static function deleteCycleSaleById(): string {
        return "DELETE FROM cycle_sales WHERE id = :id AND cycle_id = :cycle_id";
    }

    // ======================= Inventory Queries =======================

    /**
     * إضافة حركة مخزون للدورة
     */
    public static function insertCycleInventory(): string {
        return "INSERT INTO cycle_inventory (cycle_id, item_name, category, unit, quantity, transaction_type, notes)
                VALUES (:cycle_id, :item_name, :category, :unit, :quantity, :transaction_type, :notes)";
    }

    /**
     * جلب جميع حركات مخزون الدورة
     */
    public static function fetchCycleInventory(): string {
        return "SELECT * FROM cycle_inventory
                WHERE cycle_id = :cycle_id
                ORDER BY entry_date DESC";
    }

    /**
     * جلب ملخص المخزون (الكمية المتبقية لكل صنف)
     */
    public static function fetchCycleInventorySummary(): string {
        return "SELECT
                    item_name,
                    category,
                    unit,
                    SUM(CASE WHEN transaction_type = 'in' THEN quantity ELSE 0 END) as total_in,
                    SUM(CASE WHEN transaction_type = 'out' THEN quantity ELSE 0 END) as total_out,
                    SUM(CASE WHEN transaction_type = 'in' THEN quantity ELSE -quantity END) as remaining
                FROM cycle_inventory
                WHERE cycle_id = :cycle_id
                GROUP BY item_name, category, unit
                ORDER BY item_name ASC";
    }

    /**
     * حذف سجل مخزون واحد
     */
    public static function deleteCycleInventoryById(): string {
        return "DELETE FROM cycle_inventory WHERE id = :id AND cycle_id = :cycle_id";
    }

    /**
     * حذف جميع سجلات مخزون صنف معين
     */
    public static function deleteCycleInventoryByItemName(): string {
        return "DELETE FROM cycle_inventory WHERE cycle_id = :cycle_id AND item_name = :item_name";
    }

    /**
     * حذف جميع سجلات المخزون للدورة
     */
    public static function deleteCycleInventory(): string {
        return "DELETE FROM cycle_inventory WHERE cycle_id = :cycle_id";
    }
}

?>

