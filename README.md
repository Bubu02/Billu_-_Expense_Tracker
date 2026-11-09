# Billu / Pilu - Minimal Expense Tracker 📱✨

A high-fidelity mobile expense tracker built in **Flutter (Dart)** faithfully implementing the **Monochrome Precision Wireframe** design system extracted from **Stitch**.

The application embodies architectural austerity, functional clarity, and editorial calm with complete, pixel-accurate support for both **Light** and **Dark** themes.

---

## 🎨 Design System: Monochrome Precision Wireframe

- **Font Family**: `Inter` (with OpenType `tabularFigures` support for financial figures)
- **Palette Principles**:
  - **Light Mode**: Off-white canvas (`#F9F9F9`), sterile white containers (`#FFFFFF`), solid jet black ink accents (`#000000`), neutral gray outlines (`#7E7576`).
  - **Dark Mode**: Deep charcoal canvas (`#0A0A0A`), pitch black containers (`#000000`), crisp white ink accents (`#FFFFFF`), muted gray outlines (`#444748`).
- **Tactile Depth**: Planar hierarchy without colored alerts or heavy drop shadows, relying on binary reversals (solid vs hollow wireframes) and crisp 1.5px ink boundaries.

---

## 📱 Implemented Screens (Light & Dark)

### 1. Splash & Onboarding (`onboarding_screen.dart`)
- **Micro-header**: `V1.0 • OFFLINE READY` with pulsing dot and `monochrome` pill badge.
- **Center Stage**:
  - Precision constellation vector lines (`ConstellationPainter`) connecting the center avatar to orbiting pills.
  - Interactive floating tags with playful bounce physics (`balance`, `+ income`, `expenses ●`, `food`, `travel`, `fun ✦`).
  - Circular avatar container with anchor tick mark.
- **Actions**: `get started` primary pill button, `already tracked? restore backup`, and zen statement `zero clutter • local first`.

### 2. Dashboard / Desk (`dashboard_screen.dart`)
- **Top Utility Bar**: Period selector (`this month`), search action, and privacy balance masking button (`eye` toggle).
- **Hero Spend Card**:
  - Dynamic privacy masking (`$301.95` ⇄ `$••••••`).
  - Sinusoidal bezier spline sparkline (`SparklinePainter`) with dashed reference baselines, guidance axis, active day indicator, and floating pinned tooltip (`today $8.95`).
- **Horizontal Month Strip**: Month switcher (`jul`, `aug`, `sep`, `oct` active, `nov`, `dec`).
- **Mindful Budget Health**: Leaf icon badge, `envelope in rhythm`, `$18.05 unallocated buffer remains`, and `84%` indicator.
- **Ledger Groups**: Categorized by `today` (Coffee, Pet care, Commute, Groceries) and `yesterday` (Audiobook, Magazine Dispatch) with crisp line-art category icons and tabular prices.
- **Receipt Mark**: `PILU LEDGER • SYNC 1M AGO`.

### 3. Quick-Add Entry (`quick_add_screen.dart`)
- **Top Bar**: Dismiss `close` button, Segmented pill toggle (`expenses` ⇄ `income`), and currency indicator (`USD`).
- **Date Strip**: Horizontal calendar date strip (`12 mon`, `13 tue` active, `14 wed`, `15 thu`, `16 fri`, and calendar modal icon).
- **Amount Display**: Large hero metric (`$20.00`) with blinking ink cursor.
- **Category Selector**: `🍔 burger king` category pill with picker modal.
- **Action Helpers**: `split bill`, `scan receipt`, and `cash / bank`.
- **Note / Tag Input**: Inline note input with `#tags` quick insertion.
- **4x3 Numeric Keypad**: Large tactile touch targets with check submit button.

### 4. Budget & Analytics / Stats (`budget_analytics_screen.dart`)
- **View Controls**: Period tabs (`weekly`, `monthly`, `custom`).
- **Alert Pill**: `80% dining limit reached for october` with pulse dot.
- **Circular Breakdown**:
  - Segmented Donut Chart (`DonutChartPainter`) with center gauge readout (`OCT TOTAL`, `$1,840`, `of $2,400 cap`).
  - 2x2 Category Legend Cards (`dining & food`, `rent & bills`, `commute`, `shopping`).
- **Category Logs**: High-contrast progress meters with remaining budget calculations for active caps.

### 5. Wallets & Accounts / Vault (`wallets_screen.dart`)
- **Header Action**: `wallets & cards` with `+ add account` button.
- **Net Liquidity Card**:
  - Currency toggle (`USD $`, `EUR €`, `GBP £`).
  - Balance display (`$14,820.50`), `+3.8% vs last billing cycle`.
  - Stepped sparkline chart (`SteppedChartPainter`).
  - Cash vs Credit micro-meter (`92% liquid`).
- **Active Vaults**:
  - Chase checking (Primary, Plaid synced)
  - Apple Card (Credit, statement closing & autopay indicators)
  - Physical cash (Untracked emergency pouch)
  - Vault savings (Ally Bank 4.35% APY compounding yield)

### 6. Settings & Security / Setup (`settings_screen.dart`)
- **Profile Card**: Avatar, `pilu member`, `local vault active`, `offline first` badge.
- **Appearance & Theme**: Interactive switch to toggle between **Light Wireframe** and **Dark Precision** themes live across the entire application.
- **Security & Privacy**:
  - Biometric unlock (Fingerprint & Face ID)
  - Privacy mask mode (Hide ledger amounts in public)
  - Local SMS parser (100% on-device transaction capture)
- **Data & Export**:
  - Export vault archive (`csv • json • signed pdf`)
  - Encrypted cloud backup
  - Erase local database with confirmation dialog.
- **Zen Statement**: `pilu android v1.0.4 • pure minimal budgeting • no ads • no cloud tracking`.

---

## 📂 Project Architecture

```
Billu/
├── designs/                        # Original Stitch exported mockups & design system
│   ├── DESIGN_SYSTEM.md            # Complete design tokens, typography, and rules
│   ├── onboarding-light.html
│   ├── onboarding-dark.html
│   ├── dashboard-light.html
│   ├── dashboard-dark.html
│   ├── quick-add-light.html
│   ├── quick-add-dark.html
│   ├── budget-analytics-light.html
│   ├── budget-analytics-dark.html
│   ├── wallets-light.html
│   ├── wallets-dark.html
│   ├── settings-light.html
│   └── settings-dark.html
├── lib/
│   ├── main.dart                   # Application entry point with ThemeMode state
│   ├── theme/
│   │   ├── app_colors.dart         # Light & Dark color tokens and ThemeExtension
│   │   ├── app_typography.dart     # Inter-based typography with tabular figures
│   │   └── app_theme.dart          # Light and Dark ThemeData implementations
│   ├── models/
│   │   ├── transaction_model.dart  # Transaction ledger models and sample data
│   │   ├── account_model.dart      # Bank, card, and cash vault models
│   │   └── budget_model.dart       # Budget caps and donut segment definitions
│   ├── widgets/
│   │   ├── app_header.dart         # Top bar with title and profile avatar
│   │   ├── app_bottom_nav.dart     # 5-item navigation bar with floating action button
│   │   ├── sparkline_painter.dart  # Sinusoidal curve sparkline CustomPainter
│   │   ├── stepped_chart_painter.dart # Stepped sparkline CustomPainter
│   │   ├── donut_chart_painter.dart   # Segmented donut chart CustomPainter
│   │   └── constellation_painter.dart # Onboarding arc constellation CustomPainter
│   └── screens/
│       ├── main_scaffold.dart      # Multi-tab container coordinating navigation
│       ├── onboarding_screen.dart  # Splash & Onboarding
│       ├── dashboard_screen.dart   # Desk / Dashboard
│       ├── quick_add_screen.dart   # Keypad & Quick Add Entry
│       ├── budget_analytics_screen.dart # Stats / Analytics
│       ├── wallets_screen.dart     # Vault / Wallets & Cards
│       └── settings_screen.dart    # Setup / Settings & Security
└── pubspec.yaml                    # Flutter project configuration
```

---

## 🚀 Running the App

To run this app on an emulator, device, or web:

```bash
flutter pub get
flutter run
```

