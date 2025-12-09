-- SCRIPT ROBUSTO DE CORREÇÃO (Rode este para corrigir definitivamente)

-- 1. GARANTIR QUE AS TABELAS EXISTAM E TENHAM AS COLUNAS CERTAS
-- Se a tabela já existia mas sem a coluna, este bloco vai corrigir.

-- Tabela PLANS
CREATE TABLE IF NOT EXISTS public.plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='plans' AND column_name='barber_id') THEN
        ALTER TABLE public.plans ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='plans' AND column_name='name') THEN
        ALTER TABLE public.plans ADD COLUMN name TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='plans' AND column_name='price') THEN
        ALTER TABLE public.plans ADD COLUMN price DECIMAL(10,2);
    END IF;
END $$;

-- Tabela SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='plan_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN plan_id UUID REFERENCES public.plans(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='client_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='barber_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='active') THEN
        ALTER TABLE public.subscriptions ADD COLUMN active BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- Tabela BARBER_CLIENTS
CREATE TABLE IF NOT EXISTS public.barber_clients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='barber_clients' AND column_name='barber_id') THEN
        ALTER TABLE public.barber_clients ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='barber_clients' AND column_name='client_id') THEN
        ALTER TABLE public.barber_clients ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- 2. CORRIGIR RECURSÃO INFINITA (PERFIS)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles view" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own" ON public.profiles;
DROP POLICY IF EXISTS "Users insert own" ON public.profiles;
DROP POLICY IF EXISTS "Leitura Publica" ON public.profiles;
DROP POLICY IF EXISTS "Atualizar Proprio" ON public.profiles;
DROP POLICY IF EXISTS "Inserir Proprio" ON public.profiles;

CREATE POLICY "Leitura Publica" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Atualizar Proprio" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Inserir Proprio" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 3. APLICAR SEGURANÇA (RLS)
-- Agora é seguro aplicar pois garantimos que as colunas existem

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
