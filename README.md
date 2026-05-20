# 🏥 Swasthyogi: Rapid Crisis Response & Coordination

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Google Gemini](https://img.shields.io/badge/Google%20Gemini-8E75C2?style=for-the-badge&logo=googlegemini&logoColor=white)](https://deepmind.google/technologies/gemini/)
[![Security](https://img.shields.io/badge/Security-AES--256%20%7C%20Play%20Integrity-success?style=for-the-badge)](#-security--compliance)

> **Swasthyogi** is a high-reliability, ultra-low latency crisis management platform architected to synchronize emergency response workflows within the decentralized hospitality ecosystem. It eliminates critical information silos by creating an intelligent, secure bridge between distressed guests, on-site personnel, and external first responders.

---

## 📌 Table of Contents
* [🚩 The Problem](#-the-problem)
* [💡 The Solution](#-the-solution)
* [🏗 Architecture & Ecosystem](#-architecture--ecosystem)
* [🛡 Security & Compliance](#-security--compliance)
* [🛠 Setup & Installation](#-setup--installation)
* [🚀 Future Roadmap](#-future-roadmap)

---

## 🚩 The Problem

Hospitality venues regularly face unpredictable emergencies where critical operational and medical data is severely fragmented. 
* **Delayed Interventions:** Traditional internal hotel networks fail to quickly relay guest medical history, precise room locations, or real-time health statuses to first responders.
* **The "Information Silo":** This communication fracture during the golden seconds of a crisis directly risks human lives.

---

## 💡 The Solution

Swasthyogi bridges the gap between distress and care by pre-synchronizing guest wellness profiles directly with hospitality infrastructure.

```text
[Distressed Guest] ──( <200ms SOS )──> [Hotel On-Site Staff] ──> [First Responders]
        │                                                                │
        └───> [Gemini AI Engine: Active Multilingual First Aid] ─────────┘

```

* **⚡ Instant SOS Protocols:** User-triggered emergency signals achieving an end-to-end synchronization latency of **< 200ms**.
* **📍 Precision Asset Tracking:** Automatically binds active SOS alerts to precise Room Numbers, Floors, and Hotel Wings for instant zero-loss localization.
* **🤖 Active AI Guidance:** Deploys immediate, context-aware, multi-lingual first-aid instructions via Gemini AI to bystanders while emergency services are en route.
* **🔑 Verified Access Controls:** Implements zero-knowledge, password-based cryptographic protocols to securely unlock and share sensitive medical profiles exclusively with verified responders.

---

## 🏗 Architecture & Ecosystem

### Tech Stack Matrix

| Layer | Technology | Role |
| --- | --- | --- |
| **Frontend UI/UX** | **Flutter** | Cross-platform client-side performance, responsive state management. |
| **Backend / Cloud** | **Firebase Suite** | Real-time synchronization via Firestore, Authentication, App Check protection. |
| **Cognitive Intelligence** | **Google Gemini Pro** | On-demand symptom triaging and automated active medical guidance. |
| **Core Engineering** | **Google Antigravity** | Advanced Agentic AI-driven system engineering and prompt orchestration. |

### System Data Flow

```
 ┌────────────────┐       ⚡ <200ms Sync       ┌─────────────────────┐
 │  Flutter Client│ ─────────────────────────> │ Firestore Database │
 └────────────────┘                            └─────────────────────┘
         │                                                ▲
         ▼ (Symptom Text / Context)                       │ (Structured JSON)
 ┌────────────────┐                                       │
 │   Gemini Pro   │ ──────────────────────────────────────┘
 └────────────────┘

```

---

## 🛡 Security & Compliance

Given the critical nature of emergency data, Swasthyogi enforces a hardened security posture:

* **Data-at-Rest Encryption:** Local client-side caches are secured utilizing **AES-256** encryption models.
* **Device Attestation:** Protected via **Google Play Integrity** and **Firebase App Check** to completely eliminate reverse-engineering vectors and API scraping.
* **Access Isolation:** PII (Personally Identifiable Information) and medical datasets remain encrypted on Firestore and are only un-hashed via explicit, event-driven user consent or emergency credential handshake.

---

## 🛠 Setup & Installation

### Prerequisites

* Flutter SDK (Latest Stable Version)
* Android Studio / Xcode
* Firebase Project Instance

### Implementation Steps

1. **Clone the Repository**
```bash
git clone [https://github.com/your-repo/swasthyogi.git](https://github.com/your-repo/swasthyogi.git)
cd swasthyogi

```


2. **Configure Cloud Services**
Place your generated `google-services.json` config file inside the appropriate application directory:
```text
android/app/google-services.json

```


*(Note: This file is explicitly omitted from version control for system security.)*
3. **Inject Environment Variables**
Create a `.env` file in the project root directory and add your secret credentials:
```env
GEMINI_API_KEY=your_production_level_gemini_api_key_here

```


4. **Compile and Run**
Fetch the necessary Pubspec dependencies and launch the application profile:
```bash
flutter pub get
flutter run

```



---

## 🚀 Future Roadmap

* **🌐 Public Service Integration (PSAPs):** Developing native webhooks to securely route data directly into municipal Police and Fire Dispatch systems for fully automated city-level emergency routing.
* **📡 Smart-Room IoT Integration:** Utilizing localized sensor grids to detect un-notified physical anomalies, such as sudden falls, smoke escalation, or unauthorized entries.
* **📈 Predictive Diagnostic AI:** Evaluating longitudinal wellness trends over extended stays to identify and anticipate silent medical emergencies before acute symptoms manifest.

---

*Built for the Rapid Crisis Response Challenge | Bridging the gap between distress and care.*

```
