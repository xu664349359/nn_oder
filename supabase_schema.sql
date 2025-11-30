-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PROFILES TABLE
create table public.profiles (
  id uuid references auth.users not null primary key,
  nickname text,
  role text check (role in ('chef', 'foodie')),
  avatar_url text,
  partner_id uuid references public.profiles(id),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- COUPLES TABLE
create table public.couples (
  id uuid default uuid_generate_v4() primary key,
  chef_id uuid references public.profiles(id),
  foodie_id uuid references public.profiles(id),
  intimacy_score integer default 0,
  binding_date timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- MOMENTS TABLE
create table public.moments (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  content text,
  image_url text,
  likes integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ORDERS TABLE
create table public.orders (
  id uuid default uuid_generate_v4() primary key,
  couple_id uuid references public.couples(id) not null,
  items jsonb, -- Store items as JSON for simplicity
  status text default 'pending',
  total_price decimal,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ROW LEVEL SECURITY (RLS)
alter table public.profiles enable row level security;
alter table public.couples enable row level security;
alter table public.moments enable row level security;
alter table public.orders enable row level security;

-- POLICIES (Simple for now, can be refined)
create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
create policy "Users can insert their own profile." on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);

create policy "Couples viewable by authenticated users." on public.couples for select using (auth.role() = 'authenticated');
create policy "Couples insertable by authenticated users." on public.couples for insert with check (auth.role() = 'authenticated');

create policy "Moments viewable by everyone." on public.moments for select using (true);
create policy "Users can insert their own moments." on public.moments for insert with check (auth.uid() = user_id);

create policy "Orders viewable by authenticated users." on public.orders for select using (auth.role() = 'authenticated');
create policy "Orders insertable by authenticated users." on public.orders for insert with check (auth.role() = 'authenticated');

-- STORAGE BUCKETS (Optional, for images)
insert into storage.buckets (id, name) values ('avatars', 'avatars');
insert into storage.buckets (id, name) values ('moments', 'moments');

create policy "Avatar images are publicly accessible." on storage.objects for select using ( bucket_id = 'avatars' );
create policy "Anyone can upload an avatar." on storage.objects for insert with check ( bucket_id = 'avatars' );

create policy "Moment images are publicly accessible." on storage.objects for select using ( bucket_id = 'moments' );
create policy "Anyone can upload a moment image." on storage.objects for insert with check ( bucket_id = 'moments' );
