# Twela UI/UX Reconstruction & Layout Fix — v10

## IMPORTANT

Do NOT treat this as a small visual patch.

The current Twela UI has accumulated inconsistent layouts between screens.
We need a controlled UI/UX reconstruction across the entire app while preserving
ALL existing business logic, providers, models, storage, notifications, transaction
logic, debt logic, savings logic, statistics logic, and existing working features.

Repository:
https://github.com/CODE-NAME-IN-B/Twela

The current app is Flutter + Provider.

Before changing anything:

1. Inspect the complete current repository.
2. Understand the existing navigation architecture.
3. Understand all Providers and models.
4. Understand transaction/debt/savings balance propagation.
5. Do NOT delete working functionality just because its UI is being rebuilt.
6. Do NOT replace screens with placeholders.
7. Do NOT rebuild only Settings.
8. The final UI must be consistent across ALL screens.

==================================================
# P0 — CRITICAL LAYOUT / SYSTEM UI FIXES
==================================================

## 1. Fix content overlapping the Android status bar

The attached screenshot shows the upper content/card visually too close to /
overlapping the system notification/status-bar area.

This must be treated as a real layout bug.

Audit:

- HomeScreen
- SettingsScreen
- HistoryScreen
- DebtsScreen
- StatsScreen
- SavingsScreen
- AddTransactionScreen
- AddDebtScreen
- DebtDetailScreen
- AddSavingsGoalScreen
- RoutineSettingsScreen
- DataExportScreen

Check:

- SafeArea
- MediaQuery.padding.top
- edge-to-edge behavior
- nested Scaffold usage
- AppBar height
- status bar color
- status bar icon brightness
- top padding
- scroll view padding
- Android 15/16 edge-to-edge behavior

Do not solve this with random hardcoded top padding.

Use a consistent system UI strategy.

Acceptance:

- No card, title, icon, text, or interactive element can enter the
  notification/status-bar region.
- The top spacing looks intentional.
- Works on different Android screen sizes.
- Works in both Light and Dark themes.

==================================================
# P0 — FIX THE ADD BUTTON / EXPENSE COLOR
==================================================

Current global accent is green.

That is correct for the general Twela brand.

BUT:

When the user enters the "إضافة صرف" screen, the expense UI must use RED
as its semantic color.

Do NOT make the entire application red.

Do NOT make the global accent red.

Expense mode only:

- primary action = red
- selected expense type = red
- expense amount emphasis = red
- expense-related icons = red
- expense validation/error state = appropriate red
- expense save button = red
- expense category selection state = red where appropriate

Income mode remains green.

Debt actions use their own semantic color.

Savings uses savings/cyan or appropriate savings semantic color.

The color system must therefore distinguish:

SUCCESS / INCOME
→ Green

EXPENSE
→ Red

DEBT
→ Amber / warm semantic color

SAVINGS
→ Cyan / teal semantic color

INFO / STATISTICS
→ Blue / appropriate semantic color

Do not randomly color every component.

Create centralized semantic colors in the theme instead of hardcoding colors
inside individual screens.

Example conceptual API:

AppColors.income
AppColors.expense
AppColors.debt
AppColors.savings
AppColors.info
AppColors.warning
AppColors.error

==================================================
# P0 — REBUILD THE GLOBAL UI SYSTEM
==================================================

The current screens visually feel like different applications.

Create one unified Twela Design System.

Centralize:

- colors
- typography
- spacing
- corner radius
- card style
- borders
- shadows
- icon sizing
- button sizing
- input fields
- section headers
- empty states
- bottom sheets
- navigation
- chips
- switches
- segmented controls

Do not scatter arbitrary values throughout screens.

Use a spacing scale such as:

4
8
12
16
20
24
32

Use consistent radii:

Small: 10-12
Medium: 16
Large: 20-24

Avoid excessive rounded containers.

The UI should feel:

- premium
- clean
- modern
- financial
- calm
- mobile-first
- Arabic RTL
- Nothing/Apple-inspired
- minimal
- not overly decorative

==================================================
# P1 — REBUILD MAIN NAVIGATION
==================================================

Current MainScreen controls:

- Home
- History
- Debts
- Statistics
- Settings
- Floating +

The current implementation uses a parent Scaffold with screens that also
contain Scaffolds.

Audit this architecture carefully.

Do NOT blindly remove nested Scaffolds if they are required when screens are
opened independently as routes.

Instead establish a predictable navigation architecture.

Bottom navigation must:

- never overlap content
- never cover labels/icons
- respect SafeArea
- respect gesture navigation area
- work on small screens
- work on Nothing Phone devices
- maintain RTL correctness
- have clear selected state
- have adequate touch targets

Navigation:

الرئيسية
السجل
الديون
الإحصائيات
الإعدادات

Floating +:

- must never cover the "الديون" navigation item
- must not collide with navigation
- should have a deliberate position
- should have enough spacing around it

Use a centered or reserved navigation slot if needed.

The previous v9 issue regarding the + button covering the debt icon must
remain fixed.

==================================================
# P1 — REBUILD THE + ACTION SHEET
==================================================

The current + sheet contains:

- إضافة دخل
- إضافة مصروف
- أعطيت مالًا لشخص
- استلمت مالًا من شخص
- إضافة ادخار

Preserve all actions.

Rebuild the sheet visually.

Design:

Header:
"إضافة حركة"

Then semantic action cards:

إضافة دخل
green

إضافة مصروف
red

أعطيت مالًا لشخص
amber

استلمت مالًا من شخص
purple/appropriate debt color

إضافة ادخار
cyan

Each action:

- icon
- title
- short explanation
- semantic color
- clear touch target

The sheet must not be excessively tall.

Use proper SafeArea.

==================================================
# P1 — REBUILD HOME SCREEN
==================================================

Current HomeScreen already contains:

- greeting/header
- motivational message
- Glyph bar
- balance card
- wallet cards
- today's spending
- quick actions

Preserve the functionality.

Rebuild the hierarchy.

Suggested structure:

1. Header
   Twela + greeting
   notification/settings action if needed

2. Balance hero card
   Total balance
   Cash
   Bank
   clean visual hierarchy

3. Today's spending
   amount
   progress against daily limit

4. Quick actions

5. Recent transactions

6. Savings/debt summary where appropriate

Do NOT overload the home screen.

The user should understand their financial state in under 2 seconds.

The balance card must not touch the status bar.

The glass mode must remain optional.

Glass mode should be subtle, not excessive.

==================================================
# P1 — REBUILD SETTINGS SCREEN
==================================================

The current Settings screen is visually dense and card-heavy.

Keep all existing settings/features.

But reorganize them into clear sections:

المظهر

- فاتح
- داكن
- الجهاز

المميزات

- اهتزاز عند الحفظ
- وضع الزجاج
- Glyph Strip

التخصيص

- لون التمييز

الميزانية الشهرية

- الحد الشهري الإجمالي

Other settings should be grouped logically.

Do not put every setting inside a huge container.

Use smaller grouped sections with consistent spacing.

Switches must be visually accessible.

Selected theme state must be obvious.

The settings page must not look like a form from an old Android application.

==================================================
# P1 — REBUILD ADD TRANSACTION
==================================================

This is one of the most important screens.

The current screen has:

- type selector
- wallet selector
- amount
- category
- note
- save button

Preserve the functionality.

Rebuild UI around the selected transaction type.

Expense:

RED semantic theme.

Income:

GREEN semantic theme.

At the top:

[ مصروف ] [ دخل ]

When "مصروف" is selected:

- red selected state
- red amount emphasis
- red save button
- red semantic icons

When "دخل" is selected:

- green selected state
- green amount emphasis
- green save button

The rest of the app's brand color must NOT change.

Amount input should be the visual focus.

Make entering:

100
50
12.5

extremely easy.

Use clear LYD presentation.

Category picker should be redesigned with modern selectable chips/grid.

Note field should be secondary.

Save button should be large and obvious.

The back button must always work.

If the user enters data and attempts to leave, handle unsaved changes
appropriately.

==================================================
# P1 — REBUILD HISTORY
==================================================

History must be one of the strongest screens.

Every transaction should clearly communicate:

- category icon
- title
- date/time
- wallet
- amount
- income/expense semantic color

Expense:
red

Income:
green

Do not depend on hidden gestures.

Every transaction should have an obvious action menu:

⋮

Options:

تعديل
حذف

Edit must allow editing:

- amount
- type
- wallet
- category
- note
- date if supported by existing model

Delete must:

- show confirmation
- reverse balance correctly
- refresh UI immediately

Swipe-to-delete may remain as a shortcut but must NOT be the only method.

==================================================
# P1 — REBUILD DEBTS
==================================================

Preserve existing debt logic.

The debt UI must clearly distinguish:

"أنا أعطيت"

and

"أنا استلمت"

Debt list:

- person
- total
- remaining
- paid
- direction
- status

Debt detail must have an extremely obvious action:

"تسجيل دفعة"

or

"أعطيته مالًا"

depending on direction.

This was previously a usability problem.

The user should never have to guess how to record a payment.

Add:

- primary payment button
- transaction history
- remaining balance
- progress
- edit
- delete
- back

Do not break the existing debt balance/reversal logic.

==================================================
# P1 — REBUILD SAVINGS
==================================================

The current repository already contains a dedicated SavingsScreen and
AddSavingsGoalScreen.

Do NOT remove them.

Rebuild their UI to match the new Twela design system.

Savings screen:

- total saved
- target
- progress
- remaining
- deadline if available
- recent deposits
- add deposit
- edit goal
- delete goal

Empty state should be premium and useful.

Avoid giant empty blank spaces.

Primary savings action should use the savings semantic color.

==================================================
# P1 — REBUILD STATISTICS
==================================================

Keep existing charts/data.

Rebuild presentation:

- spending summary
- income vs expense
- categories
- daily/weekly/monthly filters
- wallet breakdown

Charts should have clear legends.

Avoid excessive colors.

Expense charts use expense red.

Income charts use income green.

Neutral information uses blue/neutral.

==================================================
# P1 — REBUILD BUDGET
==================================================

Monthly budget UI:

- monthly limit
- spent
- remaining
- percentage
- progress bar

States:

Normal
→ neutral/primary

Approaching limit
→ amber

Exceeded
→ red

The UI must communicate the state immediately.

==================================================
# P2 — EMPTY STATES
==================================================

Create one reusable EmptyState component.

Use it consistently for:

- no transactions
- no debts
- no savings goals
- no history
- no statistics

Each empty state should contain:

icon
title
short explanation
primary action

Avoid giant decorative circles unless they actually improve the UI.

==================================================
# P2 — LOADING / ERROR STATES
==================================================

Create consistent:

- loading state
- error state
- retry state
- success feedback
- delete confirmation
- undo where appropriate

Do not rely only on SnackBars for important actions.

==================================================
# P2 — RTL / ARABIC
==================================================

Audit every screen for RTL.

Check:

- icons
- arrows
- padding
- alignment
- text direction
- numbers
- currency
- progress bars
- charts
- navigation

Back arrow must point correctly for RTL.

Do not use left/right padding when start/end is appropriate.

Prefer:

EdgeInsetsDirectional
AlignmentDirectional
PositionedDirectional

where applicable.

==================================================
# P2 — RESPONSIVE DESIGN
==================================================

The app must work on:

- small Android phones
- standard Android phones
- large phones
- Nothing Phone devices

Do not design only for the screenshot dimensions.

Avoid fixed heights where content can vary.

Avoid overflow.

Test:

- 320-360 px width
- 390-430 px width

==================================================
# P2 — ACCESSIBILITY
==================================================

Interactive controls must have:

- minimum ~48x48 touch target
- readable text
- sufficient contrast
- semantic labels for icons

Do not rely on color alone.

For example:

Expense = red + expense icon/text

Income = green + income icon/text

==================================================
# P2 — CLEAN ARCHITECTURE
==================================================

Create reusable widgets where appropriate:

TwelaSectionHeader
TwelaCard
TwelaPrimaryButton
TwelaSecondaryButton
TwelaIconButton
TwelaAmountField
TwelaSegmentedControl
TwelaEmptyState
TwelaBottomSheet
TwelaSettingTile
TwelaTransactionTile
TwelaProgressIndicator

Do not create hundreds of tiny abstractions.

Only extract genuinely repeated UI.

==================================================
# THEME
==================================================

Centralize semantic colors.

Do not hardcode:

Color(0xFF...)

throughout every screen.

The theme must support:

Light
Dark

and dynamic accent selection where the existing application supports it.

Important:

The selected user accent color is NOT the same thing as semantic transaction
colors.

Semantic transaction colors must remain recognizable.

==================================================
# DO NOT BREAK EXISTING FUNCTIONALITY
==================================================

Before modifying UI, verify these systems remain functional:

- transaction creation
- transaction editing
- transaction deletion
- balance updates
- wallet propagation
- debt creation
- debt payment
- debt deletion/reversal
- savings creation
- savings deposits
- savings deletion/reversal
- monthly budget
- daily budget
- statistics
- notifications
- theme settings
- glass mode
- haptic feedback
- Glyph setting
- data export
- onboarding
- update checker

==================================================
# TESTING
==================================================

After implementation run:

flutter analyze

flutter test

flutter build apk --release --no-tree-shake-icons

Fix ALL analyzer errors/warnings introduced by this work.

Then manually verify every screen.

Test navigation:

Home
→ History
→ Debts
→ Statistics
→ Settings

Test +:

Income
Expense
Give debt
Receive debt
Savings

Test transaction:

Create expense
Create income
Edit expense
Delete expense
Verify balance

Test debt:

Create debt
Open detail
Record payment
Verify remaining
Delete/reverse

Test savings:

Create goal
Add saving
Verify progress
Delete/reverse

Test:

Light mode
Dark mode

Test:

small screen
normal screen

Test:

Arabic RTL

==================================================
# VISUAL ACCEPTANCE CRITERIA
==================================================

The final application must NOT look like the current screenshot.

Specifically:

1. Nothing touches or overlaps the Android status bar.
2. Bottom navigation never overlaps content.
3. + never covers another navigation item.
4. Expense screen is RED.
5. Income screen is GREEN.
6. Debt is visually distinct.
7. Savings is visually distinct.
8. Settings is clean and organized.
9. Savings screen has the same design language as the rest of the app.
10. Debt screen has the same design language.
11. History has clear edit/delete controls.
12. Add transaction is easy to use with one hand.
13. Typography is consistent.
14. Card radii are consistent.
15. Spacing is consistent.
16. Light/Dark mode both look intentional.
17. No overflow.
18. No hidden critical actions.
19. No loss of existing functionality.
20. No "temporary" UI.

==================================================
# IMPORTANT FINAL RULE
==================================================

Do NOT stop after fixing the screenshot.

This task is a UI/UX reconstruction of the entire Twela application.

The goal is:

ONE DESIGN SYSTEM
+
ONE NAVIGATION SYSTEM
+
CONSISTENT SCREENS
+
PRESERVED BUSINESS LOGIC
+
NO LAYOUT OVERLAPS
+
PREMIUM MOBILE UX
