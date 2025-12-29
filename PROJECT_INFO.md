# Facility Keeper - Project Information

## Project Metadata

**Project Name:** Facility Keeper (HK - Housekeeping)  
**Version:** 1.0.0  
**Created:** December 2024  
**Platform:** Flutter Mobile Application  
**Backend:** Supabase  

## Project Summary

Facility Keeper is a comprehensive mobile application designed for housekeeping and facility management staff to efficiently track, manage, and complete cleaning duties across residential complexes. The app supports a hierarchical structure (Society → Blocks → Floors → Flats) and provides role-based access for Staff and Admin users.

## Key Capabilities

### Core Features
1. **Task Management System**
   - Create, assign, and track cleaning tasks
   - Three task types: Brooming, Mopping, Garbage Collection
   - Three task statuses: Pending, Completed, Verified

2. **Photo Documentation**
   - Mandatory photo upload for task completion
   - Camera integration for real-time capture
   - Gallery picker for existing photos
   - Secure storage via Supabase Storage

3. **Hierarchical Navigation**
   - Society level (complex-wide tasks)
   - Block level (building-specific)
   - Floor level (floor-specific)
   - Flat level (unit-specific)

4. **User Roles**
   - **Staff:** Complete tasks, upload proof, add notes
   - **Admin:** Verify completed tasks, monitor activities

5. **Real-time Sync**
   - Live updates across devices
   - Supabase real-time subscriptions
   - Automatic conflict resolution

6. **Offline Support**
   - Local caching with Hive
   - Offline task completion
   - Automatic sync when online

7. **Activity Tracking**
   - Complete audit trail
   - Task history
   - User activity logs

8. **Progress Analytics**
   - Dashboard with progress bars
   - Task completion ratios
   - Real-time statistics

## Technical Architecture

### Frontend
- **Framework:** Flutter 3.0+
- **Language:** Dart
- **State Management:** Riverpod
- **UI Theme:** Material Design 3
- **Color Scheme:** White/Blue minimalist

### Backend
- **Database:** PostgreSQL (via Supabase)
- **Authentication:** Supabase Auth
- **Storage:** Supabase Storage
- **Real-time:** Supabase Realtime
- **Security:** Row Level Security (RLS)

### Local Storage
- **Cache:** Hive (NoSQL)
- **Images:** Cached Network Image

### Third-party Services
- **Image Handling:** image_picker, cached_network_image
- **Network:** connectivity_plus
- **Phone Integration:** url_launcher
- **Notifications:** fluttertoast

## Database Schema

### Tables
1. **users** - User profiles (extends auth.users)
2. **societies** - Residential complexes
3. **blocks** - Buildings within societies
4. **floors** - Floors within blocks
5. **flats** - Individual units
6. **tasks** - Cleaning tasks
7. **task_history** - Audit trail for tasks
8. **activity_log** - User activity tracking

### Relationships
- Society → Blocks (1:N)
- Block → Floors (1:N)
- Floor → Flats (1:N)
- Floor → Tasks (1:N)
- Flat → Tasks (1:N)
- User → Tasks (1:N) as assignee
- Task → Task History (1:N)
- User → Activity Log (1:N)

## Security Features

1. **Authentication**
   - Email/password authentication
   - Secure session management
   - JWT tokens

2. **Authorization**
   - Role-based access control (RBAC)
   - Row Level Security policies
   - API key protection

3. **Data Protection**
   - Encrypted connections (HTTPS)
   - Secure file storage
   - Input validation and sanitization

## Development Workflow

### Setup
1. Install Flutter SDK
2. Create Supabase project
3. Run database migrations
4. Configure app credentials
5. Install dependencies

### Development
1. Run `flutter pub get` to install dependencies
2. Run `flutter run` for development
3. Hot reload enabled for rapid iteration
4. Use `flutter analyze` for code quality

### Testing
1. Unit tests for business logic
2. Widget tests for UI components
3. Integration tests for flows
4. Manual testing on devices

### Deployment
1. Build APK/AAB for Android
2. Build IPA for iOS
3. Submit to app stores
4. Configure backend production settings

## Performance Considerations

1. **Image Optimization**
   - Compress images before upload
   - Max resolution: 1920x1080
   - Image quality: 80%

2. **Database Queries**
   - Indexed fields for fast lookup
   - Pagination for large lists
   - Efficient joins with foreign keys

3. **Caching Strategy**
   - Cache frequently accessed data
   - Lazy load images
   - Background sync

4. **Network Efficiency**
   - Batch API calls
   - Compress data transfers
   - Handle offline scenarios

## Future Enhancements

### Planned Features
- [ ] Push notifications for task assignments
- [ ] QR code scanning for flat identification
- [ ] Voice notes for task completion
- [ ] Advanced analytics dashboard
- [ ] Shift management
- [ ] Inventory tracking
- [ ] Maintenance request system
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Biometric authentication

### Technical Improvements
- [ ] GraphQL API integration
- [ ] WebSocket for real-time updates
- [ ] Advanced error reporting (Sentry)
- [ ] Performance monitoring
- [ ] A/B testing framework
- [ ] Automated testing pipeline
- [ ] CI/CD integration

## File Structure

```
facility_keeper/
├── lib/
│   ├── main.dart
│   ├── config/
│   ├── constants/
│   ├── models/
│   ├── services/
│   ├── providers/
│   ├── screens/
│   └── widgets/
├── assets/
│   ├── images/
│   └── icons/
├── test/
├── integration_test/
├── android/
├── ios/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── FLUTTER_README.md
├── SUPABASE_SETUP.md
└── PROJECT_INFO.md
```

## Dependencies Overview

### Core Dependencies
- `flutter_riverpod` - State management
- `supabase_flutter` - Backend integration
- `hive` & `hive_flutter` - Local storage

### UI Dependencies
- `google_fonts` - Typography
- `cached_network_image` - Image caching
- `shimmer` - Loading effects

### Functionality
- `image_picker` - Photo capture
- `url_launcher` - Phone/web links
- `connectivity_plus` - Network status
- `fluttertoast` - User feedback
- `intl` - Date formatting
- `uuid` - ID generation

### Development
- `flutter_lints` - Code quality
- `build_runner` - Code generation
- `hive_generator` - Model generation

## Support & Maintenance

### Bug Reporting
Submit issues via the project repository with:
- Device information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/logs

### Feature Requests
Submit via project management system with:
- Detailed description
- Use case
- Priority level
- Acceptance criteria

### Contact
- Development Team: dev@facilitykeeper.com
- Support: support@facilitykeeper.com

## License

Proprietary - All rights reserved

---

**Last Updated:** December 2024  
**Maintained By:** Development Team
