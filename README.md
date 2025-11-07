# EchoStrik

![Flutter](https://img.shields.io/badge/Flutter-Voice%20Mental%20Health-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Status](https://img.shields.io/badge/status-Prototype-orange)

## 🌟 Core Idea
EchoStrik is a voice-first mental health platform designed to help users express, process, and share their emotions anonymously. By combining audio journaling, AI-powered empathy, and community support, EchoStrik aims to create a safe space for emotional well-being.

## 📸 Screenshots
<!-- Add your screenshots below. Example: -->
<p align="center">
  <img src="docs/screenshot_home.png" width="350" alt="Home Screen" />
  <img src="docs/screenshot_record.png" width="350" alt="Record Screen" />
</p>

## 🎤 What Makes EchoStrik Unique?
- **Voice-Based Emotional Sharing:** Users record and share voice messages ("echoes") about their feelings, moods, and experiences.
- **Anonymous & Safe:** No personal data required. Users are identified by anonymous IDs, ensuring privacy and safety.
- **AI Empathy & Prompts:** Daily AI-generated prompts encourage reflection. AI can reply with empathetic support to user echoes.
- **Mood-Based Navigation:** Echoes are organized by mood (lonely, calm, hopeful, anxious, grateful, confused) for easy discovery and connection.
- **Community Threads:** Users can listen, reply, and support each other through voice replies ("strikes") in threaded conversations.
- **Premium Features (Coming Soon):** Heart Circles (live audio groups), Echo Playlists, Mood Analytics, and more.

## 🛠️ Features
- Record and share voice echoes
- Browse and filter echoes by mood
- Receive daily AI prompts for emotional expression
- Listen and reply to others anonymously
- Profile stats and emotional journey tracking
- Secure, anonymous authentication
- Firebase and Supabase integration for scalable backend
- Planned: Payment integration for premium features

## 🚀 Getting Started
1. **Clone the repository:**
   ```sh
   git clone https://github.com/vijayaragavanr18/Echostrik.git
   cd Echostrik
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Configure Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Update `lib/firebase_options.dart` with your Firebase project settings.
4. **Run the app:**
   ```sh
   flutter run
   ```

## ⚠️ Important Notes

### For Users:
- **Disable ad blockers** when using the app. Ad blockers (uBlock Origin, AdBlock, Brave Shields) block Firebase/Firestore connections.
- **Whitelist the domain** or disable ad blockers for `echostrik.vercel.app` to ensure full functionality.

### For Developers:
- Firebase configuration included for web deployment
- API keys are in the repository for demo purposes - **rotate them for production**
- Supabase integration available as alternative backend

## 💡 Vision & Roadmap
- **Phase 1: Core Data Flow**
  - Replace demo data with real Firestore queries
  - Implement real-time echo feed and mood filtering
- **Phase 2: Audio System**
  - Upload audio to Firebase Storage
  - Enable playback and caching
- **Phase 3: Social Features**
  - Complete reply/strike system
  - Implement likes, shares, and dynamic counts
- **Phase 4: AI Integration**
  - Dynamic daily prompts
  - Empathetic AI replies
  - AI moderation and insights
- **Phase 5: Search & Discovery**
  - Full search functionality
  - Advanced filters and suggestions
- **Phase 6: User System**
  - Echo history, stats, and profile customization
- **Phase 7: Premium Features**
  - Payment integration
  - Heart Circles, playlists, analytics
- **Phase 8: Safety & Support**
  - Crisis detection, moderation, emergency resources
- **Phase 9: Polish & Testing**
  - Error handling, performance, offline support

## 🤝 Contributing
We welcome contributions! Please open issues, submit pull requests, or suggest features to help improve EchoStrik.

## 📄 License
This project is licensed under the MIT License.

## 🧠 Mental Health Disclaimer
EchoStrik is not a substitute for professional help. If you or someone you know is in crisis, please seek help from a qualified mental health professional or contact emergency services.

---

*Built with ❤️ for emotional well-being and community support.*
