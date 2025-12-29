# Facility Keeper - Flutter Mobile Application

A comprehensive Flutter mobile application for facility management staff to track cleaning duties across residential complexes.

## Project Overview

**App Name:** Facility/Housekeeping Keeper (HK)  
**Primary Purpose:** Task management app for housekeeping staff to track cleaning duties (sweeping, mopping, garbage collection) across residential blocks, floors, and flats.

### User Roles
- **Staff:** Performs tasks, uploads proof, marks complete
- **Admin:** Verifies tasks

## Technology Stack

- **Framework:** Flutter (Dart)
- **Backend:** Supabase (PostgreSQL + Storage for photos)
- **State Management:** Riverpod
- **Theme:** Minimalist, Clean, White/Blue color scheme
- **Data Structure:** Hierarchical (Society → Blocks → Floors → Flats → Tasks)

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── supabase_config.dart     # Supabase configuration
├── constants/
│   ├── app_colors.dart          # Color constants
│   └── app_strings.dart         # String constants
├── models/
│   ├── user_model.dart          # User data model
│   ├── task_model.dart          # Task data model
│   ├── block_model.dart         # Block data model
│   └── activity_log_model.dart  # Activity log model
├── services/
│   ├── auth_service.dart        # Authentication service
│   ├── task_service.dart        # Task CRUD operations
│   └── block_service.dart       # Block operations
├── providers/
│   ├── auth_provider.dart       # Auth state management
│   └── task_provider.dart       # Task state management
├── screens/
│   ├── login_screen.dart        # Login interface
│   ├── staff_dashboard_screen.dart      # Main dashboard
│   ├── block_selection_screen.dart      # Block list
│   ├── floor_unit_list_screen.dart      # Floor/unit list
│   └── task_execution_screen.dart       # Task details & completion
└── widgets/
    ├── custom_button.dart       # Reusable button
    ├── custom_text_field.dart   # Reusable text field
    ├── progress_bar_widget.dart # Progress indicator
    └── task_card.dart           # Task card component
```

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (3.0.0 or higher)

3. **Android Studio / Xcode** (for mobile development)

4. **Supabase Account** (for backend services)

## Setup Instructions

### 1. Install Flutter

Follow the official Flutter installation guide:
https://docs.flutter.dev/get-started/install

### 2. Clone and Setup Project

```bash
# Navigate to project directory
cd facility_keeper

# Install dependencies
flutter pub get

# Run code generation (if needed)
flutter pub run build_runner build
```

### 3. Supabase Setup

#### Create Supabase Project

1. Go to [Supabase](https://supabase.com)
2. Create a new project
3. Note your project URL and anon key

#### Configure Supabase in App

Create a file `.env.local` in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Or update `lib/config/supabase_config.dart` directly with your credentials.

#### Create Database Schema

Run the following SQL in your Supabase SQL editor:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('staff', 'admin')),
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Societies table
CREATE TABLE societies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Blocks table
CREATE TABLE blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  society_id UUID REFERENCES societies(id) ON DELETE CASCADE,
  block_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Floors table
CREATE TABLE floors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  block_id UUID REFERENCES blocks(id) ON DELETE CASCADE,
  floor_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Flats table
CREATE TABLE flats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  floor_id UUID REFERENCES floors(id) ON DELETE CASCADE,
  flat_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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
  assignee_id UUID REFERENCES users(id),
  completed_by_id UUID REFERENCES users(id),
  verified_by_id UUID REFERENCES users(id),
  completed_at TIMESTAMP WITH TIME ZONE,
  verified_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Task history table
CREATE TABLE task_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  action TEXT NOT NULL CHECK (action IN ('completed', 'verified')),
  user_id UUID REFERENCES users(id),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT
);

-- Activity log table
CREATE TABLE activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  action_description TEXT NOT NULL,
  location TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  task_type TEXT,
  status TEXT
);

-- Create indexes for better performance
CREATE INDEX idx_tasks_block_id ON tasks(block_id);
CREATE INDEX idx_tasks_floor_id ON tasks(floor_id);
CREATE INDEX idx_tasks_flat_id ON tasks(flat_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_activity_log_user_id ON activity_log(user_id);
CREATE INDEX idx_activity_log_timestamp ON activity_log(timestamp DESC);
```

#### Setup Row Level Security (RLS)

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

-- Users can read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Staff can read all tasks
CREATE POLICY "Staff can read tasks" ON tasks
  FOR SELECT USING (true);

-- Staff can update tasks they're assigned to
CREATE POLICY "Staff can update assigned tasks" ON tasks
  FOR UPDATE USING (assignee_id = auth.uid());

-- Admin can do everything
CREATE POLICY "Admin full access to tasks" ON tasks
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Activity logs - users can read their own
CREATE POLICY "Users can read own activity" ON activity_log
  FOR SELECT USING (user_id = auth.uid());

-- Activity logs - users can create their own
CREATE POLICY "Users can create own activity" ON activity_log
  FOR INSERT WITH CHECK (user_id = auth.uid());
```

#### Setup Storage Bucket

1. Go to Storage in Supabase dashboard
2. Create a bucket named `task-photos`
3. Set it to **public** (for easier access)
4. Configure storage policies:

```sql
-- Allow authenticated users to upload photos
CREATE POLICY "Authenticated users can upload photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'task-photos');

-- Allow public read access
CREATE POLICY "Public can read photos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'task-photos');
```

### 4. Add Sample Data (Optional)

```sql
-- Insert a sample society
INSERT INTO societies (id, name) VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Green Valley Society');

-- Insert sample blocks
INSERT INTO blocks (id, society_id, block_number) VALUES 
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'A'),
  ('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111111', 'B');

-- Insert sample floors
INSERT INTO floors (id, block_id, floor_number) VALUES 
  ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', '1'),
  ('33333333-3333-3333-3333-333333333334', '22222222-2222-2222-2222-222222222222', '2');

-- Insert sample user (staff)
-- Password: password123 (you should hash this properly)
INSERT INTO users (id, email, password_hash, role, name) VALUES 
  ('44444444-4444-4444-4444-444444444444', 'staff@example.com', 'hashed_password', 'staff', 'John Doe');

-- Insert sample tasks
INSERT INTO tasks (block_id, society_id, floor_id, task_type, status, assignee_id) VALUES 
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'brooming', 'pending', '44444444-4444-4444-4444-444444444444'),
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'mopping', 'pending', '44444444-4444-4444-4444-444444444444');
```

## Running the App

### Development Mode

```bash
# Run on connected device/simulator
flutter run

# Run with specific device
flutter devices
flutter run -d <device-id>

# Hot reload is enabled by default (press 'r' in terminal)
# Hot restart (press 'R' in terminal)
```

### Build for Production

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS
```bash
flutter build ios --release
# Then open in Xcode for final steps
```

## Key Features

### 1. Authentication
- Email/password login with Supabase Auth
- Role-based access (Staff/Admin)
- Secure session management

### 2. Dashboard
- Overview of all task categories
- Progress tracking per category
- Recent activity feed
- Sync status indicator

### 3. Task Management
- Hierarchical navigation (Society → Block → Floor → Flat)
- Three task states: Pending, Completed, Verified
- Real-time status updates
- Task filtering and search

### 4. Photo Upload
- Camera integration
- Gallery picker
- Mandatory photo documentation
- Upload to Supabase Storage

### 5. Offline Support
- Local data caching with Hive
- Automatic sync when online
- Offline mode indicator

### 6. Admin Features
- Task verification
- Activity monitoring
- User management

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

## Troubleshooting

### Common Issues

**1. Supabase Connection Error**
- Verify your Supabase URL and anon key in `supabase_config.dart`
- Check if your Supabase project is active
- Ensure RLS policies allow your operations

**2. Image Picker Not Working**
- Add permissions to `AndroidManifest.xml` (Android)
- Add permissions to `Info.plist` (iOS)

**Android:** Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS:** Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos of completed tasks</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select task completion photos</string>
```

**3. Build Errors**
```bash
# Clean build cache
flutter clean
flutter pub get
flutter run
```

## Performance Optimization

1. **Image Optimization:** Images are automatically compressed when uploaded
2. **Lazy Loading:** Lists use lazy loading for better performance
3. **Caching:** Network images are cached using `cached_network_image`
4. **State Management:** Riverpod provides efficient state updates

## Security Considerations

1. **Authentication:** All API calls require valid Supabase session
2. **RLS Policies:** Database enforces row-level security
3. **Input Validation:** All user inputs are validated
4. **Secure Storage:** Sensitive data stored securely

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is proprietary software for facility management use.

## Support

For issues or questions, contact the development team.

---

**Built with Flutter 💙**
