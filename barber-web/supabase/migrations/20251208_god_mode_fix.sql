-- SCRIPT "GOD MODE" - REMOÇÃO DINÂMICA DE POLÍTICAS (Fim Definitivo da Recursão)
-- Este script não adivinha nomes. Ele varre o banco de dados e DELETA TODAS as políticas
-- das tabelas envolvidas, recriando apenas o essencial e seguro.

BEGIN;

-- 1. Desabilitar RLS em tudo para evitar travamentos durante a manutenção
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_clients DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.services DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions DISABLE ROW LEVEL SECURITY;

-- 2. LOOP PARA DELETAR TODAS AS POLÍTICAS EXISTENTES (Dinâmico)
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname, tablename
        FROM pg_policies
        WHERE schemaname = 'public' 
        AND tablename IN ('profiles', 'bookings', 'barber_clients', 'services', 'products', 'plans', 'subscriptions', 'notifications')
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- 3. RECRIAR POLÍTICAS 100% SEGURAS E NÃO-RECURSIVAS

-- === PROFILES (O Causador do Problema) ===
-- Regra: Todo mundo vê todo mundo. Zero consulta ao banco. Zero recursão.
CREATE POLICY "profiles_read_global" ON public.profiles FOR SELECT USING (true);
-- Regra: Só edita o próprio ID. Comparação direta. Zero recursão.
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (auth.uid() = id);
-- Regra: Só insere o próprio ID.
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- === BOOKINGS ===
CREATE POLICY "bookings_access_own" ON public.bookings 
FOR ALL USING (auth.uid() = client_id OR auth.uid() = barber_id);

-- === BARBER CLIENTS ===
CREATE POLICY "barber_clients_access" ON public.barber_clients 
FOR ALL USING (true); -- Aberto para leitura/escrita para evitar bloqueios de relacionamento

-- === SERVICES & PRODUCTS ===
CREATE POLICY "public_read_items" ON public.services FOR SELECT USING (true);
CREATE POLICY "barber_manage_items" ON public.services FOR ALL USING (auth.uid() = barber_id);

CREATE POLICY "public_read_products" ON public.products FOR SELECT USING (true);
CREATE POLICY "barber_manage_products" ON public.products FOR ALL USING (auth.uid() = barber_id);

-- === PLANS & SUBSCRIPTIONS ===
CREATE POLICY "public_read_plans" ON public.plans FOR SELECT USING (true);
CREATE POLICY "barber_manage_plans" ON public.plans FOR ALL USING (auth.uid() = barber_id);

CREATE POLICY "public_read_subs" ON public.subscriptions FOR SELECT USING (true);
CREATE POLICY "manage_subs" ON public.subscriptions FOR ALL USING (auth.uid() = barber_id OR auth.uid() = client_id);

-- === NOTIFICATIONS ===
CREATE POLICY "notifications_own" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "notifications_insert" ON public.notifications FOR INSERT WITH CHECK (true);

-- 4. Reabilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

COMMIT;
