-- ═══════════════════════════════════════════════════════════════════════════════
--  RECIPES TABLE — stores recipes with ingredients, steps, nutrition, and video
-- ═══════════════════════════════════════════════════════════════════════════════

create table if not exists public.recipes (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid,
  title        text not null,
  subtitle     text not null default '',
  image_url    text not null default '',
  video_url    text,                        -- Cloudinary video URL (nullable)
  duration     text not null default '',     -- e.g. "15 min"
  difficulty   text not null default 'Facile',
  kcal         int not null default 0,
  proteins     int not null default 0,
  carbs        int not null default 0,
  fat          int not null default 0,
  servings     int not null default 1,
  category     text not null default 'general',
  phase        text not null default 'all',     -- menstrual, follicular, ovulation, luteal, all
  tags         text[] not null default '{}',
  ingredients  jsonb not null default '[]',     -- [{name, qty, kcal}]
  steps        jsonb not null default '[]',     -- [{number, title, description}]
  is_featured  boolean not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Indexes
create index if not exists idx_recipes_category on public.recipes (category);
create index if not exists idx_recipes_featured on public.recipes (is_featured) where is_featured = true;
create index if not exists idx_recipes_user_id on public.recipes (user_id);

-- Auto-update updated_at
create or replace function public.update_recipes_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_recipes_updated_at
  before update on public.recipes
  for each row execute function public.update_recipes_updated_at();

-- RLS: everyone can read, only authenticated can insert/update
alter table public.recipes enable row level security;

create policy "Recipes are viewable by everyone"
  on public.recipes for select
  using (true);

create policy "Authenticated users can insert recipes"
  on public.recipes for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can update their own recipes"
  on public.recipes for update
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can delete their own recipes"
  on public.recipes for delete
  to authenticated
  using (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════════════════════
--  SEED: Insert existing hardcoded recipes
-- ═══════════════════════════════════════════════════════════════════════════════

insert into public.recipes (title, subtitle, image_url, video_url, duration, difficulty, kcal, proteins, category, tags, ingredients, steps, is_featured)
values
  (
    'Pancakes Petit-déj Protéinés',
    'Flocons d''avoine, œufs, banane, miel',
    'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=400&q=80',
    null,
    '15 min', 'Très facile', 342, 22,
    'petit-dejeuner',
    '{"protéiné","petit-déjeuner"}',
    '[{"name":"Flocons d''avoine","qty":"60 g","kcal":230},{"name":"Œuf entier","qty":"1","kcal":78},{"name":"Banane","qty":"½","kcal":45},{"name":"Miel","qty":"1 c.à.c","kcal":20}]',
    '[{"number":1,"title":"Mixer","description":"Mixez les flocons, l''œuf et la banane jusqu''à obtenir une pâte lisse."},{"number":2,"title":"Cuire","description":"Faites cuire à la poêle antiadhésive 2 min de chaque côté."},{"number":3,"title":"Servir","description":"Nappez de miel et ajoutez des fruits frais."}]',
    true
  ),
  (
    'Bowl Poulet Teriyaki',
    'Poulet grillé, riz, edamame, avocat',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
    null,
    '25 min', 'Facile', 520, 38,
    'dejeuner',
    '{"protéiné","asiatique"}',
    '[{"name":"Filet de poulet","qty":"150 g","kcal":248},{"name":"Riz blanc","qty":"120 g","kcal":156},{"name":"Edamame","qty":"50 g","kcal":60},{"name":"Avocat","qty":"¼","kcal":56}]',
    '[{"number":1,"title":"Mariner","description":"Marinez le poulet dans la sauce teriyaki 10 min."},{"number":2,"title":"Griller","description":"Grillez le poulet 5 min de chaque côté."},{"number":3,"title":"Assembler","description":"Disposez le riz, le poulet tranché, les edamame et l''avocat dans un bol."}]',
    true
  ),
  (
    'Salade César Légère',
    'Romaine, poulet, parmesan, croûtons maison',
    'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=400&q=80',
    null,
    '15 min', 'Facile', 380, 28,
    'dejeuner',
    '{"salade","léger"}',
    '[{"name":"Laitue romaine","qty":"200 g","kcal":30},{"name":"Poulet grillé","qty":"120 g","kcal":198},{"name":"Parmesan","qty":"20 g","kcal":86},{"name":"Croûtons","qty":"30 g","kcal":66}]',
    '[{"number":1,"title":"Préparer","description":"Lavez et coupez la laitue. Grillez le poulet et tranchez-le."},{"number":2,"title":"Assembler","description":"Mélangez la laitue, le poulet, le parmesan râpé et les croûtons."},{"number":3,"title":"Assaisonner","description":"Ajoutez la sauce César légère et servez."}]',
    true
  ),
  (
    'Smoothie Bowl Açaí',
    'Açaí, banane, granola, fruits rouges',
    'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&q=80',
    null,
    '10 min', 'Très facile', 290, 8,
    'petit-dejeuner',
    '{"vegan","petit-déjeuner","antioxydant"}',
    '[{"name":"Poudre d''açaí","qty":"15 g","kcal":70},{"name":"Banane congelée","qty":"1","kcal":89},{"name":"Granola","qty":"30 g","kcal":95},{"name":"Fruits rouges","qty":"50 g","kcal":36}]',
    '[{"number":1,"title":"Mixer","description":"Mixez l''açaí et la banane avec un peu de lait d''amande."},{"number":2,"title":"Verser","description":"Versez dans un bol."},{"number":3,"title":"Décorer","description":"Ajoutez le granola, les fruits rouges et des graines de chia."}]',
    true
  ),
  (
    'Overnight Oats Chocolat',
    'Avoine, cacao, lait d''amande, beurre de cacahuète',
    'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400&q=80',
    null,
    '5 min + repos', 'Très facile', 365, 14,
    'petit-dejeuner',
    '{"meal-prep","chocolat"}',
    '[{"name":"Flocons d''avoine","qty":"50 g","kcal":195},{"name":"Cacao en poudre","qty":"10 g","kcal":25},{"name":"Lait d''amande","qty":"150 ml","kcal":18},{"name":"Beurre de cacahuète","qty":"15 g","kcal":88}]',
    '[{"number":1,"title":"Mélanger","description":"Mélangez tous les ingrédients dans un bocal."},{"number":2,"title":"Réfrigérer","description":"Laissez reposer au frigo toute la nuit."},{"number":3,"title":"Déguster","description":"Le matin, ajoutez des toppings (banane, noix) et dégustez froid."}]',
    false
  );
