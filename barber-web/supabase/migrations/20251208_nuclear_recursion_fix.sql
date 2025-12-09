-- SCRIPT "NUCLEAR" ANTI-RECURSÃO (Copia e cola no Supabase SQL Editor)
-- Este script remove BRUTALMENTE todas as políticas de segurança da tabela profiles
-- e de outras tabelas críticas para garantir que não sobre nenhuma regra antiga causando loop.

BEGIN;

-- 1. Desabilitar RLS temporariamente para limpar a casa
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_clients DISABLE ROW LEVEL SECURITY;

-- 2. Remover TODAS as políticas existentes (Force Drop)
-- Infelizmente SQL padrão não tem "DROP ALL POLICIES", então vamos remover as conhecidas e genéricas
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles view" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own" ON public.profiles;
DROP POLICY IF EXISTS "Users insert own" ON public.profiles;
DROP POLICY IF EXISTS "Leitura Publica" ON public.profiles;
DROP POLICY IF EXISTS "Leitura Geral" ON public.profiles;
DROP POLICY IF EXISTS "Atualizar Proprio" ON public.profiles;
DROP POLICY IF EXISTS "Inserir Proprio" ON public.profiles;
DROP POLICY IF EXISTS "No-Recursion Read Profiles" ON public.profiles;
DROP POLICY IF EXISTS "No-Recursion Update Profiles" ON public.profiles;
DROP POLICY IF EXISTS "No-Recursion Insert Profiles" ON public.profiles;

-- 3. Criar políticas BLINDADAS (Zero Recursão) para Profiles
-- Regra 1: Todo mundo lê todo mundo (Necessário para clientes verem barbeiros e vice-versa)
CREATE POLICY "Profiles_Read_All" ON public.profiles FOR SELECT USING (true);

-- Regra 2: Só o dono edita seu perfil (Comparação direta de ID, sem Select)
CREATE POLICY "Profiles_Update_Own" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Regra 3: Só o dono insere (Geralmente feito pelo Trigger, mas deixamos aqui por segurança)
CREATE POLICY "Profiles_Insert_Own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. Recriar políticas de Bookings (Evitar bloqueios)
DROP POLICY IF EXISTS "View bookings" ON public.bookings;
DROP POLICY IF EXISTS "View Bookings General" ON public.bookings;
DROP POLICY IF EXISTS "Clients can view own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Barbers can view assigned bookings" ON public.bookings;

CREATE POLICY "Bookings_Read_Own" ON public.bookings FOR SELECT USING (auth.uid() = client_id OR auth.uid() = barber_id);
CREATE POLICY "Bookings_Insert_Own" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = client_id OR auth.uid() = barber_id);
CREATE POLICY "Bookings_Update_Own" ON public.bookings FOR UPDATE USING (auth.uid() = client_id OR auth.uid() = barber_id);

-- 5. Recriar políticas de Barber Clients (Relacionamento)
DROP POLICY IF EXISTS "Barbers view clients" ON public.barber_clients;
DROP POLICY IF EXISTS "Vincular Clientes" ON public.barber_clients;

CREATE POLICY "BarberClients_Read" ON public.barber_clients FOR SELECT USING (true);
CREATE POLICY "BarberClients_Insert" ON public.barber_clients FOR INSERT WITH CHECK (true);
CREATE POLICY "BarberClients_Delete" ON public.barber_clients FOR DELETE USING (auth.uid() = barber_id OR auth.uid() = client_id);

-- 6. Reabilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_clients ENABLE ROW LEVEL SECURITY;

COMMIT;
