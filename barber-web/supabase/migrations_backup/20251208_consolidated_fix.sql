-- SCRIPT CONSOLIDADO E CORRIGIDO (Copie e cole no Supabase SQL Editor)

-- 1. CORREÇÃO DA TABELA DE AGENDAMENTOS (Bookings)
-- Verifica e cria as colunas se elas não existirem, evitando erros.
DO $$
BEGIN
    -- Adiciona barber_id (vínculo com o barbeiro)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='barber_id') THEN
        ALTER TABLE public.bookings ADD COLUMN barber_id UUID REFERENCES auth.users(id);
    END IF;

    -- Adiciona client_id (vínculo com o cliente)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='client_id') THEN
        ALTER TABLE public.bookings ADD COLUMN client_id UUID REFERENCES auth.users(id);
    END IF;

    -- Adiciona booking_date (data e hora)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='booking_date') THEN
        ALTER TABLE public.bookings ADD COLUMN booking_date TIMESTAMP WITH TIME ZONE;
    END IF;
    
    -- Adiciona client_name (cache do nome para facilitar exibição)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='client_name') THEN
        ALTER TABLE public.bookings ADD COLUMN client_name TEXT;
    END IF;
    
    -- Adiciona service_name (nome do serviço)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='service_name') THEN
        ALTER TABLE public.bookings ADD COLUMN service_name TEXT;
    END IF;
END $$;

-- 2. CRIAÇÃO DAS TABELAS DE GESTÃO (Se não existirem)

-- Tabela de Serviços
CREATE TABLE IF NOT EXISTS public.services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de Produtos
CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    barber_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INTEGER DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de Notificações
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. HABILITAR UPLOAD DE FOTOS (Storage)
-- Cria o balde 'avatars' para fotos de perfil
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas de segurança para o Storage (Permitir upload)
DROP POLICY IF EXISTS "Avatar Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Update Access" ON storage.objects;

CREATE POLICY "Avatar Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Upload Access" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Update Access" ON storage.objects FOR UPDATE USING ( auth.uid() = owner );

-- 4. POLÍTICAS DE SEGURANÇA (Row Level Security)

-- Habilita RLS nas tabelas
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Limpa políticas antigas para evitar duplicação/conflito
DROP POLICY IF EXISTS "Barbers manage own services" ON public.services;
DROP POLICY IF EXISTS "Public read services" ON public.services;
DROP POLICY IF EXISTS "Barbers manage own products" ON public.products;
DROP POLICY IF EXISTS "Public read products" ON public.products;

-- Cria novas políticas
-- Serviços: Barbeiro dono edita, todo mundo vê
CREATE POLICY "Barbers manage own services" ON public.services USING (auth.uid() = barber_id);
CREATE POLICY "Public read services" ON public.services FOR SELECT USING (true);

-- Produtos: Barbeiro dono edita, todo mundo vê
CREATE POLICY "Barbers manage own products" ON public.products USING (auth.uid() = barber_id);
CREATE POLICY "Public read products" ON public.products FOR SELECT USING (true);

-- Notificações: Usuário vê as suas
CREATE POLICY "Users read own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
-- Permite inserção para criar notificações (Geralmente feito pelo backend ou trigger, aqui aberto para teste)
CREATE POLICY "System create notifications" ON public.notifications FOR INSERT WITH CHECK (true);
