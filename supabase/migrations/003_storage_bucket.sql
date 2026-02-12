-- 003_storage_bucket.sql
-- Storage バケット作成

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'item-images',
    'item-images',
    false,
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/heic', 'image/webp']
);

-- Storage RLS ポリシー
CREATE POLICY "Users can upload own images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'item-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own images"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'item-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update own images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'item-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'item-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );
