# Resume Enhancement Tool

Utilizing OpenAI to take your resume to the next level! Build resumes, get AI-scored reviews against a target role, and share a public, printable version of your resume.

## Tech Stack

- **Framework**: Nuxt 3 (Vue 3, TypeScript)
- **UI**: Nuxt UI, Tailwind CSS
- **State**: Pinia
- **Backend/Auth/DB**: Supabase (Postgres, Auth), run locally via Docker
- **AI**: OpenAI API
- **PDF/Docs**: pdfme, mammoth, pdf-parse, Puppeteer (print-to-PDF)

## Prerequisites

- [Node.js](https://nodejs.org/) 20+ and npm
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (running) — local Supabase runs as Docker containers
- [Supabase CLI](https://supabase.com/docs/guides/cli) — no global install needed, it's invoked via `npx supabase`
- An [OpenAI API key](https://platform.openai.com/api-keys)

## Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Copy the environment example and fill in the values:

   ```bash
   cp .env.example .env
   ```

   | Variable | Description |
   | --- | --- |
   | `PORT` | Port the Nuxt dev server listens on |
   | `NUXT_PUBLIC_SUPABASE_URL` | Local Supabase API URL (`npx supabase start` prints this — defaults to `http://127.0.0.1:54321`) |
   | `NUXT_PUBLIC_SUPABASE_KEY` | Local Supabase anon/public key (printed by `npx supabase start`) |
   | `SUPABASE_SERVICE_KEY` | Local Supabase service role key (printed by `npx supabase start`) |
   | `OPENAI_API_KEY` | Your OpenAI API key, used server-side to score/enhance resumes |

   Since Supabase is running locally, the URL and keys come from your own `npx supabase start` output (or `npx supabase status` afterwards) rather than a hosted project.

## Running Locally

```bash
npm run dev
```

This runs [`scripts/dev.sh`](scripts/dev.sh), which:

1. Starts local Supabase (`npx supabase start`) — spins up Postgres, Auth, Storage, etc. in Docker and applies migrations + [`supabase/seed.sql`](supabase/seed.sql) (this is what creates the sample users below).
2. Regenerates `types/database.types.ts` from the local schema.
3. Starts the Nuxt dev server (`npx nuxt dev`).

Press `Ctrl+C` to stop — this also runs `npx supabase stop` automatically so the Docker containers don't keep running in the background.

The app will be available at `http://localhost:3000` (or whatever `PORT` you set).

> **Note:** [`middleware/00.auth.global.ts`](middleware/00.auth.global.ts) currently bypasses all auth/route protection when `NODE_ENV=development`, so in local dev you can navigate directly to protected pages without signing in first — though you'll still need a session (i.e. sign in) for any page that loads user-specific data from Supabase.

### Other scripts

| Command | Description |
| --- | --- |
| `npm run build` | Production build |
| `npm run generate` | Static site generation |
| `npm run preview` | Preview a production build |
| `npm run lint` / `npm run lint:fix` | Lint (and autofix) |
| `npm run types:generate` | Regenerate `models/supabase/database.types.ts` from the local Supabase schema |
| `npm run tailwind-output` | Build the standalone Tailwind stylesheet used for PDF export (`public/tailwind-pdf.css`) |

## Resetting Local Supabase

To wipe the local database back to a clean state (re-running all migrations and the seed script, which restores the sample users/resumes/reviews):

```bash
npx supabase db reset
```

If Supabase's Docker containers get into a bad state (stuck, port conflicts, etc.), stop and fully remove them, then start fresh:

```bash
npx supabase stop --no-backup
npx supabase start
```

`--no-backup` discards the local database volume instead of preserving it, so this also acts as a full reset if `db reset` alone doesn't fix things. You can check running services and re-print your API URL/keys at any time with:

```bash
npx supabase status
```

## Sample Users

Seeded automatically by `supabase/seed.sql` every time you run `npx supabase db reset` (or start Supabase fresh). All three share the password `Password123!`.

### Maria Delgado
server → shift lead → assistant store manager, Tucson AZ, no college degree, three resumes from 2019 to 2026. Her current resume is the one marked public, so it'll also exercise the public-resume-sharing feature.

- Email: `maria.delgado@example.com`
- Password: `Password123!`

### David Chen
receptionist → administrative assistant → office manager, Columbus OH, a community college associate degree, three resumes from 2018 to 2025.

- Email: `david.chen@example.com`
- Password: `Password123!`

### Aisha Bennett
accounts payable clerk → bookkeeper → staff accountant, Portland OR, an associate degree plus a QuickBooks certification, three resumes from 2019 to 2026.

- Email: `aisha.bennett@example.com`
- Password: `Password123!`

## App Flows / Features

### Authentication (`/login`)
Email/password sign up and sign in via Supabase Auth. Sign up sends a confirmation email whose link redirects to `/confirm`, which waits for the session to become available and then forwards to `/dashboard`. Password reset is also handled through Supabase (`composables/auth.ts`).

### Dashboard (`/dashboard`)
Landing page after login — an overview with stats and recent activity. **Currently all placeholder/sample data** for preview purposes (an in-app banner calls this out); it's not wired up to real resume/review data yet.

### Resumes (`/resume`)
- View all of your resumes, searchable and sortable.
- **Import an existing resume**: upload a file (PDF/DOCX), which is parsed and pre-filled into the resume editor (`server/api/process_resume.post.ts`, `server/api/openai/parse_resume.post.ts`) for you to review before saving.
- **Create a new resume from scratch** (`/resume/new`) using the structured editor (contact info, summary, education, experience, projects, skills).
- **Edit a resume** (`/resume/[resumeId]`) with a live side-by-side preview, choose a visual style/template, and optionally get AI-suggested enhancements to your content.
- **Public sharing**: mark a resume `is_public` to get a shareable, unauthenticated link at `/resume/public/[resumeId]` — a clean, print-optimized view with a "Copy Public Link" and "Print Resume" (browser print-to-PDF) action.

### Reviews / Scoring (`/score`)
- View all of your past reviews, searchable/sortable/filterable by Free vs. Pro.
- **Generate a review**: pick one of your resumes and a target role, then choose:
  - **Basic (Free)** — overall match score, ATS/role-alignment/clarity ratings, top 3 issues, and a one-line career fit signal (`server/api/openai/freemium/score_resume.post.ts`).
  - **Advanced (Pro)** — everything in Basic plus a detailed score breakdown, skill/experience gap analysis, prioritized improvements, career strategy advice, and interview-readiness signals (`server/api/openai/paid/score_resume.post.ts`).
- Each review (`/score/[reviewId]`) shows the full report for that resume/role pairing, with a shortcut to generate a new review from the same resume.

### Settings (`/settings`)
Update your profile: name, email, phone, location, portfolio/LinkedIn/GitHub links.

### Known stubs / in progress
- `/cancel` is a placeholder page (intended for a cancelled-payment flow) — not yet implemented.
- The Dashboard's stats/activity feed is sample data, not live data.
