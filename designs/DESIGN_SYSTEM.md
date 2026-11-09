---
name: Monochrome Precision Wireframe
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#4c4546'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#7e7576'
  outline-variant: '#cfc4c5'
  surface-tint: '#5e5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1b1b1b'
  on-primary-container: '#848484'
  inverse-primary: '#c6c6c6'
  secondary: '#5e5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e3e2e2'
  on-secondary-container: '#646464'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#1b1b1b'
  on-tertiary-container: '#848484'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2e2e2'
  primary-fixed-dim: '#c6c6c6'
  on-primary-fixed: '#1b1b1b'
  on-primary-fixed-variant: '#474747'
  secondary-fixed: '#e3e2e2'
  secondary-fixed-dim: '#c7c6c6'
  on-secondary-fixed: '#1b1c1c'
  on-secondary-fixed-variant: '#464747'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c6'
  on-tertiary-fixed: '#1b1b1b'
  on-tertiary-fixed-variant: '#474747'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-currency:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.04em
  display-currency-mobile:
    fontFamily: Inter
    fontSize: 38px
    fontWeight: '700'
    lineHeight: 42px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  numeric-tabular:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: -0.01em
  numeric-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0em
  label-caps:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.06em
  label-subtle:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system embodies structural austerity, functional clarity, and editorial calm. Designed for focused expense tracking, the aesthetic draws directly from high-fidelity architectural wireframes, Swiss typographical grids, and modern industrial receipt layouts.

The visual style strips away ornamental skeuomorphism, colored alerts, and decorative elevations in favor of pure monochromatic contrast, deliberate spatial breathing room, and ink-line precision. The interface evokes discipline, financial mindfulness, and immediate computational legibility. Every stroke serves an informational purpose; interactive states rely strictly on binary reversals (hollow vs. solid black fills) rather than chromatic signifiers.

## Colors

The palette operates under absolute chromatic restraint:
- **Primary Canvas (`#FFFFFF`)**: Pure, sterile white providing an unyielding surface for ink-like boundaries and data points.
- **Primary Ink / Active Surface (`#000000`)**: Deep jet black used for high-priority typography, 1.5px structural borders, and inverted high-emphasis container fills.
- **Muted Secondary (`#737373`)**: Mid-tone neutral used strictly for meta-labels, timestamps, and de-emphasized structural hints.
- **Soft Neutral Fill (`#F5F5F5`)**: Tonal substrate used for inactive toggle tracks, keypad button tiles, and subtle row alternating states.
- **Subtle Hairline (`#E5E5E5`)**: Hairline dividers and inactive button boundaries.

No semantic green or red colors are utilized for financial flow. Positive and negative cash movements are differentiated solely through typographic notation (`+`, `-`), stroke thickness, or pill inversion.

## Typography

The type system is powered by Inter, optimized for screen clarity and tabular stability.
- **Tabular Figures**: All currency, totals, balance counts, and timestamps must render with OpenType `tnum` (tabular figures) enabled to prevent layout shifting across dynamic updates.
- **Casing Rules**: Category chips, operational indicators, and micro-labels use understated lowercase or sparse small caps with expanded tracking (`0.06em`). Section headers stay in clean sentence case.
- **Weights**: Heavily polarized between `400` (Regular) for descriptive commentary and `600`/`700` (Semi-Bold/Bold) for numerical values, enforcing swift data scanning.

## Layout & Spacing

The layout is built on an Android-first fluid vertical stack governed by an 8pt spatial grid:
- **Canvas Boundaries**: Outer horizontal padding is standardized to `1.25rem` (20px) on mobile viewports, extending up to `2rem` on wider tablet viewports.
- **Vertical Rhythm**: Generous whitespace between semantic transaction blocks (`space-xl`) prevents data density fatigue, countering the high contrast of the monochrome palette.
- **Grid Adaptability**: Single-column layout on standard hand-held devices, resolving to a 2-column wireframe layout on tablet/foldable viewports where the custom keypad sits anchored alongside transaction logs.

## Elevation & Depth

This system strictly rejects drop shadows, blurs, and skeuomorphic layered z-indexes. 

- **Planar Hierarchy**: Depth is communicated exclusively through outline density and surface contrast. 
- **Active / Resting Plane**: Resting surfaces sit directly on `#FFFFFF`. Tonal containment uses flat, non-bordered `#F5F5F5` fields.
- **Foreground Emphasis**: Overlays, modal bottom sheets, and elevated contextual cards are delineated by a crisp `1.5px solid #000000` stroke with a stark zero-blur hard offset or purely flush boundaries.
- **Selection States**: Achieved through total inversion—swapping a 1.5px black outline on white into a solid black field with white typography.

## Shapes

The geometric dialect utilizes an extreme contrast between hyper-rounded pill silhouettes and strict architectural rectilinearity:
- **Pill Badges & Buttons**: Interactive tokens, category pills, filter badges, and primary action controls use full pill forms (`9999px` / `roundedness: 3`).
- **Cards & Keypad Cells**: Softened internal modules leverage `0.75rem` (12px) to `1rem` (16px) radii to balance the high-contrast ink boundaries.
- **Line Endings**: Line art iconography, chart path caps, and divider strokes use precise butt or slightly rounded strokes matching the consistent 1.5px border weight.
