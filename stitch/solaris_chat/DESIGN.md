# Design System Documentation: The Radiant Social Experience

## 1. Overview & Creative North Star: "Kinetic Warmth"

The Creative North Star for this design system is **Kinetic Warmth**. While many chat applications settle for a "utility-first" utility look—flat white surfaces and rigid blue accents—this system rejects the sterile in favor of the energetic. 

We break the standard "template" look through **Tonal Immersion**. Instead of black text on a white background, we use a sophisticated palette of ambers, creams, and deep burnt oranges. The UI should feel like a living, breathing space where light and depth define boundaries, not harsh lines. By utilizing asymmetric layouts in chat bubbles and overlapping avatar clusters, we create an editorial rhythm that feels premium and custom-built.

## 2. Colors: Beyond the Hex

Our color strategy moves away from "flat" application. We use Material Design 3 logic to ensure the "Vibrant Orange" and "Sunny Yellow" interact harmoniously without causing visual fatigue.

### The "No-Line" Rule
**Strict Mandate:** Designers are prohibited from using 1px solid borders to section off content. 
*   **The Technique:** Boundaries must be defined solely through background color shifts. For example, a search bar should be `surface-container-highest` sitting on a `surface` background.
*   **Visual Soul:** Use the `primary` (#8c4a00) to `primary-container` (#fd8b00) gradient for main Action Buttons to provide a "lit-from-within" glow that a flat hex code cannot achieve.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use these tokens to create "nested" depth:
*   **Base Layer:** `surface` (#fff5ed) - The canvas.
*   **Secondary Layer:** `surface-container-low` (#ffeedf) - For grouped content like message threads.
*   **Accent Layer:** `surface-container-highest` (#ffd6ab) - For prominent interactive elements like the message input field.

### The "Glass & Gradient" Rule
For floating elements (like the "New Message" FAB), use **Glassmorphism**. Apply `surface-tint` at 12% opacity with a 20px backdrop blur. This allows the energetic background colors to bleed through, softening the edges of the UI.

## 3. Typography: The Editorial Voice

We utilize a dual-font strategy to balance character with readability.

*   **Display & Headlines (Plus Jakarta Sans):** Used for "high-personality" moments like Usernames in profiles or "Chat" headers. It’s wide and modern, leaning into the "Flutter-inspired" friendly aesthetic.
*   **Body & Labels (Inter):** Optimized for the rapid-fire reading of chat messages. Inter’s tall x-height ensures clarity even at `body-sm` (0.75rem).

**The Hierarchy:**
*   **Headline-lg (2rem):** Used for "Moments" or "Stories" titles.
*   **Title-md (1.125rem):** The gold standard for contact names in a list.
*   **Body-lg (1rem):** The default for chat bubbles to ensure high accessibility.

## 4. Elevation & Depth: Tonal Layering

Shadows are no longer "gray smears." They are an extension of the light source.

*   **The Layering Principle:** To lift a card, place a `surface-container-lowest` (#ffffff) card on a `surface-container` (#ffe4c9) background. The contrast provides "Natural Lift."
*   **Ambient Shadows:** For floating elements, use a `12px` blur with 6% opacity. The shadow color must be a tint of `on-surface` (#452800) rather than pure black, ensuring the shadow feels like a warm glow rather than a dark void.
*   **The "Ghost Border" Fallback:** If a border is required for accessibility, use `outline-variant` (#d4a46f) at 15% opacity. Never use 100% opaque borders.

## 5. Components

### Chat Bubbles (The Signature Component)
*   **Incoming:** `surface-container-high` (#ffddba) with `on-surface` (#452800) text. Use `DEFAULT` (1rem) roundedness on all corners except the bottom-left (set to `sm`).
*   **Outgoing:** `primary-container` (#fd8b00) with `on-primary-container` (#442100) text. Use `DEFAULT` (1rem) roundedness except the bottom-right (set to `sm`).
*   **Spacing:** Use `spacing-2` (0.5rem) between bubbles from the same user; `spacing-4` (1rem) between different users.

### Input Fields
*   **Surface:** `surface-container-highest` (#ffd6ab).
*   **Shape:** `full` (9999px) for a soft, pill-like feel.
*   **Icons:** Use `on-surface-variant` (#7a5426) for inactive states. When typing, the "Send" icon should transition to `primary` (#8c4a00).

### Buttons
*   **Primary:** Solid `primary-fixed` (#fd8b00) with a subtle 5% top-down linear gradient. `xl` (3rem) roundedness.
*   **Secondary:** `secondary-container` (#ffd709) with `on-secondary-container` (#5b4b00). Use for "Add Media" or "Location" actions.

### Cards & Lists
*   **Rule:** Forbid divider lines.
*   **Execution:** Separate chat threads using `spacing-6` (1.5rem) of vertical white space and a subtle background shift on hover/press using `surface-container-low` (#ffeedf).

### Additional Component: "The Ripple Wave"
For audio messages, use a waveform generated from the `secondary` (#6c5a00) color, sitting atop a `surface-variant` (#ffd6ab) track. This maintains the "energetic" theme through functional motion.

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical spacing. If an avatar is on the left, give the text more "breathing room" on the right using `spacing-5` (1.25rem).
*   **Do** lean into the warm spectrum. Every "neutral" color in this system is tinted with orange/yellow to ensure the app feels "sunny."
*   **Do** use `xl` (3rem) roundedness for large containers to emphasize the friendly, Flutter-inspired vibe.

### Don't
*   **Don't** use pure #000000 for text. Always use `on-surface` (#452800) to maintain tonal depth.
*   **Don't** use "Drop Shadows" on flat surfaces. Only use shadows for elements that truly "float" over other content (like Modals or FABs).
*   **Don't** use the `error` color (#b02500) for anything other than critical destructive actions. For "Warning" states, use the `tertiary` (#6f5900) palette.