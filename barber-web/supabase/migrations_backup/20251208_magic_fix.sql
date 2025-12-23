-- MAGIC FIX SCRIPT (Rode este script para corrigir TODAS as tabelas)
-- Este script usa a sintaxe 'ADD COLUMN IF NOT EXISTS' que é mais segura e evita erros.

-- 1. CORRIGIR TABELA BOOKINGS (Agendamentos)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS barber_id UUID REFERENCES auth.users(id);
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS client_id UUID REFERENCES auth.users(id);
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS booking_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS client_name TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS service_name TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending';
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS price DECIMAL(10,2);

-- 2. CORRIGIR TABELA SERVICES (Serviços)
CREATE TABLE IF NOT EXISTS public.services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.services ADD COLUMN IF NOT EXISTS barber_id UUID REFERENCES auth.users(id);
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS name TEXT; -- Pode dar erro se já existe como NOT NULL, mas vamos tentar
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS price DECIMAL(10,2);
ALTER TABLE public.services ADD COLUMN IF NOT EXISTS duration_minutes INTEGER DEFAULT 30;

-- 3. CORRIGIR TABELA PRODUCTS (Produtos)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.products ADD COLUMN IF NOT EXISTS barber_id UUID REFERENCES auth.users(id);
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS price DECIMAL(10,2);
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS stock INTEGER DEFAULT 0;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 4. CORRIGIR TABELA NOTIFICATIONS (Notificações)
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS message TEXT;
ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS read BOOLEAN DEFAULT FALSE;

-- 5. CONFIGURAR STORAGE (Fotos)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true) 
ON CONFLICT (id) DO NOTHING;

-- Políticas de Storage (Remove antigas e recria)
DROP POLICY IF EXISTS "Avatar Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Update Access" ON storage.objects;

CREATE POLICY "Avatar Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Upload Access" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Update Access" ON storage.objects FOR UPDATE USING ( auth.uid() = owner );

-- 6. RECRIAR POLÍTICAS DE SEGURANÇA (RLS)
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Limpeza de políticas antigas
DROP POLICY IF EXISTS "Barbers manage own services" ON public.services;
DROP POLICY IF EXISTS "Public read services" ON public.services;
DROP POLICY IF EXISTS "Barbers manage own products" ON public.products;
DROP POLICY IF EXISTS "Public read products" ON public.products;
DROP POLICY IF EXISTS "Users read own notifications" ON public.notifications;

-- Novas Políticas
-- Serviços
CREATE POLICY "Barbers manage own services" ON public.services USING (auth.uid() = barber_id);
CREATE POLICY "Public read services" ON public.services FOR SELECT USING (true);

-- Produtos
CREATE POLICY "Barbers manage own products" ON public.products USING (auth.uid() = barber_id);
CREATE POLICY "Public read products" ON public.products FOR SELECT USING (true);

-- Notificações
CREATE POLICY "Users read own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System create notifications" ON public.notifications FOR INSERT WITH CHECK (true);

-- Bookings (Reforço)
DROP POLICY IF EXISTS "Clients can view own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Barbers can view assigned bookings" ON public.bookings;

CREATE POLICY "Clients can view own bookings" ON public.bookings FOR SELECT USING ( auth.uid() = client_id );
CREATE POLICY "Barbers can view assigned bookings" ON public.bookings FOR SELECT USING ( auth.uid() = barber_id );
CREATE POLICY "Clients create bookings" ON public.bookings FOR INSERT WITH CHECK ( auth.uid() = client_id );
CREATE POLICY "Barbers update bookings" ON public.bookings FOR UPDATE USING ( auth.uid() = barber_id );
