# Workplace Hazard Reporting Tool

A full-stack web application for reporting, tracking, and resolving workplace hazards. Employees can report hazards from any device, supervisors can review and assign corrective actions, and everyone gets visibility into resolution status.

Built with **Rails 8.1**, **Bootstrap 5**, and **Hotwire** (Turbo + Stimulus).

---

## Features

- **Hazard reporting** — employees submit reports with title, description, location, severity, date, and an optional photo
- **Workflow management** — AASM-powered lifecycle: Open → Assigned → In Progress → Resolved → Closed, with reopen support
- **Role-based access** — employees see only their own reports; supervisors manage all reports
- **Real-time comments** — inline comment threads using Turbo Streams (no page reload)
- **Dashboard** — supervisor view with traffic light indicator, resolution rate, and charts (by severity, location, 30-day trend); employee view with personal stats
- **Email notifications** — on report creation, assignment, resolution, and new comments (letter_opener in development)
- **QR codes** — printable QR codes per location that pre-fill the report form on scan
- **CSV & PDF export** — export all reports as CSV or download individual reports as PDF
- **Search & filtering** — filter reports by title, severity, status, and location with auto-submit
- **Pagination** — Kaminari with Bootstrap theme

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Rails 8.1.2 |
| Language | Ruby 3.4.8 |
| Database | SQLite3 |
| Frontend | Bootstrap 5, Importmap, Hotwire |
| Auth | Devise (with email confirmation) |
| Authorization | Pundit |
| Workflow | AASM |
| Charts | Chartkick + Chart.js |
| QR Codes | RQRCode |
| PDF | Prawn |
| Background Jobs | Solid Queue (no Redis required) |
| Testing | RSpec, FactoryBot, Shoulda Matchers |

## Getting Started

### Prerequisites

- Ruby 3.4.8
- Node.js & Yarn
- SQLite3

### Setup

```bash
git clone https://github.com/your-org/hazard_reporting_tool.git
cd hazard_reporting_tool

bundle install
yarn install

rails db:create db:migrate db:seed
yarn build:css

bin/dev
```

Visit **http://localhost:3000**

### Demo Accounts

| Role | Email | Password |
|---|---|---|
| Supervisor | sarah.manager@company.com | password123 |
| Supervisor | john.lead@company.com | password123 |
| Employee | alice.worker@company.com | password123 |
| Employee | bob.tech@company.com | password123 |
| Employee | carol.ops@company.com | password123 |

The seed data includes 8 locations, 10 reports across all severity levels and workflow states, and 7 comments.

## Running Tests

```bash
bundle exec rspec                         # all specs
bundle exec rspec --format documentation  # verbose output
bundle exec rspec spec/models/            # model specs only
bundle exec rspec spec/requests/          # request specs only
```

**87 examples, 0 failures.**

Test coverage includes: model validations, associations, AASM state transitions, Pundit policy rules, request specs (CRUD, workflow, auth, CSV/PDF export), and mailer specs.

## Report Workflow

```
OPEN → (assign) → ASSIGNED → (start_work) → IN PROGRESS
                                    ↓               ↓
                               (resolve)       (resolve)
                                    └────→ RESOLVED → (close) → CLOSED
                                               ↑
                                          (reopen)
```

Requires an assignee to be set before the `assign` transition. Reopening clears the assignee.

## QR Codes

Navigate to **Locations** to view and print QR codes for each site. Scanning a code opens the report form pre-filled with that location — useful for posting codes on noticeboards or machinery.

## Email Previews

In development, emails open in the browser via `letter_opener`. You can also browse all email templates at:

```
http://localhost:3000/rails/mailers/hazard_mailer
```

## Deployment

The project includes a `Dockerfile` and Kamal deployment configuration (`config/deploy.yml`). Swap SQLite for PostgreSQL for multi-process production deployments.

```bash
bundle exec kamal setup   # first deploy
bundle exec kamal deploy  # subsequent deploys
```

## Security

- CSRF protection enabled (Rails default)
- Pundit policies enforced on all controller actions
- Active Storage validations: photo content type (PNG/JPEG/WebP) and size (< 5 MB)
- Sensitive parameters filtered from logs
- Brakeman static analysis: `bundle exec brakeman`
- Gem audit: `bundle exec bundler-audit`

## License

MIT
