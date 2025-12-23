-- =====================================================
-- MIGRAÇÃO COMPLETA: ESTRUTURA MULTI-TENANT FOC BARBER
-- Data: 2024-12-16
-- Descrição: Cria estrutura completa para múltiplas barbearias
-- =====================================================

-- =====================================================
-- 0. LIMPAR TABELAS ANTIGAS INCOMPATÍVEIS
-- =====================================================
DROP TABLE IF EXISTS public.barber_clients CASCADE;

-- =====================================================
-- 1. TABELA DE BARBEARIAS (TENANT PRINCIPAL)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barbershops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    cnpj TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    logo_url TEXT,
    cover_url TEXT,
    description TEXT,
    owner_id UUID REFERENCES auth.users(id),
    is_active BOOLEAN DEFAULT true,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_barbershops_slug ON public.barbershops(slug);
CREATE INDEX IF NOT EXISTS idx_barbershops_owner ON public.barbershops(owner_id);

-- =====================================================
-- 2. TABELA DE BARBEIROS (RECRIADA COM NOVA ESTRUTURA)
-- =====================================================
-- Primeiro, dropar a tabela antiga se existir (com estrutura incompatível)
DROP TABLE IF EXISTS public.barbers CASCADE;

CREATE TABLE public.barbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) UNIQUE,
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    avatar_url TEXT,
    bio TEXT,
    specialties TEXT[] DEFAULT '{}',
    commission_rate DECIMAL(5,2) DEFAULT 50.00,
    is_owner BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_barbers_barbershop ON public.barbers(barbershop_id);
CREATE INDEX idx_barbers_user ON public.barbers(user_id);

-- =====================================================
-- 3. TABELA DE CLIENTES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) UNIQUE,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    avatar_url TEXT,
    birth_date DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_clients_user ON public.clients(user_id);

-- =====================================================
-- 4. CLIENTES POR BARBEARIA (VÍNCULO + EXCLUSIVIDADE)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barbershop_clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    client_id UUID REFERENCES public.clients(id) ON DELETE CASCADE NOT NULL,
    exclusive_barber_id UUID REFERENCES public.barbers(id) ON DELETE SET NULL,
    is_exclusive BOOLEAN DEFAULT false,
    loyalty_points INTEGER DEFAULT 0,
    notes TEXT,
    last_visit TIMESTAMPTZ,
    total_visits INTEGER DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(barbershop_id, client_id)
);

CREATE INDEX IF NOT EXISTS idx_barbershop_clients_barbershop ON public.barbershop_clients(barbershop_id);
CREATE INDEX IF NOT EXISTS idx_barbershop_clients_client ON public.barbershop_clients(client_id);

-- =====================================================
-- 5. SERVIÇOS DA BARBEARIA
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barbershop_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration_minutes INTEGER NOT NULL DEFAULT 30,
    category TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_barbershop_services_barbershop ON public.barbershop_services(barbershop_id);

-- =====================================================
-- 6. SERVIÇOS POR BARBEIRO
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barber_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE NOT NULL,
    service_id UUID REFERENCES public.barbershop_services(id) ON DELETE CASCADE NOT NULL,
    price_override DECIMAL(10,2),
    duration_override INTEGER,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(barber_id, service_id)
);

CREATE INDEX IF NOT EXISTS idx_barber_services_barber ON public.barber_services(barber_id);

-- =====================================================
-- 7. AGENDAMENTOS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barbershop_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE NOT NULL,
    client_id UUID REFERENCES public.clients(id) ON DELETE CASCADE NOT NULL,
    service_id UUID REFERENCES public.barbershop_services(id) ON DELETE SET NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show')),
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'partial', 'refunded')),
    payment_method TEXT,
    total_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    notes TEXT,
    cancelled_by TEXT,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bookings_barbershop ON public.barbershop_bookings(barbershop_id);
CREATE INDEX IF NOT EXISTS idx_bookings_barber ON public.barbershop_bookings(barber_id);
CREATE INDEX IF NOT EXISTS idx_bookings_client ON public.barbershop_bookings(client_id);
CREATE INDEX IF NOT EXISTS idx_bookings_start_time ON public.barbershop_bookings(start_time);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.barbershop_bookings(status);

-- =====================================================
-- 8. HORÁRIOS DE FUNCIONAMENTO
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barbershop_working_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    lunch_start TIME,
    lunch_end TIME,
    is_available BOOLEAN DEFAULT true,
    UNIQUE(barbershop_id, barber_id, day_of_week)
);

CREATE INDEX IF NOT EXISTS idx_working_hours_barbershop ON public.barbershop_working_hours(barbershop_id);

-- =====================================================
-- 9. BLOQUEIOS DE HORÁRIO
-- =====================================================
CREATE TABLE IF NOT EXISTS public.time_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    reason TEXT,
    block_type TEXT DEFAULT 'break' CHECK (block_type IN ('break', 'vacation', 'holiday', 'other')),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_time_blocks_barbershop ON public.time_blocks(barbershop_id);
CREATE INDEX IF NOT EXISTS idx_time_blocks_barber ON public.time_blocks(barber_id);

-- =====================================================
-- 10. PLANOS DE ASSINATURA
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barbershop_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration_days INTEGER NOT NULL DEFAULT 30,
    max_bookings_per_month INTEGER,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    included_services UUID[] DEFAULT '{}',
    benefits TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_plans_barbershop ON public.barbershop_plans(barbershop_id);

-- =====================================================
-- 11. ASSINATURAS DOS CLIENTES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.client_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    client_id UUID REFERENCES public.clients(id) ON DELETE CASCADE NOT NULL,
    plan_id UUID REFERENCES public.barbershop_plans(id) ON DELETE SET NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    bookings_used INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    auto_renew BOOLEAN DEFAULT false,
    payment_status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_barbershop ON public.client_subscriptions(barbershop_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_client ON public.client_subscriptions(client_id);

-- =====================================================
-- 12. PRODUTOS DA BARBEARIA
-- =====================================================
CREATE TABLE IF NOT EXISTS public.barbershop_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    stock INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 5,
    image_url TEXT,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_barbershop ON public.barbershop_products(barbershop_id);

-- =====================================================
-- 13. VENDAS DE PRODUTOS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.product_sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.barbershop_products(id) ON DELETE SET NULL,
    client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
    barber_id UUID REFERENCES public.barbers(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES public.barbershop_bookings(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    payment_method TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_product_sales_barbershop ON public.product_sales(barbershop_id);

-- =====================================================
-- 14. NOTIFICAÇÕES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info' CHECK (type IN ('info', 'booking', 'promotion', 'reminder', 'system')),
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.user_notifications(user_id);

-- =====================================================
-- 15. AVALIAÇÕES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE,
    client_id UUID REFERENCES public.clients(id) ON DELETE CASCADE NOT NULL,
    booking_id UUID REFERENCES public.barbershop_bookings(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    reply TEXT,
    replied_at TIMESTAMPTZ,
    is_visible BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reviews_barbershop ON public.reviews(barbershop_id);
CREATE INDEX IF NOT EXISTS idx_reviews_barber ON public.reviews(barber_id);

-- =====================================================
-- 16. HISTÓRICO FINANCEIRO
-- =====================================================
CREATE TABLE IF NOT EXISTS public.financial_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barbershop_id UUID REFERENCES public.barbershops(id) ON DELETE CASCADE NOT NULL,
    barber_id UUID REFERENCES public.barbers(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES public.barbershop_bookings(id) ON DELETE SET NULL,
    sale_id UUID REFERENCES public.product_sales(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('booking_payment', 'product_sale', 'subscription', 'commission', 'expense', 'refund')),
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    payment_method TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_financial_barbershop ON public.financial_transactions(barbershop_id);
CREATE INDEX IF NOT EXISTS idx_financial_created ON public.financial_transactions(created_at);

-- =====================================================
-- 17. ATUALIZAR TABELA PROFILES
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'barbershop_id') THEN
        ALTER TABLE public.profiles ADD COLUMN barbershop_id UUID REFERENCES public.barbershops(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'user_type') THEN
        ALTER TABLE public.profiles ADD COLUMN user_type TEXT DEFAULT 'client';
    END IF;
END $$;

-- =====================================================
-- 18. TRIGGERS PARA UPDATED_AT
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['barbershops', 'barbers', 'clients', 'barbershop_clients',
                              'barbershop_services', 'barbershop_bookings', 'barbershop_working_hours',
                              'barbershop_plans', 'client_subscriptions', 'barbershop_products']
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS update_%s_updated_at ON public.%s', t, t);
        EXECUTE format('CREATE TRIGGER update_%s_updated_at BEFORE UPDATE ON public.%s FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()', t, t);
    END LOOP;
END $$;

-- =====================================================
-- 19. FUNÇÕES AUXILIARES PARA RLS
-- =====================================================
CREATE OR REPLACE FUNCTION get_user_barbershop_id()
RETURNS UUID AS $$
DECLARE
    v_barbershop_id UUID;
BEGIN
    SELECT barbershop_id INTO v_barbershop_id
    FROM public.barbers
    WHERE user_id = auth.uid()
    LIMIT 1;

    IF v_barbershop_id IS NOT NULL THEN
        RETURN v_barbershop_id;
    END IF;

    SELECT barbershop_id INTO v_barbershop_id
    FROM public.profiles
    WHERE id = auth.uid()
    LIMIT 1;

    RETURN v_barbershop_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_barbershop_owner(shop_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.barbershops
        WHERE id = shop_id AND owner_id = auth.uid()
    ) OR EXISTS (
        SELECT 1 FROM public.barbers
        WHERE barbershop_id = shop_id AND user_id = auth.uid() AND is_owner = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_barbershop_member(shop_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.barbers
        WHERE barbershop_id = shop_id AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_user_client_id()
RETURNS UUID AS $$
DECLARE
    v_client_id UUID;
BEGIN
    SELECT id INTO v_client_id
    FROM public.clients
    WHERE user_id = auth.uid()
    LIMIT 1;

    RETURN v_client_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =====================================================
-- 20. RLS PARA NOVAS TABELAS
-- =====================================================

-- BARBERSHOPS
ALTER TABLE public.barbershops ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "barbershops_read" ON public.barbershops;
DROP POLICY IF EXISTS "barbershops_insert" ON public.barbershops;
DROP POLICY IF EXISTS "barbershops_update" ON public.barbershops;
DROP POLICY IF EXISTS "barbershops_delete" ON public.barbershops;
CREATE POLICY "barbershops_read" ON public.barbershops FOR SELECT USING (is_active = true OR owner_id = auth.uid() OR is_admin());
CREATE POLICY "barbershops_insert" ON public.barbershops FOR INSERT WITH CHECK (is_admin() OR auth.uid() = owner_id);
CREATE POLICY "barbershops_update" ON public.barbershops FOR UPDATE USING (owner_id = auth.uid() OR is_admin());
CREATE POLICY "barbershops_delete" ON public.barbershops FOR DELETE USING (is_admin());

-- BARBERS
ALTER TABLE public.barbers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "barbers_read" ON public.barbers;
DROP POLICY IF EXISTS "barbers_insert" ON public.barbers;
DROP POLICY IF EXISTS "barbers_update" ON public.barbers;
DROP POLICY IF EXISTS "barbers_delete" ON public.barbers;
CREATE POLICY "barbers_read" ON public.barbers FOR SELECT USING (is_active = true OR user_id = auth.uid() OR is_barbershop_owner(barbershop_id) OR is_admin());
CREATE POLICY "barbers_insert" ON public.barbers FOR INSERT WITH CHECK (is_barbershop_owner(barbershop_id) OR is_admin());
CREATE POLICY "barbers_update" ON public.barbers FOR UPDATE USING (user_id = auth.uid() OR is_barbershop_owner(barbershop_id) OR is_admin());
CREATE POLICY "barbers_delete" ON public.barbers FOR DELETE USING (is_barbershop_owner(barbershop_id) OR is_admin());

-- CLIENTS
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "clients_read" ON public.clients;
DROP POLICY IF EXISTS "clients_insert" ON public.clients;
DROP POLICY IF EXISTS "clients_update" ON public.clients;
CREATE POLICY "clients_read" ON public.clients FOR SELECT USING (user_id = auth.uid() OR is_admin() OR EXISTS (SELECT 1 FROM public.barbershop_clients bc JOIN public.barbers b ON b.barbershop_id = bc.barbershop_id WHERE bc.client_id = clients.id AND b.user_id = auth.uid()));
CREATE POLICY "clients_insert" ON public.clients FOR INSERT WITH CHECK (user_id = auth.uid() OR is_admin());
CREATE POLICY "clients_update" ON public.clients FOR UPDATE USING (user_id = auth.uid() OR is_admin());

-- BARBERSHOP_CLIENTS
ALTER TABLE public.barbershop_clients ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "barbershop_clients_read" ON public.barbershop_clients;
DROP POLICY IF EXISTS "barbershop_clients_insert" ON public.barbershop_clients;
DROP POLICY IF EXISTS "barbershop_clients_update" ON public.barbershop_clients;
DROP POLICY IF EXISTS "barbershop_clients_delete" ON public.barbershop_clients;
CREATE POLICY "barbershop_clients_read" ON public.barbershop_clients FOR SELECT USING (is_admin() OR client_id = get_user_client_id() OR (is_barbershop_member(barbershop_id) AND is_exclusive = false) OR (is_exclusive = true AND exclusive_barber_id IN (SELECT id FROM public.barbers WHERE user_id = auth.uid())));
CREATE POLICY "barbershop_clients_insert" ON public.barbershop_clients FOR INSERT WITH CHECK (client_id = get_user_client_id() OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "barbershop_clients_update" ON public.barbershop_clients FOR UPDATE USING (is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "barbershop_clients_delete" ON public.barbershop_clients FOR DELETE USING (is_barbershop_owner(barbershop_id) OR client_id = get_user_client_id() OR is_admin());

-- BARBERSHOP_SERVICES
ALTER TABLE public.barbershop_services ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "services_read" ON public.barbershop_services;
DROP POLICY IF EXISTS "services_insert" ON public.barbershop_services;
DROP POLICY IF EXISTS "services_update" ON public.barbershop_services;
DROP POLICY IF EXISTS "services_delete" ON public.barbershop_services;
CREATE POLICY "services_read" ON public.barbershop_services FOR SELECT USING (is_active = true OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "services_insert" ON public.barbershop_services FOR INSERT WITH CHECK (is_barbershop_owner(barbershop_id) OR is_admin());
CREATE POLICY "services_update" ON public.barbershop_services FOR UPDATE USING (is_barbershop_owner(barbershop_id) OR is_admin());
CREATE POLICY "services_delete" ON public.barbershop_services FOR DELETE USING (is_barbershop_owner(barbershop_id) OR is_admin());

-- BARBER_SERVICES
ALTER TABLE public.barber_services ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "barber_services_read" ON public.barber_services;
DROP POLICY IF EXISTS "barber_services_manage" ON public.barber_services;
CREATE POLICY "barber_services_read" ON public.barber_services FOR SELECT USING (true);
CREATE POLICY "barber_services_manage" ON public.barber_services FOR ALL USING (barber_id IN (SELECT id FROM public.barbers WHERE user_id = auth.uid()) OR is_admin());

-- BARBERSHOP_BOOKINGS
ALTER TABLE public.barbershop_bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "bookings_read" ON public.barbershop_bookings;
DROP POLICY IF EXISTS "bookings_insert" ON public.barbershop_bookings;
DROP POLICY IF EXISTS "bookings_update" ON public.barbershop_bookings;
CREATE POLICY "bookings_read" ON public.barbershop_bookings FOR SELECT USING (client_id = get_user_client_id() OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "bookings_insert" ON public.barbershop_bookings FOR INSERT WITH CHECK (client_id = get_user_client_id() OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "bookings_update" ON public.barbershop_bookings FOR UPDATE USING (client_id = get_user_client_id() OR is_barbershop_member(barbershop_id) OR is_admin());

-- BARBERSHOP_WORKING_HOURS
ALTER TABLE public.barbershop_working_hours ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "working_hours_read" ON public.barbershop_working_hours;
DROP POLICY IF EXISTS "working_hours_manage" ON public.barbershop_working_hours;
CREATE POLICY "working_hours_read" ON public.barbershop_working_hours FOR SELECT USING (true);
CREATE POLICY "working_hours_manage" ON public.barbershop_working_hours FOR ALL USING (is_barbershop_owner(barbershop_id) OR (barber_id IN (SELECT id FROM public.barbers WHERE user_id = auth.uid())) OR is_admin());

-- TIME_BLOCKS
ALTER TABLE public.time_blocks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "time_blocks_read" ON public.time_blocks;
DROP POLICY IF EXISTS "time_blocks_manage" ON public.time_blocks;
CREATE POLICY "time_blocks_read" ON public.time_blocks FOR SELECT USING (is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "time_blocks_manage" ON public.time_blocks FOR ALL USING (is_barbershop_owner(barbershop_id) OR (barber_id IN (SELECT id FROM public.barbers WHERE user_id = auth.uid())) OR is_admin());

-- BARBERSHOP_PLANS
ALTER TABLE public.barbershop_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "plans_read" ON public.barbershop_plans;
DROP POLICY IF EXISTS "plans_manage" ON public.barbershop_plans;
CREATE POLICY "plans_read" ON public.barbershop_plans FOR SELECT USING (is_active = true OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "plans_manage" ON public.barbershop_plans FOR ALL USING (is_barbershop_owner(barbershop_id) OR is_admin());

-- CLIENT_SUBSCRIPTIONS
ALTER TABLE public.client_subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "subscriptions_read" ON public.client_subscriptions;
DROP POLICY IF EXISTS "subscriptions_insert" ON public.client_subscriptions;
DROP POLICY IF EXISTS "subscriptions_update" ON public.client_subscriptions;
CREATE POLICY "subscriptions_read" ON public.client_subscriptions FOR SELECT USING (client_id = get_user_client_id() OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "subscriptions_insert" ON public.client_subscriptions FOR INSERT WITH CHECK (client_id = get_user_client_id() OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "subscriptions_update" ON public.client_subscriptions FOR UPDATE USING (is_barbershop_member(barbershop_id) OR is_admin());

-- BARBERSHOP_PRODUCTS
ALTER TABLE public.barbershop_products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "products_read" ON public.barbershop_products;
DROP POLICY IF EXISTS "products_manage" ON public.barbershop_products;
CREATE POLICY "products_read" ON public.barbershop_products FOR SELECT USING (is_active = true OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "products_manage" ON public.barbershop_products FOR ALL USING (is_barbershop_owner(barbershop_id) OR is_admin());

-- PRODUCT_SALES
ALTER TABLE public.product_sales ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "sales_read" ON public.product_sales;
DROP POLICY IF EXISTS "sales_insert" ON public.product_sales;
CREATE POLICY "sales_read" ON public.product_sales FOR SELECT USING (is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "sales_insert" ON public.product_sales FOR INSERT WITH CHECK (is_barbershop_member(barbershop_id) OR is_admin());

-- USER_NOTIFICATIONS
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "notifications_read" ON public.user_notifications;
DROP POLICY IF EXISTS "notifications_insert" ON public.user_notifications;
DROP POLICY IF EXISTS "notifications_update" ON public.user_notifications;
CREATE POLICY "notifications_read" ON public.user_notifications FOR SELECT USING (user_id = auth.uid() OR is_admin());
CREATE POLICY "notifications_insert" ON public.user_notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "notifications_update" ON public.user_notifications FOR UPDATE USING (user_id = auth.uid());

-- REVIEWS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "reviews_read" ON public.reviews;
DROP POLICY IF EXISTS "reviews_insert" ON public.reviews;
DROP POLICY IF EXISTS "reviews_update" ON public.reviews;
CREATE POLICY "reviews_read" ON public.reviews FOR SELECT USING (is_visible = true OR is_barbershop_member(barbershop_id) OR is_admin());
CREATE POLICY "reviews_insert" ON public.reviews FOR INSERT WITH CHECK (client_id = get_user_client_id() OR is_admin());
CREATE POLICY "reviews_update" ON public.reviews FOR UPDATE USING (client_id = get_user_client_id() OR is_barbershop_owner(barbershop_id) OR is_admin());

-- FINANCIAL_TRANSACTIONS
ALTER TABLE public.financial_transactions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "financial_read" ON public.financial_transactions;
DROP POLICY IF EXISTS "financial_insert" ON public.financial_transactions;
CREATE POLICY "financial_read" ON public.financial_transactions FOR SELECT USING (is_barbershop_owner(barbershop_id) OR is_admin());
CREATE POLICY "financial_insert" ON public.financial_transactions FOR INSERT WITH CHECK (is_barbershop_member(barbershop_id) OR is_admin());
