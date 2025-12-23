-- ULTIMATE RECURSION KILLER (O FIM DA RECURSÃO)
-- Rode este script para limpar de vez qualquer política que esteja travando o banco.

BEGIN;

-- 1. Desliga a segurança temporariamente para garantir acesso
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 2. Remove TODAS as políticas conhecidas (lista exaustiva)
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
DROP POLICY IF EXISTS "Profiles_Read_All" ON public.profiles;
DROP POLICY IF EXISTS "Profiles_Update_Own" ON public.profiles;
DROP POLICY IF EXISTS "Profiles_Insert_Own" ON public.profiles;
DROP POLICY IF EXISTS "allow_all_select" ON public.profiles;
DROP POLICY IF EXISTS "allow_self_update" ON public.profiles;

-- 3. Recria APENAS 3 políticas simples (Blindadas contra recursão)

-- Leitura: Liberada geral (necessário para que clientes vejam barbeiros e vice-versa)
-- USING (true) significa "Sempre verdade", nunca consulta o banco, logo, zero recursão.
CREATE POLICY "profiles_read_global" ON public.profiles FOR SELECT USING (true);

-- Atualização: Apenas o dono do ID (Compara ID da sessão com ID da linha)
CREATE POLICY "profiles_update_self" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Inserção: Apenas o dono
CREATE POLICY "profiles_insert_self" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. Reabilita a segurança
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 5. Garante que outras tabelas críticas não tenham recursão (referenciando profiles de forma errada)
-- Limpeza preventiva em barber_clients
DROP POLICY IF EXISTS "Barbers view clients" ON public.barber_clients;
DROP POLICY IF EXISTS "Vincular Clientes" ON public.barber_clients;
CREATE POLICY "barber_clients_read_all" ON public.barber_clients FOR SELECT USING (true);
CREATE POLICY "barber_clients_insert_all" ON public.barber_clients FOR INSERT WITH CHECK (true);
CREATE POLICY "barber_clients_delete_all" ON public.barber_clients FOR DELETE USING (true);

COMMIT;
