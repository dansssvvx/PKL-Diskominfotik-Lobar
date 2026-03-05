// ─── USER MANAGEMENT ───────────────────────────────────────────────────────

export type UserRole = 'user' | 'operator' | 'admin'

export interface Role {
  id: number
  name: UserRole
  display_name: string
  permissions: Record<string, boolean> | null
  created_at: string
}

export interface User {
  id: number
  email: string
  fullname: string
  phone: string | null
  role_id: number
  role?: Role
  profile_photo: string | null
  is_verified: boolean
  is_active: boolean
  created_at: string
}

export interface AuthUser extends User {
  token: string
}

// ─── TOURISM CONTENT ────────────────────────────────────────────────────────

export type DestinationStatus = 'draft' | 'pending' | 'published' | 'archived'

export interface DestinationCategory {
  id: number
  name: string
  slug: string
  icon: string | null
  description: string | null
  display_order: number
}

export interface Facility {
  id: number
  name: string
  icon: string | null
  description: string | null
}

export interface DestinationFacility {
  id: number
  destination_id: number
  facility_id: number
  facility?: Facility
  notes: string | null
  is_available: boolean
}

export interface DestinationImage {
  id: number
  destination_id: number
  image_url: string
  caption: string | null
  display_order: number
  uploaded_by: number | null
  is_featured: boolean
  created_at: string
}

export interface TourismDestination {
  id: number
  name: string
  slug: string
  category_id: number
  category?: DestinationCategory
  description: string | null
  address: string | null
  village: string | null
  district: string | null
  latitude: number | null
  longitude: number | null
  opening_hours: string | null
  ticket_price: number
  parking_fee: number
  contact_phone: string | null
  contact_email: string | null
  website: string | null
  main_image: string | null
  status: DestinationStatus
  contributor_id: number | null
  operator_id: number | null
  views_count: number
  created_at: string
  updated_at: string
  // Relations
  images?: DestinationImage[]
  facilities?: DestinationFacility[]
  reviews?: Review[]
  avg_rating?: number
  review_count?: number
}

export interface Culinary {
  id: number
  destination_id: number | null
  name: string
  description: string | null
  price_range: string | null
  contact: string | null
  image: string | null
  latitude: number | null
  longitude: number | null
  is_standalone: boolean
  is_verified: boolean
  created_at: string
}

export interface Culture {
  id: number
  name: string
  description: string | null
  location: string | null
  event_date: string | null
  event_frequency: string | null
  images: string[] | null
  contributor_id: number | null
  status: DestinationStatus
  created_at: string
}

export interface Review {
  id: number
  user_id: number
  user?: User
  destination_id: number
  rating: 1 | 2 | 3 | 4 | 5
  comment: string | null
  images: string[] | null
  helpful_count: number
  is_verified_visit: boolean
  created_at: string
  updated_at: string
}

export interface Wishlist {
  id: number
  user_id: number
  destination_id: number
  destination?: TourismDestination
  notes: string | null
  created_at: string
}

// ─── TRAVEL SERVICES ────────────────────────────────────────────────────────

export interface TravelAgency {
  id: number
  user_id: number
  user?: User
  business_name: string
  license_number: string | null
  address: string | null
  phone: string | null
  email: string | null
  logo: string | null
  description: string | null
  bank_account: BankAccount | null
  is_verified: boolean
  is_active: boolean
  created_at: string
}

export interface BankAccount {
  bank_name: string
  account_number: string
  account_holder: string
}

export type PackageInclusionCategory = 'accommodation' | 'transportation' | 'meals' | 'activities' | 'other'

export interface PackageDestination {
  id: number
  package_id: number
  destination_id: number
  destination?: TourismDestination
  day_number: number
  visit_order: number
  duration_hours: number | null
  notes: string | null
}

export interface PackageItinerary {
  id: number
  package_id: number
  day_number: number
  time: string | null
  activity: string
  location: string | null
  description: string | null
  image: string | null
  display_order: number
}

export interface PackageInclusion {
  id: number
  package_id: number
  item: string
  is_included: boolean
  category: PackageInclusionCategory
}

export interface TourPackage {
  id: number
  agency_id: number
  agency?: TravelAgency
  name: string
  slug: string
  description: string | null
  duration_days: number
  min_person: number
  max_person: number | null
  price_per_person: number
  discount_percentage: number
  main_image: string | null
  inclusions: string | null
  exclusions: string | null
  terms_conditions: string | null
  is_active: boolean
  is_featured: boolean
  views_count: number
  booking_count: number
  created_at: string
  // Relations
  destinations?: PackageDestination[]
  itineraries?: PackageItinerary[]
  package_inclusions?: PackageInclusion[]
  discounted_price?: number
}

export type VehicleType = 'car' | 'motorcycle' | 'bus' | 'van' | 'other'

export interface Vehicle {
  id: number
  agency_id: number
  agency?: TravelAgency
  type: VehicleType
  brand: string
  model: string
  year: number | null
  capacity: number | null
  plate_number: string
  daily_rate: number
  driver_rate: number
  image: string | null
  features: string[] | null
  is_available: boolean
  is_active: boolean
  created_at: string
}

export interface HomestayRoom {
  id: number
  homestay_id: number
  room_number: string | null
  room_type: string | null
  capacity: number
  price_per_night: number
  facilities: string[] | null
  image: string | null
  is_available: boolean
  created_at: string
}

export interface Homestay {
  id: number
  owner_id: number
  owner?: User
  name: string
  address: string | null
  village: string | null
  district: string | null
  latitude: number | null
  longitude: number | null
  total_rooms: number
  description: string | null
  phone: string | null
  amenities: string[] | null
  main_image: string | null
  check_in_time: string
  check_out_time: string
  policies: string | null
  is_verified: boolean
  is_active: boolean
  created_at: string
  rooms?: HomestayRoom[]
}

// ─── BOOKING & TRANSACTIONS ──────────────────────────────────────────────────

export type BookingStatus = 'pending' | 'confirmed' | 'cancelled' | 'completed'
export type PaymentStatus = 'pending' | 'paid' | 'refunded' | 'failed'

export interface Booking {
  id: number
  booking_number: string
  user_id: number
  user?: User
  package_id: number
  package?: TourPackage
  start_date: string
  end_date: string           // GENERATED
  total_person: number
  total_price: number
  discount_amount: number
  final_price: number        // GENERATED
  special_request: string | null
  status: BookingStatus
  payment_status: PaymentStatus
  payment_method: string | null
  payment_proof: string | null
  notes: string | null
  cancelled_at: string | null
  cancelled_reason: string | null
  created_at: string
}

export interface HomestayBooking {
  id: number
  booking_number: string
  user_id: number
  user?: User
  room_id: number
  room?: HomestayRoom
  check_in: string
  check_out: string
  total_nights: number       // GENERATED
  total_price: number
  guest_name: string
  guest_phone: string | null
  guest_email: string | null
  guest_count: number
  special_request: string | null
  status: BookingStatus
  payment_status: PaymentStatus
  payment_method: string | null
  payment_proof: string | null
  notes: string | null
  created_at: string
}

export interface VehicleRental {
  id: number
  rental_number: string
  user_id: number
  user?: User
  vehicle_id: number
  vehicle?: Vehicle
  start_date: string
  end_date: string
  total_days: number         // GENERATED
  daily_rate: number
  driver_included: boolean
  driver_rate: number
  total_price: number
  pickup_location: string | null
  dropoff_location: string | null
  renter_name: string
  renter_phone: string
  renter_id_number: string | null
  renter_id_photo: string | null
  status: BookingStatus
  payment_status: PaymentStatus
  payment_method: string | null
  notes: string | null
  created_at: string
}

// ─── AI & CONTRIBUTIONS ──────────────────────────────────────────────────────

export interface AIRecommendation {
  id: number
  user_id: number | null
  session_id: string | null
  preferences: Record<string, unknown> | null
  budget: number | null
  duration: string | null
  travel_style: string | null
  interests: string[] | null
  recommendations: TourismDestination[] | null
  feedback_rating: number | null
  created_at: string
}

export type ContributionType = 'destination' | 'culinary' | 'culture' | 'other'
export type ContributionStatus = 'pending' | 'approved' | 'rejected' | 'revision_requested'

export interface Contribution {
  id: number
  contributor_id: number
  contributor?: User
  type: ContributionType
  entity_id: number | null
  data: Record<string, unknown>
  status: ContributionStatus
  rejection_reason: string | null
  revision_notes: string | null
  reviewed_by: number | null
  reviewer?: User
  submitted_at: string
  reviewed_at: string | null
}

// ─── SYSTEM ──────────────────────────────────────────────────────────────────

export type NotificationType = 'info' | 'warning' | 'alert' | 'success'

export interface Notification {
  id: number
  user_id: number
  title: string
  message: string
  type: NotificationType
  related_entity_type: string | null
  related_entity_id: number | null
  is_read: boolean
  created_at: string
  read_at: string | null
}

export interface ActivityLog {
  id: number
  user_id: number | null
  user?: User
  action: string
  entity_type: string | null
  entity_id: number | null
  old_value: Record<string, unknown> | null
  new_value: Record<string, unknown> | null
  ip_address: string | null
  user_agent: string | null
  created_at: string
}

// ─── API RESPONSE WRAPPERS ───────────────────────────────────────────────────

export interface PaginatedResponse<T> {
  count: number
  next: string | null
  previous: string | null
  results: T[]
}

export interface ApiError {
  detail?: string
  message?: string
  errors?: Record<string, string[]>
}

// ─── FORM TYPES ──────────────────────────────────────────────────────────────

export interface LoginForm {
  email: string
  password: string
}

export interface RegisterForm {
  email: string
  password: string
  fullname: string
  phone?: string
  role: 'user' | 'operator'
}

export interface BookingForm {
  package_id: number
  start_date: string
  total_person: number
  special_request?: string
}

export interface HomestayBookingForm {
  room_id: number
  check_in: string
  check_out: string
  guest_name: string
  guest_phone?: string
  guest_email?: string
  guest_count: number
  special_request?: string
}

export interface VehicleRentalForm {
  vehicle_id: number
  start_date: string
  end_date: string
  driver_included: boolean
  pickup_location?: string
  dropoff_location?: string
  renter_name: string
  renter_phone: string
  renter_id_number?: string
}

export interface AIRecommendationForm {
  budget?: number
  duration?: string
  travel_style?: string
  interests: string[]
}

export interface DestinationFilterParams {
  search?: string
  category?: number
  district?: string
  status?: DestinationStatus
  page?: number
  page_size?: number
}
