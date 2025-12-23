-- EMERGENCY FIX: ADD MISSING COLUMNS (plans, subscriptions, barber_clients)
-- Run this script to fix the "column barber_id does not exist" error.

DO $$
BEGIN
    -- 1. Fix 'plans' table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='plans' AND column_name='barber_id') THEN
        ALTER TABLE public.plans ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    
    -- 2. Fix 'subscriptions' table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='barber_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='client_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='plan_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN plan_id UUID REFERENCES public.plans(id);
    END IF;

    -- 3. Fix 'barber_clients' table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='barber_clients' AND column_name='barber_id') THEN
        ALTER TABLE public.barber_clients ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='barber_clients' AND column_name='client_id') THEN
        ALTER TABLE public.barber_clients ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- 4. RE-APPLY POLICIES (Now that columns definitely exist)

-- Plans
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Barbers manage plans" ON public.plans;
CREATE POLICY "Barbers manage plans" ON public.plans USING (auth.uid() = barber_id);
DROP POLICY IF EXISTS "Public read plans" ON public.plans;
CREATE POLICY "Public read plans" ON public.plans FOR SELECT USING (true);

-- Subscriptions
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Barbers manage subs" ON public.subscriptions;
CREATE POLICY "Barbers manage subs" ON public.subscriptions USING (auth.uid() = barber_id OR auth.uid() = client_id);
DROP POLICY IF EXISTS "Public read subs" ON public.subscriptions;
CREATE POLICY "Public read subs" ON public.subscriptions FOR SELECT USING (true);

-- Barber Clients
ALTER TABLE public.barber_clients ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Barbers view clients" ON public.barber_clients;
CREATE POLICY "Barbers view clients" ON public.barber_clients FOR SELECT USING (true);
