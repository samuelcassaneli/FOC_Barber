export interface Profile {
    id: string
    full_name: string
    email: string
    role: 'client' | 'barber' | 'admin'
    created_at?: string
}

export interface Service {
    id: string
    name: string
    description: string
    price: number
    duration_minutes: number
    image_url?: string
}

export interface Barber {
    id: string
    profile_id: string
    name: string
    shop_name?: string
    address?: string
    specialty: string
    photo_url?: string
    bio?: string
    status: 'pending' | 'approved' | 'rejected' | 'banned'
}

export interface Booking {
    id: string
    client_id: string
    barber_id: string
    service_id: string
    booking_date: string // ISO string
    status: 'pending' | 'confirmed' | 'completed' | 'cancelled'
    barber?: Barber
    service?: Service
}

export interface FinancialTransaction {
    id: string
    barbershop_id: string
    transaction_type: string
    amount: number
    description?: string
    transaction_date: string // ISO string
    created_at?: string
    updated_at?: string
}

