-- Update orders table structure to match the Order model

-- Add missing columns to orders table
ALTER TABLE public.orders 
  ADD COLUMN IF NOT EXISTS foodie_id UUID REFERENCES public.profiles(id),
  ADD COLUMN IF NOT EXISTS chef_id UUID REFERENCES public.profiles(id),
  ADD COLUMN IF NOT EXISTS menu_item_id UUID,
  ADD COLUMN IF NOT EXISTS menu_item_name TEXT,
  ADD COLUMN IF NOT EXISTS menu_item_image TEXT,
  ADD COLUMN IF NOT EXISTS rating INTEGER,
  ADD COLUMN IF NOT EXISTS review_comment TEXT;

-- Update status column to match enum values (pending, cooking, completed)
-- The default 'pending' is already correct

-- Note: existing rows will have NULL for new columns
-- You may want to delete existing test data if any
