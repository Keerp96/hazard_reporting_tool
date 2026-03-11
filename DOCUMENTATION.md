# Workplace Hazard Reporting Tool — Technical Documentation

> **Rails 8.1.2 • Ruby 3.4.8 • Bootstrap 5 • SQLite3**

A full-stack web application for reporting, tracking, and resolving workplace hazards. Employees submit hazard reports from any device; supervisors review, assign, and manage resolution workflows.

---

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [Architecture Overview](#2-architecture-overview)
3. [Technology Stack](#3-technology-stack)
4. [Database Schema](#4-database-schema)
5. [Authentication (Devise)](#5-authentication-devise)
6. [Authorization (Pundit)](#6-authorization-pundit)
7. [Data Models](#7-data-models)
8. [State Machine (AASM)](#8-state-machine-aasm)
9. [Controllers & Routing](#9-controllers--routing)
10. [Views & Layout](#10-views--layout)
11. [Hotwire (Turbo Streams & Stimulus)](#11-hotwire-turbo-streams--stimulus)
12. [Action Mailer (Email Notifications)](#12-action-mailer-email-notifications)
13. [QR Code Integration](#13-qr-code-integration)
14. [CSV & PDF Export](#14-csv--pdf-export)
15. [Dashboard & Charts](#15-dashboard--charts)
16. [Seed Data & Demo Credentials](#16-seed-data--demo-credentials)
17. [Testing (RSpec)](#17-testing-rspec)
18. [File Structure Reference](#18-file-structure-reference)

---

## 1. Getting Started

### Prerequisites

- Ruby 3.4.8+
- Rails 8.1.2
- Node.js & Yarn (for Bootstrap CSS compilation)
- SQLite3

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd hazard_reporting_tool

# Install Ruby dependencies
bundle install

# Install JS/CSS dependencies
yarn install

# Create and migrate the database
rails db:create db:migrate

# Seed demo data
rails db:seed

# Build CSS assets
yarn build:css

# Start the server
bin/dev
```

Visit `http://localhost:3000` and sign in with the demo credentials listed in [Section 16](#16-seed-data--demo-credentials).

---

## 2. Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                       Browser                            │
│  (Bootstrap 5, Turbo Drive/Frames/Streams, Stimulus)     │
└──────────────────────┬───────────────────────────────────┘
                       │
┌──────────────────────▼───────────────────────────────────┐
│                   Rails 8 App                            │
│                                                          │
│  ┌─────────┐  ┌──────────┐  ┌────────────┐              │
│  │ Devise  │  │  Pundit  │  │   AASM     │              │
│  │  Auth   │  │  AuthZ   │  │  Workflow  │              │
│  └─────────┘  └──────────┘  └────────────┘              │
│                                                          │
│  ┌─────────────────────────────────────────────────┐     │
│  │              Controllers                         │     │
│  │  Dashboard • Reports • Comments • Locations      │     │
│  └─────────────────────────────────────────────────┘     │
│                                                          │
│  ┌─────────────────────────────────────────────────┐     │
│  │               Models                             │     │
│  │  User • Report • Comment • Location              │     │
│  └─────────────────────────────────────────────────┘     │
│                                                          │
│  ┌─────────────┐ ┌──────────┐ ┌──────────────────┐      │
│  │ HazardMailer│ │ReportPdf │ │ Active Storage   │      │
│  └─────────────┘ └──────────┘ └──────────────────┘      │
│                                                          │
│  ┌─────────────────────────────────────────────────┐     │
│  │  Solid Queue (Background Jobs — no Redis)        │     │
│  └─────────────────────────────────────────────────┘     │
│                                                          │
└──────────────────────┬───────────────────────────────────┘
                       │
              ┌────────▼────────┐
              │    SQLite3      │
              └─────────────────┘
```

---

## 3. Technology Stack

| Category        | Technology                     | Purpose                                   |
|-----------------|--------------------------------|-------------------------------------------|
| Framework       | Rails 8.1.2                    | Web application framework                 |
| Language        | Ruby 3.4.8                     | Server-side language                      |
| Database        | SQLite3                        | Data persistence (dev/test)               |
| Asset Pipeline  | Propshaft                      | Modern asset pipeline                     |
| JavaScript      | importmap-rails                | ES module imports (no bundler)            |
| CSS             | cssbundling-rails + Bootstrap 5| Styling framework                         |
| Authentication  | Devise 5.x                     | User sign-up/sign-in/confirmation         |
| Authorization   | Pundit 2.x                     | Policy-based access control               |
| State Machine   | AASM 5.x                       | Report workflow lifecycle                 |
| Pagination      | Kaminari 1.x                   | Paginated listing with Bootstrap 4 theme  |
| Search/Filter   | Ransack 4.x                    | Advanced search on reports                |
| Charts          | Chartkick 5.x + Chart.js       | Dashboard visualizations                  |
| Date Grouping   | groupdate                      | Group records by time periods             |
| QR Codes        | RQRCode 3.x                    | SVG QR code generation                    |
| PDF Export      | Prawn + prawn-table             | PDF report generation                     |
| CSV Export      | csv (stdlib gem)                | CSV data export                           |
| File Uploads    | Active Storage                 | Photo attachments on reports              |
| File Validation | active_storage_validations     | Content type & file size checks           |
| Background Jobs | Solid Queue                    | Database-backed job processing (no Redis) |
| Email (dev)     | letter_opener                  | Preview emails in browser                 |
| Testing         | RSpec, FactoryBot, Faker       | Comprehensive test suite                  |
| Testing         | Shoulda Matchers               | One-liner model/association specs         |
| Real-time       | Turbo (Streams/Frames/Drive)   | SPA-like without custom JS               |
| Interactivity   | Stimulus                       | Lightweight JS controllers                |

---

## 4. Database Schema

### Users

| Column                 | Type     | Notes                          |
|------------------------|----------|--------------------------------|
| `id`                   | integer  | Primary key                    |
| `email`                | string   | Unique, Devise default         |
| `encrypted_password`   | string   | Devise default                 |
| `first_name`           | string   | Required                       |
| `last_name`            | string   | Required                       |
| `role`                 | integer  | Enum: 0=employee, 1=supervisor |
| `confirmation_token`   | string   | Devise confirmable             |
| `confirmed_at`         | datetime | Devise confirmable             |
| `confirmation_sent_at` | datetime | Devise confirmable             |
| `reset_password_token` | string   | Devise recoverable             |
| `remember_created_at`  | datetime | Devise rememberable            |
| `created_at`           | datetime |                                |
| `updated_at`           | datetime |                                |

### Reports

| Column        | Type     | Notes                                  |
|---------------|----------|----------------------------------------|
| `id`          | integer  | Primary key                            |
| `title`       | string   | Required, max 200 chars                |
| `description` | text     | Required                               |
| `location`    | string   | Required, indexed                      |
| `severity`    | integer  | Enum: 0=low, 1=medium, 2=high, 3=critical |
| `status`      | integer  | Enum: 0=open … 4=closed, indexed       |
| `reported_at` | datetime | Required                               |
| `reporter_id` | integer  | FK → users, required                   |
| `assignee_id` | integer  | FK → users, optional                   |
| `created_at`  | datetime |                                        |
| `updated_at`  | datetime |                                        |

### Comments

| Column      | Type     | Notes             |
|-------------|----------|-------------------|
| `id`        | integer  | Primary key       |
| `body`      | text     | Required          |
| `report_id` | integer  | FK → reports      |
| `user_id`   | integer  | FK → users        |
| `created_at`| datetime |                   |
| `updated_at`| datetime |                   |

### Locations

| Column      | Type     | Notes                 |
|-------------|----------|-----------------------|
| `id`        | integer  | Primary key           |
| `name`      | string   | Required, unique      |
| `code`      | string   | Required, unique      |
| `created_at`| datetime |                       |
| `updated_at`| datetime |                       |

---

## 5. Authentication (Devise)

Devise is configured with the following modules:

- **database_authenticatable** — email/password sign-in
- **registerable** — self-service sign-up
- **recoverable** — password reset via email
- **rememberable** — "remember me" cookie
- **validatable** — email format & password length
- **confirmable** — email confirmation before access

### Custom Sign-Up Parameters

The `ApplicationController` permits additional fields on sign-up:

```ruby
devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])
devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
```

### User Model

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum :role, { employee: 0, supervisor: 1 }

  has_many :reported_hazards, class_name: "Report", foreign_key: :reporter_id
  has_many :assigned_hazards, class_name: "Report", foreign_key: :assignee_id
  has_many :comments, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
```

---

## 6. Authorization (Pundit)

### ReportPolicy

| Action     | Employee                 | Supervisor |
|------------|--------------------------|------------|
| `index?`   | ✅ (scoped to own)       | ✅ (all)   |
| `show?`    | ✅ own reports only      | ✅ all     |
| `create?`  | ✅                       | ✅         |
| `update?`  | ❌                       | ✅         |
| `destroy?` | ❌                       | ✅         |
| `assign?`  | ❌                       | ✅         |
| `resolve?` | ❌                       | ✅         |
| `export?`  | ✅ (scoped)              | ✅ (all)   |

### Scoped Queries

```ruby
class Scope < ApplicationPolicy::Scope
  def resolve
    if user.supervisor?
      scope.all
    else
      scope.where(reporter_id: user.id)
    end
  end
end
```

### CommentPolicy

| Action     | Owner | Supervisor | Other |
|------------|-------|------------|-------|
| `create?`  | ✅    | ✅         | ✅    |
| `destroy?` | ✅    | ✅         | ❌    |

---

## 7. Data Models

### Report

- **Associations**: `belongs_to :reporter` (User), `belongs_to :assignee` (User, optional), `has_many :comments`, `has_one_attached :photo`
- **Enums**: `severity` (low/medium/high/critical), `status` (open/assigned/in_progress/resolved/closed)
- **Validations**: title (present, ≤200), description (present), location (present), severity (present), reported_at (present), photo (image types, <5MB)
- **Scopes**: `open_reports`, `resolved_reports`, `by_severity`, `by_location`, `recent`, `this_month`
- **Class Methods**: `open_count`, `resolution_rate_this_month`, `traffic_light` (returns :green/:yellow/:red based on open count thresholds)
- **Instance Methods**: `severity_color`, `status_color` (return Bootstrap color class names), `assignee_present?` (AASM guard)
- **Ransack**: Whitelisted searchable attributes and associations

### Comment

- **Associations**: `belongs_to :report`, `belongs_to :user`
- **Validations**: body (present)
- **Default scope**: ordered by `created_at ASC`

### Location

- **Validations**: name (present, unique), code (present, unique)
- **Ransack**: name and code are searchable

---

## 8. State Machine (AASM)

The report workflow is managed by AASM on the `status` column (backed by integer enum):

```
┌──────┐    assign    ┌──────────┐  start_work  ┌─────────────┐
│ OPEN │─────────────→│ ASSIGNED │─────────────→│ IN_PROGRESS │
└──┬───┘              └─────┬────┘              └──────┬──────┘
   │                        │                          │
   │                        │  resolve                 │ resolve
   │                        └──────────┐  ┌────────────┘
   │                                   ▼  ▼
   │                              ┌──────────┐    close    ┌────────┐
   │        reopen                │ RESOLVED │────────────→│ CLOSED │
   │◄─────────────────────────────┴──────────┘             └───┬────┘
   │◄──────────────────────────────────────────────────────────┘
                                  reopen
```

### Events & Guards

| Event        | From                        | To           | Guard/After            |
|--------------|-----------------------------|--------------|------------------------|
| `assign`     | open                        | assigned     | `assignee_present?`    |
| `start_work` | assigned                    | in_progress  | —                      |
| `resolve`    | assigned, in_progress       | resolved     | —                      |
| `close`      | resolved                    | closed       | —                      |
| `reopen`     | resolved, closed            | open         | after: clears assignee |

### Guard Details

The `assign` event uses a guard method `assignee_present?` that returns `true` only when an assignee has been set. If the guard fails, AASM raises `AASM::InvalidTransition`.

---

## 9. Controllers & Routing

### Routes

```ruby
Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end
  root "dashboard#index"

  resources :reports do
    resources :comments, only: [:create, :destroy]
    member do
      patch :assign
      patch :start_work
      patch :resolve
      patch :close
      patch :reopen
      get   :download_pdf
    end
    collection do
      get :export_csv
    end
  end

  resources :locations, only: [:index] do
    member do
      get :qr_code
    end
  end
end
```

### DashboardController

- **Supervisor view**: displays `open_count`, `resolution_rate`, `traffic_light` indicator, charts (by severity, by location, over time), recent reports list, totals
- **Employee view**: displays own reports, personal open/total/resolved counts

### ReportsController

| Action         | HTTP   | Path                              | Description                              |
|----------------|--------|-----------------------------------|------------------------------------------|
| `index`        | GET    | `/reports`                        | Filtered, paginated report listing       |
| `show`         | GET    | `/reports/:id`                    | Report detail with comments & timeline   |
| `new`          | GET    | `/reports/new`                    | New report form (optionally pre-filled)  |
| `create`       | POST   | `/reports`                        | Create report + email notification       |
| `edit`         | GET    | `/reports/:id/edit`               | Edit report form                         |
| `update`       | PATCH  | `/reports/:id`                    | Update report                            |
| `destroy`      | DELETE | `/reports/:id`                    | Delete report (supervisor only)          |
| `assign`       | PATCH  | `/reports/:id/assign`             | Assign to supervisor + email             |
| `start_work`   | PATCH  | `/reports/:id/start_work`         | Transition to in_progress                |
| `resolve`      | PATCH  | `/reports/:id/resolve`            | Mark resolved + email reporter           |
| `close`        | PATCH  | `/reports/:id/close`              | Close resolved report                    |
| `reopen`       | PATCH  | `/reports/:id/reopen`             | Reopen resolved/closed report            |
| `export_csv`   | GET    | `/reports/export_csv`             | Download all reports as CSV              |
| `download_pdf` | GET    | `/reports/:id/download_pdf`       | Download single report as PDF            |

### CommentsController

| Action    | HTTP   | Path                                     | Description                  |
|-----------|--------|------------------------------------------|------------------------------|
| `create`  | POST   | `/reports/:report_id/comments`           | Add comment (Turbo Stream)   |
| `destroy` | DELETE | `/reports/:report_id/comments/:id`       | Remove comment (Turbo Stream)|

### LocationsController

| Action    | HTTP | Path                       | Description                   |
|-----------|------|----------------------------|-------------------------------|
| `index`   | GET  | `/locations`               | List all locations            |
| `qr_code` | GET  | `/locations/:id/qr_code`   | Show QR code for a location   |

---

## 10. Views & Layout

### Application Layout

The main layout (`app/views/layouts/application.html.erb`) includes:

- **Navbar**: Bootstrap 5 navbar with brand logo, navigation links (Dashboard, Reports, Locations), user role badge (Employee/Supervisor), and sign-out button
- **Flash messages**: auto-dismissed Bootstrap alerts for notice/alert
- **Footer**: simple footer with copyright

### Report Views

| View                     | Description                                                       |
|--------------------------|-------------------------------------------------------------------|
| `reports/index.html.erb` | Table listing with Ransack filter sidebar, severity/status badges, Kaminari pagination |
| `reports/show.html.erb`  | Detail card with sidebar (status workflow buttons, assign form, export links), comments section with Turbo Frames, activity timeline |
| `reports/new.html.erb`   | New report form wrapper                                            |
| `reports/edit.html.erb`  | Edit report form wrapper                                           |
| `reports/_form.html.erb` | Shared form partial with location dropdown, severity selector, date picker, photo upload (Stimulus-powered preview), description textarea |

### Comment Views

| View                                | Description                                      |
|-------------------------------------|--------------------------------------------------|
| `comments/_comment.html.erb`        | Comment card with Turbo Frame wrapper, delete button |
| `comments/_form.html.erb`           | Inline comment form                              |
| `comments/create.turbo_stream.erb`  | Turbo Stream response appending new comment       |

### Location Views

| View                          | Description                                 |
|-------------------------------|---------------------------------------------|
| `locations/index.html.erb`    | Grid of location cards with QR code links   |
| `locations/qr_code.html.erb`  | Full-page QR code with location details     |

### Devise Views

Custom Bootstrap-styled views for:
- Sign in (`devise/sessions/new.html.erb`)
- Sign up (`devise/registrations/new.html.erb`)

### Custom Styles

`app/assets/stylesheets/application.bootstrap.scss` extends Bootstrap with:
- `.cursor-pointer` utility
- `.bg-orange` badge color for high-severity reports
- Kaminari pagination integration with Bootstrap classes

---

## 11. Hotwire (Turbo Streams & Stimulus)

### Turbo

- **Turbo Drive**: enabled globally — full-page navigations are seamlessly replaced
- **Turbo Frames**: comments section wrapped in `<turbo-frame id="comments">` for inline CRUD
- **Turbo Streams**: comment creation/deletion updates the DOM without a full page reload via `turbo_stream.append` and `turbo_stream.remove`

### Stimulus Controllers

#### `photo_preview_controller.js`

Provides real-time image preview when a photo is selected in the report form. Validates file size (≤5MB client-side) and displays a thumbnail preview.

**Targets**: `input`, `preview` 
**Actions**: `preview` (on input change)

#### `severity_highlight_controller.js`

Dynamically updates the form's visual indicator when severity is changed. Applies Bootstrap border colors:
- low → green, medium → warning, high → orange, critical → danger

**Targets**: `select`, `container`
**Actions**: `highlight` (on select change)

#### `filter_controller.js`

Auto-submits the Ransack search/filter form after a debounced delay (300ms), enabling real-time filtering of the reports list.

**Actions**: `submit` (on input/change)

---

## 12. Action Mailer (Email Notifications)

All emails are sent asynchronously via `deliver_later` using Solid Queue.

| Mailer Method               | Triggered When               | Recipients                     | Subject Prefix        |
|-----------------------------|------------------------------|--------------------------------|-----------------------|
| `new_report_notification`   | New report created           | All supervisors                | `[HazardTracker]`     |
| `assignment_notification`   | Report assigned to user      | Assigned supervisor            | `[HazardTracker]`     |
| `resolution_notification`   | Report resolved              | Original reporter              | `[HazardTracker]`     |
| `comment_notification`      | New comment added            | Reporter + assignee (minus commenter) | `[HazardTracker]` |

### Development Email Preview

In development, emails are captured by `letter_opener` and opened in the browser instead of being sent. Mailer previews are available at:

```
http://localhost:3000/rails/mailers/hazard_mailer
```

Preview class: `spec/mailers/previews/hazard_mailer_preview.rb`

---

## 13. QR Code Integration

Each location has a unique code (e.g., `warehouse-a`). The QR code feature generates an SVG QR code that encodes a URL pointing to the new report form, pre-filled with the location:

```
/reports/new?location=warehouse-a
```

### How It Works

1. `LocationsController#qr_code` generates the QR code using `RQRCode`
2. The encoded URL uses `new_report_url(location: @location.code)`
3. The QR code is rendered as inline SVG in the view
4. When scanned, users are taken directly to the report form with the location field pre-selected

### Usage

Print QR codes and place them at physical locations around the workplace. Employees scan from any device to quickly file a hazard report for that specific location.

---

## 14. CSV & PDF Export

### CSV Export

**Endpoint**: `GET /reports/export_csv`

Exports all reports the user has access to (respects Pundit scope) as a downloadable CSV file with columns:

| Column      | Content                    |
|-------------|----------------------------|
| ID          | Report ID                  |
| Title       | Report title               |
| Description | Full description           |
| Location    | Location name              |
| Severity    | Titleized severity         |
| Status      | Titleized status           |
| Reporter    | Reporter full name         |
| Assignee    | Assignee name or "Unassigned" |
| Reported At | Formatted datetime         |
| Created At  | Formatted datetime         |

### PDF Export

**Endpoint**: `GET /reports/:id/download_pdf`

Generates a single-report PDF using Prawn with:

- Report header with ID
- Detail table (title, severity, status, location, reporter, assignee, dates)
- Full description text
- All comments with author names and timestamps
- Generation timestamp footer

Service object: `app/services/report_pdf.rb`

---

## 15. Dashboard & Charts

### Supervisor Dashboard

| Widget                  | Description                                     |
|-------------------------|-------------------------------------------------|
| Traffic Light Indicator | 🟢 <5 open, 🟡 5–10 open, 🔴 >10 open          |
| Open Reports Count      | Number of unresolved reports                    |
| Resolution Rate         | % of this month's reports that are resolved     |
| Total Reports           | All-time report count                           |
| Reports This Month      | Current month count                             |
| Severity Pie Chart      | Breakdown by severity (Chartkick pie chart)     |
| Location Bar Chart      | Reports per location (Chartkick bar chart)      |
| Trend Line Chart        | Reports over last 30 days (grouped by day)      |
| Recent Reports Table    | Last 5 reports with status badges               |

### Employee Dashboard

| Widget                  | Description                                     |
|-------------------------|-------------------------------------------------|
| My Open Reports         | Count of own unresolved reports                 |
| My Total Reports        | Count of all own reports                        |
| My Resolved Reports     | Count of own resolved/closed reports            |
| Recent Reports List     | Last 5 of own reports with status               |

Charts are rendered using **Chartkick** (backed by Chart.js via importmap).

---

## 16. Seed Data & Demo Credentials

Run `rails db:seed` to populate:

- **8 Locations**: Office Kitchen, Warehouse A, Parking Lot, Main Lobby, Server Room, Loading Dock, Break Room, Stairwell B
- **5 Users**: 2 supervisors + 3 employees (all pre-confirmed)
- **10 Reports**: varying severities and locations with realistic descriptions
- **Workflow states**: 5 reports advanced through various stages (assigned, in_progress, resolved, closed)
- **7 Comments**: threaded comments on several reports

### Demo Credentials

| Role       | Email                         | Password     |
|------------|-------------------------------|--------------|
| Supervisor | sarah.manager@company.com     | password123  |
| Supervisor | john.lead@company.com         | password123  |
| Employee   | alice.worker@company.com      | password123  |
| Employee   | bob.tech@company.com          | password123  |
| Employee   | carol.ops@company.com         | password123  |

---

## 17. Testing (RSpec)

### Running Tests

```bash
bundle exec rspec                    # Run all specs
bundle exec rspec --format documentation  # Verbose output
bundle exec rspec spec/models/       # Run only model specs
bundle exec rspec spec/requests/     # Run only request specs
```

### Test Suite Summary

| Category       | File                               | Examples | Coverage                                      |
|----------------|------------------------------------|----------|-----------------------------------------------|
| Model          | `spec/models/user_spec.rb`         | 8        | Validations, associations, enum, `#full_name`  |
| Model          | `spec/models/report_spec.rb`       | 24       | Validations, associations, enums, scopes, AASM transitions, class methods, helpers |
| Model          | `spec/models/comment_spec.rb`      | 3        | Validations, associations                      |
| Model          | `spec/models/location_spec.rb`     | 4        | Validations, uniqueness                        |
| Policy         | `spec/policies/report_policy_spec.rb` | 10    | All actions per role, scope filtering          |
| Request        | `spec/requests/reports_spec.rb`    | 15       | CRUD, auth redirects, workflow actions, CSV/PDF export |
| Request        | `spec/requests/comments_spec.rb`   | 4        | Create, destroy, authorization                 |
| Mailer         | `spec/mailers/hazard_mailer_spec.rb` | 9      | All 4 mailer methods, recipients, subjects, body content |
| **Total**      |                                    | **87**   | **All passing ✅**                             |

### Test Configuration

- **FactoryBot**: factories in `spec/factories/` with traits for all model states
- **Shoulda Matchers**: configured for Rails + RSpec in `spec/support/shoulda_matchers.rb`
- **Devise Helpers**: `Devise::Test::IntegrationHelpers` included for request specs via `sign_in`
- **Faker**: used in factories for realistic test data

---

## 18. File Structure Reference

```
hazard_reporting_tool/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       └── application.bootstrap.scss     # Bootstrap + custom styles
│   ├── controllers/
│   │   ├── application_controller.rb          # Pundit, Devise params, error handling
│   │   ├── dashboard_controller.rb            # Dashboard metrics & charts
│   │   ├── reports_controller.rb              # Full CRUD + workflow + export
│   │   ├── comments_controller.rb             # Nested CRUD with Turbo Stream
│   │   └── locations_controller.rb            # Index + QR code generation
│   ├── javascript/
│   │   ├── application.js                     # Chartkick + Chart.js imports
│   │   └── controllers/
│   │       ├── photo_preview_controller.js    # Image preview on upload
│   │       ├── severity_highlight_controller.js # Dynamic severity coloring
│   │       └── filter_controller.js           # Auto-submit search form
│   ├── mailers/
│   │   └── hazard_mailer.rb                   # 4 notification methods
│   ├── models/
│   │   ├── user.rb                            # Devise + roles + associations
│   │   ├── report.rb                          # AASM + enums + scopes + Active Storage
│   │   ├── comment.rb                         # Validations + default scope
│   │   └── location.rb                        # Validations + Ransack
│   ├── policies/
│   │   ├── report_policy.rb                   # Role-based access + scoped queries
│   │   └── comment_policy.rb                  # Owner/supervisor access
│   ├── services/
│   │   └── report_pdf.rb                      # Prawn PDF generator
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb           # Bootstrap layout, navbar, flash
│       ├── dashboard/
│       │   └── index.html.erb                 # Supervisor/employee dashboard
│       ├── reports/
│       │   ├── index.html.erb                 # Filtered list + pagination
│       │   ├── show.html.erb                  # Detail + sidebar + comments
│       │   ├── new.html.erb                   # New report wrapper
│       │   ├── edit.html.erb                  # Edit report wrapper
│       │   └── _form.html.erb                 # Shared form partial
│       ├── comments/
│       │   ├── _comment.html.erb              # Comment card partial
│       │   ├── _form.html.erb                 # Comment form partial
│       │   └── create.turbo_stream.erb        # Turbo Stream append
│       ├── locations/
│       │   ├── index.html.erb                 # QR code grid
│       │   └── qr_code.html.erb               # Single QR code view
│       ├── devise/
│       │   ├── sessions/new.html.erb          # Sign in
│       │   └── registrations/new.html.erb     # Sign up
│       └── hazard_mailer/
│           ├── new_report_notification.html.erb
│           ├── assignment_notification.html.erb
│           ├── resolution_notification.html.erb
│           └── comment_notification.html.erb
├── config/
│   ├── routes.rb                              # All routes defined
│   ├── importmap.rb                           # Chartkick + Chart.js pins
│   └── environments/
│       └── development.rb                     # letter_opener config
├── db/
│   ├── migrate/
│   │   ├── *_devise_create_users.rb           # Users table + confirmable
│   │   ├── *_create_reports.rb                # Reports table + FKs + indexes
│   │   ├── *_create_comments.rb               # Comments table
│   │   ├── *_create_locations.rb              # Locations table
│   │   └── *_create_active_storage_tables.rb  # Active Storage tables
│   └── seeds.rb                               # Demo data (users, reports, comments)
├── spec/
│   ├── rails_helper.rb                        # RSpec config
│   ├── support/
│   │   └── shoulda_matchers.rb                # Shoulda config
│   ├── factories/
│   │   ├── users.rb
│   │   ├── reports.rb
│   │   ├── comments.rb
│   │   └── locations.rb
│   ├── models/
│   │   ├── user_spec.rb
│   │   ├── report_spec.rb
│   │   ├── comment_spec.rb
│   │   └── location_spec.rb
│   ├── policies/
│   │   └── report_policy_spec.rb
│   ├── requests/
│   │   ├── reports_spec.rb
│   │   └── comments_spec.rb
│   └── mailers/
│       ├── hazard_mailer_spec.rb
│       └── previews/
│           └── hazard_mailer_preview.rb
└── Gemfile                                    # All dependencies
```
