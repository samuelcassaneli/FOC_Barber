-- FIX DATABASE SCHEMA & ADD FEATURES

-- 1. Fix Bookings Table (Ensure columns exist)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    client_id UUID REFERENCES auth.users(id),
    barber_id UUID REFERENCES auth.users(id),
    service_name TEXT,
    client_name TEXT, -- Denormalized for easier display
    price DECIMAL(10,2),
    status TEXT DEFAULT 'pending', -- pending, confirmed, cancelled, completed
    booking_date TIMESTAMP WITH TIME ZONE -- Ensure this column exists
);

-- Safely add column if it was missing (for existing tables)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='booking_date') THEN
        ALTER TABLE public.bookings ADD COLUMN booking_date TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- 2. Create Services Table
CREATE TABLE IF NOT EXISTS public.services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create Notifications Table (For client alerts)
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Enable RLS
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 6. Policies (Simplified for development, tighten for production)

-- Services
CREATE POLICY "Barbers manage own services" ON public.services USING (auth.uid() = barber_id);
CREATE POLICY "Public read services" ON public.services FOR SELECT USING (true);

-- Products
CREATE POLICY "Barbers manage own products" ON public.products USING (auth.uid() = barber_id);
CREATE POLICY "Public read products" ON public.products FOR SELECT USING (true);

-- Notifications
CREATE POLICY "Users read own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Barbers create notifications" ON public.notifications FOR INSERT WITH CHECK (true); -- Allow barbers to insert into client notifications

-- 7. Fix Profiles (Ensure avatar update is allowed)
CREATE POLICY "Users update own avatar" ON public.storage.objects FOR UPDATE USING (auth.uid() = owner);
