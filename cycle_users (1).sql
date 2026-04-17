-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Apr 07, 2026 at 11:08 AM
-- Server version: 8.0.44
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `farkha`
--

-- --------------------------------------------------------

--
-- Table structure for table `cycle_users`
--

CREATE TABLE `cycle_users` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `cycle_id` int NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','accepted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'accepted'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cycle_users`
--

INSERT INTO `cycle_users` (`id`, `user_id`, `cycle_id`, `role`, `status`) VALUES
(2, 21, 2, 'owner', 'accepted'),
(3, 23, 3, 'owner', 'accepted'),
(4, 24, 4, 'owner', 'accepted'),
(5, 26, 5, 'owner', 'accepted'),
(6, 26, 6, 'owner', 'accepted'),
(7, 27, 7, 'owner', 'accepted'),
(8, 28, 8, 'owner', 'accepted'),
(9, 30, 9, 'owner', 'accepted'),
(11, 18, 11, 'owner', 'accepted'),
(12, 33, 12, 'owner', 'accepted'),
(13, 34, 13, 'owner', 'accepted'),
(14, 35, 14, 'owner', 'accepted'),
(15, 37, 15, 'owner', 'accepted'),
(16, 38, 16, 'owner', 'accepted'),
(19, 2, 19, 'owner', 'accepted'),
(20, 39, 20, 'owner', 'accepted'),
(21, 41, 21, 'owner', 'accepted'),
(22, 42, 22, 'owner', 'accepted'),
(23, 42, 23, 'owner', 'accepted'),
(25, 48, 25, 'owner', 'accepted'),
(27, 51, 27, 'owner', 'accepted'),
(28, 53, 28, 'owner', 'accepted'),
(29, 55, 29, 'owner', 'accepted'),
(31, 58, 31, 'owner', 'accepted'),
(32, 8, 32, 'owner', 'accepted'),
(33, 59, 33, 'owner', 'accepted'),
(34, 60, 34, 'owner', 'accepted'),
(35, 61, 35, 'owner', 'accepted'),
(36, 62, 36, 'owner', 'accepted'),
(37, 63, 37, 'owner', 'accepted'),
(38, 64, 38, 'owner', 'accepted'),
(39, 65, 39, 'owner', 'accepted'),
(41, 47, 41, 'owner', 'accepted'),
(44, 69, 44, 'owner', 'accepted'),
(45, 44, 45, 'owner', 'accepted'),
(46, 71, 46, 'owner', 'accepted'),
(47, 72, 47, 'owner', 'accepted'),
(48, 73, 48, 'owner', 'accepted'),
(49, 74, 49, 'owner', 'accepted'),
(50, 75, 50, 'owner', 'accepted'),
(51, 76, 51, 'owner', 'accepted'),
(52, 77, 52, 'owner', 'accepted'),
(53, 77, 53, 'owner', 'accepted'),
(54, 21, 54, 'owner', 'accepted'),
(57, 80, 57, 'owner', 'accepted'),
(58, 81, 58, 'owner', 'accepted'),
(59, 12, 59, 'owner', 'accepted'),
(60, 82, 60, 'owner', 'accepted'),
(61, 84, 61, 'owner', 'accepted'),
(63, 85, 63, 'owner', 'accepted'),
(64, 86, 64, 'owner', 'accepted'),
(66, 88, 66, 'owner', 'accepted'),
(67, 89, 67, 'owner', 'accepted'),
(69, 91, 69, 'owner', 'accepted'),
(70, 92, 70, 'owner', 'accepted'),
(71, 93, 71, 'owner', 'accepted'),
(72, 94, 72, 'owner', 'accepted'),
(73, 85, 73, 'owner', 'accepted'),
(74, 97, 74, 'owner', 'accepted'),
(75, 98, 75, 'owner', 'accepted'),
(77, 100, 77, 'owner', 'accepted'),
(78, 101, 78, 'owner', 'accepted'),
(79, 103, 79, 'owner', 'accepted'),
(80, 17, 80, 'owner', 'accepted'),
(81, 104, 81, 'owner', 'accepted'),
(82, 2, 82, 'owner', 'accepted'),
(84, 66, 84, 'owner', 'accepted'),
(85, 106, 85, 'owner', 'accepted'),
(86, 108, 86, 'owner', 'accepted'),
(87, 109, 87, 'owner', 'accepted'),
(88, 112, 88, 'owner', 'accepted'),
(89, 111, 89, 'owner', 'accepted'),
(90, 112, 90, 'owner', 'accepted'),
(91, 113, 91, 'owner', 'accepted'),
(92, 102, 92, 'owner', 'accepted'),
(93, 114, 93, 'owner', 'accepted'),
(95, 83, 95, 'owner', 'accepted'),
(96, 118, 96, 'owner', 'accepted'),
(97, 119, 97, 'owner', 'accepted'),
(98, 122, 98, 'owner', 'accepted'),
(99, 15, 99, 'owner', 'accepted'),
(100, 20, 100, 'owner', 'accepted'),
(103, 127, 103, 'owner', 'accepted'),
(105, 79, 105, 'owner', 'accepted'),
(108, 133, 108, 'owner', 'accepted'),
(109, 135, 109, 'owner', 'accepted'),
(110, 128, 110, 'owner', 'accepted'),
(112, 134, 112, 'owner', 'accepted'),
(113, 141, 113, 'owner', 'accepted'),
(114, 52, 114, 'owner', 'accepted'),
(115, 29, 115, 'owner', 'accepted'),
(116, 52, 116, 'owner', 'accepted'),
(117, 40, 117, 'owner', 'accepted'),
(118, 147, 118, 'owner', 'accepted'),
(119, 148, 119, 'owner', 'accepted'),
(120, 149, 120, 'owner', 'accepted'),
(121, 150, 121, 'owner', 'accepted'),
(122, 152, 122, 'owner', 'accepted'),
(124, 53, 124, 'owner', 'accepted'),
(126, 18, 126, 'owner', 'accepted'),
(127, 157, 127, 'owner', 'accepted'),
(128, 158, 128, 'owner', 'accepted'),
(129, 159, 129, 'owner', 'accepted'),
(131, 161, 131, 'owner', 'accepted'),
(133, 162, 133, 'owner', 'accepted'),
(135, 117, 135, 'owner', 'accepted'),
(137, 166, 137, 'owner', 'accepted'),
(138, 94, 138, 'owner', 'accepted'),
(139, 46, 139, 'owner', 'accepted'),
(140, 99, 140, 'owner', 'accepted'),
(141, 171, 141, 'owner', 'accepted'),
(142, 173, 142, 'owner', 'accepted'),
(143, 174, 143, 'owner', 'accepted'),
(144, 64, 144, 'owner', 'accepted'),
(145, 174, 145, 'owner', 'accepted'),
(146, 177, 146, 'owner', 'accepted'),
(147, 95, 147, 'owner', 'accepted'),
(149, 85, 149, 'owner', 'accepted'),
(150, 179, 150, 'owner', 'accepted'),
(151, 181, 151, 'owner', 'accepted'),
(152, 182, 152, 'owner', 'accepted'),
(153, 183, 153, 'owner', 'accepted'),
(155, 185, 155, 'owner', 'accepted'),
(157, 3, 157, 'owner', 'accepted'),
(158, 169, 158, 'owner', 'accepted'),
(159, 191, 159, 'owner', 'accepted'),
(160, 192, 160, 'owner', 'accepted'),
(161, 194, 161, 'owner', 'accepted'),
(162, 195, 162, 'owner', 'accepted'),
(163, 59, 163, 'owner', 'accepted'),
(164, 196, 164, 'owner', 'accepted'),
(165, 48, 165, 'owner', 'accepted'),
(166, 71, 166, 'owner', 'accepted'),
(167, 197, 167, 'owner', 'accepted'),
(168, 198, 168, 'owner', 'accepted'),
(169, 190, 169, 'owner', 'accepted'),
(172, 200, 172, 'owner', 'accepted'),
(174, 3, 174, 'owner', 'accepted'),
(175, 3, 175, 'owner', 'accepted'),
(176, 117, 176, 'owner', 'accepted'),
(177, 3, 177, 'owner', 'accepted'),
(178, 3, 178, 'owner', 'accepted'),
(179, 3, 179, 'owner', 'accepted'),
(180, 124, 180, 'owner', 'accepted'),
(181, 206, 181, 'owner', 'accepted'),
(182, 136, 182, 'owner', 'accepted'),
(183, 207, 175, 'member', 'accepted'),
(184, 3, 183, 'owner', 'accepted'),
(185, 207, 174, 'member', 'accepted'),
(186, 207, 157, 'member', 'accepted'),
(191, 207, 186, 'owner', 'accepted'),
(192, 3, 187, 'owner', 'accepted'),
(193, 207, 187, 'admin', 'accepted'),
(194, 3, 188, 'owner', 'accepted'),
(195, 207, 188, 'admin', 'accepted'),
(198, 3, 190, 'owner', 'accepted'),
(199, 3, 191, 'owner', 'accepted'),
(200, 3, 192, 'owner', 'accepted'),
(207, 207, 192, 'viewer', 'accepted'),
(208, 3, 193, 'owner', 'accepted'),
(209, 207, 193, 'member', 'accepted');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cycle_users`
--
ALTER TABLE `cycle_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `cycle_users` (`cycle_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cycle_users`
--
ALTER TABLE `cycle_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=210;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cycle_users`
--
ALTER TABLE `cycle_users`
  ADD CONSTRAINT `cycle_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `cycle_users_ibfk_2` FOREIGN KEY (`cycle_id`) REFERENCES `cycles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
