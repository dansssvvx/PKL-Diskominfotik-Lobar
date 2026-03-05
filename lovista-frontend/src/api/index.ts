import axios, { type AxiosInstance, type AxiosRequestConfig } from 'axios'
import type {
  TourismDestination, DestinationCategory, TourPackage,
  Homestay, Vehicle, Culinary, Culture, Review,
  Booking, HomestayBooking, VehicleRental,
  AIRecommendation, Contribution, Notification,
  ActivityLog, Wishlist, User, TravelAgency,
  PaginatedResponse, LoginForm, RegisterForm,
  BookingForm, HomestayBookingForm, VehicleRentalForm,
  AIRecommendationForm, DestinationFilterParams
} from '@/types'

const api: AxiosInstance = axios.create({
  baseURL: 'http://127.0.0.1:8000/api',
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
})

// Request interceptor — attach JWT token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('lovista_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Response interceptor — handle 401
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('lovista_token')
      // window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

// ─── AUTH ────────────────────────────────────────────────────────────────────
export const authApi = {
  login: (data: LoginForm) =>
    api.post<{ access: string; refresh: string; user: User }>('/token/', data),
  register: (data: RegisterForm) =>
    api.post<User>('/users/', data),
  refresh: (refresh: string) =>
    api.post<{ access: string }>('/token/refresh/', { refresh }),
  me: () => api.get<User>('/users/me/'),
  uploadPhoto: (file: File) => {
    const fd = new FormData()
    fd.append('profile_photo', file)
    return api.post<{ profile_photo: string }>('/users/upload_photo/', fd, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}

// ─── DESTINATIONS ────────────────────────────────────────────────────────────
export const destinationApi = {
  list: (params?: DestinationFilterParams) =>
    api.get<PaginatedResponse<TourismDestination>>('/destinations/', { params }),
  detail: (slug: string) =>
    api.get<TourismDestination>(`/destinations/${slug}/`),
  create: (data: Partial<TourismDestination>) =>
    api.post<TourismDestination>('/destinations/', data),
  update: (id: number, data: Partial<TourismDestination>) =>
    api.patch<TourismDestination>(`/destinations/${id}/`, data),
  delete: (id: number) => api.delete(`/destinations/${id}/`),
  featured: () => api.get<TourismDestination[]>('/destinations/featured/'),
  popular: () => api.get<TourismDestination[]>('/destinations/popular/'),
  nearby: (lat: number, lng: number, radius = 10) =>
    api.get<TourismDestination[]>('/destinations/nearby/', { params: { lat, lng, radius } }),
  categories: () => api.get<DestinationCategory[]>('/destination-categories/'),
  addReview: (destId: number, data: { rating: number; comment: string }) =>
    api.post<Review>(`/destinations/${destId}/reviews/`, data),
  toggleWishlist: (destId: number) =>
    api.post<{ wishlisted: boolean }>(`/destinations/${destId}/wishlist/`),
}

// ─── TOUR PACKAGES ──────────────────────────────────────────────────────────
export const packageApi = {
  list: (params?: { search?: string; agency?: number; featured?: boolean; page?: number }) =>
    api.get<PaginatedResponse<TourPackage>>('/packages/', { params }),
  detail: (slug: string) => api.get<TourPackage>(`/packages/${slug}/`),
  featured: () => api.get<TourPackage[]>('/packages/featured/'),
  create: (data: Partial<TourPackage>) => api.post<TourPackage>('/packages/', data),
  update: (id: number, data: Partial<TourPackage>) =>
    api.patch<TourPackage>(`/packages/${id}/`, data),
  delete: (id: number) => api.delete(`/packages/${id}/`),
}

// ─── HOMESTAY ────────────────────────────────────────────────────────────────
export const homestayApi = {
  list: (params?: { district?: string; check_in?: string; check_out?: string; page?: number }) =>
    api.get<PaginatedResponse<Homestay>>('/homestays/', { params }),
  detail: (id: number) => api.get<Homestay>(`/homestays/${id}/`),
  create: (data: Partial<Homestay>) => api.post<Homestay>('/homestays/', data),
  update: (id: number, data: Partial<Homestay>) =>
    api.patch<Homestay>(`/homestays/${id}/`, data),
  checkAvailability: (roomId: number, checkIn: string, checkOut: string) =>
    api.get<{ available: boolean }>(`/homestay-rooms/${roomId}/availability/`, {
      params: { check_in: checkIn, check_out: checkOut }
    }),
}

// ─── VEHICLES ────────────────────────────────────────────────────────────────
export const vehicleApi = {
  list: (params?: { type?: string; agency?: number; available?: boolean; page?: number }) =>
    api.get<PaginatedResponse<Vehicle>>('/vehicles/', { params }),
  detail: (id: number) => api.get<Vehicle>(`/vehicles/${id}/`),
  create: (data: Partial<Vehicle>) => api.post<Vehicle>('/vehicles/', data),
  update: (id: number, data: Partial<Vehicle>) =>
    api.patch<Vehicle>(`/vehicles/${id}/`, data),
}

// ─── CULTURE ─────────────────────────────────────────────────────────────────
export const cultureApi = {
  list: (params?: { search?: string; status?: string; page?: number }) =>
    api.get<PaginatedResponse<Culture>>('/cultures/', { params }),
  detail: (id: number) => api.get<Culture>(`/cultures/${id}/`),
  create: (data: Partial<Culture>) => api.post<Culture>('/cultures/', data),
  update: (id: number, data: Partial<Culture>) =>
    api.patch<Culture>(`/cultures/${id}/`, data),
  featured: () => api.get<Culture[]>('/cultures/featured/'),
}

// ─── CULINARY ────────────────────────────────────────────────────────────────
export const culinaryApi = {
  list: (params?: { search?: string; destination?: number; page?: number }) =>
    api.get<PaginatedResponse<Culinary>>('/culinaries/', { params }),
  detail: (id: number) => api.get<Culinary>(`/culinaries/${id}/`),
  featured: () => api.get<Culinary[]>('/culinaries/featured/'),
}

// ─── BOOKINGS ────────────────────────────────────────────────────────────────
export const bookingApi = {
  create: (data: BookingForm) => api.post<Booking>('/bookings/', data),
  list: () => api.get<PaginatedResponse<Booking>>('/bookings/'),
  detail: (id: number) => api.get<Booking>(`/bookings/${id}/`),
  cancel: (id: number, reason: string) =>
    api.post(`/bookings/${id}/cancel/`, { reason }),
  uploadPaymentProof: (id: number, file: File) => {
    const fd = new FormData()
    fd.append('payment_proof', file)
    return api.post(`/bookings/${id}/upload-proof/`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },
  homestayCreate: (data: HomestayBookingForm) =>
    api.post<HomestayBooking>('/homestay-bookings/', data),
  homestayList: () => api.get<PaginatedResponse<HomestayBooking>>('/homestay-bookings/'),
  rentalCreate: (data: VehicleRentalForm) =>
    api.post<VehicleRental>('/vehicle-rentals/', data),
  rentalList: () => api.get<PaginatedResponse<VehicleRental>>('/vehicle-rentals/'),
}

// ─── AI RECOMMENDATION ───────────────────────────────────────────────────────
export const aiApi = {
  recommend: (data: AIRecommendationForm) =>
    api.post<AIRecommendation>('/ai-recommendations/', data),
  feedback: (id: number, rating: number) =>
    api.patch(`/ai-recommendations/${id}/`, { feedback_rating: rating }),
}

// ─── CONTRIBUTIONS ───────────────────────────────────────────────────────────
export const contributionApi = {
  submit: (data: Partial<Contribution>) =>
    api.post<Contribution>('/contributions/', data),
  list: (params?: { status?: string; type?: string }) =>
    api.get<PaginatedResponse<Contribution>>('/contributions/', { params }),
  review: (id: number, action: 'approve' | 'reject' | 'request_revision', notes?: string) =>
    api.post(`/contributions/${id}/${action}/`, { notes }),
}

// ─── NOTIFICATIONS ───────────────────────────────────────────────────────────
export const notificationApi = {
  list: () => api.get<PaginatedResponse<Notification>>('/notifications/'),
  markRead: (id: number) => api.patch(`/notifications/${id}/`, { is_read: true }),
  markAllRead: () => api.post('/notifications/mark-all-read/'),
  unreadCount: () => api.get<{ count: number }>('/notifications/unread-count/'),
}

// ─── ADMIN ───────────────────────────────────────────────────────────────────
export const adminApi = {
  stats: () => api.get<{
    total_destinations: number
    total_users: number
    total_bookings: number
    total_revenue: number
    pending_contributions: number
    active_operators: number
  }>('/admin/stats/'),
  users: (params?: { role?: string; page?: number }) =>
    api.get<PaginatedResponse<User>>('/admin/users/', { params }),
  activityLogs: (params?: { page?: number }) =>
    api.get<PaginatedResponse<ActivityLog>>('/admin/activity-logs/', { params }),
  verifyAgency: (id: number) => api.post(`/admin/agencies/${id}/verify/`),
  verifyHomestay: (id: number) => api.post(`/admin/homestays/${id}/verify/`),
}

// ─── AGENCY / OPERATOR ───────────────────────────────────────────────────────
export const agencyApi = {
  me: () => api.get<TravelAgency>('/agencies/me/'),
  update: (data: Partial<TravelAgency>) => api.patch<TravelAgency>('/agencies/me/', data),
  bookings: (params?: { status?: string; page?: number }) =>
    api.get<PaginatedResponse<Booking>>('/agencies/me/bookings/', { params }),
  homestayBookings: (params?: { status?: string }) =>
    api.get<PaginatedResponse<HomestayBooking>>('/agencies/me/homestay-bookings/', { params }),
  rentalBookings: (params?: { status?: string }) =>
    api.get<PaginatedResponse<VehicleRental>>('/agencies/me/rentals/', { params }),
  dashboard: () => api.get<{
    total_bookings: number
    pending_bookings: number
    total_revenue: number
    active_packages: number
    active_vehicles: number
    active_homestays: number
  }>('/agencies/me/dashboard/'),
}

// ─── WISHLIST ────────────────────────────────────────────────────────────────
export const wishlistApi = {
  list: () => api.get<PaginatedResponse<Wishlist>>('/wishlist/'),
}

export default api
