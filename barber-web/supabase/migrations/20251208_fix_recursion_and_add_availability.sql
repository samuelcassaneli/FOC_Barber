-- FIX INFINITE RECURSION & ADD MISSING FEATURES

-- 1. FIX INFINITE RECURSION (CRITICAL)
-- The recursion happens when a policy queries the same table it protects.
-- We will simplify policies to rely purely on auth.uid() matching IDs, avoiding lookups.

ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY; -- Reset
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;

-- Simple, non-recursive policies
CREATE POLICY "Public profiles view" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users update own" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users insert own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Fix Services/Products recursion just in case
DROP POLICY IF EXISTS "Barbers manage own services" ON public.services;
CREATE POLICY "Barbers manage services" ON public.services USING (auth.uid() = barber_id);

DROP POLICY IF EXISTS "Barbers manage own products" ON public.products;
CREATE POLICY "Barbers manage products" ON public.products USING (auth.uid() = barber_id);

-- 2. CREATE AVAILABILITY TABLE (For "Horário de Atendimento" & Agenda Blocking)
CREATE TABLE IF NOT EXISTS public.barber_availability (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    day_of_week INTEGER NOT NULL, -- 0 = Sunday, 1 = Monday, etc.
    start_time TIME DEFAULT '09:00',
    end_time TIME DEFAULT '18:00',
    is_working_day BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(barber_id, day_of_week)
);

ALTER TABLE public.barber_availability ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Barbers manage availability" ON public.barber_availability USING (auth.uid() = barber_id);
CREATE POLICY "Public read availability" ON public.barber_availability FOR SELECT USING (true);

-- 3. INSERT DEFAULT AVAILABILITY (If not exists)
-- This creates rows for Mon-Sat for existing barbers is handled in app logic or trigger, 
-- but we'll leave it empty to be handled by the UI logic (upsert).

-- 4. FIX NOTIFICATIONS
-- Ensure the table exists and has RLS
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users read own notifications" ON public.notifications;
CREATE POLICY "Users read own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Insert notifications" ON public.notifications FOR INSERT WITH CHECK (true); -- Allow system/barbers to send

-- 5. FIX BOOKINGS (Ensure no recursion)
DROP POLICY IF EXISTS "Clients can view own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Barbers can view assigned bookings" ON public.bookings;
CREATE POLICY "View bookings" ON public.bookings FOR SELECT USING (
  auth.uid() = client_id OR auth.uid() = barber_id
);
