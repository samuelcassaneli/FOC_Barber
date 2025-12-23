-- =====================================================
-- MIGRAÇÃO: ADICIONAR COLUNAS WHITE-LABEL
-- Data: 2024-12-23
-- Descrição: Adiciona colunas faltantes para sistema white-label
-- =====================================================

-- 1. Adicionar coluna website na tabela barbershops
ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS website TEXT;

-- 2. Adicionar colunas de personalização (white-label)
ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS cnpj TEXT;

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS primary_color TEXT DEFAULT '#D4AF37';

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS secondary_color TEXT DEFAULT '#1C1C1E';

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE;

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS plan_type TEXT DEFAULT 'free' CHECK (plan_type IN ('free', 'basic', 'premium', 'enterprise'));

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS plan_expires_at TIMESTAMPTZ;

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS max_barbers INTEGER DEFAULT 5;

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS whatsapp TEXT;

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS instagram TEXT;

ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS facebook TEXT;

-- 3. Criar índice para invite_code
CREATE INDEX IF NOT EXISTS idx_barbershops_invite_code ON public.barbershops(invite_code);

-- 4. Função para gerar código de convite único
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    result TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..8 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 5. Trigger para gerar invite_code automaticamente
CREATE OR REPLACE FUNCTION set_invite_code()
RETURNS TRIGGER AS $$
DECLARE
    new_code TEXT;
    code_exists BOOLEAN;
BEGIN
    IF NEW.invite_code IS NULL THEN
        LOOP
            new_code := generate_invite_code();
            SELECT EXISTS(SELECT 1 FROM public.barbershops WHERE invite_code = new_code) INTO code_exists;
            EXIT WHEN NOT code_exists;
        END LOOP;
        NEW.invite_code := new_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_barbershop_invite_code ON public.barbershops;
CREATE TRIGGER set_barbershop_invite_code
    BEFORE INSERT ON public.barbershops
    FOR EACH ROW
    EXECUTE FUNCTION set_invite_code();

-- 6. Gerar códigos para barbearias existentes que não têm
UPDATE public.barbershops
SET invite_code = generate_invite_code()
WHERE invite_code IS NULL;

-- 7. Tabela de planos do sistema (para admin vender)
CREATE TABLE IF NOT EXISTS public.system_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2) NOT NULL,
    price_yearly DECIMAL(10,2),
    max_barbers INTEGER DEFAULT 5,
    max_clients INTEGER,
    max_bookings_per_month INTEGER,
    features JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Inserir planos padrão
INSERT INTO public.system_plans (name, slug, description, price_monthly, price_yearly, max_barbers, max_clients, features, display_order)
VALUES
    ('Gratuito', 'free', 'Plano inicial para testar a plataforma', 0, 0, 1, 50, '{"booking_confirmation": true, "basic_reports": true}', 1),
    ('Básico', 'basic', 'Ideal para barbearias iniciantes', 49.90, 479.90, 3, 200, '{"booking_confirmation": true, "basic_reports": true, "whatsapp_notifications": true}', 2),
    ('Premium', 'premium', 'Para barbearias em crescimento', 99.90, 959.90, 10, 1000, '{"booking_confirmation": true, "advanced_reports": true, "whatsapp_notifications": true, "financial_control": true, "multiple_locations": false}', 3),
    ('Enterprise', 'enterprise', 'Solução completa para redes', 249.90, 2399.90, -1, -1, '{"booking_confirmation": true, "advanced_reports": true, "whatsapp_notifications": true, "financial_control": true, "multiple_locations": true, "api_access": true, "white_label": true}', 4)
ON CONFLICT (slug) DO NOTHING;

-- 9. RLS para system_plans
ALTER TABLE public.system_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "system_plans_read" ON public.system_plans;
CREATE POLICY "system_plans_read" ON public.system_plans FOR SELECT USING (is_active = true OR is_admin());

-- 10. Adicionar coluna owner_email para facilitar criação de barbearia
ALTER TABLE public.barbershops
ADD COLUMN IF NOT EXISTS owner_email TEXT;

-- 11. Comentário nas colunas para documentação
COMMENT ON COLUMN public.barbershops.website IS 'Website da barbearia';
COMMENT ON COLUMN public.barbershops.invite_code IS 'Código único para clientes se vincularem à barbearia';
COMMENT ON COLUMN public.barbershops.primary_color IS 'Cor primária para personalização do app';
COMMENT ON COLUMN public.barbershops.secondary_color IS 'Cor secundária para personalização do app';
COMMENT ON COLUMN public.barbershops.plan_type IS 'Tipo do plano atual da barbearia';
COMMENT ON COLUMN public.barbershops.owner_email IS 'Email do proprietário para envio de convite';
