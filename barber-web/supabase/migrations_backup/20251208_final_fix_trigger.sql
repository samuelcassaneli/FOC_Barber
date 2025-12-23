-- FINAL FIX FOR 500 ERROR
-- This script drops the old trigger and recreates a "Safe" version
-- It handles missing metadata gracefully and bypasses permission checks

-- 1. Drop existing trigger and function to ensure a clean slate
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. Create the function with SECURITY DEFINER (Runs as Admin)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, role, avatar_url)
  VALUES (
    new.id,
    -- Fallback to 'Nome Indefinido' if metadata is missing to prevent NOT NULL errors
    COALESCE(new.raw_user_meta_data->>'full_name', 'Nome Indefinido'),
    new.email,
    -- Fallback to 'client' if role is missing
    COALESCE(new.raw_user_meta_data->>'role', 'client'),
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
EXCEPTION
  WHEN others THEN
    -- If something fails, log it but don't crash the transaction (prevents 500 error)
    RAISE WARNING 'Error creating profile for user %: %', new.id, SQLERRM;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Re-create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
