# Hijibiji 2026 Saraswati Puja – Collections & Expense Module (SocietyCare)

This document describes the Supabase backend + Storage setup required for the **Puja Dashboard** module added under `lib/features/puja_dashboard`.

> Note: The main app already uses a `users` table with `role IN ('staff','admin')`. In this module, **staff = viewer** and **admin = admin**.

## 1) Database Tables

Run in Supabase SQL editor:

```sql
-- Transactions
CREATE TABLE IF NOT EXISTS puja_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type VARCHAR NOT NULL CHECK (type IN ('collection', 'expense')),
  category VARCHAR NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description TEXT,
  donor_payer_name VARCHAR,
  date DATE NOT NULL,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Attachments
CREATE TABLE IF NOT EXISTS puja_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES puja_transactions(id) ON DELETE CASCADE,
  file_path VARCHAR NOT NULL,
  file_type VARCHAR,
  uploaded_at TIMESTAMP DEFAULT NOW()
);

-- AI processing logs
CREATE TABLE IF NOT EXISTS ai_processing_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  extracted_data JSONB,
  status VARCHAR DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected')),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 2) RLS Policies

Enable RLS:

```sql
ALTER TABLE puja_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE puja_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_processing_logs ENABLE ROW LEVEL SECURITY;
```

Policies (adjust to your needs):

```sql
-- Read access for all authenticated users
CREATE POLICY "Users can read all puja transactions" ON puja_transactions
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can read all puja attachments" ON puja_attachments
  FOR SELECT TO authenticated USING (true);

-- Admin-only write access (uses existing users.role = 'admin')
CREATE POLICY "Admin can insert puja transactions" ON puja_transactions
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admin can update puja transactions" ON puja_transactions
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admin can delete puja transactions" ON puja_transactions
  FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admin can insert puja attachments" ON puja_attachments
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admin can delete puja attachments" ON puja_attachments
  FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- AI logs: users can create/read their own
CREATE POLICY "Users can read own ai logs" ON ai_processing_logs
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "Users can create own ai logs" ON ai_processing_logs
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own ai logs" ON ai_processing_logs
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
```

## 3) Storage Bucket

Create a bucket named:

- `puja-attachments`

Suggested policies:

```sql
-- Allow authenticated users to read
CREATE POLICY "Authenticated can read puja attachments"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'puja-attachments');

-- Allow admin upload/delete
CREATE POLICY "Admin can upload puja attachments"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'puja-attachments' AND
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Admin can delete puja attachments"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'puja-attachments' AND
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
```

## 4) Google Sheets Export

The module uses:

- `google_sign_in`
- `googleapis` (Sheets API)
- `extension_google_sign_in_as_googleapis_auth`

You must configure OAuth client IDs for Android / iOS / Web for Google Sign-In.

## 5) Entry Point

In the app, open **Staff Dashboard** → tap the wallet icon (**Puja Dashboard**).
