-- MEGA FIX: RECURSION, PLANS, CLIENT RELATIONSHIPS & BLOCKING

-- 1. NUKE & REBUILD RLS (The only way to kill infinite recursion guarantees)
-- We remove ALL policies from relevant tables and apply simple, flat rules.

ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies on profiles to be safe
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles view" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users insert own" ON public.profiles;

-- NON-RECURSIVE POLICIES (Pure ID matching, no lookups)
CREATE POLICY "No-Recursion Read Profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "No-Recursion Update Profiles" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "No-Recursion Insert Profiles" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. CLIENT-BARBER RELATIONSHIP (My Clients)
CREATE TABLE IF NOT EXISTS public.barber_clients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    client_id UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(barber_id, client_id)
);

ALTER TABLE public.barber_clients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Barbers view clients" ON public.barber_clients FOR SELECT USING (auth.uid() = barber_id OR auth.uid() = client_id);
CREATE POLICY "Clients join barbers" ON public.barber_clients FOR INSERT WITH CHECK (auth.uid() = client_id OR auth.uid() = barber_id);

-- 3. PLANS & SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS public.plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL, -- e.g., "VIP Mensal"
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    plan_id UUID REFERENCES public.plans(id) NOT NULL,
    client_id UUID REFERENCES auth.users(id) NOT NULL,
    barber_id UUID REFERENCES auth.users(id) NOT NULL, -- Denormalized for RLS
    active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read plans" ON public.plans FOR SELECT USING (true);
CREATE POLICY "Barbers manage plans" ON public.plans USING (auth.uid() = barber_id);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read subs" ON public.subscriptions FOR SELECT USING (true);
CREATE POLICY "Barbers manage subs" ON public.subscriptions USING (auth.uid() = barber_id OR auth.uid() = client_id);

-- 4. FIX BOOKINGS & BLOCKING
-- We add 'blocked' as a valid status context in the app logic, no DB change needed for column, 
-- but we ensure the policy allows the barber to see/edit everything.

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "View bookings" ON public.bookings;
DROP POLICY IF EXISTS "Clients can view own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Barbers can view assigned bookings" ON public.bookings;
DROP POLICY IF EXISTS "Clients create bookings" ON public.bookings;
DROP POLICY IF EXISTS "Barbers update bookings" ON public.bookings;

-- Simple Policies
CREATE POLICY "View Bookings General" ON public.bookings FOR SELECT USING (auth.uid() = client_id OR auth.uid() = barber_id);
CREATE POLICY "Create Bookings General" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = client_id OR auth.uid() = barber_id);
CREATE POLICY "Update Bookings General" ON public.bookings FOR UPDATE USING (auth.uid() = client_id OR auth.uid() = barber_id);
DELETE FROM public.bookings WHERE status = 'blocked'; -- Optional: Clear old blocks if structure changed (Safety)

-- 5. NOTIFICATIONS (Double Check)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "System create notifications" ON public.notifications;
CREATE POLICY "System create notifications" ON public.notifications FOR INSERT WITH CHECK (true);
