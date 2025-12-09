-- SCRIPT DE CORREÇÃO DE TIPAGEM (RODE ESTE)
-- O erro ocorreu porque a coluna 'role' é de um tipo especial (ENUM), não texto simples.
-- Este script faz a conversão explícita (CAST) para corrigir o problema.

BEGIN;

-- 1. ATUALIZAR A FUNÇÃO DO GATILHO (TRIGGER) COM O CAST CORRETO
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, role, avatar_url, shop_code)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Novo Usuário'),
    new.email,
    -- AQUI ESTÁ A CORREÇÃO: ::public.user_role
    COALESCE(new.raw_user_meta_data->>'role', 'client')::public.user_role,
    new.raw_user_meta_data->>'avatar_url',
    CASE 
        WHEN (new.raw_user_meta_data->>'role') = 'barber' THEN 
            UPPER(SUBSTRING(COALESCE(new.raw_user_meta_data->>'full_name', 'BAR') FROM 1 FOR 3) || CAST(FLOOR(RANDOM() * 1000 + 1000) AS TEXT))
        ELSE NULL 
    END
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = EXCLUDED.role;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. REPPOPULAR PERFIS (RECUPERAR USUÁRIOS SUMIDOS)
INSERT INTO public.profiles (id, email, role, full_name, created_at)
SELECT 
    id, 
    email, 
    -- CORREÇÃO DO TIPO AQUI TAMBÉM
    COALESCE(raw_user_meta_data->>'role', 'client')::public.user_role,
    COALESCE(raw_user_meta_data->>'full_name', 'Usuário Recuperado'),
    created_at
FROM auth.users
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = EXCLUDED.role;

-- 3. DEFINIR BARBEIRO E ADMIN COM O TIPO CORRETO
UPDATE public.profiles
SET role = 'barber'::public.user_role, shop_code = 'BARBER01'
WHERE email = 'samuelcassaneli@proton.me';

UPDATE public.profiles
SET role = 'admin'::public.user_role
WHERE email = 'aiucmt.kiaaivmtq@gmail.com';

-- 4. GARANTIR PERMISSÕES DE ADMIN (SUPER ADMIN)
DROP POLICY IF EXISTS "Admin Everything" ON public.profiles;
CREATE POLICY "Admin Everything" ON public.profiles
FOR ALL 
USING (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com')
WITH CHECK (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com');

-- 5. PERMISSÃO DE LEITURA GLOBAL (Para Admin ver tudo e Login funcionar)
DROP POLICY IF EXISTS "Global Read" ON public.profiles;
CREATE POLICY "Global Read" ON public.profiles FOR SELECT USING (true);

COMMIT;
