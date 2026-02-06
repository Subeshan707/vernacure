#  Vernacure - Multilingual AI & Blockchain InsurTech Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-02569B?logo=flutter)](https://flutter.dev)
[![Avalanche](https://img.shields.io/badge/Blockchain-Avalanche%20Fuji-E84142?logo=avalanche)](https://avax.network)
[![n8n](https://img.shields.io/badge/Backend-n8n%20Workflows-FF6D5A?logo=n8n)](https://n8n.io)
[![Groq](https://img.shields.io/badge/AI-Groq%20LLaMA%203.1-00D4AA)](https://groq.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> AI IGNITE 2026 Hackathon | PS 6: Multilingual InsurTech Platform
>
> *India's First Large-Scale Agentic AI Hackathon*

---

##  Overview

**Vernacure** is a revolutionary multilingual insurance platform that combines AI-powered assistance with blockchain security. It enables users across India to understand, compare, and purchase insurance policies in their native language (Tamil, Hindi, Telugu, Kannada, Malayalam) with transparent, immutable policy records on the Avalanche blockchain.

###  Problem Statement

> *"How might we create a multilingual InsurTech platform that makes insurance accessible to non-English speakers while ensuring transparency and trust through blockchain technology?"*

---

##  Key Features

| Feature | Description |
|---------|-------------|
|  **Multilingual Voice Agent** | Natural conversation in 5 Indian languages |
|  **AI Policy Comparison** | Side-by-side comparison with explainable AI recommendations |
|  **RAG Chatbot** | Ask questions about any insurance policy in your language |
|  **Blockchain Security** | Policy purchases secured on Avalanche testnet |
|  **5 Languages** | Tamil, Hindi, Telugu, Kannada, Malayalam |
|  **Transparent Pricing** | No hidden costs, all premiums on-chain |

---

##  App Screens

| # | Screen | Description |
|---|--------|-------------|
| 1 | **Welcome** | Language selection with beautiful gradient UI |
| 2 | **Policy Browser** | Browse & filter policies by category |
| 3 | **AI Comparison** | Side-by-side policy comparison with AI recommendations |
| 4 | **Voice Chat** | Multilingual voice interaction with TTS responses |
| 5 | **RAG Chatbot** | Context-aware Q&A about insurance policies |
| 6 | **Purchase** | MetaMask wallet integration, pay in AVAX |
| 7 | **My Policies** | View purchased policies with blockchain records |

---

##  Architecture

```

                      FLUTTER APP                             
    Cross-platform (Android/iOS/Web)                        
    Riverpod State Management                               
    Material Design 3 + Speech-to-Text/TTS                  

                          
          
                                        
       
    n8n Voice     n8n RAG       n8n Policy 
    Processing    Chatbot       Compare    
       
         
                         
              
                   GROQ API        
                LLaMA 3.1 70B      
              


                  AVALANCHE BLOCKCHAIN                        
    Fuji C-Chain Testnet (Chain ID: 43113)                  
    Smart Contract: VernacureInsurance.sol                  
    Policy NFT Minting + Premium Payments in AVAX           

```

---

##  Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter 3.29 | Cross-platform mobile & web |
| **State** | Riverpod | Reactive state management |
| **Blockchain** | Avalanche Fuji | Decentralized policy storage |
| **Smart Contract** | Solidity | VernacureInsurance.sol |
| **LLM** | Groq (LLaMA 3.1 70B) | Multilingual AI responses |
| **Backend** | n8n Workflows | API orchestration |
| **Voice** | Speech-to-Text | Multilingual voice input |
| **TTS** | flutter_tts | Voice responses |

---

##  Project Structure

```
vernacure/
 lib/
    main.dart                    # App entry point
    config/
       constants.dart           # API endpoints, webhook URLs
       avax_config.dart         # Avalanche blockchain config
       theme.dart               # Material 3 theme
    models/
       policy.dart              # Insurance policy model
    screens/
       welcome_screen.dart      # Language selection
       home_screen.dart         # Main navigation hub
       policy_list_screen.dart  # Browse policies
       policy_comparison_screen.dart
       voice_chat_screen.dart   # Voice interaction
       rag_chatbot_screen.dart  # Text chatbot
       purchase_screen.dart     # Blockchain purchase
       my_policies_screen.dart  # User's policies
    services/
       n8n_service.dart         # n8n webhook client
    widgets/
        policy_card.dart         # Reusable policy card
 contracts/
    VernacureInsurance.sol       # Solidity smart contract
 n8n_workflows/
    voice_processing.json
    rag_chatbot.json
    policy_comparison.json
 pubspec.yaml
```

---

##  Quick Start

### Prerequisites

- **Flutter SDK** 3.29.2+
- **Android Studio** / **VS Code**
- **MetaMask** wallet (for blockchain features)
- **n8n** instance (self-hosted or cloud)
- **Groq API Key** - [console.groq.com](https://console.groq.com)

### 1. Clone & Install

```bash
git clone https://github.com/Subeshan707/vernacure.git
cd vernacure
flutter pub get
```

### 2. Configure Environment

Update `lib/config/constants.dart`:

```dart
class AppConstants {
  static const String n8nBaseUrl = 'https://your-n8n-instance.com';
  static const String voiceWebhook = '$n8nBaseUrl/webhook/voice-process';
  static const String ragWebhook = '$n8nBaseUrl/webhook/rag-chat';
  static const String comparisonWebhook = '$n8nBaseUrl/webhook/policy-compare';
}
```

### 3. Run the App

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# With API Key
flutter run --dart-define=GROQ_API_KEY=your_api_key
```

### 4. Build Release

```bash
# Android APK
flutter build apk --release

# Web
flutter build web --release
```

---

##  Blockchain Integration

### Avalanche Fuji Testnet

| Property | Value |
|----------|-------|
| **Network** | Avalanche Fuji C-Chain |
| **Chain ID** | 43113 |
| **RPC URL** | `https://api.avax-test.network/ext/bc/C/rpc` |
| **Explorer** | [testnet.snowtrace.io](https://testnet.snowtrace.io) |
| **Faucet** | [faucet.avax.network](https://faucet.avax.network) |

### Smart Contract

```solidity
// contracts/VernacureInsurance.sol
contract VernacureInsurance {
    struct Policy {
        uint256 id;
        address holder;
        string policyType;
        uint256 premium;
        uint256 coverage;
        uint256 startDate;
        uint256 endDate;
        bool isActive;
    }
    
    function purchasePolicy(...) external payable;
    function getPolicy(uint256 id) external view returns (Policy);
    function getUserPolicies(address user) external view returns (Policy[]);
}
```

---

##  Supported Languages

| Language | Code | Voice | Text |
|----------|------|:-----:|:----:|
|  Tamil | `ta` |  |  |
|  Hindi | `hi` |  |  |
|  Telugu | `te` |  |  |
|  Kannada | `kn` |  |  |
|  Malayalam | `ml` |  |  |
|  English | `en` |  |  |

---

##  n8n Workflow Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/webhook/voice-process` | POST | Process voice queries |
| `/webhook/rag-chat` | POST | RAG chatbot responses |
| `/webhook/policy-compare` | POST | AI policy comparison |
| `/webhook/agent-assist` | POST | Agent assistance |

### Example Request

```json
{
  "query": "What is the best health insurance for a family of 4?",
  "language": "ta",
  "context": {
    "budget": "50000",
    "members": 4
  }
}
```

---

##  Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

##  Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

##  License

MIT License - see [LICENSE](LICENSE) file.

---

##  Team

**Built for AI IGNITE 2026** - India's First Large-Scale Agentic AI Hackathon

---

<p align="center">
  <strong> Vernacure - Insurance for Everyone, in Every Language</strong>
  <br><br>
  <em>Powered by AI  Secured by Blockchain  Built with  in India</em>
</p>
