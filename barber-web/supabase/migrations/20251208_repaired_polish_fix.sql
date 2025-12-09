-- REPAIRED POLISH FIX (Rode este script para corrigir o erro da coluna 'duration')

-- 1. CORRIGIR TABELA SERVICES (Remover 'duration_min' e garantir 'duration_minutes')
DO $$
BEGIN
    -- Remove 'duration_min' se existir (esta é a coluna que estava causando conflito)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='duration_min') THEN
        ALTER TABLE public.services DROP COLUMN duration_min;
    END IF;

    -- Garante que 'duration_minutes' exista (coluna correta que o app usa)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='duration_minutes') THEN
        ALTER TABLE public.services ADD COLUMN duration_minutes INTEGER; -- Adiciona sem NOT NULL primeiro
    END IF;
    
    -- Define DEFAULT e NOT NULL para 'duration_minutes'
    ALTER TABLE public.services ALTER COLUMN duration_minutes SET DEFAULT 30;
    ALTER TABLE public.services ALTER COLUMN duration_minutes SET NOT NULL;

    -- Garante que 'name' e 'price' também sejam NOT NULL e tenham DEFAULT 
    -- (Pode ser que existam de criações parciais anteriores)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='name') THEN
        ALTER TABLE public.services ALTER COLUMN name SET NOT NULL;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='price') THEN
        ALTER TABLE public.services ALTER COLUMN price SET DEFAULT 0.0;
        ALTER TABLE public.services ALTER COLUMN price SET NOT NULL;
    END IF;

END $$;

-- 2. FORÇAR GERAÇÃO DE SHOP CODES (Para Barbers que vêem "...")
UPDATE public.profiles
SET shop_code = UPPER(SUBSTRING(full_name FROM 1 FOR 3) || CAST(FLOOR(RANDOM() * 1000 + 1000) AS TEXT))
WHERE role = 'barber' AND shop_code IS NULL;

-- 3. REAPLICAR POLÍTICAS DE STORAGE (Para garantir upload de fotos)
DROP POLICY IF EXISTS "Avatar Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Update Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Select Access" ON storage.objects;

-- Regras de acesso ao bucket 'avatars'
CREATE POLICY "Avatar Select Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
CREATE POLICY "Avatar Upload Access" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' AND auth.uid() = owner );
CREATE POLICY "Avatar Update Access" ON storage.objects FOR UPDATE USING ( bucket_id = 'avatars' AND auth.uid() = owner );

-- 4. REAPLICAR RLS DE PROFILES (Para garantir leitura do shop_code)
DROP POLICY IF EXISTS "profiles_read_global" ON public.profiles;
CREATE POLICY "profiles_read_global" ON public.profiles FOR SELECT USING (true);
