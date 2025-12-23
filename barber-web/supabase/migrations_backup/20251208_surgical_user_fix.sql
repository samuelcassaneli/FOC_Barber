-- SCRIPT "CIRÚRGICO" (Rode este para corrigir seus usuários específicos e o Admin)

-- 1. FORÇAR CÓDIGO DA BARBEARIA PARA SEU USUÁRIO
-- Define um código fixo para fácil teste
UPDATE public.profiles
SET shop_code = 'BARBER01'
WHERE email = 'samuelcassaneli@proton.me';

-- 2. DEFINIR SUPER ADMIN NO BANCO
-- Garante que seu email de admin tenha a role correta
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'aiucmt.kiaaivmtq@gmail.com';

-- 3. CORREÇÃO DEFINITIVA DO STORAGE (FOTOS)
-- Removemos todas as políticas complexas e deixamos o básico:
-- Todo mundo vê (public), Dono faz upload/update.
UPDATE storage.buckets SET public = true WHERE id = 'avatars';

DROP POLICY IF EXISTS "Avatar Select Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Update Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Delete Access" ON storage.objects;

CREATE POLICY "Avatar Select Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Upload Access" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' AND auth.uid() = owner );
CREATE POLICY "Avatar Update Access" ON storage.objects FOR UPDATE USING ( bucket_id = 'avatars' AND auth.uid() = owner );
CREATE POLICY "Avatar Delete Access" ON storage.objects FOR DELETE USING ( bucket_id = 'avatars' AND auth.uid() = owner );

-- 4. PERMISSÕES DE SUPER ADMIN (Para o WebApp funcionar)
-- Permite que o Admin (identificado pelo email no token) faça TUDO na tabela profiles
CREATE POLICY "Admin Full Access" ON public.profiles
FOR ALL
USING (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com');

-- Permite que Admin delete barbearias (que deleta cascade para os bookings)
CREATE POLICY "Admin Delete Barbers" ON public.barber_clients
FOR ALL
USING (auth.jwt() ->> 'email' = 'aiucmt.kiaaivmtq@gmail.com');
