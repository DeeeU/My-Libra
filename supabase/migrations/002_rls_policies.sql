-- 002_rls_policies.sql
-- Row Level Security ポリシー

-- profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- categories
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own categories"
    ON public.categories FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own categories"
    ON public.categories FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own categories"
    ON public.categories FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own categories"
    ON public.categories FOR DELETE
    USING (auth.uid() = user_id);

-- wishlist_items
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own wishlist items"
    ON public.wishlist_items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own wishlist items"
    ON public.wishlist_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own wishlist items"
    ON public.wishlist_items FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own wishlist items"
    ON public.wishlist_items FOR DELETE
    USING (auth.uid() = user_id);

-- items
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own items"
    ON public.items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own items"
    ON public.items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items"
    ON public.items FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own items"
    ON public.items FOR DELETE
    USING (auth.uid() = user_id);
