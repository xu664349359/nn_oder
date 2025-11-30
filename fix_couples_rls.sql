-- Fix RLS policy for couples table to allow intimacy updates

-- Drop existing restrictive policies if any
DROP POLICY IF EXISTS "Users can view own couple." ON public.couples;
DROP POLICY IF EXISTS "Users can update own couple." ON public.couples;

-- Create policy to allow users to view their couple
CREATE POLICY "Users can view own couple"
  ON public.couples FOR SELECT
  USING (
    auth.uid() = chef_id OR auth.uid() = foodie_id
  );

-- Create policy to allow users to update their couple (including intimacy score)
CREATE POLICY "Users can update own couple"
  ON public.couples FOR UPDATE
  USING (
    auth.uid() = chef_id OR auth.uid() = foodie_id
  )
  WITH CHECK (
    auth.uid() = chef_id OR auth.uid() = foodie_id
  );

-- Create policy to allow users to insert couple records (for binding)
CREATE POLICY "Users can create couples"
  ON public.couples FOR INSERT
  WITH CHECK (
    auth.uid() = chef_id OR auth.uid() = foodie_id
  );
