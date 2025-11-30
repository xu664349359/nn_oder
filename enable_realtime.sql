-- Enable Realtime for profiles table
-- This allows listening to INSERT, UPDATE, DELETE events on the profiles table

ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
