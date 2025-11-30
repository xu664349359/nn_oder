-- Fix RLS policy for orders table to allow status updates

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Orders viewable by authenticated users." ON public.orders;
DROP POLICY IF EXISTS "Orders insertable by authenticated users." ON public.orders;

-- Create policy to allow users to view their couple's orders
CREATE POLICY "Users can view couple orders"
  ON public.orders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.couples c
      WHERE c.id = orders.couple_id
      AND (c.chef_id = auth.uid() OR c.foodie_id = auth.uid())
    )
  );

-- Create policy to allow users to insert orders for their couple
CREATE POLICY "Users can create couple orders"
  ON public.orders FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.couples c
      WHERE c.id = orders.couple_id
      AND (c.chef_id = auth.uid() OR c.foodie_id = auth.uid())
    )
  );

-- Create policy to allow users to update their couple's orders
CREATE POLICY "Users can update couple orders"
  ON public.orders FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.couples c
      WHERE c.id = orders.couple_id
      AND (c.chef_id = auth.uid() OR c.foodie_id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.couples c
      WHERE c.id = orders.couple_id
      AND (c.chef_id = auth.uid() OR c.foodie_id = auth.uid())
    )
  );
