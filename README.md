# Facility Keeper - Housekeeping Management System

A comprehensive mobile application for facility management staff to track cleaning duties across residential complexes.

## 🏗️ Project Structure

This repository contains a **Flutter mobile application** for facility management.

### Main Documentation

- **[Flutter App Documentation](FLUTTER_README.md)** - Complete guide for the mobile app
- **[Supabase Setup Guide](SUPABASE_SETUP.md)** - Backend configuration instructions

## 📱 Mobile App (Flutter)

The main application is built with Flutter and provides:

- **Task Management:** Track cleaning duties across blocks, floors, and flats
- **Photo Documentation:** Upload proof of task completion
- **Real-time Updates:** Live sync with Supabase backend
- **Offline Support:** Work offline with automatic sync
- **Role-based Access:** Staff and Admin roles with different permissions

### Quick Start

1. **Install Flutter:**
   ```bash
   # See: https://docs.flutter.dev/get-started/install
   flutter doctor
   ```

2. **Setup Backend:**
   Follow the [Supabase Setup Guide](SUPABASE_SETUP.md)

3. **Configure App:**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your Supabase credentials
   ```

4. **Run App:**
   ```bash
   flutter pub get
   flutter run
   ```

## 🎯 Features

### For Staff Users
- ✅ View assigned cleaning tasks
- ✅ Complete tasks with photo proof
- ✅ Add notes to task completion
- ✅ Track personal activity history
- ✅ Navigate hierarchical structure (Society → Block → Floor → Flat)

### For Admin Users
- ✅ Verify completed tasks
- ✅ Monitor all staff activities
- ✅ View comprehensive progress reports
- ✅ Access real-time dashboard

### Technical Features
- 🔐 Secure authentication with Supabase
- 📸 Camera integration for photo capture
- 🖼️ Gallery picker for image selection
- 💾 Offline-first with local caching
- 🔄 Real-time sync when online
- 📊 Progress tracking and analytics

## 🛠️ Technology Stack

- **Frontend:** Flutter (Dart)
- **State Management:** Riverpod
- **Backend:** Supabase (PostgreSQL)
- **Storage:** Supabase Storage
- **Authentication:** Supabase Auth
- **Local Cache:** Hive
- **Image Handling:** image_picker, cached_network_image

## 📚 Documentation

- [Flutter App Guide](FLUTTER_README.md) - Full Flutter documentation
- [Supabase Setup](SUPABASE_SETUP.md) - Backend setup instructions
- [API Documentation](docs/API.md) - API reference (if needed)

## 🚀 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter test integration_test
```

## 📸 Screenshots

(Add screenshots of your app here once built)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software for facility management use.

## 📞 Support

For issues, questions, or contributions, please contact the development team.

---

**Built with Flutter 💙 | Powered by Supabase ⚡**
