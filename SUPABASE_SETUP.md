# Supabase Backend Setup Guide

This guide will walk you through setting up the complete Supabase backend for the Facility Keeper app.

## Prerequisites

- A Supabase account (sign up at https://supabase.com)
- Basic understanding of SQL
- Access to Supabase dashboard

## Step 1: Create a New Supabase Project

1. Log in to your Supabase dashboard
2. Click "New Project"
3. Fill in the project details:
   - **Name:** Facility Keeper
   - **Database Password:** (Choose a strong password and save it securely)
   - **Region:** (Choose the closest to your users)
4. Click "Create new project"
5. Wait for the project to be provisioned (usually 1-2 minutes)

## Step 2: Get Your Project Credentials

1. In your project dashboard, go to **Settings** → **API**
2. Note down:
   - **Project URL:** `https://xxxxxxxxxxxxx.supabase.co`
   - **Anon/Public Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
3. Update these in your Flutter app's `lib/config/supabase_config.dart`

## Step 3: Create Database Schema

Go to **SQL Editor** in your Supabase dashboard and run the following SQL:

### 3.1 Enable Extensions

```sql
-- Enable UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

### 3.2 Create Tables

```sql
-- Users table (extends Supabase Auth)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('staff', 'admin')),
  name TEXT NOT NULL,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Societies table
CREATE TABLE societies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Blocks table
CREATE TABLE blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  society_id UUID REFERENCES societies(id) ON DELETE CASCADE,
  block_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(society_id, block_number)
);

-- Floors table
CREATE TABLE floors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  block_id UUID REFERENCES blocks(id) ON DELETE CASCADE,
  floor_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(block_id, floor_number)
);

-- Flats table
CREATE TABLE flats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  floor_id UUID REFERENCES floors(id) ON DELETE CASCADE,
  flat_number TEXT NOT NULL,
  resident_name TEXT,
  resident_phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(floor_id, flat_number)
);

-- Tasks table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  flat_id UUID REFERENCES flats(id) ON DELETE CASCADE,
  floor_id UUID REFERENCES floors(id) ON DELETE CASCADE,
  block_id UUID REFERENCES blocks(id) ON DELETE CASCADE NOT NULL,
  society_id UUID REFERENCES societies(id) ON DELETE CASCADE NOT NULL,
  task_type TEXT NOT NULL CHECK (task_type IN ('brooming', 'mopping', 'garbage')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'verified')),
  assignee_id UUID REFERENCES users(id) ON DELETE SET NULL,
  completed_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
  verified_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  verified_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Task history table
CREATE TABLE task_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  action TEXT NOT NULL CHECK (action IN ('created', 'assigned', 'completed', 'verified', 'reopened')),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT,
  metadata JSONB
);

-- Activity log table
CREATE TABLE activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  action_description TEXT NOT NULL,
  location TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  task_type TEXT,
  status TEXT,
  metadata JSONB
);
```

### 3.3 Create Indexes

```sql
-- Indexes for better query performance
CREATE INDEX idx_tasks_block_id ON tasks(block_id);
CREATE INDEX idx_tasks_floor_id ON tasks(floor_id);
CREATE INDEX idx_tasks_flat_id ON tasks(flat_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assignee_id ON tasks(assignee_id);
CREATE INDEX idx_tasks_created_at ON tasks(created_at DESC);

CREATE INDEX idx_blocks_society_id ON blocks(society_id);
CREATE INDEX idx_floors_block_id ON floors(block_id);
CREATE INDEX idx_flats_floor_id ON flats(floor_id);

CREATE INDEX idx_activity_log_user_id ON activity_log(user_id);
CREATE INDEX idx_activity_log_timestamp ON activity_log(timestamp DESC);

CREATE INDEX idx_task_history_task_id ON task_history(task_id);
CREATE INDEX idx_task_history_timestamp ON task_history(timestamp DESC);
```

### 3.4 Create Functions

```sql
-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to auto-update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_societies_updated_at BEFORE UPDATE ON societies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blocks_updated_at BEFORE UPDATE ON blocks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_floors_updated_at BEFORE UPDATE ON floors
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_flats_updated_at BEFORE UPDATE ON flats
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically log task history
CREATE OR REPLACE FUNCTION log_task_change()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO task_history (task_id, action, user_id, notes)
    VALUES (NEW.id, 'created', NEW.assignee_id, 'Task created');
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status != NEW.status THEN
      INSERT INTO task_history (task_id, action, user_id, notes)
      VALUES (
        NEW.id,
        CASE 
          WHEN NEW.status = 'completed' THEN 'completed'
          WHEN NEW.status = 'verified' THEN 'verified'
          ELSE 'reopened'
        END,
        CASE 
          WHEN NEW.status = 'completed' THEN NEW.completed_by_id
          WHEN NEW.status = 'verified' THEN NEW.verified_by_id
          ELSE NULL
        END,
        NEW.notes
      );
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_history_trigger
  AFTER INSERT OR UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION log_task_change();
```

## Step 4: Set Up Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE societies ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE floors ENABLE ROW LEVEL SECURITY;
ALTER TABLE flats ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Societies policies (all authenticated users can read)
CREATE POLICY "Authenticated users can read societies" ON societies
  FOR SELECT TO authenticated USING (true);

-- Blocks policies
CREATE POLICY "Authenticated users can read blocks" ON blocks
  FOR SELECT TO authenticated USING (true);

-- Floors policies
CREATE POLICY "Authenticated users can read floors" ON floors
  FOR SELECT TO authenticated USING (true);

-- Flats policies
CREATE POLICY "Authenticated users can read flats" ON flats
  FOR SELECT TO authenticated USING (true);

-- Tasks policies
CREATE POLICY "Users can read all tasks" ON tasks
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Staff can update assigned tasks" ON tasks
  FOR UPDATE TO authenticated
  USING (
    assignee_id = auth.uid() OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admin can do everything on tasks" ON tasks
  FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
  );

-- Task history policies
CREATE POLICY "Users can read task history" ON task_history
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "System can insert task history" ON task_history
  FOR INSERT TO authenticated WITH CHECK (true);

-- Activity log policies
CREATE POLICY "Users can read own activity" ON activity_log
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "Users can create own activity" ON activity_log
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admin can read all activity" ON activity_log
  FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
  );
```

## Step 5: Set Up Storage

### 5.1 Create Storage Bucket

1. Go to **Storage** in Supabase dashboard
2. Click "New bucket"
3. **Name:** `task-photos`
4. **Public bucket:** ✓ (Check this)
5. Click "Create bucket"

### 5.2 Set Storage Policies

Go to **Storage** → **Policies** → `task-photos` bucket and add:

```sql
-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload task photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'task-photos' AND
  (storage.foldername(name))[1] = 'tasks'
);

-- Allow authenticated users to update their uploads
CREATE POLICY "Users can update task photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'task-photos');

-- Allow public read access
CREATE POLICY "Public can read task photos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'task-photos');

-- Allow authenticated users to delete (if admin)
CREATE POLICY "Admin can delete task photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'task-photos' AND
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
```

## Step 6: Insert Sample Data

```sql
-- Insert a default society
INSERT INTO societies (id, name, address) VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Green Valley Residential Complex', '123 Main Street, City');

-- Insert blocks
INSERT INTO blocks (id, society_id, block_number) VALUES 
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'A'),
  ('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111111', 'B'),
  ('22222222-2222-2222-2222-222222222224', '11111111-1111-1111-1111-111111111111', 'C');

-- Insert floors for Block A
INSERT INTO floors (id, block_id, floor_number) VALUES 
  ('33333333-3333-3333-3333-333333333331', '22222222-2222-2222-2222-222222222222', 'Ground'),
  ('33333333-3333-3333-3333-333333333332', '22222222-2222-2222-2222-222222222222', '1'),
  ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', '2'),
  ('33333333-3333-3333-3333-333333333334', '22222222-2222-2222-2222-222222222222', '3');

-- Insert flats for Floor 1
INSERT INTO flats (floor_id, flat_number, resident_name) VALUES 
  ('33333333-3333-3333-3333-333333333332', '101', 'John Smith'),
  ('33333333-3333-3333-3333-333333333332', '102', 'Jane Doe'),
  ('33333333-3333-3333-3333-333333333332', '103', 'Bob Johnson');
```

## Step 7: Create Test Users

### Via Supabase Auth UI

1. Go to **Authentication** → **Users**
2. Click "Add user"
3. Create two test users:

**Staff User:**
- Email: `staff@example.com`
- Password: `Test123!@#`
- Auto Confirm User: ✓

**Admin User:**
- Email: `admin@example.com`
- Password: `Admin123!@#`
- Auto Confirm User: ✓

### Via SQL (Add to users table)

After creating users via Auth UI, insert their profiles:

```sql
-- Get user IDs from auth.users
-- Replace the UUIDs below with actual auth.users IDs

INSERT INTO users (id, email, role, name, phone) VALUES 
  ('your-staff-user-auth-id', 'staff@example.com', 'staff', 'John Doe', '+1234567890'),
  ('your-admin-user-auth-id', 'admin@example.com', 'admin', 'Jane Smith', '+1234567891');
```

## Step 8: Create Sample Tasks

```sql
-- Insert tasks for Block A, Floor 1
INSERT INTO tasks (block_id, society_id, floor_id, flat_id, task_type, status, assignee_id)
SELECT 
  '22222222-2222-2222-2222-222222222222',
  '11111111-1111-1111-1111-111111111111',
  '33333333-3333-3333-3333-333333333332',
  id,
  'brooming',
  'pending',
  (SELECT id FROM users WHERE role = 'staff' LIMIT 1)
FROM flats 
WHERE floor_id = '33333333-3333-3333-3333-333333333332';

INSERT INTO tasks (block_id, society_id, floor_id, flat_id, task_type, status, assignee_id)
SELECT 
  '22222222-2222-2222-2222-222222222222',
  '11111111-1111-1111-1111-111111111111',
  '33333333-3333-3333-3333-333333333332',
  id,
  'mopping',
  'pending',
  (SELECT id FROM users WHERE role = 'staff' LIMIT 1)
FROM flats 
WHERE floor_id = '33333333-3333-3333-3333-333333333332';

INSERT INTO tasks (block_id, society_id, floor_id, flat_id, task_type, status, assignee_id)
SELECT 
  '22222222-2222-2222-2222-222222222222',
  '11111111-1111-1111-1111-111111111111',
  '33333333-3333-3333-3333-333333333332',
  id,
  'garbage',
  'pending',
  (SELECT id FROM users WHERE role = 'staff' LIMIT 1)
FROM flats 
WHERE floor_id = '33333333-3333-3333-3333-333333333332';
```

## Step 9: Test Your Setup

### Test Queries

Run these queries to verify your setup:

```sql
-- Check societies
SELECT * FROM societies;

-- Check blocks
SELECT * FROM blocks;

-- Check floors with block info
SELECT f.*, b.block_number 
FROM floors f
JOIN blocks b ON f.block_id = b.id;

-- Check tasks with all details
SELECT 
  t.id,
  t.task_type,
  t.status,
  b.block_number,
  f.floor_number,
  fl.flat_number,
  u.name as assignee_name
FROM tasks t
LEFT JOIN blocks b ON t.block_id = b.id
LEFT JOIN floors f ON t.floor_id = f.id
LEFT JOIN flats fl ON t.flat_id = fl.id
LEFT JOIN users u ON t.assignee_id = u.id;

-- Check user count
SELECT role, COUNT(*) 
FROM users 
GROUP BY role;
```

## Step 10: Configure Flutter App

Update `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  static const String storageBucket = 'task-photos';
}
```

## Maintenance and Monitoring

### Regular Tasks

1. **Monitor Storage Usage:**
   - Go to **Settings** → **Usage**
   - Check storage bucket size

2. **Review Logs:**
   - Go to **Logs** → **API Logs**
   - Monitor for errors

3. **Database Backups:**
   - Supabase automatically backs up your database
   - For manual backup: Go to **Database** → **Backups**

### Performance Tips

1. Add indexes as your data grows
2. Use connection pooling for high traffic
3. Monitor slow queries in the dashboard
4. Consider enabling Point-in-Time Recovery for production

## Troubleshooting

### Common Issues

**Q: "Row Level Security Policy Violation"**
- Check if RLS policies are correctly set
- Ensure user is authenticated
- Verify user role in users table

**Q: "Storage upload fails"**
- Check storage policies
- Verify bucket exists and is public
- Check file size limits (default 50MB)

**Q: "Foreign key violation"**
- Ensure parent records exist before creating child records
- Check cascade delete settings

## Next Steps

- Test the Flutter app with your Supabase backend
- Add more sample data as needed
- Set up production environment
- Configure email templates for auth
- Set up monitoring and alerts

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Documentation](https://supabase.com/docs/guides/storage)

---

**Last Updated:** December 2024
