-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 11, 2026 at 03:04 PM
-- Server version: 11.8.6-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u869543217_farkha`
--

-- --------------------------------------------------------

--
-- Table structure for table `suggestions`
--

CREATE TABLE `suggestions` (
  `id` int(11) NOT NULL,
  `suggestions_text` varchar(300) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `suggestions`
--

INSERT INTO `suggestions` (`id`, `suggestions_text`, `date`) VALUES
(1, 'النمس عمك', '2025-11-25 18:28:19'),
(2, 'اع', '2025-11-29 17:10:51'),
(3, 'تفصيل لتربيه الفراخ البلدي مثل درراسه جدوى واوزان الفراخ عند البيع واوضاع التربيه عامه\nوشكرا', '2025-12-07 08:16:44'),
(4, 'السلام عليكم ورحمة الله وبركاته \nأقترح على حضراتكم أن تهتموا بأداة الشفاط لأني لاحظت أنها لا تعطي نتائج سليمة في كثير من الأحيان و أقترح عليكم أن تضيفوا لها برامج مخصصة للتشغيل مثل برنامج ال10 دقائق يعني أن يعمل الشفاط 3 تشغيل و 7 إيقاف و هكذا مثلًا مع إضافة عدة برامج أخرى طبعًا الدقيقة و 5 دقائق', '2025-12-16 03:23:28'),
(5, 'استكمالًا لاقتراح السابق أرجو أيضًا أن يتم إضافة قائمة خاصة بالمضادات الحيوية و أسمها المنتشرة في الأسواق مع إضافة نوع المضاد الحيوي و فترة سحبه في قائمة خاصة و أيضًا حبذا لو تم تطوير خانة الأمراض بأن يتم إضافة أمراض أكثر و أيضًا الأعراض التي يظهرها المرض في التشريح', '2025-12-16 03:26:28'),
(6, 'ماهو سعر الفراخ البلدي في الأسواق حيه', '2026-01-05 08:10:56'),
(7, 'البورصه رفعت انهارده ليه التطبيق مش بيكون سريع في اضافه اخر تحديث للبورصه،????????', '2026-01-24 17:28:10'),
(8, 'بيع وشراء على الابلكيشن.\nهو ينفع اشتري خامات الاعلاف من على الابلكيشن', '2026-02-10 02:46:32'),
(9, 'ليه الدورات المعمول ع الابليكيشن للفراخ البيضا بس\nليه مفيش للفراخ الساسو مثلا', '2026-02-11 10:22:47'),
(10, 'صقر الكتكوت يوم 15 الابيض', '2026-02-16 09:21:37'),
(11, 'ليه تحديث الأسعار كل يومين او ثلاثة ، المفروض كل يوم عشان ساعات بيبقي في تغير في الأسعار', '2026-02-26 09:45:33'),
(12, 'خانه حساب العلف الاجمالي بتحسب خطأ\nفي دراسه الجدوي', '2026-03-23 13:40:59'),
(13, 'افصل اضافه الدورة بط و الاغنام', '2026-03-24 12:37:46');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `suggestions`
--
ALTER TABLE `suggestions`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `suggestions`
--
ALTER TABLE `suggestions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
