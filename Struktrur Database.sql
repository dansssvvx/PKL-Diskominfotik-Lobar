-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 05 Jun 2026 pada 06.49
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lovista`
--
CREATE DATABASE IF NOT EXISTS `lovista` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `lovista`;

-- --------------------------------------------------------

--
-- Struktur dari tabel `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `old_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_value`)),
  `new_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_value`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `ai_recommendations`
--

CREATE TABLE `ai_recommendations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`preferences`)),
  `budget` decimal(10,2) DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `travel_style` varchar(100) DEFAULT NULL,
  `interests` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`interests`)),
  `recommendations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recommendations`)),
  `feedback_rating` tinyint(4) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add permission', 1, 'add_permission'),
(2, 'Can change permission', 1, 'change_permission'),
(3, 'Can delete permission', 1, 'delete_permission'),
(4, 'Can view permission', 1, 'view_permission'),
(5, 'Can add group', 2, 'add_group'),
(6, 'Can change group', 2, 'change_group'),
(7, 'Can delete group', 2, 'delete_group'),
(8, 'Can view group', 2, 'view_group'),
(9, 'Can add content type', 3, 'add_contenttype'),
(10, 'Can change content type', 3, 'change_contenttype'),
(11, 'Can delete content type', 3, 'delete_contenttype'),
(12, 'Can view content type', 3, 'view_contenttype'),
(13, 'Can add user', 4, 'add_user'),
(14, 'Can change user', 4, 'change_user'),
(15, 'Can delete user', 4, 'delete_user'),
(16, 'Can view user', 4, 'view_user'),
(17, 'Can add destination category', 5, 'add_destinationcategory'),
(18, 'Can change destination category', 5, 'change_destinationcategory'),
(19, 'Can delete destination category', 5, 'delete_destinationcategory'),
(20, 'Can view destination category', 5, 'view_destinationcategory'),
(21, 'Can add facility', 6, 'add_facility'),
(22, 'Can change facility', 6, 'change_facility'),
(23, 'Can delete facility', 6, 'delete_facility'),
(24, 'Can view facility', 6, 'view_facility'),
(25, 'Can add homestay', 7, 'add_homestay'),
(26, 'Can change homestay', 7, 'change_homestay'),
(27, 'Can delete homestay', 7, 'delete_homestay'),
(28, 'Can view homestay', 7, 'view_homestay'),
(29, 'Can add role', 8, 'add_role'),
(30, 'Can change role', 8, 'change_role'),
(31, 'Can delete role', 8, 'delete_role'),
(32, 'Can view role', 8, 'view_role'),
(33, 'Can add tourism destination', 9, 'add_tourismdestination'),
(34, 'Can change tourism destination', 9, 'change_tourismdestination'),
(35, 'Can delete tourism destination', 9, 'delete_tourismdestination'),
(36, 'Can view tourism destination', 9, 'view_tourismdestination'),
(37, 'Can add travel agency', 10, 'add_travelagency'),
(38, 'Can change travel agency', 10, 'change_travelagency'),
(39, 'Can delete travel agency', 10, 'delete_travelagency'),
(40, 'Can view travel agency', 10, 'view_travelagency'),
(41, 'Can add vehicle', 11, 'add_vehicle'),
(42, 'Can change vehicle', 11, 'change_vehicle'),
(43, 'Can delete vehicle', 11, 'delete_vehicle'),
(44, 'Can view vehicle', 11, 'view_vehicle'),
(45, 'Can add vehicle rental', 12, 'add_vehiclerental'),
(46, 'Can change vehicle rental', 12, 'change_vehiclerental'),
(47, 'Can delete vehicle rental', 12, 'delete_vehiclerental'),
(48, 'Can view vehicle rental', 12, 'view_vehiclerental'),
(49, 'Can add tour package', 13, 'add_tourpackage'),
(50, 'Can change tour package', 13, 'change_tourpackage'),
(51, 'Can delete tour package', 13, 'delete_tourpackage'),
(52, 'Can view tour package', 13, 'view_tourpackage'),
(53, 'Can add setting', 14, 'add_setting'),
(54, 'Can change setting', 14, 'change_setting'),
(55, 'Can delete setting', 14, 'delete_setting'),
(56, 'Can view setting', 14, 'view_setting'),
(57, 'Can add package itinerary', 15, 'add_packageitinerary'),
(58, 'Can change package itinerary', 15, 'change_packageitinerary'),
(59, 'Can delete package itinerary', 15, 'delete_packageitinerary'),
(60, 'Can view package itinerary', 15, 'view_packageitinerary'),
(61, 'Can add package inclusion', 16, 'add_packageinclusion'),
(62, 'Can change package inclusion', 16, 'change_packageinclusion'),
(63, 'Can delete package inclusion', 16, 'delete_packageinclusion'),
(64, 'Can view package inclusion', 16, 'view_packageinclusion'),
(65, 'Can add notification', 17, 'add_notification'),
(66, 'Can change notification', 17, 'change_notification'),
(67, 'Can delete notification', 17, 'delete_notification'),
(68, 'Can view notification', 17, 'view_notification'),
(69, 'Can add homestay room', 18, 'add_homestayroom'),
(70, 'Can change homestay room', 18, 'change_homestayroom'),
(71, 'Can delete homestay room', 18, 'delete_homestayroom'),
(72, 'Can view homestay room', 18, 'view_homestayroom'),
(73, 'Can add homestay booking', 19, 'add_homestaybooking'),
(74, 'Can change homestay booking', 19, 'change_homestaybooking'),
(75, 'Can delete homestay booking', 19, 'delete_homestaybooking'),
(76, 'Can view homestay booking', 19, 'view_homestaybooking'),
(77, 'Can add destination image', 20, 'add_destinationimage'),
(78, 'Can change destination image', 20, 'change_destinationimage'),
(79, 'Can delete destination image', 20, 'delete_destinationimage'),
(80, 'Can view destination image', 20, 'view_destinationimage'),
(81, 'Can add culture', 21, 'add_culture'),
(82, 'Can change culture', 21, 'change_culture'),
(83, 'Can delete culture', 21, 'delete_culture'),
(84, 'Can view culture', 21, 'view_culture'),
(85, 'Can add culinary', 22, 'add_culinary'),
(86, 'Can change culinary', 22, 'change_culinary'),
(87, 'Can delete culinary', 22, 'delete_culinary'),
(88, 'Can view culinary', 22, 'view_culinary'),
(89, 'Can add contribution', 23, 'add_contribution'),
(90, 'Can change contribution', 23, 'change_contribution'),
(91, 'Can delete contribution', 23, 'delete_contribution'),
(92, 'Can view contribution', 23, 'view_contribution'),
(93, 'Can add booking', 24, 'add_booking'),
(94, 'Can change booking', 24, 'change_booking'),
(95, 'Can delete booking', 24, 'delete_booking'),
(96, 'Can view booking', 24, 'view_booking'),
(97, 'Can add ai recommendation', 25, 'add_airecommendation'),
(98, 'Can change ai recommendation', 25, 'change_airecommendation'),
(99, 'Can delete ai recommendation', 25, 'delete_airecommendation'),
(100, 'Can view ai recommendation', 25, 'view_airecommendation'),
(101, 'Can add activity log', 26, 'add_activitylog'),
(102, 'Can change activity log', 26, 'change_activitylog'),
(103, 'Can delete activity log', 26, 'delete_activitylog'),
(104, 'Can view activity log', 26, 'view_activitylog'),
(105, 'Can add wishlist', 27, 'add_wishlist'),
(106, 'Can change wishlist', 27, 'change_wishlist'),
(107, 'Can delete wishlist', 27, 'delete_wishlist'),
(108, 'Can view wishlist', 27, 'view_wishlist'),
(109, 'Can add review', 28, 'add_review'),
(110, 'Can change review', 28, 'change_review'),
(111, 'Can delete review', 28, 'delete_review'),
(112, 'Can view review', 28, 'view_review'),
(113, 'Can add package destination', 29, 'add_packagedestination'),
(114, 'Can change package destination', 29, 'change_packagedestination'),
(115, 'Can delete package destination', 29, 'delete_packagedestination'),
(116, 'Can view package destination', 29, 'view_packagedestination'),
(117, 'Can add destination facility', 30, 'add_destinationfacility'),
(118, 'Can change destination facility', 30, 'change_destinationfacility'),
(119, 'Can delete destination facility', 30, 'delete_destinationfacility'),
(120, 'Can view destination facility', 30, 'view_destinationfacility'),
(121, 'Can add log entry', 31, 'add_logentry'),
(122, 'Can change log entry', 31, 'change_logentry'),
(123, 'Can delete log entry', 31, 'delete_logentry'),
(124, 'Can view log entry', 31, 'view_logentry'),
(125, 'Can add session', 32, 'add_session'),
(126, 'Can change session', 32, 'change_session'),
(127, 'Can delete session', 32, 'delete_session'),
(128, 'Can view session', 32, 'view_session');

-- --------------------------------------------------------

--
-- Struktur dari tabel `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `booking_number` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_person` int(11) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `discount_amount` decimal(10,2) DEFAULT 0.00,
  `final_price` decimal(10,2) GENERATED ALWAYS AS (`total_price` - `discount_amount`) VIRTUAL,
  `special_request` text DEFAULT NULL,
  `status` enum('pending','confirmed','cancelled','completed') DEFAULT 'pending',
  `payment_status` enum('pending','paid','refunded','failed') DEFAULT 'pending',
  `payment_method` varchar(100) DEFAULT NULL,
  `payment_proof` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `cancelled_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `contributions`
--

CREATE TABLE `contributions` (
  `id` int(11) NOT NULL,
  `contributor_id` int(11) NOT NULL,
  `type` enum('destination','culinary','culture','other') NOT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  `status` enum('pending','approved','rejected','revision_requested') DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `revision_notes` text DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `culinaries`
--

CREATE TABLE `culinaries` (
  `id` int(11) NOT NULL,
  `destination_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price_range` varchar(50) DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `is_standalone` tinyint(1) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `culinaries`
--

INSERT INTO `culinaries` (`id`, `destination_id`, `name`, `description`, `price_range`, `contact`, `latitude`, `longitude`, `is_standalone`, `is_verified`, `created_at`, `images`) VALUES
(7, NULL, 'Sate Bulayak', 'Kamu pecinta Sate? Wajib banget mencoba kuliner khas Lombok yang satu ini. Adalah Sate Bulayak Suranadi, resto yang telah menyajikan sate bulayak sejak 1990. Sate bulayak sendiri terbuat dari daging sapi, ayam, dan jeroan sapi.\r\n\r\nDiolah dengan berbagai rempah, seperti kemiri, lada, ketumbar, jintan, bawang merah, bawang putih, santan kelapa, dan jeruk, membuat satai ini punya cita rasa gurih yang khas. Karenanya, kurang lengkap rasanya bila berkunjung ke Lombok tanpa mencicipi sajian khas yang satu ini.\r\n\r\nBerlokasi di Suranadi, Narmada, Kabupaten Lombok Barat, Nusa Tenggara Barat, kamu dapat mengunjungi wisata kuliner yang satu ini mulai pukul 8.00 s.d. 18.00 WITA. Harga yang ditawarkan pun terbilang terjangkau, yakni mulai dari Rp20 ribu.', 'Rp 20.000 - Rp. 35.000', NULL, -8.59113000, 116.20247000, 1, 1, '2026-06-03 07:30:18', '[\"https://lombokbaratkab.go.id/wp-content/uploads/2015/08/sate-3.jpg\", \"https://lombokbaratkab.go.id/wp-content/uploads/2015/08/sate-lombok.jpg\"]');

-- --------------------------------------------------------

--
-- Struktur dari tabel `cultures`
--

CREATE TABLE `cultures` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `event_date` date DEFAULT NULL,
  `event_frequency` varchar(100) DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `contributor_id` int(11) DEFAULT NULL,
  `status` enum('draft','pending','published','archived') DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `cultures`
--

INSERT INTO `cultures` (`id`, `name`, `description`, `location`, `event_date`, `event_frequency`, `images`, `contributor_id`, `status`, `created_at`) VALUES
(3, 'Perang Topat', 'tradisi budaya dan ritual sakral saling melempar ketupat (topat) yang dilakukan oleh masyarakat suku Sasak (Islam) dan Bali (Hindu) di kawasan Pura Lingsar, Kecamatan Lingsar, Kabupaten Lombok Barat, Nusa Tenggara Barat. Tradisi ini merupakan simbol perdamaian, toleransi, dan kerukunan antarumat beragama.', 'Pura Lingsar', '2026-04-30', 'Annual (setelah Hari Raya Ketupat / sekitar 7 hari setelah Idul Fitri)', '[\"https://lombokbaratkab.go.id/wp-content/uploads/2016/12/perangtopat.jpg\", \"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg7zS8QcpNHIPwp3ZoxMS4FPUDxQ-GdHZx-FTFMZb6j_RzBcILlmdJ8z7LlJXbWYs_0u2_8Ch1ZJ7A2xt3HYSZ9QCjRnv7PkWiV9yVzi2BcNYzdnKzGUo6cttnAbE5swi2aTVlX-i9sx5A/s1600/Tradisi+Perang+Topat+di+Lingsar+Lombok.jpg\", \"https://statik.tempo.co/data/2019/12/12/id_897223/897223_720.jpg\", \"https://1001indonesia.net/asset/2018/12/Perang-Topat.jpg\", \"https://img.antarafoto.com/cache/1200x805/2010/11/21/tradisi-perang-topat-2pmt-dom.webp\"]', 7, 'published', '2026-04-29 16:37:26');

-- --------------------------------------------------------

--
-- Struktur dari tabel `destination_categories`
--

CREATE TABLE `destination_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `display_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `destination_categories`
--

INSERT INTO `destination_categories` (`id`, `name`, `slug`, `icon`, `description`, `display_order`) VALUES
(1, 'Alam', 'alam', 'nature', 'Wisata Alam', 0),
(2, 'Budaya', 'budaya', 'culture', 'Wisata Budaya', 0),
(3, 'Kuliner', 'kuliner', 'food', 'Wisata Kuliner', 0),
(4, 'Religi', 'religi', 'mosque', 'Wisata Religi', 0),
(5, 'Belanja', 'belanja', 'shopping', 'Pusat Perbelanjaan', 0),
(6, 'Pantai & Gili', 'pantai-gili', 'beach', 'Wisata bahari mempesona', 0),
(7, 'Alam & Perbukitan', 'alam-perbukitan', 'landscape', 'Keindahan alam pegunungan', 0),
(8, 'Budaya & Sejarah', 'budaya-sejarah', 'history', 'Warisan leluhur Lombok', 0),
(10, 'Pantai', 'pantai', NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Struktur dari tabel `destination_facilities`
--

CREATE TABLE `destination_facilities` (
  `id` int(11) NOT NULL,
  `destination_id` int(11) NOT NULL,
  `facility_id` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `destination_images`
--

CREATE TABLE `destination_images` (
  `id` int(11) NOT NULL,
  `destination_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `caption` varchar(255) DEFAULT NULL,
  `display_order` int(11) DEFAULT 0,
  `uploaded_by` int(11) DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2026-04-29 19:48:14.227771', '5', 'Bukit Merese', 2, '[{\"changed\": {\"fields\": [\"Parking fee\"]}}]', 9, 6),
(2, '2026-04-29 19:49:19.552399', '6', 'Air Terjun Benang Kelambu', 3, '', 9, 6),
(3, '2026-04-29 19:49:24.477405', '5', 'Bukit Merese', 3, '', 9, 6),
(4, '2026-04-29 19:49:30.567201', '4', 'Gili Kedis', 3, '', 9, 6),
(5, '2026-04-29 19:49:36.751361', '3', 'Pura Lingsar', 3, '', 9, 6),
(6, '2026-04-29 19:49:45.377078', '2', 'Gili Nanggu', 3, '', 9, 6),
(7, '2026-04-29 19:49:50.060663', '1', 'Pantai Senggigi', 3, '', 9, 6),
(8, '2026-04-29 19:54:03.289754', '7', 'Pantai Senggig', 1, '[{\"added\": {}}]', 9, 6),
(9, '2026-04-29 19:54:24.683776', '7', 'Pantai Senggigi', 2, '[{\"changed\": {\"fields\": [\"Name\", \"Main image\"]}}]', 9, 6),
(10, '2026-04-29 19:55:10.227230', '7', 'Pantai Senggigi', 2, '[{\"changed\": {\"fields\": [\"Main image\"]}}]', 9, 6),
(11, '2026-04-29 19:56:58.011879', '1', 'TourPackage object (1)', 3, '', 13, 6),
(12, '2026-04-29 19:57:03.008373', '4', 'TourPackage object (4)', 3, '', 13, 6),
(13, '2026-04-29 19:57:06.887948', '3', 'TourPackage object (3)', 3, '', 13, 6),
(14, '2026-04-29 19:57:13.903055', '2', 'TourPackage object (2)', 3, '', 13, 6),
(15, '2026-04-29 19:57:27.471203', '5', 'Culinary object (5)', 3, '', 22, 6),
(16, '2026-04-29 19:57:30.718662', '4', 'Culinary object (4)', 3, '', 22, 6),
(17, '2026-04-29 19:57:34.407113', '3', 'Culinary object (3)', 3, '', 22, 6),
(18, '2026-04-29 19:57:37.711333', '2', 'Culinary object (2)', 3, '', 22, 6),
(19, '2026-04-29 19:57:41.260150', '1', 'Culinary object (1)', 3, '', 22, 6),
(20, '2026-04-29 19:57:52.146333', '2', 'Culture object (2)', 3, '', 21, 6),
(21, '2026-04-29 19:57:56.713080', '1', 'Culture object (1)', 3, '', 21, 6),
(22, '2026-04-29 19:58:24.869641', '7', 'Pantai Senggigi', 2, '[{\"changed\": {\"fields\": [\"Slug\"]}}]', 9, 6),
(23, '2026-04-29 20:20:16.178716', '7', 'Pantai Senggigi', 2, '[{\"changed\": {\"fields\": [\"Parking fee\"]}}]', 9, 6),
(24, '2026-04-29 23:24:40.640771', '8', 'Bukit Malimbu', 1, '[{\"added\": {}}]', 9, 6),
(25, '2026-04-29 23:27:48.173830', '5', 'TourPackage object (5)', 1, '[{\"added\": {}}]', 13, 6),
(26, '2026-04-29 23:28:02.160713', '5', 'TourPackage object (5)', 2, '[{\"changed\": {\"fields\": [\"Is featured\"]}}]', 13, 6),
(27, '2026-04-29 23:54:18.003858', '5', 'TourPackage object (5)', 2, '[]', 13, 6),
(28, '2026-04-30 00:16:08.723969', '6', 'Culinary object (6)', 1, '[{\"added\": {}}]', 22, 6),
(29, '2026-04-30 00:16:38.424619', '6', 'Culinary object (6)', 2, '[{\"changed\": {\"fields\": [\"Price range\"]}}]', 22, 6),
(30, '2026-04-30 00:37:26.918229', '3', 'Culture object (3)', 1, '[{\"added\": {}}]', 21, 6),
(31, '2026-04-30 00:50:35.228209', '3', 'Culture object (3)', 2, '[]', 21, 6),
(32, '2026-06-03 13:39:09.717629', '9', 'Pantai Alberto', 1, '[{\"added\": {}}]', 9, 7),
(33, '2026-06-03 13:39:30.413784', '6', 'Culinary object (6)', 2, '[{\"changed\": {\"fields\": [\"Destination\"]}}]', 22, 7),
(34, '2026-06-03 13:51:47.331969', '10', 'Gili Kedis', 1, '[{\"added\": {}}]', 9, 7),
(35, '2026-06-03 13:53:03.039983', '10', 'Gili Kedis', 2, '[{\"changed\": {\"fields\": [\"Main image\"]}}]', 9, 7),
(36, '2026-06-03 13:53:43.478170', '10', 'Gili Kedis', 2, '[{\"changed\": {\"fields\": [\"Main image\"]}}]', 9, 7),
(37, '2026-06-03 13:56:06.745864', '3', 'Culture object (3)', 2, '[]', 21, 7),
(38, '2026-06-03 13:56:39.228153', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Contributor\"]}}]', 21, 7),
(39, '2026-06-03 13:59:49.782746', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Images\"]}}]', 21, 7),
(40, '2026-06-03 14:17:35.020371', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Images\"]}}]', 21, 7),
(41, '2026-06-03 14:21:48.245997', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Images\"]}}]', 21, 7),
(42, '2026-06-03 14:26:09.197020', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Images\"]}}]', 21, 7),
(43, '2026-06-03 14:27:39.490302', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Images\"]}}]', 21, 7),
(44, '2026-06-03 14:28:11.304167', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Images\"]}}]', 21, 7),
(45, '2026-06-03 14:29:31.354048', '3', 'Culture object (3)', 2, '[{\"changed\": {\"fields\": [\"Description\"]}}]', 21, 7),
(46, '2026-06-03 14:38:00.521272', '6', 'Culinary object (6)', 2, '[]', 22, 7),
(47, '2026-06-03 14:38:03.661402', '6', 'Culinary object (6)', 2, '[]', 22, 7),
(48, '2026-06-03 14:42:45.525048', '6', 'Culinary object (6)', 2, '[{\"changed\": {\"fields\": [\"Images\"]}}]', 22, 7),
(49, '2026-06-03 15:25:26.178256', '6', 'Culinary object (6)', 3, '', 22, 7),
(50, '2026-06-03 15:30:18.457621', '7', 'Culinary object (7)', 1, '[{\"added\": {}}]', 22, 7),
(51, '2026-06-03 15:32:17.257861', '7', 'Culinary object (7)', 2, '[{\"changed\": {\"fields\": [\"Longitude\"]}}]', 22, 7),
(52, '2026-06-03 15:33:00.643340', '7', 'Culinary object (7)', 2, '[{\"changed\": {\"fields\": [\"Latitude\", \"Longitude\"]}}]', 22, 7),
(53, '2026-06-03 15:34:01.887694', '7', 'Culinary object (7)', 2, '[{\"changed\": {\"fields\": [\"Latitude\", \"Longitude\"]}}]', 22, 7),
(54, '2026-06-03 15:34:23.613614', '7', 'Culinary object (7)', 2, '[]', 22, 7),
(55, '2026-06-03 15:38:02.514757', '1', 'Vehicle object (1)', 1, '[{\"added\": {}}]', 11, 7),
(56, '2026-06-03 15:44:28.789046', '1', 'Vehicle object (1)', 2, '[]', 11, 7),
(57, '2026-06-03 15:44:31.423274', '1', 'Vehicle object (1)', 2, '[]', 11, 7),
(58, '2026-06-03 15:48:14.380605', '1', 'Vehicle object (1)', 2, '[{\"changed\": {\"fields\": [\"Daily rate\"]}}]', 11, 7),
(59, '2026-06-03 16:07:19.284398', '1', 'Vehicle object (1)', 2, '[{\"changed\": {\"fields\": [\"Features\"]}}]', 11, 7),
(60, '2026-06-03 16:08:10.727432', '1', 'Vehicle object (1)', 2, '[{\"changed\": {\"fields\": [\"Features\"]}}]', 11, 7),
(61, '2026-06-03 16:09:36.516337', '1', 'Vehicle object (1)', 2, '[{\"changed\": {\"fields\": [\"Driver rate\"]}}]', 11, 7),
(62, '2026-06-03 16:11:09.971961', '1', 'TravelAgency object (1)', 2, '[]', 10, 7),
(63, '2026-06-04 17:58:54.836270', '7', 'daniramadany2005@gmail.com', 2, '[]', 4, 7),
(64, '2026-06-04 17:59:05.977134', '5', 'admin@gmail.com', 2, '[{\"changed\": {\"fields\": [\"Role\"]}}]', 4, 7),
(65, '2026-06-04 17:59:12.991234', '4', '123@gmail.com', 2, '[{\"changed\": {\"fields\": [\"Role\"]}}]', 4, 7),
(66, '2026-06-04 19:06:57.986887', '7', 'daniramadany2005@gmail.com', 2, '[]', 4, 7),
(67, '2026-06-04 19:07:06.626780', '7', 'daniramadany2005@gmail.com', 2, '[{\"changed\": {\"fields\": [\"Is verified\"]}}]', 4, 7);

-- --------------------------------------------------------

--
-- Struktur dari tabel `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(31, 'admin', 'logentry'),
(26, 'api', 'activitylog'),
(25, 'api', 'airecommendation'),
(24, 'api', 'booking'),
(23, 'api', 'contribution'),
(22, 'api', 'culinary'),
(21, 'api', 'culture'),
(5, 'api', 'destinationcategory'),
(30, 'api', 'destinationfacility'),
(20, 'api', 'destinationimage'),
(6, 'api', 'facility'),
(7, 'api', 'homestay'),
(19, 'api', 'homestaybooking'),
(18, 'api', 'homestayroom'),
(17, 'api', 'notification'),
(29, 'api', 'packagedestination'),
(16, 'api', 'packageinclusion'),
(15, 'api', 'packageitinerary'),
(28, 'api', 'review'),
(8, 'api', 'role'),
(14, 'api', 'setting'),
(9, 'api', 'tourismdestination'),
(13, 'api', 'tourpackage'),
(10, 'api', 'travelagency'),
(4, 'api', 'user'),
(11, 'api', 'vehicle'),
(12, 'api', 'vehiclerental'),
(27, 'api', 'wishlist'),
(2, 'auth', 'group'),
(1, 'auth', 'permission'),
(3, 'contenttypes', 'contenttype'),
(32, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Struktur dari tabel `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2026-04-29 18:46:14.276728'),
(2, 'contenttypes', '0002_remove_content_type_name', '2026-04-29 18:46:14.376746'),
(20, 'sessions', '0001_initial', '2026-04-29 19:44:56.793499'),
(21, 'auth', '0001_initial', '2026-04-29 19:45:33.737006'),
(22, 'auth', '0002_alter_permission_name_max_length', '2026-04-29 19:45:33.737006'),
(23, 'auth', '0003_alter_user_email_max_length', '2026-04-29 19:45:33.744280'),
(24, 'auth', '0004_alter_user_username_opts', '2026-04-29 19:45:33.747200'),
(25, 'auth', '0005_alter_user_last_login_null', '2026-04-29 19:45:33.756166'),
(26, 'auth', '0006_require_contenttypes_0002', '2026-04-29 19:45:33.761540'),
(27, 'auth', '0007_alter_validators_add_error_messages', '2026-04-29 19:45:33.762370'),
(28, 'auth', '0008_alter_user_username_max_length', '2026-04-29 19:45:33.770008'),
(29, 'auth', '0009_alter_user_last_name_max_length', '2026-04-29 19:45:33.771016'),
(30, 'auth', '0010_alter_group_name_max_length', '2026-04-29 19:45:33.771016'),
(31, 'auth', '0011_update_proxy_permissions', '2026-04-29 19:45:33.777803'),
(32, 'auth', '0012_alter_user_first_name_max_length', '2026-04-29 19:45:33.777803'),
(33, 'api', '0001_initial', '2026-04-29 19:45:33.777803'),
(34, 'admin', '0001_initial', '2026-04-29 19:45:33.787178'),
(35, 'admin', '0002_logentry_remove_auto_add', '2026-04-29 19:45:33.788847'),
(36, 'admin', '0003_logentry_add_action_flag_choices', '2026-04-29 19:45:33.788847'),
(37, 'api', '0002_remove_culinary_image_culinary_images', '2026-06-03 14:36:40.957449');

-- --------------------------------------------------------

--
-- Struktur dari tabel `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('3edz9g1xoi0ggvt3azei97p4uj2jsgok', '.eJxVjEEOwiAQRe_C2hAKrUNduu8ZyMwwSNVAUtqV8e7apAvd_vfef6mA25rD1mQJc1QXBer0uxHyQ8oO4h3LrWquZV1m0ruiD9r0VKM8r4f7d5Cx5W9t-4SjcdQzjo6ZxApHBhaP1HUpeQ8d4NADJA-WafQWzwLOGiZDA6v3BxGOOMU:1wUlhb:AioKlvLy4A2lpuep1UOY5hvgwxDiCTUn181vQVoPeAw', '2026-06-17 13:32:11.972234'),
('c5necakpzwvlvkz72i8g40wkiqtg8wfw', '.eJxVjDsOwjAQBe_iGln-4Q8lfc5grb1rHEC2FCcV4u4QKQW0b2bei0XY1hq3QUuckV2YZaffLUF-UNsB3qHdOs-9rcuc-K7wgw4-daTn9XD_DiqM-q09nj1IIxGCsgl1saJ4cKR1QJGAks-gZKBQTCGC7KwQUhjMaJyyOrH3B_4jOI4:1wIArH:bGJUhTUiN2GfAZ78_-6fRCMc4ISMuUTTc2KYp7j1-bs', '2026-05-13 19:46:07.612446'),
('ocdix7nqq40sqsracs0ykjhgpljcf6sg', '.eJxVjEEOwiAQRe_C2hAKrUNduu8ZyMwwSNVAUtqV8e7apAvd_vfef6mA25rD1mQJc1QXBer0uxHyQ8oO4h3LrWquZV1m0ruiD9r0VKM8r4f7d5Cx5W9t-4SjcdQzjo6ZxApHBhaP1HUpeQ8d4NADJA-WafQWzwLOGiZDA6v3BxGOOMU:1wVCCM:mJ-VvoSU7Lc0FArfBqMHSjO0eQoHUwSkNpRjZgXz_uI', '2026-06-18 17:49:42.646355');

-- --------------------------------------------------------

--
-- Struktur dari tabel `facilities`
--

CREATE TABLE `facilities` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `homestays`
--

CREATE TABLE `homestays` (
  `id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `village` varchar(100) DEFAULT NULL,
  `district` varchar(100) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `total_rooms` int(11) DEFAULT 1,
  `description` text DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `main_image` varchar(255) DEFAULT NULL,
  `check_in_time` time DEFAULT '14:00:00',
  `check_out_time` time DEFAULT '12:00:00',
  `policies` text DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `homestay_bookings`
--

CREATE TABLE `homestay_bookings` (
  `id` int(11) NOT NULL,
  `booking_number` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `total_nights` int(11) GENERATED ALWAYS AS (to_days(`check_out`) - to_days(`check_in`)) VIRTUAL,
  `total_price` decimal(10,2) NOT NULL,
  `guest_name` varchar(255) NOT NULL,
  `guest_phone` varchar(20) DEFAULT NULL,
  `guest_email` varchar(255) DEFAULT NULL,
  `guest_count` int(11) DEFAULT 1,
  `special_request` text DEFAULT NULL,
  `status` enum('pending','confirmed','cancelled','completed') DEFAULT 'pending',
  `payment_status` enum('pending','paid','refunded','failed') DEFAULT 'pending',
  `payment_method` varchar(100) DEFAULT NULL,
  `payment_proof` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `homestay_rooms`
--

CREATE TABLE `homestay_rooms` (
  `id` int(11) NOT NULL,
  `homestay_id` int(11) NOT NULL,
  `room_number` varchar(50) DEFAULT NULL,
  `room_type` varchar(100) DEFAULT NULL,
  `capacity` int(11) DEFAULT 1,
  `price_per_night` decimal(10,2) NOT NULL,
  `facilities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`facilities`)),
  `image` varchar(255) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('info','warning','alert','success') DEFAULT 'info',
  `related_entity_type` varchar(100) DEFAULT NULL,
  `related_entity_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `package_destinations`
--

CREATE TABLE `package_destinations` (
  `id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `destination_id` int(11) NOT NULL,
  `day_number` int(11) NOT NULL,
  `visit_order` int(11) NOT NULL,
  `duration_hours` decimal(5,2) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `package_inclusions`
--

CREATE TABLE `package_inclusions` (
  `id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `item` varchar(255) NOT NULL,
  `is_included` tinyint(1) DEFAULT 1,
  `category` enum('accommodation','transportation','meals','activities','other') DEFAULT 'other'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `package_itineraries`
--

CREATE TABLE `package_itineraries` (
  `id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `day_number` int(11) NOT NULL,
  `time` time DEFAULT NULL,
  `activity` varchar(255) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `display_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `destination_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `helpful_count` int(11) DEFAULT 0,
  `is_verified_visit` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `reviews`
--

INSERT INTO `reviews` (`id`, `user_id`, `destination_id`, `rating`, `comment`, `images`, `helpful_count`, `is_verified_visit`, `created_at`, `updated_at`) VALUES
(1, 5, 7, 4, 'pantainya bagus banget', NULL, 0, 0, '2026-04-29 14:19:01', '2026-04-29 14:19:01'),
(6, 5, 8, 2, 'wow', NULL, 0, 0, '2026-04-29 15:53:50', '2026-04-29 15:53:50');

-- --------------------------------------------------------

--
-- Struktur dari tabel `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `roles`
--

INSERT INTO `roles` (`id`, `name`, `display_name`, `permissions`, `created_at`) VALUES
(1, 'admin', 'Administrator', NULL, '2026-04-06 01:10:50'),
(2, 'operator', 'Agency/Homestay Operator', NULL, '2026-04-06 01:10:50'),
(3, 'contributor', 'Content Contributor', NULL, '2026-04-06 01:10:50'),
(4, 'user', 'Regular User', NULL, '2026-04-06 01:10:50'),
(9, '4', '4', NULL, '2026-04-29 11:25:35'),
(10, '1', '1', NULL, '2026-04-29 11:37:42');

-- --------------------------------------------------------

--
-- Struktur dari tabel `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `key_name` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tourism_destinations`
--

CREATE TABLE `tourism_destinations` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `category_id` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `village` varchar(100) DEFAULT NULL,
  `district` varchar(100) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `opening_hours` varchar(255) DEFAULT NULL,
  `ticket_price` decimal(10,2) DEFAULT 0.00,
  `parking_fee` decimal(10,2) DEFAULT 0.00,
  `contact_phone` varchar(20) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `main_image` varchar(255) DEFAULT NULL,
  `status` enum('draft','pending','published','archived') DEFAULT 'draft',
  `contributor_id` int(11) DEFAULT NULL,
  `operator_id` int(11) DEFAULT NULL,
  `views_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `tourism_destinations`
--

INSERT INTO `tourism_destinations` (`id`, `name`, `slug`, `category_id`, `description`, `address`, `village`, `district`, `latitude`, `longitude`, `opening_hours`, `ticket_price`, `parking_fee`, `contact_phone`, `contact_email`, `website`, `main_image`, `status`, `contributor_id`, `operator_id`, `views_count`, `created_at`, `updated_at`) VALUES
(7, 'Pantai Senggigi', 'pantai-senggigi', 6, 'Pantai paling populer di Lombok Barat dengan garis pantai panjang, sunset yang ikonik, serta fasilitas wisata lengkap.', 'Jl. Raya Senggigi, Desa Senggigi, Kecamatan Batulayar, Kabupaten Lombok Barat, NTB.', 'Senggigi', 'Batu Layar', -8.48960000, 116.04120000, '24 Hours', 2500.00, 2500.00, NULL, NULL, NULL, 'https://thelangkahtravel.com/wp-content/uploads/2020/03/Pantai-Senggigi-Lombok-2.jpg', 'published', NULL, NULL, 36, '2026-04-29 11:54:03', '2026-06-04 16:37:33'),
(8, 'Bukit Malimbu', 'bukit-malimbu', 7, 'Spot terbaik untuk menikmati panorama laut dan gugusan Gili dengan latar sunset yang dramatis.', 'H2GV+VQ7, Jl. Raya Senggigi, Malaka, Kec. Pemenang, Kabupaten Lombok Utara, Nusa Tenggara Bar. 83352', 'Malaka', 'Pemenang', -8.45300000, 116.03849999, '24 Hours', 5000.00, 5000.00, NULL, NULL, NULL, 'https://ik.imagekit.io/tvlk/blog/2025/05/bukit-malimbu-desktop.jpg?tr=q-70,c-at_max,w-500,h-250,dpr-2', 'published', NULL, NULL, 5, '2026-04-29 15:24:40', '2026-06-03 13:39:45'),
(9, 'Pantai Alberto', 'pantai-alberto', 6, 'Pantai Alberto (terkenal dengan kawasan Cafe Alberto) adalah destinasi bersantai tepi laut yang menawan di pesisir barat Lombok. Berlokasi di kawasan strategis Senggigi, pantai ini memadukan pesona pasir putih, pemandangan matahari terbenam yang spektakuler, serta suasana bersantap ala Italia di pinggir laut.', 'Jl. Raya Senggigi, Batu Bolong, Kecamatan Batu Layar, Kabupaten Lombok Barat, Nusa Tenggara Barat (83355).', 'Senggigi', 'Batu Layar', -8.50458660, 116.05446530, '24 Hours', 0.00, 2000.00, NULL, NULL, NULL, 'https://cf.bstatic.com/xdata/images/hotel/max1024x768/14920661.jpg?k=a16a072d4fe4b46a2e3d1a18fc8f713f5a011f0b7ddff5f383ffddd455029a38&o=', 'published', NULL, NULL, 3, '2026-06-03 05:39:09', '2026-06-03 15:34:33'),
(10, 'Gili Kedis', 'gili-kedis', 6, 'pulau mungil tak berpenghuni di barat daya Sekotong, Lombok Barat. Terkenal sebagai Honeymoon Island karena bentuknya yang menyerupai hati, pulau ini dapat dikelilingi dalam waktu kurang dari 5 menit. Pasir putihnya yang halus, air lautnya yang jernih, serta suasananya yang sepi menjadikannya destinasi sempurna untuk bersantai atau snorkeling.\r\n\r\nKarena harus menyeberang menggunakan perahu (slow boat), biaya terbesar tetap ada pada sewa perahu per rombongan (sekitar Rp300.000 untuk rute bolak-balik 3 pulau). Jadi, semakin banyak anggota rombongan Anda untuk patungan, biaya per orangnya akan jauh lebih murah', 'Sekotong Barat, Kecamatan Sekotong, Kabupaten Lombok Barat, Nusa Tenggara Barat, Indonesia', 'Sekotong Barat', 'Sekotong', -8.74199000, 116.06460000, NULL, 5000.00, 5000.00, NULL, NULL, NULL, 'https://i.ibb.co.com/zH5LPNHD/f7affa3c-1c5e-46e6-aad2-2d047b7fd8bd.jpg', 'published', NULL, NULL, 0, '2026-06-03 05:51:47', '2026-06-03 05:53:43');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tour_packages`
--

CREATE TABLE `tour_packages` (
  `id` int(11) NOT NULL,
  `agency_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `duration_days` int(11) NOT NULL DEFAULT 1,
  `min_person` int(11) DEFAULT 1,
  `max_person` int(11) DEFAULT NULL,
  `price_per_person` decimal(10,2) NOT NULL,
  `discount_percentage` decimal(5,2) DEFAULT 0.00,
  `main_image` varchar(255) DEFAULT NULL,
  `inclusions` text DEFAULT NULL,
  `exclusions` text DEFAULT NULL,
  `terms_conditions` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `is_featured` tinyint(1) DEFAULT 0,
  `views_count` int(11) DEFAULT 0,
  `booking_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `tour_packages`
--

INSERT INTO `tour_packages` (`id`, `agency_id`, `name`, `slug`, `description`, `duration_days`, `min_person`, `max_person`, `price_per_person`, `discount_percentage`, `main_image`, `inclusions`, `exclusions`, `terms_conditions`, `is_active`, `is_featured`, `views_count`, `booking_count`, `created_at`) VALUES
(5, 1, 'Lombok Barat Highlight Tour (Senggigi - Malimbu - Nipah)', 'lombok-barat-highlight-tour', 'Paket wisata satu hari menjelajahi destinasi ikonik Lombok Barat seperti Pantai Senggigi, Bukit Malimbu, dan Pantai Nipah. Nikmati kombinasi pantai eksotis, panorama laut dari ketinggian, serta kuliner lokal khas pesisir. Cocok untuk wisatawan yang ingin pengalaman singkat namun lengkap.', 1, 1, 10, 350000.00, 0.00, 'https://www.joglowisata.com/wp-content/themes/midway/framework/extensions/timthumb/timthumb.php?src=https%3A%2F%2Fwww.joglowisata.com%2Fwp-content%2Fuploads%2F2015%2F03%2FPaket-Wisata-Lombok-3-Hari-2-Malam.jpg&w=527', 'Transportasi AC (pickup & drop hotel)\r\nDriver + BBM\r\nTiket masuk objek wisata\r\nAir mineral', 'Makan & minum pribadi\r\nPengeluaran pribadi\r\nDokumentasi profesional', 'Harga berlaku untuk domestik traveler\r\nPenjemputan area Senggigi/Mataram (area lain tambahan biaya)\r\nPembatalan H-1 dikenakan 50% biaya\r\nCuaca buruk dapat mengubah itinerary', 1, 1, 0, 0, '2026-04-29 15:27:48');

-- --------------------------------------------------------

--
-- Struktur dari tabel `travel_agencies`
--

CREATE TABLE `travel_agencies` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `business_name` varchar(255) NOT NULL,
  `license_number` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `bank_account` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`bank_account`)),
  `is_verified` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `travel_agencies`
--

INSERT INTO `travel_agencies` (`id`, `user_id`, `business_name`, `license_number`, `address`, `phone`, `email`, `logo`, `description`, `bank_account`, `is_verified`, `is_active`, `created_at`) VALUES
(1, 3, 'Lombok Vista Tour & Travel', NULL, NULL, '08123456789', 'info@lombokvista.com', NULL, 'Penyedia layanan wisata terbaik di Lombok Barat.', NULL, 1, 1, '2026-04-06 01:23:37');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `fullname` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `profile_photo` varchar(255) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login` datetime DEFAULT NULL,
  `is_superuser` tinyint(1) DEFAULT 0,
  `is_staff` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `fullname`, `phone`, `role_id`, `profile_photo`, `is_verified`, `is_active`, `created_at`, `last_login`, `is_superuser`, `is_staff`) VALUES
(1, 'admin@lovista.com', 'pbkdf2_sha256$600000$kQ1Ye8jKKGuGKjn48l1GpW$8oNJhVTk6uZI6MOw7FvNgdfxSPYgSKfCuzB1KuEoTag=', 'System Admin', NULL, 1, '', 1, 1, '2026-04-06 01:10:50', NULL, 0, 0),
(3, 'operator@lovista.com', '$2b$10$vHiv5Pqu6nDEy.YOCcdBLOwS81HtNBj6g50OfZhJI31teHl99Yxee', 'Lombok Travel Agency', NULL, 2, NULL, 1, 1, '2026-04-06 01:23:37', NULL, 0, 0),
(4, '123@gmail.com', 'pbkdf2_sha256$600000$VQNkGqK1l7FDJRYjVWgevU$/NtLJ+rEpgC8hSuiRpy+MEhBmnRdQt6MYhMHyMK2eD0=', '123', '083132913123', 1, 'profiles/FORMAL.jpg', 0, 1, '2026-04-29 11:25:35', NULL, 0, 0),
(5, 'admin@gmail.com', 'pbkdf2_sha256$600000$BaIb6S59OGWvJN7SxCBvxZ$nUpwyY80Q+PoPm/K7++eBDV9peo4C9JqWGO5nQKFBFQ=', 'admin', '083132913370', 1, '', 0, 1, '2026-04-29 11:37:43', NULL, 0, 0),
(6, 'rama@gmail.com', 'pbkdf2_sha256$600000$n9blabi4LBSaLIWmgGWehS$Cs1V6S2IoPkLOVL+M37e70YXkQMfxIrwIdmp8a9CVCI=', 'Ahmad Ramadhani', NULL, 1, '', 0, 1, '2026-04-29 11:41:47', '2026-04-29 19:46:07', 1, 1),
(7, 'daniramadany2005@gmail.com', 'pbkdf2_sha256$600000$odXslqlQJcO5F8nJpntT9b$c66/RMTDmNgbxm/zrm9aWvzPqMWWmw7l42WtRRWlQnM=', 'Ahmad Ramadhani R', NULL, 1, 'profiles/FORMAL_BrfBwfb.jpg', 1, 1, '2026-06-03 05:31:45', '2026-06-04 17:49:42', 1, 1),
(8, 'johndoe@gmail.com', 'pbkdf2_sha256$600000$7eLwhyu26gdcPOzFG7PLNX$EG4GASZUPEX0KEr3uAEcZPJk2DZi2fYGd8cBNKW+a4s=', 'John Doe', '081123890283', 4, '', 0, 1, '2026-06-04 09:51:41', NULL, 0, 0);

-- --------------------------------------------------------

--
-- Struktur dari tabel `users_groups`
--

CREATE TABLE `users_groups` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users_user_permissions`
--

CREATE TABLE `users_user_permissions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `vehicles`
--

CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL,
  `agency_id` int(11) NOT NULL,
  `type` enum('car','motorcycle','bus','van','other') NOT NULL,
  `brand` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  `year` int(11) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `plate_number` varchar(20) NOT NULL,
  `daily_rate` decimal(10,2) NOT NULL,
  `driver_rate` decimal(10,2) DEFAULT 0.00,
  `image` varchar(255) DEFAULT NULL,
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`features`)),
  `is_available` tinyint(1) DEFAULT 1,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `vehicles`
--

INSERT INTO `vehicles` (`id`, `agency_id`, `type`, `brand`, `model`, `year`, `capacity`, `plate_number`, `daily_rate`, `driver_rate`, `image`, `features`, `is_available`, `is_active`, `created_at`) VALUES
(1, 1, 'car', 'Toyota', 'Avanza 1.5 G', 2022, 7, 'DR 1234 AB', 300000.00, 200000.00, 'https://imgcdn.oto.com/large/gallery/exterior/38/1654/toyota-avanza-front-angle-low-view-844132.jpg', '[\"Dengan drivetrain Front-Wheel Drive (FWD) yang memberikan efisiensi bahan bakar lebih baik\", \"Memiliki kapasitas kabin luas yang mampu menampung hingga 7 orang penumpang\", \"Dilengkapi fitur keselamatan canggih Toyota Safety Sense (TSS) pada varian tertinggi\", \"Menggunakan transmisi CVT Automatic untuk akselerasi yang lebih halus dan responsif\", \"Dilengkapi dengan Long Sofa Mode pada kursi untuk kenyamanan maksimal saat istirahat\"]', 1, 1, '2026-06-03 07:38:02');

-- --------------------------------------------------------

--
-- Struktur dari tabel `vehicle_rentals`
--

CREATE TABLE `vehicle_rentals` (
  `id` int(11) NOT NULL,
  `rental_number` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vehicle_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_days` int(11) GENERATED ALWAYS AS (to_days(`end_date`) - to_days(`start_date`) + 1) VIRTUAL,
  `daily_rate` decimal(10,2) NOT NULL,
  `driver_included` tinyint(1) DEFAULT 0,
  `driver_rate` decimal(10,2) DEFAULT 0.00,
  `total_price` decimal(10,2) NOT NULL,
  `pickup_location` varchar(255) DEFAULT NULL,
  `dropoff_location` varchar(255) DEFAULT NULL,
  `renter_name` varchar(255) NOT NULL,
  `renter_phone` varchar(20) NOT NULL,
  `renter_id_number` varchar(50) DEFAULT NULL,
  `renter_id_photo` varchar(255) DEFAULT NULL,
  `status` enum('pending','confirmed','cancelled','completed') DEFAULT 'pending',
  `payment_status` enum('pending','paid','refunded','failed') DEFAULT 'pending',
  `payment_method` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `wishlists`
--

CREATE TABLE `wishlists` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `destination_id` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `wishlists`
--

INSERT INTO `wishlists` (`id`, `user_id`, `destination_id`, `notes`, `created_at`) VALUES
(2, 5, 7, NULL, '2026-04-29 14:25:05');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_activity_logs_user_id` (`user_id`);

--
-- Indeks untuk tabel `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ai_recommendations_user_id` (`user_id`);

--
-- Indeks untuk tabel `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indeks untuk tabel `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indeks untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_number` (`booking_number`),
  ADD KEY `fk_bookings_user_id` (`user_id`),
  ADD KEY `fk_bookings_package_id` (`package_id`),
  ADD KEY `idx_bookings_status` (`status`),
  ADD KEY `idx_bookings_payment_status` (`payment_status`);

--
-- Indeks untuk tabel `contributions`
--
ALTER TABLE `contributions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_contributions_contributor_id` (`contributor_id`),
  ADD KEY `fk_contributions_reviewed_by` (`reviewed_by`);

--
-- Indeks untuk tabel `culinaries`
--
ALTER TABLE `culinaries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_culinaries_destination_id` (`destination_id`);
ALTER TABLE `culinaries` ADD FULLTEXT KEY `ft_culinaries_search` (`name`,`description`);

--
-- Indeks untuk tabel `cultures`
--
ALTER TABLE `cultures`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_cultures_contributor_id` (`contributor_id`);
ALTER TABLE `cultures` ADD FULLTEXT KEY `ft_cultures_search` (`name`,`description`,`location`);

--
-- Indeks untuk tabel `destination_categories`
--
ALTER TABLE `destination_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indeks untuk tabel `destination_facilities`
--
ALTER TABLE `destination_facilities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `destination_id` (`destination_id`,`facility_id`),
  ADD KEY `fk_dest_fac_facility_id` (`facility_id`);

--
-- Indeks untuk tabel `destination_images`
--
ALTER TABLE `destination_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_destination_images_destination_id` (`destination_id`),
  ADD KEY `fk_destination_images_uploaded_by` (`uploaded_by`);

--
-- Indeks untuk tabel `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`);

--
-- Indeks untuk tabel `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indeks untuk tabel `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indeks untuk tabel `facilities`
--
ALTER TABLE `facilities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `homestays`
--
ALTER TABLE `homestays`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_homestays_owner_id` (`owner_id`);

--
-- Indeks untuk tabel `homestay_bookings`
--
ALTER TABLE `homestay_bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_number` (`booking_number`),
  ADD KEY `fk_homestay_bookings_user_id` (`user_id`),
  ADD KEY `fk_homestay_bookings_room_id` (`room_id`);

--
-- Indeks untuk tabel `homestay_rooms`
--
ALTER TABLE `homestay_rooms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_homestay_rooms_homestay_id` (`homestay_id`);

--
-- Indeks untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user_read` (`user_id`,`is_read`);

--
-- Indeks untuk tabel `package_destinations`
--
ALTER TABLE `package_destinations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `package_id` (`package_id`,`destination_id`,`day_number`,`visit_order`),
  ADD KEY `fk_pkg_dest_destination_id` (`destination_id`);

--
-- Indeks untuk tabel `package_inclusions`
--
ALTER TABLE `package_inclusions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_package_inclusions_package_id` (`package_id`);

--
-- Indeks untuk tabel `package_itineraries`
--
ALTER TABLE `package_itineraries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_package_itineraries_package_day` (`package_id`,`day_number`);

--
-- Indeks untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`destination_id`),
  ADD KEY `fk_reviews_destination_id` (`destination_id`);

--
-- Indeks untuk tabel `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeks untuk tabel `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `key_name` (`key_name`),
  ADD KEY `fk_settings_updated_by` (`updated_by`);

--
-- Indeks untuk tabel `tourism_destinations`
--
ALTER TABLE `tourism_destinations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `fk_tourism_destinations_contributor_id` (`contributor_id`),
  ADD KEY `fk_tourism_destinations_operator_id` (`operator_id`),
  ADD KEY `idx_tourism_destinations_status` (`status`),
  ADD KEY `idx_tourism_destinations_district` (`district`),
  ADD KEY `idx_tourism_destinations_category_status` (`category_id`,`status`),
  ADD KEY `idx_tourism_destinations_district_status` (`district`,`status`);
ALTER TABLE `tourism_destinations` ADD FULLTEXT KEY `ft_tourism_destinations_search` (`name`,`description`,`address`);

--
-- Indeks untuk tabel `tour_packages`
--
ALTER TABLE `tour_packages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `fk_tour_packages_agency_id` (`agency_id`);

--
-- Indeks untuk tabel `travel_agencies`
--
ALTER TABLE `travel_agencies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_users_role_id` (`role_id`);

--
-- Indeks untuk tabel `users_groups`
--
ALTER TABLE `users_groups`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users_user_permissions`
--
ALTER TABLE `users_user_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `plate_number` (`plate_number`),
  ADD KEY `fk_vehicles_agency_id` (`agency_id`);

--
-- Indeks untuk tabel `vehicle_rentals`
--
ALTER TABLE `vehicle_rentals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rental_number` (`rental_number`),
  ADD KEY `fk_vehicle_rentals_user_id` (`user_id`),
  ADD KEY `fk_vehicle_rentals_vehicle_id` (`vehicle_id`);

--
-- Indeks untuk tabel `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`destination_id`),
  ADD KEY `fk_wishlists_destination_id` (`destination_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=129;

--
-- AUTO_INCREMENT untuk tabel `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `contributions`
--
ALTER TABLE `contributions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `culinaries`
--
ALTER TABLE `culinaries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `cultures`
--
ALTER TABLE `cultures`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `destination_categories`
--
ALTER TABLE `destination_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `destination_facilities`
--
ALTER TABLE `destination_facilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `destination_images`
--
ALTER TABLE `destination_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT untuk tabel `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT untuk tabel `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT untuk tabel `facilities`
--
ALTER TABLE `facilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `homestays`
--
ALTER TABLE `homestays`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `homestay_bookings`
--
ALTER TABLE `homestay_bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `homestay_rooms`
--
ALTER TABLE `homestay_rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `package_destinations`
--
ALTER TABLE `package_destinations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `package_inclusions`
--
ALTER TABLE `package_inclusions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `package_itineraries`
--
ALTER TABLE `package_itineraries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `tourism_destinations`
--
ALTER TABLE `tourism_destinations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `tour_packages`
--
ALTER TABLE `tour_packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `travel_agencies`
--
ALTER TABLE `travel_agencies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT untuk tabel `users_groups`
--
ALTER TABLE `users_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users_user_permissions`
--
ALTER TABLE `users_user_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `vehicle_rentals`
--
ALTER TABLE `vehicle_rentals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_activity_logs_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  ADD CONSTRAINT `fk_ai_recommendations_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Ketidakleluasaan untuk tabel `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Ketidakleluasaan untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `fk_bookings_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bookings_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `contributions`
--
ALTER TABLE `contributions`
  ADD CONSTRAINT `fk_contributions_contributor_id` FOREIGN KEY (`contributor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_contributions_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `culinaries`
--
ALTER TABLE `culinaries`
  ADD CONSTRAINT `fk_culinaries_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `cultures`
--
ALTER TABLE `cultures`
  ADD CONSTRAINT `fk_cultures_contributor_id` FOREIGN KEY (`contributor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `destination_facilities`
--
ALTER TABLE `destination_facilities`
  ADD CONSTRAINT `fk_dest_fac_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dest_fac_facility_id` FOREIGN KEY (`facility_id`) REFERENCES `facilities` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `destination_images`
--
ALTER TABLE `destination_images`
  ADD CONSTRAINT `fk_destination_images_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_destination_images_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Ketidakleluasaan untuk tabel `homestays`
--
ALTER TABLE `homestays`
  ADD CONSTRAINT `fk_homestays_owner_id` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `homestay_bookings`
--
ALTER TABLE `homestay_bookings`
  ADD CONSTRAINT `fk_homestay_bookings_room_id` FOREIGN KEY (`room_id`) REFERENCES `homestay_rooms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_homestay_bookings_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `homestay_rooms`
--
ALTER TABLE `homestay_rooms`
  ADD CONSTRAINT `fk_homestay_rooms_homestay_id` FOREIGN KEY (`homestay_id`) REFERENCES `homestays` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `package_destinations`
--
ALTER TABLE `package_destinations`
  ADD CONSTRAINT `fk_pkg_dest_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pkg_dest_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `package_inclusions`
--
ALTER TABLE `package_inclusions`
  ADD CONSTRAINT `fk_package_inclusions_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `package_itineraries`
--
ALTER TABLE `package_itineraries`
  ADD CONSTRAINT `fk_package_itineraries_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_reviews_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reviews_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `settings`
--
ALTER TABLE `settings`
  ADD CONSTRAINT `fk_settings_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `tourism_destinations`
--
ALTER TABLE `tourism_destinations`
  ADD CONSTRAINT `fk_tourism_destinations_category_id` FOREIGN KEY (`category_id`) REFERENCES `destination_categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tourism_destinations_contributor_id` FOREIGN KEY (`contributor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tourism_destinations_operator_id` FOREIGN KEY (`operator_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ketidakleluasaan untuk tabel `tour_packages`
--
ALTER TABLE `tour_packages`
  ADD CONSTRAINT `fk_tour_packages_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `travel_agencies` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `travel_agencies`
--
ALTER TABLE `travel_agencies`
  ADD CONSTRAINT `fk_travel_agencies_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `fk_vehicles_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `travel_agencies` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `vehicle_rentals`
--
ALTER TABLE `vehicle_rentals`
  ADD CONSTRAINT `fk_vehicle_rentals_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_vehicle_rentals_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `fk_wishlists_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_wishlists_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Database: `phpmyadmin`
--
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `phpmyadmin`;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__bookmark`
--

CREATE TABLE `pma__bookmark` (
  `id` int(10) UNSIGNED NOT NULL,
  `dbase` varchar(255) NOT NULL DEFAULT '',
  `user` varchar(255) NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `query` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Bookmarks';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__central_columns`
--

CREATE TABLE `pma__central_columns` (
  `db_name` varchar(64) NOT NULL,
  `col_name` varchar(64) NOT NULL,
  `col_type` varchar(64) NOT NULL,
  `col_length` text DEFAULT NULL,
  `col_collation` varchar(64) NOT NULL,
  `col_isNull` tinyint(1) NOT NULL,
  `col_extra` varchar(255) DEFAULT '',
  `col_default` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Central list of columns';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__column_info`
--

CREATE TABLE `pma__column_info` (
  `id` int(5) UNSIGNED NOT NULL,
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `column_name` varchar(64) NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) NOT NULL DEFAULT '',
  `transformation_options` varchar(255) NOT NULL DEFAULT '',
  `input_transformation` varchar(255) NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Column information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__designer_settings`
--

CREATE TABLE `pma__designer_settings` (
  `username` varchar(64) NOT NULL,
  `settings_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Settings related to Designer';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__export_templates`
--

CREATE TABLE `pma__export_templates` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL,
  `export_type` varchar(10) NOT NULL,
  `template_name` varchar(64) NOT NULL,
  `template_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved export templates';

--
-- Dumping data untuk tabel `pma__export_templates`
--

INSERT INTO `pma__export_templates` (`id`, `username`, `export_type`, `template_name`, `template_data`) VALUES
(1, 'root', 'database', 'lovista', '{\"quick_or_custom\":\"quick\",\"what\":\"sql\",\"structure_or_data_forced\":\"0\",\"table_select[]\":[\"activity_logs\",\"ai_recommendations\",\"auth_group\",\"auth_group_permissions\",\"auth_permission\",\"bookings\",\"contributions\",\"culinaries\",\"cultures\",\"destination_categories\",\"destination_facilities\",\"destination_images\",\"django_admin_log\",\"django_content_type\",\"django_migrations\",\"django_session\",\"facilities\",\"homestays\",\"homestay_bookings\",\"homestay_rooms\",\"notifications\",\"package_destinations\",\"package_inclusions\",\"package_itineraries\",\"reviews\",\"roles\",\"settings\",\"tourism_destinations\",\"tour_packages\",\"travel_agencies\",\"users\",\"vehicles\",\"vehicle_rentals\",\"wishlists\"],\"table_structure[]\":[\"activity_logs\",\"ai_recommendations\",\"auth_group\",\"auth_group_permissions\",\"auth_permission\",\"bookings\",\"contributions\",\"culinaries\",\"cultures\",\"destination_categories\",\"destination_facilities\",\"destination_images\",\"django_admin_log\",\"django_content_type\",\"django_migrations\",\"django_session\",\"facilities\",\"homestays\",\"homestay_bookings\",\"homestay_rooms\",\"notifications\",\"package_destinations\",\"package_inclusions\",\"package_itineraries\",\"reviews\",\"roles\",\"settings\",\"tourism_destinations\",\"tour_packages\",\"travel_agencies\",\"users\",\"vehicles\",\"vehicle_rentals\",\"wishlists\"],\"table_data[]\":[\"activity_logs\",\"ai_recommendations\",\"auth_group\",\"auth_group_permissions\",\"auth_permission\",\"bookings\",\"contributions\",\"culinaries\",\"cultures\",\"destination_categories\",\"destination_facilities\",\"destination_images\",\"django_admin_log\",\"django_content_type\",\"django_migrations\",\"django_session\",\"facilities\",\"homestays\",\"homestay_bookings\",\"homestay_rooms\",\"notifications\",\"package_destinations\",\"package_inclusions\",\"package_itineraries\",\"reviews\",\"roles\",\"settings\",\"tourism_destinations\",\"tour_packages\",\"travel_agencies\",\"users\",\"vehicles\",\"vehicle_rentals\",\"wishlists\"],\"aliases_new\":\"\",\"output_format\":\"sendit\",\"filename_template\":\"@DATABASE@\",\"remember_template\":\"on\",\"charset\":\"utf-8\",\"compression\":\"none\",\"maxsize\":\"\",\"codegen_structure_or_data\":\"data\",\"codegen_format\":\"0\",\"csv_separator\":\",\",\"csv_enclosed\":\"\\\"\",\"csv_escaped\":\"\\\"\",\"csv_terminated\":\"AUTO\",\"csv_null\":\"NULL\",\"csv_columns\":\"something\",\"csv_structure_or_data\":\"data\",\"excel_null\":\"NULL\",\"excel_columns\":\"something\",\"excel_edition\":\"win\",\"excel_structure_or_data\":\"data\",\"json_structure_or_data\":\"data\",\"json_unicode\":\"something\",\"latex_caption\":\"something\",\"latex_structure_or_data\":\"structure_and_data\",\"latex_structure_caption\":\"Struktur tabel @TABLE@\",\"latex_structure_continued_caption\":\"Struktur tabel @TABLE@ (dilanjutkan)\",\"latex_structure_label\":\"tab:@TABLE@-structure\",\"latex_relation\":\"something\",\"latex_comments\":\"something\",\"latex_mime\":\"something\",\"latex_columns\":\"something\",\"latex_data_caption\":\"Isi tabel @TABLE@\",\"latex_data_continued_caption\":\"Isi tabel @TABLE@ (dilanjutkan)\",\"latex_data_label\":\"tab:@TABLE@-data\",\"latex_null\":\"\\\\textit{NULL}\",\"mediawiki_structure_or_data\":\"structure_and_data\",\"mediawiki_caption\":\"something\",\"mediawiki_headers\":\"something\",\"htmlword_structure_or_data\":\"structure_and_data\",\"htmlword_null\":\"NULL\",\"ods_null\":\"NULL\",\"ods_structure_or_data\":\"data\",\"odt_structure_or_data\":\"structure_and_data\",\"odt_relation\":\"something\",\"odt_comments\":\"something\",\"odt_mime\":\"something\",\"odt_columns\":\"something\",\"odt_null\":\"NULL\",\"pdf_report_title\":\"\",\"pdf_structure_or_data\":\"structure_and_data\",\"phparray_structure_or_data\":\"data\",\"sql_include_comments\":\"something\",\"sql_header_comment\":\"\",\"sql_use_transaction\":\"something\",\"sql_compatibility\":\"NONE\",\"sql_structure_or_data\":\"structure_and_data\",\"sql_create_table\":\"something\",\"sql_auto_increment\":\"something\",\"sql_create_view\":\"something\",\"sql_procedure_function\":\"something\",\"sql_create_trigger\":\"something\",\"sql_backquotes\":\"something\",\"sql_type\":\"INSERT\",\"sql_insert_syntax\":\"both\",\"sql_max_query_size\":\"50000\",\"sql_hex_for_binary\":\"something\",\"sql_utc_time\":\"something\",\"texytext_structure_or_data\":\"structure_and_data\",\"texytext_null\":\"NULL\",\"xml_structure_or_data\":\"data\",\"xml_export_events\":\"something\",\"xml_export_functions\":\"something\",\"xml_export_procedures\":\"something\",\"xml_export_tables\":\"something\",\"xml_export_triggers\":\"something\",\"xml_export_views\":\"something\",\"xml_export_contents\":\"something\",\"yaml_structure_or_data\":\"data\",\"\":null,\"lock_tables\":null,\"as_separate_files\":null,\"csv_removeCRLF\":null,\"excel_removeCRLF\":null,\"json_pretty_print\":null,\"htmlword_columns\":null,\"ods_columns\":null,\"sql_dates\":null,\"sql_relation\":null,\"sql_mime\":null,\"sql_disable_fk\":null,\"sql_views_as_tables\":null,\"sql_metadata\":null,\"sql_create_database\":null,\"sql_drop_table\":null,\"sql_if_not_exists\":null,\"sql_simple_view_export\":null,\"sql_view_current_user\":null,\"sql_or_replace_view\":null,\"sql_truncate\":null,\"sql_delayed\":null,\"sql_ignore\":null,\"texytext_columns\":null}');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__favorite`
--

CREATE TABLE `pma__favorite` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Favorite tables';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__history`
--

CREATE TABLE `pma__history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db` varchar(64) NOT NULL DEFAULT '',
  `table` varchar(64) NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='SQL history for phpMyAdmin';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__navigationhiding`
--

CREATE TABLE `pma__navigationhiding` (
  `username` varchar(64) NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `item_type` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Hidden items of navigation tree';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__pdf_pages`
--

CREATE TABLE `pma__pdf_pages` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `page_nr` int(10) UNSIGNED NOT NULL,
  `page_descr` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='PDF relation pages for phpMyAdmin';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__recent`
--

CREATE TABLE `pma__recent` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Recently accessed tables';

--
-- Dumping data untuk tabel `pma__recent`
--

INSERT INTO `pma__recent` (`username`, `tables`) VALUES
('root', '[{\"db\":\"lovista\",\"table\":\"users\"}]');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__relation`
--

CREATE TABLE `pma__relation` (
  `master_db` varchar(64) NOT NULL DEFAULT '',
  `master_table` varchar(64) NOT NULL DEFAULT '',
  `master_field` varchar(64) NOT NULL DEFAULT '',
  `foreign_db` varchar(64) NOT NULL DEFAULT '',
  `foreign_table` varchar(64) NOT NULL DEFAULT '',
  `foreign_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Relation table';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__savedsearches`
--

CREATE TABLE `pma__savedsearches` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `search_name` varchar(64) NOT NULL DEFAULT '',
  `search_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved searches';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__table_coords`
--

CREATE TABLE `pma__table_coords` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `pdf_page_number` int(11) NOT NULL DEFAULT 0,
  `x` float UNSIGNED NOT NULL DEFAULT 0,
  `y` float UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table coordinates for phpMyAdmin PDF output';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__table_info`
--

CREATE TABLE `pma__table_info` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `display_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__table_uiprefs`
--

CREATE TABLE `pma__table_uiprefs` (
  `username` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `prefs` text NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Tables'' UI preferences';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__tracking`
--

CREATE TABLE `pma__tracking` (
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `version` int(10) UNSIGNED NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text NOT NULL,
  `schema_sql` text DEFAULT NULL,
  `data_sql` longtext DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') DEFAULT NULL,
  `tracking_active` int(1) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Database changes tracking for phpMyAdmin';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__userconfig`
--

CREATE TABLE `pma__userconfig` (
  `username` varchar(64) NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User preferences storage for phpMyAdmin';

--
-- Dumping data untuk tabel `pma__userconfig`
--

INSERT INTO `pma__userconfig` (`username`, `timevalue`, `config_data`) VALUES
('root', '2026-06-05 04:49:26', '{\"Console\\/Mode\":\"collapse\",\"lang\":\"id\"}');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__usergroups`
--

CREATE TABLE `pma__usergroups` (
  `usergroup` varchar(64) NOT NULL,
  `tab` varchar(64) NOT NULL,
  `allowed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User groups with configured menu items';

-- --------------------------------------------------------

--
-- Struktur dari tabel `pma__users`
--

CREATE TABLE `pma__users` (
  `username` varchar(64) NOT NULL,
  `usergroup` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users and their assignments to user groups';

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `pma__central_columns`
--
ALTER TABLE `pma__central_columns`
  ADD PRIMARY KEY (`db_name`,`col_name`);

--
-- Indeks untuk tabel `pma__column_info`
--
ALTER TABLE `pma__column_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`);

--
-- Indeks untuk tabel `pma__designer_settings`
--
ALTER TABLE `pma__designer_settings`
  ADD PRIMARY KEY (`username`);

--
-- Indeks untuk tabel `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`);

--
-- Indeks untuk tabel `pma__favorite`
--
ALTER TABLE `pma__favorite`
  ADD PRIMARY KEY (`username`);

--
-- Indeks untuk tabel `pma__history`
--
ALTER TABLE `pma__history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`,`db`,`table`,`timevalue`);

--
-- Indeks untuk tabel `pma__navigationhiding`
--
ALTER TABLE `pma__navigationhiding`
  ADD PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`);

--
-- Indeks untuk tabel `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  ADD PRIMARY KEY (`page_nr`),
  ADD KEY `db_name` (`db_name`);

--
-- Indeks untuk tabel `pma__recent`
--
ALTER TABLE `pma__recent`
  ADD PRIMARY KEY (`username`);

--
-- Indeks untuk tabel `pma__relation`
--
ALTER TABLE `pma__relation`
  ADD PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  ADD KEY `foreign_field` (`foreign_db`,`foreign_table`);

--
-- Indeks untuk tabel `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`);

--
-- Indeks untuk tabel `pma__table_coords`
--
ALTER TABLE `pma__table_coords`
  ADD PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`);

--
-- Indeks untuk tabel `pma__table_info`
--
ALTER TABLE `pma__table_info`
  ADD PRIMARY KEY (`db_name`,`table_name`);

--
-- Indeks untuk tabel `pma__table_uiprefs`
--
ALTER TABLE `pma__table_uiprefs`
  ADD PRIMARY KEY (`username`,`db_name`,`table_name`);

--
-- Indeks untuk tabel `pma__tracking`
--
ALTER TABLE `pma__tracking`
  ADD PRIMARY KEY (`db_name`,`table_name`,`version`);

--
-- Indeks untuk tabel `pma__userconfig`
--
ALTER TABLE `pma__userconfig`
  ADD PRIMARY KEY (`username`);

--
-- Indeks untuk tabel `pma__usergroups`
--
ALTER TABLE `pma__usergroups`
  ADD PRIMARY KEY (`usergroup`,`tab`,`allowed`);

--
-- Indeks untuk tabel `pma__users`
--
ALTER TABLE `pma__users`
  ADD PRIMARY KEY (`username`,`usergroup`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pma__column_info`
--
ALTER TABLE `pma__column_info`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `pma__history`
--
ALTER TABLE `pma__history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  MODIFY `page_nr` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- Database: `test`
--
CREATE DATABASE IF NOT EXISTS `test` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `test`;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
