-- Create Menu Table and Recipe Steps for Menu Images & Recipe Upload Feature

-- 1. Create menu table if not exists
CREATE TABLE IF NOT EXISTS public.menu (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  couple_id UUID REFERENCES public.couples(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  intimacy_price INTEGER DEFAULT 0,
  ingredients JSONB DEFAULT '[]'::jsonb,
  is_published BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create recipe_steps table for detailed cooking instructions
CREATE TABLE IF NOT EXISTS public.recipe_steps (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  menu_item_id UUID REFERENCES public.menu(id) ON DELETE CASCADE,
  step_number INTEGER NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  video_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(menu_item_id, step_number)
);

-- 3. Enable RLS on menu and recipe_steps
ALTER TABLE public.menu ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_steps ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for menu
CREATE POLICY "Authenticated users can view menu"
  ON public.menu FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can manage couple menu"
  ON public.menu FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.couples c
      WHERE c.id = menu.couple_id
      AND (c.chef_id = auth.uid() OR c.foodie_id = auth.uid())
    )
  );

-- 5. RLS Policies for recipe_steps
CREATE POLICY "Authenticated users can view recipe steps"
  ON public.recipe_steps FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can manage couple recipes"
  ON public.recipe_steps FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.menu m
      JOIN public.couples c ON c.id = m.couple_id
      WHERE m.id = recipe_steps.menu_item_id
      AND (c.chef_id = auth.uid() OR c.foodie_id = auth.uid())
    )
  );

-- 6. Create storage buckets for menu images
INSERT INTO storage.buckets (id, name, public)
VALUES ('menu-images', 'menu-images', true)
ON CONFLICT (id) DO NOTHING;

-- 7. Create storage buckets for recipe media
INSERT INTO storage.buckets (id, name, public)
VALUES ('recipe-media', 'recipe-media', true)
ON CONFLICT (id) DO NOTHING;

-- 8. Storage policies for menu images
CREATE POLICY "Anyone can view menu images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'menu-images');

CREATE POLICY "Authenticated users can upload menu images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'menu-images' AND auth.role() = 'authenticated');

CREATE POLICY "Users can delete their menu images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'menu-images' AND auth.role() = 'authenticated');

-- 9. Storage policies for recipe media
CREATE POLICY "Authenticated users can view recipe media"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'recipe-media' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can upload recipe media"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'recipe-media' AND auth.role() = 'authenticated');

CREATE POLICY "Users can delete their recipe media"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'recipe-media' AND auth.role() = 'authenticated');
