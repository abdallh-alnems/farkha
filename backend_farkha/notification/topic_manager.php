<?php

/**
 * Topic Manager - FCM Topics Management System
 * 
 * Manages all product topics for Firebase Cloud Messaging notifications.
 * Provides methods to get topics by product ID, category, and name.
 */

class TopicManager {
    
    /**
     * Get all product topics with their names
     * @return array Array of topic_name => product_name
     */
    public static function getAllTopics() { 
        return [
            // Meat Products (6 products)
            'lhm_abyad' => 'اللحم الابيض',
            'lhm_sasw' => 'اللحم الساسو', 
            'farkh_bldy' => 'الفراخ البلدي',
            'amhat_hbrd_kbyr' => 'الامهات الهيبرد',
            'rmy_abyad' => 'الرومي الابيض',
            'rmy_aswd' => 'الرومي الاسود',
            
            // Poultry Products (11 products)
            'frkh_hyh' => 'الفراخ البيضاء في منافذ البيع',
            'frkh_baad_aldbh' => 'الفراخ بعد الدبح',
            'fylyh' => 'الفيليه',
            'wrak' => 'الوراك',
            'dbabys' => 'الدبابيس',
            'ajnh' => 'الاجنحة',
            'sdwr_blljd' => 'الصدور بالجلد',
            'sdwr_blladm' => 'الصدور بالعضم',
            'shysh' => 'الشيش',
            'shysh_blljd' => 'الشيش بالجلد',
            'kbd_wqwanas' => 'الكبد والقوانص',
            
            // Egg Products (12 products)
            'abyad_shrkat' => 'كتكوت ابيض من الشركان',
            'abyad_qtaan' => 'كتكوت ابيض من المعامل',
            'sasw' => 'كتكوت ساسو',
            'sasw_bywr' => 'كتكوت ساسو بيور',
            'kakot_bldy' => 'كتكوت بلدي',
            'bldy_mshar' => 'كتكوت بلدي مشعر',
            'hjyn' => 'كتكوت هجين',
            'jyl_tany' => 'كتكوت جيل التاني',
            'ruzy_bywr' => 'كتكوت روزي بيور',
            'jmyzh' => 'كتكوت جميزة',
            'sman_abyad' => 'كتكوت سمان ابيض',
            'sman_asmar' => 'كتكوت سمان اسمر',
            
            // Color Products (3 products)
            'ahmar' => 'البيص احمر',
            'abyad' => 'البيص ابيض',
            'byd_bldy' => 'البيص بلدي',
            
            // Duck Products (8 products)
            'fransawy' => 'البط الفرنساوي',
            'mskwfy' => 'البط المسكوفي',
            'mwlar' => 'البط المولار',
            'bghaly' => 'البط البغالي',
            'bat_bldy' => 'البط البلدي',
            'ktkt_fransawy' => 'كتكوت البط الفرنساوي',
            'ktkt_mskwfy' => 'كتكوت البط المسكوفي',
            'ktkt_mwlar' => 'كتكوت البط المولار',
            
            // Feed Products (7 products)
            'bady' => ' علف البادي',
            'namy' => 'علف النامي',
            'nahy' => 'علف الناهي',
            'bady_namy' => 'علف البادي النامي',
            '14_byad' => 'علف بياض %14 ',
            '16_byad' => 'علف بياض %16 ',
            '18_byad' => 'علف بياض %18 ',
            
            // Feed Materials (5 products)
            'dhrt_arjntyny' => 'الذرة الارجنتيني',
            'dhrt_brazyly' => 'الذرة البرازيلي',
            'dhrt_awkrny' => 'الذرة الاوكراني',
            'kwrn_flak' => 'الكورن فلاك',
            'ksb_swya_44' => 'الكسب صويا %44'
        ];
    }
    
    /**
     * Get topic name by product ID
     * @param int $productId Product ID
     * @return string|null Topic name or null if not found
     */
    public static function getTopicByProductId($productId) {
        // Create mapping from old product IDs to new topic names
        $productIdMapping = [
            1 => 'lhm_abyad', 2 => 'lhm_sasw', 3 => 'farkh_bldy', 4 => 'amhat_hbrd_kbyr',
            5 => 'rmy_abyad', 6 => 'rmy_aswd', 7 => 'frkh_hyh', 8 => 'frkh_baad_aldbh',
            9 => 'fylyh', 10 => 'wrak', 11 => 'dbabys', 12 => 'ajnh',
            13 => 'sdwr_blljd', 14 => 'sdwr_blladm', 15 => 'shysh', 16 => 'shysh_blljd',
            17 => 'kbd_wqwanas', 18 => 'abyad_shrkat', 19 => 'abyad_qtaan', 20 => 'sasw',
            21 => 'sasw_bywr', 22 => 'kakot_bldy', 23 => 'bldy_mshar', 24 => 'hjyn',
            25 => 'jyl_tany', 26 => 'ruzy_bywr', 27 => 'jmyzh', 28 => 'sman_abyad',
            29 => 'sman_asmar', 30 => 'ahmar', 31 => 'abyad', 32 => 'byd_bldy',
            33 => 'fransawy', 34 => 'mskwfy', 35 => 'mwlar', 36 => 'bghaly',
            37 => 'bat_bldy', 38 => 'ktkt_fransawy', 39 => 'ktkt_mskwfy', 40 => 'ktkt_mwlar',
            41 => 'bady', 42 => 'namy', 43 => 'nahy', 44 => 'bady_namy',
            45 => '14_byad', 46 => '16_byad', 47 => '18_byad', 48 => 'dhrt_arjntyny',
            49 => 'dhrt_brazyly', 50 => 'dhrt_awkrny', 51 => 'kwrn_flak', 52 => 'ksb_swya_44'
        ];
        
        return isset($productIdMapping[$productId]) ? $productIdMapping[$productId] : null;
    }
    
    /**
     * Get product name by topic
     * @param string $topicName Topic name
     * @return string|null Product name or null if not found
     */
    public static function getProductNameByTopic($topicName) {
        $topics = self::getAllTopics();
        return isset($topics[$topicName]) ? $topics[$topicName] : null;
    }
    
    /**
     * Get all topics as JSON
     * @return string JSON string of all topics
     */
    public static function getTopicsAsJson() {
        return json_encode(self::getAllTopics(), JSON_UNESCAPED_UNICODE);
    }
}

// Example usage
if (basename(__FILE__) == basename($_SERVER['SCRIPT_NAME'])) {
    echo "<h1>Topic Manager System</h1>";
    
    echo "<h2>All Topics (" . count(TopicManager::getAllTopics()) . " total)</h2>";
    echo "<pre>" . TopicManager::getTopicsAsJson() . "</pre>";
    
    echo "<h2>Usage Examples</h2>";
    echo "<p>Get topic for product ID 1: " . TopicManager::getTopicByProductId(1) . "</p>";
    echo "<p>Get product name for topic: " . TopicManager::getProductNameByTopic('lhm_abyad') . "</p>";
}

?>
