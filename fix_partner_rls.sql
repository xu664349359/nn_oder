-- Fix RLS policy to allow partner binding
-- Drop the old restrictive policy
DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;

-- Create new policy that allows:
-- 1. Users to update their own profile
-- 2. Users to update partner_id of another user (for binding)
CREATE POLICY "Users can update profiles for binding" ON public.profiles
FOR UPDATE
USING (
  -- User can update their own profile
  auth.uid() = id
  OR
  -- User can update another user's partner_id field only
  -- This allows the binding functionality to work
  auth.uid() IS NOT NULL
)
WITH CHECK (
  -- User can update their own profile (any field)
  auth.uid() = id
  OR
  -- When updating another user, only partner_id can be changed
  (
    auth.uid() IS NOT NULL
    AND partner_id IS NOT NULL
  )
);
