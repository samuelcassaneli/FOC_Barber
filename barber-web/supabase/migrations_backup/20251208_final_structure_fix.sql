-- FINAL DATABASE REPAIR SCRIPT
-- This script safely adds missing columns to existing tables and sets up Storage.

-- 1. Fix 'bookings' table (Add missing columns safely)
DO $$
BEGIN
    -- Check and add 'barber_id' if missing (This caused your specific error)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='barber_id') THEN
        ALTER TABLE public.bookings ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;

    -- Check and add 'client_id'
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='client_id') THEN
        ALTER TABLE public.bookings ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;

    -- Check and add 'booking_date'
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='booking_date') THEN
        ALTER TABLE public.bookings ADD COLUMN booking_date TIMESTAMP WITH TIME ZONE;
    END IF;
    
    -- Check and add 'client_name'
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='client_name') THEN
        ALTER TABLE public.bookings ADD COLUMN client_name TEXT;
    END IF;
    
    -- Check and add 'service_name'
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='service_name') THEN
        ALTER TABLE public.bookings ADD COLUMN service_name TEXT;
    END IF;
END $$;

-- 2. Create Services Table (if not exists)
CREATE TABLE IF NOT EXISTS public.services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create Products Table (if not exists)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create Notifications Table (if not exists)
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. ENABLE STORAGE FOR AVATARS (Crucial for Profile Picture)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies (Drop first to avoid conflicts)
DROP POLICY IF EXISTS "Avatar Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Update Access" ON storage.objects;

CREATE POLICY "Avatar Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Upload Access" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Update Access" ON storage.objects FOR UPDATE USING ( auth.uid() = owner );

-- 6. Re-Apply RLS Policies for Tables
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Barbers manage services" ON public.services;
CREATE POLICY "Barbers manage services" ON public.services USING (auth.uid() = barber_id);
DROP POLICY IF EXISTS "Public read services" ON public.services;
CREATE POLICY "Public read services" ON public.services FOR SELECT USING (true);

DROP POLICY IF EXISTS "Barbers manage products" ON public.products;
CREATE POLICY "Barbers manage products" ON public.products USING (auth.uid() = barber_id);
