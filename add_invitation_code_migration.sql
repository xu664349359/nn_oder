-- Add invitation_code column to profiles table
ALTER TABLE public.profiles 
ADD COLUMN invitation_code TEXT;

-- Create unique index on invitation_code
CREATE UNIQUE INDEX idx_profiles_invitation_code 
ON public.profiles(invitation_code) 
WHERE invitation_code IS NOT NULL;

-- Add check constraint to ensure it's 6 digits
ALTER TABLE public.profiles
ADD CONSTRAINT invitation_code_format 
CHECK (invitation_code IS NULL OR (invitation_code ~ '^\d{6}$'));
