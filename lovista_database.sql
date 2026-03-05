SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lovista`
--

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) UNIQUE NOT NULL,
  `display_name` VARCHAR(100) NOT NULL,
  `permissions` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `fullname` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20),
  `role_id` INT NOT NULL,
  `profile_photo` VARCHAR(255),
  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_users_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `destination_categories`
--

DROP TABLE IF EXISTS `destination_categories`;
CREATE TABLE IF NOT EXISTS `destination_categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(120) UNIQUE NOT NULL,
  `icon` VARCHAR(255),
  `description` TEXT,
  `display_order` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tourism_destinations`
--

DROP TABLE IF EXISTS `tourism_destinations`;
CREATE TABLE IF NOT EXISTS `tourism_destinations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) UNIQUE NOT NULL,
  `category_id` INT NOT NULL,
  `description` TEXT,
  `address` VARCHAR(255),
  `village` VARCHAR(100),
  `district` VARCHAR(100),
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `opening_hours` VARCHAR(255),
  `ticket_price` DECIMAL(10, 2) DEFAULT 0.00,
  `parking_fee` DECIMAL(10, 2) DEFAULT 0.00,
  `contact_phone` VARCHAR(20),
  `contact_email` VARCHAR(255),
  `website` VARCHAR(255),
  `main_image` VARCHAR(255),
  `status` ENUM('draft', 'pending', 'published', 'archived') DEFAULT 'draft',
  `contributor_id` INT,
  `operator_id` INT,
  `views_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_tourism_destinations_category_id` FOREIGN KEY (`category_id`) REFERENCES `destination_categories`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tourism_destinations_contributor_id` FOREIGN KEY (`contributor_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_tourism_destinations_operator_id` FOREIGN KEY (`operator_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `destination_images`
--

DROP TABLE IF EXISTS `destination_images`;
CREATE TABLE IF NOT EXISTS `destination_images` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `destination_id` INT NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `caption` VARCHAR(255),
  `display_order` INT DEFAULT 0,
  `uploaded_by` INT,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_destination_images_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_destination_images_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `facilities`
--

DROP TABLE IF EXISTS `facilities`;
CREATE TABLE IF NOT EXISTS `facilities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) UNIQUE NOT NULL,
  `icon` VARCHAR(255),
  `description` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `destination_facilities`
--

DROP TABLE IF EXISTS `destination_facilities`;
CREATE TABLE IF NOT EXISTS `destination_facilities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `destination_id` INT NOT NULL,
  `facility_id` INT NOT NULL,
  `notes` TEXT,
  `is_available` BOOLEAN DEFAULT TRUE,
  CONSTRAINT `fk_dest_fac_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dest_fac_facility_id` FOREIGN KEY (`facility_id`) REFERENCES `facilities`(`id`) ON DELETE CASCADE,
  UNIQUE (`destination_id`, `facility_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `culinaries`
--

DROP TABLE IF EXISTS `culinaries`;
CREATE TABLE IF NOT EXISTS `culinaries` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `destination_id` INT,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `price_range` VARCHAR(50),
  `contact` VARCHAR(255),
  `image` VARCHAR(255),
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `is_standalone` BOOLEAN DEFAULT FALSE,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_culinaries_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cultures`
--

DROP TABLE IF EXISTS `cultures`;
CREATE TABLE IF NOT EXISTS `cultures` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `location` VARCHAR(255),
  `event_date` DATE,
  `event_frequency` VARCHAR(100),
  `images` JSON,
  `contributor_id` INT,
  `status` ENUM('draft', 'pending', 'published', 'archived') DEFAULT 'draft',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_cultures_contributor_id` FOREIGN KEY (`contributor_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `destination_id` INT NOT NULL,
  `rating` TINYINT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `comment` TEXT,
  `images` JSON,
  `helpful_count` INT DEFAULT 0,
  `is_verified_visit` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_reviews_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations`(`id`) ON DELETE CASCADE,
  UNIQUE (`user_id`, `destination_id`) -- A user can only review a destination once
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

DROP TABLE IF EXISTS `wishlists`;
CREATE TABLE IF NOT EXISTS `wishlists` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `destination_id` INT NOT NULL,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_wishlists_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlists_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations`(`id`) ON DELETE CASCADE,
  UNIQUE (`user_id`, `destination_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `travel_agencies`
--

DROP TABLE IF EXISTS `travel_agencies`;
CREATE TABLE IF NOT EXISTS `travel_agencies` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNIQUE NOT NULL,
  `business_name` VARCHAR(255) NOT NULL,
  `license_number` VARCHAR(100),
  `address` VARCHAR(255),
  `phone` VARCHAR(20),
  `email` VARCHAR(255),
  `logo` VARCHAR(255),
  `description` TEXT,
  `bank_account` JSON,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_travel_agencies_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tour_packages`
--

DROP TABLE IF EXISTS `tour_packages`;
CREATE TABLE IF NOT EXISTS `tour_packages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `agency_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) UNIQUE NOT NULL,
  `description` TEXT,
  `duration_days` INT NOT NULL DEFAULT 1,
  `min_person` INT DEFAULT 1,
  `max_person` INT,
  `price_per_person` DECIMAL(10, 2) NOT NULL,
  `discount_percentage` DECIMAL(5, 2) DEFAULT 0.00,
  `main_image` VARCHAR(255),
  `inclusions` TEXT,
  `exclusions` TEXT,
  `terms_conditions` TEXT,
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `views_count` INT DEFAULT 0,
  `booking_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_tour_packages_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `travel_agencies`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `package_destinations`
--

DROP TABLE IF EXISTS `package_destinations`;
CREATE TABLE IF NOT EXISTS `package_destinations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `package_id` INT NOT NULL,
  `destination_id` INT NOT NULL,
  `day_number` INT NOT NULL,
  `visit_order` INT NOT NULL,
  `duration_hours` DECIMAL(5, 2),
  `notes` TEXT,
  CONSTRAINT `fk_pkg_dest_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pkg_dest_destination_id` FOREIGN KEY (`destination_id`) REFERENCES `tourism_destinations`(`id`) ON DELETE CASCADE,
  UNIQUE (`package_id`, `destination_id`, `day_number`, `visit_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `package_itineraries`
--

DROP TABLE IF EXISTS `package_itineraries`;
CREATE TABLE IF NOT EXISTS `package_itineraries` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `package_id` INT NOT NULL,
  `day_number` INT NOT NULL,
  `time` TIME,
  `activity` VARCHAR(255) NOT NULL,
  `location` VARCHAR(255),
  `description` TEXT,
  `image` VARCHAR(255),
  `display_order` INT DEFAULT 0,
  CONSTRAINT `fk_package_itineraries_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `package_inclusions`
--

DROP TABLE IF EXISTS `package_inclusions`;
CREATE TABLE IF NOT EXISTS `package_inclusions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `package_id` INT NOT NULL,
  `item` VARCHAR(255) NOT NULL,
  `is_included` BOOLEAN DEFAULT TRUE,
  `category` ENUM('accommodation', 'transportation', 'meals', 'activities', 'other') DEFAULT 'other',
  CONSTRAINT `fk_package_inclusions_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `agency_id` INT NOT NULL,
  `type` ENUM('car', 'motorcycle', 'bus', 'van', 'other') NOT NULL,
  `brand` VARCHAR(100) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  `year` INT,
  `capacity` INT,
  `plate_number` VARCHAR(20) UNIQUE NOT NULL,
  `daily_rate` DECIMAL(10, 2) NOT NULL,
  `driver_rate` DECIMAL(10, 2) DEFAULT 0.00,
  `image` VARCHAR(255),
  `features` JSON,
  `is_available` BOOLEAN DEFAULT TRUE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_vehicles_agency_id` FOREIGN KEY (`agency_id`) REFERENCES `travel_agencies`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `homestays`
--

DROP TABLE IF EXISTS `homestays`;
CREATE TABLE IF NOT EXISTS `homestays` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `owner_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `address` VARCHAR(255),
  `village` VARCHAR(100),
  `district` VARCHAR(100),
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `total_rooms` INT DEFAULT 1,
  `description` TEXT,
  `phone` VARCHAR(20),
  `amenities` JSON,
  `main_image` VARCHAR(255),
  `check_in_time` TIME DEFAULT '14:00:00',
  `check_out_time` TIME DEFAULT '12:00:00',
  `policies` TEXT,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_homestays_owner_id` FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `homestay_rooms`
--

DROP TABLE IF EXISTS `homestay_rooms`;
CREATE TABLE IF NOT EXISTS `homestay_rooms` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `homestay_id` INT NOT NULL,
  `room_number` VARCHAR(50),
  `room_type` VARCHAR(100),
  `capacity` INT DEFAULT 1,
  `price_per_night` DECIMAL(10, 2) NOT NULL,
  `facilities` JSON,
  `image` VARCHAR(255),
  `is_available` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_homestay_rooms_homestay_id` FOREIGN KEY (`homestay_id`) REFERENCES `homestays`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_number` VARCHAR(50) UNIQUE NOT NULL,
  `user_id` INT NOT NULL,
  `package_id` INT NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `total_person` INT NOT NULL,
  `total_price` DECIMAL(10, 2) NOT NULL,
  `discount_amount` DECIMAL(10, 2) DEFAULT 0.00,
  `final_price` DECIMAL(10, 2) GENERATED ALWAYS AS (`total_price` - `discount_amount`) VIRTUAL,
  `special_request` TEXT,
  `status` ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
  `payment_status` ENUM('pending', 'paid', 'refunded', 'failed') DEFAULT 'pending',
  `payment_method` VARCHAR(100),
  `payment_proof` VARCHAR(255),
  `notes` TEXT,
  `cancelled_at` TIMESTAMP NULL,
  `cancelled_reason` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_bookings_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bookings_package_id` FOREIGN KEY (`package_id`) REFERENCES `tour_packages`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `homestay_bookings`
--

DROP TABLE IF EXISTS `homestay_bookings`;
CREATE TABLE IF NOT EXISTS `homestay_bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_number` VARCHAR(50) UNIQUE NOT NULL,
  `user_id` INT NOT NULL,
  `room_id` INT NOT NULL,
  `check_in` DATE NOT NULL,
  `check_out` DATE NOT NULL,
  `total_nights` INT GENERATED ALWAYS AS (DATEDIFF(`check_out`, `check_in`)) VIRTUAL,
  `total_price` DECIMAL(10, 2) NOT NULL,
  `guest_name` VARCHAR(255) NOT NULL,
  `guest_phone` VARCHAR(20),
  `guest_email` VARCHAR(255),
  `guest_count` INT DEFAULT 1,
  `special_request` TEXT,
  `status` ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
  `payment_status` ENUM('pending', 'paid', 'refunded', 'failed') DEFAULT 'pending',
  `payment_method` VARCHAR(100),
  `payment_proof` VARCHAR(255),
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_homestay_bookings_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_homestay_bookings_room_id` FOREIGN KEY (`room_id`) REFERENCES `homestay_rooms`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_rentals`
--

DROP TABLE IF EXISTS `vehicle_rentals`;
CREATE TABLE IF NOT EXISTS `vehicle_rentals` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `rental_number` VARCHAR(50) UNIQUE NOT NULL,
  `user_id` INT NOT NULL,
  `vehicle_id` INT NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `total_days` INT GENERATED ALWAYS AS (DATEDIFF(`end_date`, `start_date`) + 1) VIRTUAL,
  `daily_rate` DECIMAL(10, 2) NOT NULL,
  `driver_included` BOOLEAN DEFAULT FALSE,
  `driver_rate` DECIMAL(10, 2) DEFAULT 0.00,
  `total_price` DECIMAL(10, 2) NOT NULL,
  `pickup_location` VARCHAR(255),
  `dropoff_location` VARCHAR(255),
  `renter_name` VARCHAR(255) NOT NULL,
  `renter_phone` VARCHAR(20) NOT NULL,
  `renter_id_number` VARCHAR(50),
  `renter_id_photo` VARCHAR(255),
  `status` ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
  `payment_status` ENUM('pending', 'paid', 'refunded', 'failed') DEFAULT 'pending',
  `payment_method` VARCHAR(100),
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_vehicle_rentals_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vehicle_rentals_vehicle_id` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_recommendations`
--

DROP TABLE IF EXISTS `ai_recommendations`;
CREATE TABLE IF NOT EXISTS `ai_recommendations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT,
  `session_id` VARCHAR(255),
  `preferences` JSON,
  `budget` DECIMAL(10, 2),
  `duration` VARCHAR(100),
  `travel_style` VARCHAR(100),
  `interests` JSON,
  `recommendations` JSON,
  `feedback_rating` TINYINT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_ai_recommendations_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `contributions`
--

DROP TABLE IF EXISTS `contributions`;
CREATE TABLE IF NOT EXISTS `contributions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `contributor_id` INT NOT NULL,
  `type` ENUM('destination', 'culinary', 'culture', 'other') NOT NULL,
  `entity_id` INT, -- ID of the entity being contributed/modified, NULL if new
  `data` JSON NOT NULL, -- The new or updated data for the entity
  `status` ENUM('pending', 'approved', 'rejected', 'revision_requested') DEFAULT 'pending',
  `rejection_reason` TEXT,
  `revision_notes` TEXT,
  `reviewed_by` INT,
  `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` TIMESTAMP NULL,
  CONSTRAINT `fk_contributions_contributor_id` FOREIGN KEY (`contributor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_contributions_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT,
  `action` VARCHAR(255) NOT NULL,
  `entity_type` VARCHAR(100),
  `entity_id` INT,
  `old_value` JSON,
  `new_value` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_activity_logs_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
CREATE TABLE IF NOT EXISTS `settings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `key_name` VARCHAR(255) UNIQUE NOT NULL,
  `value` TEXT,
  `type` VARCHAR(50),
  `description` TEXT,
  `is_public` BOOLEAN DEFAULT FALSE,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` INT,
  CONSTRAINT `fk_settings_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `type` ENUM('info', 'warning', 'alert', 'success') DEFAULT 'info',
  `related_entity_type` VARCHAR(100),
  `related_entity_id` INT,
  `is_read` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `read_at` TIMESTAMP NULL,
  CONSTRAINT `fk_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for `tourism_destinations`
--
CREATE INDEX `idx_tourism_destinations_status` ON `tourism_destinations` (`status`);
CREATE INDEX `idx_tourism_destinations_district` ON `tourism_destinations` (`district`);
CREATE INDEX `idx_tourism_destinations_category_status` ON `tourism_destinations` (`category_id`, `status`);
CREATE INDEX `idx_tourism_destinations_district_status` ON `tourism_destinations` (`district`, `status`);
ALTER TABLE `tourism_destinations` ADD FULLTEXT KEY `ft_tourism_destinations_search` (`name`, `description`, `address`);

--
-- Indexes for `bookings`
--
CREATE INDEX `idx_bookings_status` ON `bookings` (`status`);
CREATE INDEX `idx_bookings_payment_status` ON `bookings` (`payment_status`);

--
-- Indexes for `package_itineraries`
--
CREATE INDEX `idx_package_itineraries_package_day` ON `package_itineraries` (`package_id`, `day_number`);

--
-- Indexes for `cultures`
--
ALTER TABLE `cultures` ADD FULLTEXT KEY `ft_cultures_search` (`name`, `description`, `location`);

--
-- Indexes for `culinaries`
--
ALTER TABLE `culinaries` ADD FULLTEXT KEY `ft_culinaries_search` (`name`, `description`);

--
-- Indexes for `notifications`
--
CREATE INDEX `idx_notifications_user_read` ON `notifications` (`user_id`, `is_read`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
