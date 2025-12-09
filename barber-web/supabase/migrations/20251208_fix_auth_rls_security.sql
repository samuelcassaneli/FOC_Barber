-- 1. Reset and Fix Trigger Function (Crucial for 500 Error)
-- We use SECURITY DEFINER to bypass RLS during user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, role, avatar_url)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Novo Usuário'),
    new.email,
    COALESCE(new.raw_user_meta_data->>'role', 'client'),
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Re-bind the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 3. Security & RLS (Row Level Security)

-- Enable RLS on Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Public Read for Barbers (So clients can see them)
CREATE POLICY "Public profiles are viewable by everyone"
ON public.profiles FOR SELECT
USING ( true );

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
USING ( auth.uid() = id );

-- Policy: Users can insert their own profile (Fallback if trigger fails, though trigger is preferred)
CREATE POLICY "Users can insert own profile"
ON public.profiles FOR INSERT
WITH CHECK ( auth.uid() = id );

-- 4. Bookings Security (IDOR Prevention)

-- Ensure table exists (simplified structure for safety)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    client_id UUID REFERENCES public.profiles(id) NOT NULL,
    barber_id UUID REFERENCES public.profiles(id) NOT NULL,
    service_name TEXT NOT NULL,
    booking_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Policy: Clients can view ONLY their own bookings
CREATE POLICY "Clients can view own bookings"
ON public.bookings FOR SELECT
USING ( auth.uid() = client_id );

-- Policy: Barbers can view bookings assigned to them
CREATE POLICY "Barbers can view assigned bookings"
ON public.bookings FOR SELECT
USING ( auth.uid() = barber_id );

-- Policy: Clients can create bookings for themselves
CREATE POLICY "Clients can create bookings"
ON public.bookings FOR INSERT
WITH CHECK ( auth.uid() = client_id );

-- Policy: Barbers can update status of their bookings
CREATE POLICY "Barbers can update booking status"
ON public.bookings FOR UPDATE
USING ( auth.uid() = barber_id );
