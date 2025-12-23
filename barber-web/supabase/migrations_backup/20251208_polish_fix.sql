-- FIX DATABASE INCONSISTENCIES & GENERATE CODES

-- 1. FIX SERVICES TABLE (Standardize column name to 'duration_minutes')
DO $$
BEGIN
    -- If 'duration_min' exists (User reported this), rename it to 'duration_minutes'
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='duration_min') THEN
        ALTER TABLE public.services RENAME COLUMN duration_min TO duration_minutes;
    END IF;

    -- Ensure 'duration_minutes' exists now
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='duration_minutes') THEN
        ALTER TABLE public.services ADD COLUMN duration_minutes INTEGER DEFAULT 30;
    END IF;
    
    -- Force Not Null constraint to be optional initially or set default
    ALTER TABLE public.services ALTER COLUMN duration_minutes SET DEFAULT 30;
END $$;

-- 2. FORCE GENERATE SHOP CODES (For Barbers who see "...")
UPDATE public.profiles
SET shop_code = UPPER(SUBSTRING(full_name FROM 1 FOR 3) || CAST(FLOOR(RANDOM() * 1000 + 1000) AS TEXT))
WHERE role = 'barber' AND shop_code IS NULL;

-- 3. FIX PROFILE PICTURE RLS (Ensure updates work)
-- Sometimes 'storage.objects' policies get tricky. We refresh them.
DROP POLICY IF EXISTS "Avatar Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Update Access" ON storage.objects;
DROP POLICY IF EXISTS "Avatar Select Access" ON storage.objects;

-- Allow anyone to read avatars
CREATE POLICY "Avatar Select Access" ON storage.objects FOR SELECT USING ( bucket_id = 'avatars' );
-- Allow authenticated users to upload their own avatar (owner match)
CREATE POLICY "Avatar Upload Access" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'avatars' AND auth.uid() = owner );
-- Allow update
CREATE POLICY "Avatar Update Access" ON storage.objects FOR UPDATE USING ( bucket_id = 'avatars' AND auth.uid() = owner );

-- 4. ENSURE PROFILES CAN BE READ (For Shop Code display)
-- Re-run the non-recursive read policy just to be sure
DROP POLICY IF EXISTS "profiles_read_global" ON public.profiles;
CREATE POLICY "profiles_read_global" ON public.profiles FOR SELECT USING (true);
