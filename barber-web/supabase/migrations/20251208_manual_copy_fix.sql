-- SCRIPT FINAL E COMPLETO (Abra este arquivo, copie tudo e cole no Supabase SQL Editor)

-- 1. RESOLVER RECURSÃO INFINITA (CRÍTICO)
-- Reseta as políticas da tabela de perfis para evitar o erro "infinite recursion"
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles view" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own" ON public.profiles;
DROP POLICY IF EXISTS "Users insert own" ON public.profiles;

-- Políticas simples (sem sub-selects)
CREATE POLICY "Leitura Geral" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Atualizar Proprio" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Inserir Proprio" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. CORRIGIR COLUNAS FALTANTES (ERRO 42703)
-- Este bloco verifica se as colunas existem antes de tentar criar, evitando erros.
DO $$
BEGIN
    -- Tabela PLANS
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='plans' AND column_name='barber_id') THEN
        ALTER TABLE public.plans ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;

    -- Tabela SUBSCRIPTIONS
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='barber_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='client_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='subscriptions' AND column_name='plan_id') THEN
        ALTER TABLE public.subscriptions ADD COLUMN plan_id UUID REFERENCES public.plans(id);
    END IF;

    -- Tabela BARBER_CLIENTS
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='barber_clients' AND column_name='barber_id') THEN
        ALTER TABLE public.barber_clients ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='barber_clients' AND column_name='client_id') THEN
        ALTER TABLE public.barber_clients ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- 3. REAPLICAR POLÍTICAS DE SEGURANÇA (RLS)
-- Garante que as regras de acesso funcionem com as novas colunas

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
CREATE POLICY "Insert clients" ON public.barber_clients FOR INSERT WITH CHECK (true);
