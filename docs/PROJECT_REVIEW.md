# Project Review – Centralized Library Management System

**Student:** Saw Pyae Phyo Kyaw (200309) · **Module:** Information Systems Project (NCC / Lancashire, Level 6)
**Reviewed:** 1 November 2026 · **Final deadline:** **30 November 2026, 9am UK time** (4 weeks left)

Sources reviewed: the proposal (28/03/2026), the interim report (26/05/2026), the *ISP Final Report Guidance – Autumn 2026*, and the code in this repository. Everything marked "verified" below was checked by running the app locally.

---

## 1. What the final submission requires

There are **four separate deliverables**. The report is only one of them.

| # | Deliverable | Key requirements |
|---|---|---|
| 1 | **Final report** (65% of module) | About 6,500 words (±10%), not counting appendices. Fixed chapter structure (see §6). Harvard referencing. Signed "Statement and Confirmation of Own Work" as the cover page. |
| 2 | **Product (zip)** | All source code **plus install and run instructions** and **minimum system specifications**. *"If it does not run then it cannot be marked."* |
| 3 | **10-minute presentation/demo** | Video, screencast, or PowerPoint with voice-over. Its stated purpose: *"to demonstrate that you understand what you have built and how it works."* |
| 4 | **Possible viva** | A short online interview, only in special cases. |

**Formatting rules:** A4 portrait, 2.5 cm margins, 11pt sans-serif (Arial), single spacing, 6–12pt between paragraphs, page numbers in the footer, no coloured text outside diagrams, every figure and table labelled "Fig x" / "Table x", heading numbers no deeper than 3 levels (1.2.1). Each chapter starts with a short introduction and ends with a short summary.

---

## 2. What has been done so far

### Documents
- **Proposal:** problem, objectives, scope (AI recommendations are explicitly **excluded**), architecture, ERD, 12-week plan.
- **Interim report:** research (Koha and Libib comparison), technology justification, functional and non-functional requirements, use case diagram, ERD, architecture diagram, 25 UI screenshots, learning reflection, Gantt chart, risks.

### The app (working and fairly complete)
| Area | Status |
|---|---|
| Login / registration, bcrypt password hashing, JWT (8h), three roles (student / librarian / admin) | ✅ Done |
| Book catalogue: add, edit, delete, search, categories (30), 150 seeded books | ✅ Done |
| Borrow workflow: request → approve/reject → return request → return approve | ✅ Done (with a bug, see §4) |
| Overdue detection and fines | ✅ Done (rates are hard-coded, see §4) |
| Dashboard and reports (top books, top borrowers, categories, overdue, monthly trend, low stock) | ✅ Done (monthly trend is broken, see §4) |
| Admin: users, roles, system settings, database backup download | ✅ Done (backup button is broken, see §4) |
| Security: Helmet headers, rate limiting (3 failed logins per 5 minutes), audit log table | ✅ Done |
| **Reservations** (listed in the interim requirements and shown in Figs 12, 18, 25) | ❌ **No reservation feature in the current code** |
| Automated tests | ❌ None |

**Against the proposal's technical objectives:** centralised database ✅ · find/borrow/return ✅ · backups ✅ (manual download only; "automatic backups" was promised) · reports on borrowed and overdue books ✅. **Overall the product meets its core objectives.** What's left is fixing a few bugs, aligning the documents with the code, and writing up.

---

## 3. ⚠️ Inconsistencies between the documents and the code (fix these first)

An examiner who reads the report and then opens the code will spot these, so they matter.

| What the reports say | What the code actually does | What to do |
|---|---|---|
| "**MySQL** Server – primary production database" (proposal and interim, Technology table, "MySQL vs PostgreSQL/SQLite" comparison) | **SQLite** locally (`library.db` via better-sqlite3) and **Turso** (libSQL, a cloud SQLite) when deployed. No MySQL anywhere. | **Don't switch to MySQL.** In the final report, explain it as a design change: *"MySQL was planned; during implementation SQLite/Turso was chosen because it needs no server to install, runs free on Vercel, and keeps the same relational schema and ERD."* Examiners reward honest, justified changes. Mention it in Ch 4 (Design) and Ch 7 (Conclusions). |
| "JSON Ledger Backup Storage" | Doesn't exist. Backups are SQL dump files. | Drop the claim, or describe the SQL backup instead. |
| Reservations are a functional requirement, with screenshots | No reservation routes or tables | Either (a) state honestly that reservations were descoped (good material for Ch 7), or (b) treat the "Request" status as the reservation step. **(a) is the simpler choice.** |
| Proposal excludes AI | `metadata.json` / `.env.example` mention Gemini, which is AI Studio boilerplate. Gemini isn't actually used. | Don't claim AI features. Optionally delete the Gemini lines so nobody gets confused. |
| `ARCHITECTURE.md` mentions React 18, "MARC21/RDA", "Serials & Acquisitions", "Predictive serials" | Mostly database columns with little or no UI | Only claim features that can be **shown in the demo**. |

### Academic-integrity note (important)
- The code was built with **Google AI Studio** (AI-generated). The cover sheet makes him sign *"this is my own work"*. He should **check KBTC/NCC's policy on AI tools** and, if they're allowed, **say openly in the report** (Ch 5, Implementation) that AI Studio was used as a development tool and describe what he did himself: requirements, design, ERD, testing, debugging, and deployment decisions. Hiding it is far riskier than declaring it.
- `INTERIM_REPORT_GUIDE.md` contains ready-written report paragraphs generated by the AI. **Do not paste that text into the final report.** He needs to write it in his own words. It's fine to use it as notes.
- The demo exists *to prove he understands the system*. §5 below is a plain-language explanation he can learn from.

---

## 4. Bugs found (verified by running the app)

Ordered by importance. Each one is a small fix, and each makes good material for Ch 5 ("problems encountered") and Ch 6 (Testing).

### 🔴 B1. Borrow-approve and return-approve show an error in local mode, and the "transaction" doesn't actually protect anything
- **Test:** student requests book 5 → admin clicks Approve.
- **Result:** the API responds `400 {"error":"Transaction function cannot return a promise"}`, **but** the database shows the book stock dropped to 0, the record is `borrowed`, and the log says "Approved". The librarian sees a failure even though the changes were saved, and they weren't saved atomically. The same happens with return-approve.
- **Cause:** the local driver (better-sqlite3) only supports *synchronous* transactions, but `server.ts` passes an `async` function. This is the same transaction code the interim report highlights as the core concurrency solution.
- **On Turso (deployed)** the libSQL driver supports async transactions, so it probably works there. That's why the bug may not have been noticed.
- **Easiest fix:** use the libSQL client for the local database too (`createClient({ url: 'file:library.db' })`). The code already has this path. It's about a 3-line change in `startServer()`, and both environments then behave the same way.
- **Extra improvement (small):** decrement stock with a guarded update (`SET available_quantity = available_quantity - 1 WHERE book_id = ? AND available_quantity > 0`) so the database itself prevents lending the last copy twice. This is a strong point to make in the report.

### 🔴 B2. Anyone can register as admin (a privilege-escalation bug, notable for a *Cyber Security* degree)
- **Test:** `POST /api/auth/register` with `{"role":"admin", ...}` → *"User registered successfully"*, then login returns an **admin token**.
- **Cause:** the server trusts the `role` field sent by the browser. The sign-up form also lets anyone choose "Librarian Staff".
- **Fix:** public sign-up always creates a `student`. Only a logged-in admin can create librarians or admins (the admin "Add Member" screen already exists; give it its own protected route).
- **For the report:** this is a great Ch 6 security test ("found by testing, fixed, retested"). It ties directly to OWASP *Broken Access Control*, which is #1 on the OWASP Top 10.

### 🟠 B3. The "Download backup" button always fails (401)
- `AdminManagement.tsx` uses `window.location.href = '/api/admin/database-dump'`. A browser navigation doesn't send the JWT, so the server replies *"Auth token missing"*. With the token, the endpoint works (verified).
- **Fix:** fetch it with the existing `api` helper (`responseType: 'blob'`) and save the file. About 10 lines.

### 🟠 B4. Monthly trend chart always shows 0, and seeded dates are in the year 58,804
- **Test:** after a borrow in November 2026, `/api/reports/detailed → monthlyTrends` shows November = 0. The config `updatedAt` came back as `+058804-09-03`.
- **Cause:** a seconds-versus-milliseconds mix-up. Drizzle stores timestamps in **seconds**, but the seed code inserts `Date.now()` (**milliseconds**), and the trend SQL divides by 1000.
- **Fix:** use `Math.floor(Date.now()/1000)` in the seed, and `datetime(borrow_date,'unixepoch')` in the trend query.

### 🟡 B5. Admin settings are ignored
- The settings screen saves `DAILY_FINE_RATE = 0.50`, `LOAN_DURATION_DAYS = 14` and `MAX_LOANS_PER_USER = 5`, but the server **hard-codes** a fine rate of 1.50 and a 14-day loan, and never checks the 5-book limit.
- **Fix:** read the values from `system_config` in `updateFines` and `/borrow/request`, and reject a request if the student already has 5 active loans.

### 🟡 B6. A "paid" fine comes back
- `pay-fine` sets the fine to 0, but the next time the history is loaded, `updateFines()` recalculates it while the book is still overdue. Either record the payment separately (`fine_paid`) or only allow payment when the book is returned.

### ⚪ Minor / housekeeping
- A hard-coded fallback `JWT_SECRET` is committed in `server.ts`. Make sure the real one is set in hosting. Mention it in the security section.
- `package.json` name is still `react-example`, and `README.md` is the AI Studio template. Replace it with real install instructions, which the submission requires anyway (see §7).
- No automated tests yet (see §8).

---

## 5. Plain-language explanation: how the app is built, what tools it uses, where it's hosted

He should be able to explain this section **out loud** in the demo. It can also be adapted into Ch 4 and Ch 5.

### 5.1 Architecture: three tiers
```
 ┌──────────────── Browser (client tier) ────────────────┐
 │ React 19 single-page app (Vite build, Tailwind CSS)    │
 │ Pages: Login, Books, My History, Dashboard,            │
 │        Manage Books, Admin, Profile                    │
 │ Saves JWT in localStorage → sends it as                │
 │ "Authorization: Bearer <token>" on every API call      │
 └───────────────────────────┬────────────────────────────┘
                             │ HTTPS + JSON (REST, /api/...)
 ┌───────────────────────────▼────────────────────────────┐
 │ Node.js + Express API (application tier) – server.ts   │
 │  Helmet (security headers) → rate limiter → JWT check  │
 │  → role check (student / librarian / admin) → route    │
 │  ~35 REST endpoints: auth, books, borrow, admin, report│
 │  Drizzle ORM converts TypeScript calls → SQL           │
 └───────────────────────────┬────────────────────────────┘
                             │ SQL
 ┌───────────────────────────▼────────────────────────────┐
 │ Relational database (data tier)                        │
 │  Local dev:  SQLite file  library.db                   │
 │  Deployed:   Turso (cloud libSQL / SQLite)             │
 │  9 tables: users, students, librarians, categories,    │
 │  books, borrow_records, logs, system_config,           │
 │  serial_issues                                         │
 └────────────────────────────────────────────────────────┘
```

### 5.2 Folder structure (what each part does)
| Path | Purpose |
|---|---|
| `src/pages/*.tsx` | One file per screen (Login, StudentHome = catalogue, BorrowHistory, LibrarianBooks, AdminManagement, Dashboard, Profile) |
| `src/components/` | Shared parts: Navbar, AnalyticsWorkspace (charts) |
| `src/App.tsx` | Page routing, plus `PrivateRoute`, which hides pages from the wrong roles |
| `src/lib/api.ts` | Axios helper that attaches the JWT to every request |
| `src/db/librarydb.ts` | **Database schema** (tables and relationships), the source of the ERD |
| `server.ts` | The whole backend: DB connection, table creation and seeding, security middleware, all API routes |
| `api/index.ts` | A small wrapper so Vercel can run `server.ts` as a serverless function |
| `vercel.json` | Tells Vercel: `/api/*` goes to the backend function, everything else goes to the React app |
| `restore_database.sql` | An auto-generated SQL backup of the database |

### 5.3 Tools and why each one is used
| Tool | Role | One-line justification |
|---|---|---|
| **Google AI Studio** | Development environment / code generation | Speeds up building; he directed the requirements, design and testing |
| **React 19 + Vite** | Front end | Reusable components; fast build |
| **Tailwind CSS** | Styling | Responsive layout without writing custom CSS |
| **Recharts** | Dashboard charts | Ready-made React charts |
| **Node.js + Express** | Back-end REST API | Same language (TypeScript) on both ends; lightweight |
| **TypeScript** | Language | Type checking catches errors before the code runs |
| **Drizzle ORM** | Database access | Type-safe queries; the schema in code matches the ERD |
| **SQLite / Turso (libSQL)** | Database | Relational with transactions; no DB server to install; free cloud tier |
| **bcryptjs** | Password hashing | Passwords are never stored as plain text |
| **jsonwebtoken (JWT)** | Login sessions | Stateless; the token carries the user's role |
| **Helmet, express-rate-limit** | Security | Secure HTTP headers; blocks brute-force logins |
| **Git + GitHub** | Version control | Change history; Vercel deploys from GitHub |

### 5.4 Where it's hosted (**he needs to confirm which one he actually uses**)
The repository is set up for **two** possible hosts:

1. **Google AI Studio → Google Cloud Run.** When an AI Studio app is published, Google runs it in a container on Cloud Run (`.env.example` refers to the "Cloud Run service URL"). The database is then a local SQLite file inside the container, so **data can be lost whenever the container restarts.**
2. **Vercel + Turso (the setup described in `DEPLOYMENT_GUIDE.md`).** Vercel serves the built React files from its global CDN and runs `api/index.ts` as a **serverless function**. The database is **Turso**, a hosted cloud SQLite whose region (e.g., Singapore) is chosen at setup. Data persists. **This is the setup to describe in the report.** ⚠️ If Turso is *not* connected, the app uses `/tmp/library.db` on Vercel, which is wiped regularly.

For the report, include one deployment diagram (Browser → Vercel CDN / Vercel Function → Turso DB, with regions), plus the environment variables used: `JWT_SECRET`, `TURSO_DATABASE_URL`, `TURSO_AUTH_TOKEN`.

### 5.5 Key flow to explain in the demo: borrowing a book
1. Student clicks **Borrow** → `POST /api/borrow/request` → the server checks the token and role, checks stock, and creates a `borrow_records` row with status `requested`.
2. Librarian clicks **Approve** → `POST /api/borrow/approve/:id` → **inside one transaction**: re-check that stock is > 0, decrement `available_quantity`, set status to `borrowed`, write an audit log entry. If any step fails, everything is rolled back, so two students can never get the last copy.
3. Student requests a return → librarian approves → stock goes up again and the status becomes `returned`.
4. Each time the history is viewed, overdue loans are marked `overdue` and fines are calculated as days late × daily rate.

---

## 6. Final report plan: chapter → existing material → what's still needed

Suggested word budget totals about 6,500.

| Chapter | ~Words | Reuse from interim | Still needed |
|---|---|---|---|
| Abstract | 100 | – | Write last |
| 1 Introduction, Aims & Objectives | 500 | Background, motivation, objectives (copy the objectives **exactly** as in the interim) | One-paragraph summary of each chapter |
| 2 Research | 1,000 | Koha/Libib comparison, technology research | **Evaluate the research methods** (what worked, and what didn't, e.g., if the planned interviews with libraries never happened, say so) |
| 3 Analysis | 700 | Functional/non-functional requirements, use case diagram | Use case descriptions (in an appendix); a simple activity diagram of the borrow flow |
| 4 Design | 1,100 | ERD, architecture diagram | **Justify design decisions**, including the MySQL→SQLite/Turso change; the borrow-status state diagram (requested→borrowed→return_requested→returned / overdue / cancelled); GUI design (wireframes vs final screens); security design (JWT, roles, bcrypt) |
| 5 Implementation | 1,300 | Screenshots | Folder structure (§5.2), key code snippets (transaction, auth middleware), deployment (§5.4), DB seeding, **problems encountered** (B1–B6 make excellent examples), use of AI Studio |
| 6 Testing & Results | 900 | – | Test plan and results table (§8), security tests, browser/mobile tests, and ideally a small user test (2–3 classmates + a short questionnaire in an appendix) |
| 7 Conclusions & Future Work | 900 | – | **The most important chapter for the grade.** Go through each objective: achieved / partly / not, and why (reservations descoped, automatic backup only manual, etc.). Personal learning. Future work: reservations, email reminders, barcode scanning, real automatic backups |
| References | – | Clean up the duplicates (the proposal lists Pressman and Connolly twice) | Harvard format, consistent |
| Appendices | – | Gantt chart | Use case descriptions, test cases, install guide, questionnaire |

---

## 7. Product zip checklist (the product won't be marked if it doesn't run)
- [ ] Replace `README.md` with: what the app is, **minimum specs** (e.g., Windows 10/macOS/Linux, Node.js 20+, 4 GB RAM, Chrome/Edge/Firefox), install steps (`npm install` → `npm run dev` → open http://localhost:3000), and demo logins:
  - Admin: `admin@library.edu` / `admin123`
  - Librarian: `sarah@library.edu` / `password123`
  - Student: `saw@student.edu` / `password123`
- [ ] Include the live URL as well.
- [ ] Zip **without** `node_modules`, `.env` or `library.db`.
- [ ] Test the zip on a **different computer** from scratch.

---

## 8. Ready-made test cases for Chapter 6
Most of these have already been run (results from 1 Nov 2026 are shown). After the fixes, rerun them and record "after fix" results. That gives a strong before-and-after story.

| ID | Test | Expected | Result (1 Nov) |
|---|---|---|---|
| T1 | Login with valid student credentials | Token returned, student dashboard shown | ✅ Pass |
| T2 | Login with wrong password ×4 | 4th attempt blocked for 5 min | (to run) |
| T3 | Student requests an available book | Record `requested` | ✅ Pass |
| T4 | Librarian approves request | Success message; stock −1; status `borrowed` | ❌ Error shown, though data changed (B1) |
| T5 | Two approvals for the last copy | Second one rejected | (rerun after B1 fix) |
| T6 | Return request + approve | Stock +1; status `returned` | ❌ Error (B1) |
| T7 | Register via API with role=admin | Rejected / created as student | ❌ Admin account created (B2) |
| T8 | Student calls admin-only API | 403 Access denied | (to run) |
| T9 | Admin downloads backup | `.sql` file downloaded | ❌ 401 (B3) |
| T10 | Monthly trend after a borrow this month | Current month ≥ 1 | ❌ Shows 0 (B4) |
| T11 | Change fine rate in settings | New rate used for fines | ❌ Ignored (B5) |
| T12 | Overdue book | Status `overdue`, fine = days × rate | (to run) |
| T13 | Passwords in DB | Stored as bcrypt hash | ✅ Pass |
| T14 | Works on mobile width / Chrome / Firefox | Usable layout | (to run) |

---

## 9. Suggested 4-week plan (low effort, highest marks first)

| Week | Tasks |
|---|---|
| **1 (2–8 Nov)** | Fix B1, B2 and B3 (small changes; we can do these together). Confirm which hosting is live; connect Turso if it isn't. Write the new README. |
| **2 (9–15 Nov)** | Fix B4 and B5 (optionally B6). Run all tests in §8 and take screenshots. Short user test with 2–3 people. Start Ch 4 and Ch 5. |
| **3 (16–22 Nov)** | Write Ch 1–3 (mostly reused from the interim), Ch 6, and Ch 7. Draw the new diagrams (deployment, state, activity). |
| **4 (23–29 Nov)** | Abstract, references, formatting check, signed declaration. Record the 10-minute demo (script: problem → architecture §5.1 → live borrow flow §5.5 → admin reports → security → what he'd improve). Test the zip on another PC. **Submit before 30 Nov, 9am UK.** |

**Don't add new features** (reservations, AI, email). Fixing, testing and explaining what already exists will earn more marks with far less risk.
