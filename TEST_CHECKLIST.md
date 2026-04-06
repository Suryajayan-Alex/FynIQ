# Fyniq — Final QA Test Checklist
## "Outsmart your spending." | v1.0.0

### Onboarding
□ Splash screen animates correctly (2.8s auto-advance)
□ Page 1, 2, 3 of onboarding display correctly
□ Continue button advances pages
□ Page 3: name field validation (cannot be empty)
□ "Let's get smart 🚀" saves name and income goal
□ Default categories seeded after onboarding
□ Navigates to dashboard after onboarding

### Dashboard
□ Username shows in header after onboarding
□ Total balance shows correctly (income - expense)
□ Period selector switches: Today / Week / Month / Year
□ Balance toggles hidden/visible with eye icon
□ Spending ring shows category breakdown
□ Budget alert cards show correct percentages
□ Recent transactions list shows last 5
□ Pull-to-refresh updates all data
□ Empty state shows when no transactions
□ Shimmer shows while data loads

### Add Transaction
□ Expense / Income toggle works
□ Numpad digits append correctly
□ Decimal point works (max 2 decimal places)
□ Backspace removes last digit
□ Title field required (shows error if empty)
□ Category selection highlights selected chip
□ "New" category chip opens add category sheet
□ Date picker opens and sets date
□ Note field optional
□ Recurring toggle shows interval options
□ Save shows success overlay and returns to dashboard
□ New transaction appears in recent list immediately

### Analytics
□ Trend line chart renders with data
□ Income vs expense bars render correctly
□ Category bar chart shows top categories
□ Stats cards show biggest spend, active day, avg
□ Filter (All/Expense/Income) filters list correctly
□ Sort changes order of transaction list
□ All transactions grouped by date with headers
□ Period selector synced with dashboard

### Budgets
□ Overall summary card shows total budget health
□ Individual budget cards show progress bars
□ Progress bar color changes: green → orange → red
□ Swipe to delete works with confirmation
□ Empty state shows when no budgets
□ Add Budget: category selection works
□ Add Budget: name auto-fills with category name
□ Add Budget: numpad sets amount correctly
□ Add Budget: period toggle (Weekly/Monthly) works
□ Created budget appears in list immediately

### Settings
□ Profile name shows and is editable
□ Biometric toggle enables correctly
□ Biometric prompts authentication before enabling
□ Reminder toggle enables/disables notifications
□ Reminder time picker saves and schedules notification
□ Manage Categories shows all categories
□ Default categories cannot be deleted
□ Custom categories can be added/deleted
□ Export CSV creates file in Downloads
□ Clear All Data requires typing "DELETE"

### Security
□ Biometric gate shows if biometric enabled
□ Biometric gate auto-triggers authentication
□ Failed auth shows retry message
□ Successful auth navigates to dashboard

### Notifications
□ Daily reminder fires at set time (test with 1 min from now)
□ Budget 75% alert fires when spending crosses 75%
□ Budget 90% alert fires when spending crosses 90%
□ Budget exceeded alert fires when over limit
□ Recurring transaction auto-logs on next app open
□ Auto-log notification shows count

### Performance
□ All screens load without jank
□ Animations run at 60fps (use Flutter DevTools)
□ No memory leaks (provider.autoDispose works)
□ App cold start < 3 seconds
□ Database operations don't block UI

### Design QA
□ Colors match Master Brief palette throughout
□ Glassmorphism cards visible on all screens
□ Bottom nav is floating pill shape
□ FAB is gradient pill with breathing animation
□ Haptic feedback on every interaction
□ Dark theme consistent across all screens
□ Plus Jakarta Sans font used for text
□ Space Grotesk used for all money amounts
□ Status bar transparent with white icons
□ Edge-to-edge display enabled
