-- ADD SHOP CODE & LINKING LOGIC

-- 1. Add shop_code to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS shop_code TEXT UNIQUE;

-- 2. Generate codes for existing barbers (Simple Logic: First Name + Random Number)
UPDATE public.profiles
SET shop_code = UPPER(SUBSTRING(full_name FROM 1 FOR 3) || CAST(FLOOR(RANDOM() * 1000 + 1000) AS TEXT))
WHERE role = 'barber' AND shop_code IS NULL;

-- 3. Update Trigger to Auto-Link Clients based on Shop Code
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  target_barber_id UUID;
  invite_code TEXT;
BEGIN
  invite_code := new.raw_user_meta_data->>'invite_code';

  -- Create Profile
  INSERT INTO public.profiles (id, full_name, email, role, avatar_url, shop_code)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Novo Usuário'),
    new.email,
    COALESCE(new.raw_user_meta_data->>'role', 'client'),
    new.raw_user_meta_data->>'avatar_url',
    -- Generate code only if it's a barber
    CASE 
        WHEN (new.raw_user_meta_data->>'role') = 'barber' THEN 
            UPPER(SUBSTRING(COALESCE(new.raw_user_meta_data->>'full_name', 'BAR') FROM 1 FOR 3) || CAST(FLOOR(RANDOM() * 1000 + 1000) AS TEXT))
        ELSE NULL 
    END
  );

  -- If Client provided an invite code, link them immediately
  IF invite_code IS NOT NULL AND (new.raw_user_meta_data->>'role') = 'client' THEN
      SELECT id INTO target_barber_id FROM public.profiles WHERE shop_code = invite_code LIMIT 1;
      
      IF target_barber_id IS NOT NULL THEN
          INSERT INTO public.barber_clients (barber_id, client_id)
          VALUES (target_barber_id, new.id);
      END IF;
  END IF;

  RETURN new;
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'Erro no trigger handle_new_user: %', SQLERRM;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Ensure RLS allows reading shop_code (Already covered by "profiles_read_global" but good to know)
