-- Create membership_plans table
create table if not exists membership_plans (
  id uuid default gen_random_uuid() primary key,
  barber_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  description text,
  price decimal(10,2) not null,
  benefits text[], -- Array of strings describing benefits
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create subscriptions table (link client to plan)
create table if not exists subscriptions (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references auth.users(id) on delete cascade not null,
  plan_id uuid references membership_plans(id) on delete cascade not null,
  status text check (status in ('active', 'cancelled', 'expired')) default 'active',
  start_date timestamp with time zone default timezone('utc'::text, now()) not null,
  end_date timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies
alter table membership_plans enable row level security;
alter table subscriptions enable row level security;

-- Plans: Barbers can CRUD their own, Everyone can read
create policy "Barbers can manage own plans" on membership_plans
  for all using (auth.uid() = barber_id);

create policy "Everyone can view plans" on membership_plans
  for select using (true);

-- Subscriptions: Clients view own, Barbers view their plans' subscriptions
create policy "Clients view own subscriptions" on subscriptions
  for select using (auth.uid() = client_id);

create policy "Barbers view subscriptions to their plans" on subscriptions
  for select using (
    exists (
      select 1 from membership_plans
      where membership_plans.id = subscriptions.plan_id
      and membership_plans.barber_id = auth.uid()
    )
  );
