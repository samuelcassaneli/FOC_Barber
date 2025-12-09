-- SCRIPT "DIAGNOSTIC & FIX" (DIAGNÓSTICO E CORREÇÃO)

-- 1. VERIFICAR E CORRIGIR TRIGGERS (Garantir que usuários novos vão para profiles)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, role, avatar_url, shop_code)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Novo Usuário'),
    new.email,
    COALESCE(new.raw_user_meta_data->>'role', 'client'),
    new.raw_user_meta_data->>'avatar_url',
    CASE 
        WHEN (new.raw_user_meta_data->>'role') = 'barber' THEN 
            UPPER(SUBSTRING(COALESCE(new.raw_user_meta_data->>'full_name', 'BAR') FROM 1 FOR 3) || CAST(FLOOR(RANDOM() * 1000 + 1000) AS TEXT))
        ELSE NULL 
    END
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = EXCLUDED.role; -- Atualiza se já existir
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 2. REPPOPULAR TABELA PROFILES (Recuperar dados perdidos da auth.users)
-- Isso conserta o Painel Admin zerado se os dados estiverem apenas na Auth
INSERT INTO public.profiles (id, email, role, full_name, created_at)
SELECT 
    id, 
    email, 
    COALESCE(raw_user_meta_data->>'role', 'client'),
    COALESCE(raw_user_meta_data->>'full_name', 'Usuário Recuperado'),
    created_at
FROM auth.users
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = EXCLUDED.role;

-- 3. FORÇAR CÓDIGO E ROLE PARA SEUS USUÁRIOS ESPECÍFICOS
UPDATE public.profiles
SET role = 'barber', shop_code = 'BARBER01'
WHERE email = 'samuelcassaneli@proton.me';

UPDATE public.profiles
SET role = 'admin'
WHERE email = 'aiucmt.kiaaivmtq@gmail.com';

-- 4. CORREÇÃO EXTREMA DE RLS (POLÍTICAS DE SEGURANÇA)
-- Se o Admin não vê nada, é porque o RLS está bloqueando.
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY; -- Desliga temporariamente para teste/correção
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin Full Access" ON public.profiles;
DROP POLICY IF EXISTS "Leitura Publica" ON public.profiles;
DROP POLICY IF EXISTS "profiles_read_global" ON public.profiles;

-- Política de Leitura GLOBAL (Essencial para Admin e Login funcionarem bem)
CREATE POLICY "Global Read" ON public.profiles FOR SELECT USING (true);

-- Política de Admin (Pode fazer TUDO)
CREATE POLICY "Admin Everything" ON public.profiles FOR ALL 
USING (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com')
WITH CHECK (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com');

-- Política de Usuário (Edita a si mesmo)
CREATE POLICY "User Update Self" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 5. CORREÇÃO STORAGE (FOTOS)
UPDATE storage.buckets SET public = true WHERE id = 'avatars';
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
DROP POLICY IF EXISTS "User Upload" ON storage.objects;
CREATE POLICY "User Upload" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' AND auth.uid() = owner );
DROP POLICY IF EXISTS "User Update" ON storage.objects;
CREATE POLICY "User Update" ON storage.objects FOR UPDATE USING ( bucket_id = 'avatars' AND auth.uid() = owner );
