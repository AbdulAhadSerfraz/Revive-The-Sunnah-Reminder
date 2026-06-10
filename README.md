# Revive – The Sunnah Reminder

A Flutter app designed to help Muslims revive forgotten Sunnahs through daily reminders and gamified motivation.

## 🌟 Features

### Core Features
- **Daily Sunnah**: One new Sunnah delivered each day
- **Hadith & Benefits**: Complete hadith text with practical benefits
- **Streak Tracking**: Gamified progress tracking with streaks
- **Completion Tracking**: Mark Sunnahs as completed daily
- **Search & Browse**: Search through all Sunnahs by category
- **Progress Analytics**: View completion rates and statistics
- **Daily Reminders**: Customizable notification reminders

### Categories Covered
- **Eating**: Table manners and food-related Sunnahs
- **Sleeping**: Bedtime routines and protection
- **Social**: Greetings, visiting, and helping others
- **Daily**: Everyday actions and routines
- **Hygiene**: Personal cleanliness and grooming

## 📱 Screenshots

The app features a beautiful, modern UI with:
- Splash screen with animated logo
- Home screen with today's Sunnah
- Progress tracking with streak visualization
- Searchable Sunnah library
- Settings with notification preferences

## 🛠 Tech Stack

- **Frontend**: Flutter 3.0+
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Notifications**: flutter_local_notifications
- **UI**: Material Design with custom theming
- **Animations**: flutter_animate
- **Data**: JSON-based local storage

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio / VS Code
- Android SDK (for Android development)
- iOS SDK (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/revive-sunnah-reminder.git
   cd revive-sunnah-reminder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📊 Data Structure

The app uses a JSON-based data structure for Sunnahs:

```json
{
  "id": 1,
  "title": "Say Bismillah Before Eating",
  "category": "Eating",
  "hadith": "The Prophet (ﷺ) said: 'When one of you eats...'",
  "benefit": "Brings blessings to your food and protects from harm",
  "source": "Abu Dawud 3767, Tirmidhi 1858"
}
```

## 🎯 Key Features Explained

### Daily Sunnah Selection
- Random selection from unused Sunnahs
- Resets when all Sunnahs have been shown
- Persists throughout the day

### Streak System
- Tracks consecutive days of completion
- Shows longest streak achieved
- Motivational messages based on streak length

### Progress Tracking
- Calendar view of completed days
- Completion rate percentage
- Total Sunnahs completed

### Notification System
- Daily reminders at customizable time
- Default reminder at 6:00 AM
- Can be enabled/disabled in settings

## 🎨 UI/UX Design

### Color Scheme
- **Primary**: Green (#2E7D32) - Represents growth and Islam
- **Secondary**: Light green (#388E3C) - Complementary shade
- **Background**: Light grey (#F5F5F5) - Clean and modern
- **Text**: Dark grey for readability

### Typography
- **Primary Font**: Poppins (Google Fonts)
- **Headings**: Bold weights for emphasis
- **Body Text**: Regular weight for readability

### Animations
- Smooth fade-in animations
- Slide transitions between screens
- Loading animations with shimmer effects

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── sunnah.dart          # Sunnah data model
├── providers/
│   ├── sunnah_provider.dart # Sunnah state management
│   └── streak_provider.dart # Streak tracking
├── screens/
│   ├── splash_screen.dart   # Loading screen
│   ├── home_screen.dart     # Main home screen
│   ├── progress_screen.dart # Progress tracking
│   ├── all_sunnahs_screen.dart # Sunnah library
│   └── settings_screen.dart # App settings
├── services/
│   └── notification_service.dart # Notification handling
└── widgets/
    ├── sunnah_card.dart     # Sunnah display widget
    └── streak_widget.dart   # Streak display widget

assets/
├── data/
│   └── sunnahs.json        # Sunnah data
├── images/                 # App images
└── animations/             # Lottie animations
```

## 🔧 Configuration

### Notification Settings
- Default reminder time: 6:00 AM
- Customizable through settings
- Can be completely disabled

### Data Management
- All data stored locally
- No internet connection required
- Data persists between app sessions

## 🚀 Future Enhancements

### Planned Features
- [ ] User authentication
- [ ] Cloud sync for progress
- [ ] Social features (leaderboards)
- [ ] Multiple languages
- [ ] Dark mode
- [ ] Offline hadith database
- [ ] Push notifications for special occasions
- [ ] Widget support for home screen

### Technical Improvements
- [ ] Unit tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] Analytics integration

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

### Development Guidelines
1. Follow Flutter best practices
2. Maintain consistent code style
3. Add comments for complex logic
4. Test thoroughly before submitting
5. Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Hadith sources: Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah
- UI inspiration from modern Islamic apps
- Flutter community for excellent documentation

## 📞 Support

For support, email us at: support@revive-app.com

---

**Revive** - Helping Muslims revive the Sunnah, one day at a time. 🌟 