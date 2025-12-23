-- SCRIPT DE CRIAÇÃO TOTAL (Rode este para corrigir o erro "relation does not exist")

-- 1. CRIAR TABELAS QUE FALTAM (PLANS, SUBSCRIPTIONS, BARBER_CLIENTS)
CREATE TABLE IF NOT EXISTS public.plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    plan_id UUID REFERENCES public.plans(id) NOT NULL,
    client_id UUID REFERENCES auth.users(id) NOT NULL,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.barber_clients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    client_id UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(barber_id, client_id)
);

-- 2. CORRIGIR TABELA PROFILES (Fim da Recursão Infinita)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles view" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own" ON public.profiles;
DROP POLICY IF EXISTS "Users insert own" ON public.profiles;

CREATE POLICY "Leitura Publica" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Atualizar Proprio" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Inserir Proprio" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 3. HABILITAR SEGURANÇA (RLS) NAS NOVAS TABELAS

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
DROP POLICY IF EXISTS "Vincular Clientes" ON public.barber_clients;
CREATE POLICY "Vincular Clientes" ON public.barber_clients FOR INSERT WITH CHECK (true);
