-- SCRIPT DE CORREÇÃO: ADICIONAR COLUNA EMAIL E CONFIGURAR USUÁRIOS
-- Este script corrige o erro "column email does not exist" e aplica as configurações do seu usuário.

-- 1. ADICIONAR A COLUNA EMAIL NA TABELA PROFILES (Se não existir)
-- É importante ter o email no perfil para facilitar a exibição e busca.
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- 2. SINCRONIZAR EMAILS DA TABELA DE AUTENTICAÇÃO
-- Preenche a coluna email vazia com os dados reais dos usuários.
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND (p.email IS NULL OR p.email = '');

-- 3. FORÇAR CÓDIGO DA BARBEARIA PARA SEU USUÁRIO (Agora vai funcionar)
UPDATE public.profiles
SET shop_code = 'BARBER01'
WHERE email = 'samuelcassaneli@proton.me';

-- 4. DEFINIR SUPER ADMIN
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'aiucmt.kiaaivmtq@gmail.com';

-- 5. REAPLICAR PERMISSÕES DE ADMIN (Garantia)
DROP POLICY IF EXISTS "Admin Full Access" ON public.profiles;
CREATE POLICY "Admin Full Access" ON public.profiles
FOR ALL
USING (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com');

DROP POLICY IF EXISTS "Admin Delete Barbers" ON public.barber_clients;
CREATE POLICY "Admin Delete Barbers" ON public.barber_clients
FOR ALL
USING (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com');

-- 6. CORREÇÃO DE STORAGE (FOTOS) - REFORÇO
UPDATE storage.buckets SET public = true WHERE id = 'avatars';

DROP POLICY IF EXISTS "Avatar Select Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Update Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Delete Access" ON storage.objects;

CREATE POLICY "Avatar Select Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Upload Access" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' AND auth.uid() = owner );
CREATE POLICY "Avatar Update Access" ON storage.objects FOR UPDATE USING ( bucket_id = 'avatars' AND auth.uid() = owner );
