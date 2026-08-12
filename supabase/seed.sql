-- ============================================================================
-- Local demo seed data — Level Up / Resume Enhancement Tool
-- ============================================================================
-- Runs automatically on `supabase start` (first run) and `supabase db reset`.
-- LOCAL DEVELOPMENT ONLY. Never run this against a hosted/production project —
-- it inserts directly into auth.users with a hand-set password hash, which is
-- a local-only workaround. On a real project, create users through the
-- Admin API (supabase.auth.admin.createUser) instead.
--
-- Demo logins (all three share one password):
--   maria.delgado@example.com   / Password123!   Retail & hospitality -> assistant store manager
--   david.chen@example.com      / Password123!   Administrative support -> office manager
--   aisha.bennett@example.com   / Password123!   Bookkeeping -> staff accountant
--
-- Each account has 3 resumes spanning ~2018-2026, showing believable,
-- average-person career growth: no elite schools, no big-name employers,
-- modest specific accomplishments rather than superstar metrics.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- Auth users + identities (required for local email/password sign-in)
-- ----------------------------------------------------------------------------

INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, confirmation_token, email_change,
  email_change_token_new, recovery_token,
  raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) VALUES
  (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111',
    'authenticated', 'authenticated',
    'maria.delgado@example.com',
    crypt('Password123!', gen_salt('bf')),
    '2019-03-01 12:00:00+00', '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Maria Delgado"}'::jsonb,
    '2019-03-01 12:00:00+00', '2019-03-01 12:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '22222222-2222-2222-2222-222222222222',
    'authenticated', 'authenticated',
    'david.chen@example.com',
    crypt('Password123!', gen_salt('bf')),
    '2018-08-15 12:00:00+00', '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"David Chen"}'::jsonb,
    '2018-08-15 12:00:00+00', '2018-08-15 12:00:00+00'
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '33333333-3333-3333-3333-333333333333',
    'authenticated', 'authenticated',
    'aisha.bennett@example.com',
    crypt('Password123!', gen_salt('bf')),
    '2019-01-15 12:00:00+00', '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"name":"Aisha Bennett"}'::jsonb,
    '2019-01-15 12:00:00+00', '2019-01-15 12:00:00+00'
  );

INSERT INTO auth.identities (
  id, user_id, provider_id, identity_data, provider,
  last_sign_in_at, created_at, updated_at
)
SELECT
  gen_random_uuid(), id, id::text,
  jsonb_build_object('sub', id::text, 'email', email),
  'email', created_at, created_at, created_at
FROM auth.users
WHERE id IN (
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222',
  '33333333-3333-3333-3333-333333333333'
);

-- The signup trigger already created a bare profile row for each user
-- (name + email from raw_user_meta_data). Fill in the rest.

UPDATE public.profiles SET
  phone = '(520) 555-0142',
  location = 'Tucson, AZ',
  created_at = '2019-03-01 12:00:00+00'
WHERE user_id = '11111111-1111-1111-1111-111111111111';

UPDATE public.profiles SET
  phone = '(614) 555-0176',
  location = 'Columbus, OH',
  created_at = '2018-08-15 12:00:00+00'
WHERE user_id = '22222222-2222-2222-2222-222222222222';

UPDATE public.profiles SET
  phone = '(503) 555-0134',
  location = 'Portland, OR',
  created_at = '2019-01-15 12:00:00+00'
WHERE user_id = '33333333-3333-3333-3333-333333333333';


-- ============================================================================
-- MARIA DELGADO — Server -> Shift Lead -> Assistant Store Manager
-- ============================================================================

INSERT INTO public.resumes (
  id, user_id, created_at, updated_at, name, email, phone, location,
  portfolio, summary, linkedin, github, skills, is_public, style,
  nickname, exp_before_edu
) VALUES
  (
    '11111111-1111-1111-1111-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111',
    '2019-03-10 09:00:00+00', '2019-03-10 09:00:00+00',
    'Maria Delgado', 'maria.delgado@example.com', '(520) 555-0142', 'Tucson, AZ',
    NULL,
    'Dependable server with about a year of experience in busy restaurant settings. Comfortable multitasking during peak hours, handling cash and card payments accurately, and staying calm when the dining room gets full. Looking to bring the same reliability to a new role.',
    NULL, NULL,
    '["Customer Service", "Cash Handling", "POS Systems", "Time Management", "Teamwork", "Food Safety Basics"]'::jsonb,
    false, 'modern', 'Server Resume (2019)', false
  ),
  (
    '11111111-1111-1111-1111-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111111',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'Maria Delgado', 'maria.delgado@example.com', '(520) 555-0142', 'Tucson, AZ',
    NULL,
    'Retail and food service professional with about four years of experience, including a year and a half leading shifts of four to six employees. Known for staying organized during busy periods and helping resolve customer issues before they become bigger problems.',
    'linkedin.com/in/maria-delgado-520', NULL,
    '["Shift Supervision", "Scheduling", "Inventory Counts", "Customer Service", "Cash Handling", "POS Systems", "Conflict Resolution", "Onboarding New Staff"]'::jsonb,
    false, 'modern', 'Shift Lead Resume (2022)', true
  ),
  (
    '11111111-1111-1111-1111-aaaaaaaaaaa3', '11111111-1111-1111-1111-111111111111',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'Maria Delgado', 'maria.delgado@example.com', '(520) 555-0142', 'Tucson, AZ',
    NULL,
    'Retail manager with seven years of combined food service and retail experience, including nearly three years in supervisory and management roles. Comfortable managing a small team, tracking inventory, and keeping a store running smoothly during busy seasons.',
    'linkedin.com/in/maria-delgado-520', NULL,
    '["Team Leadership", "Inventory Management", "Staff Scheduling", "Hiring and Onboarding", "Customer Service", "Loss Prevention Basics", "POS Systems", "Vendor Communication"]'::jsonb,
    true, 'modern', 'Assistant Store Manager Resume (2026)', true
  );

INSERT INTO public.education (
  user_id, resume_id, created_at, updated_at, certification, institution,
  start_date, end_date, location, field_of_study, notable_courses, awards
) VALUES
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa1',
    '2019-03-10 09:00:00+00', '2019-03-10 09:00:00+00',
    'High School Diploma', 'Cactus Wren High School',
    '2014-09-01', '2018-06-01', 'Tucson, AZ', NULL, '[]'::jsonb, '[]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa2',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'High School Diploma', 'Cactus Wren High School',
    '2014-09-01', '2018-06-01', 'Tucson, AZ', NULL, '[]'::jsonb, '[]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa2',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'ServSafe Food Handler Certification', 'National Restaurant Association',
    '2019-02-01', NULL, NULL, NULL, '[]'::jsonb, '[]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'High School Diploma', 'Cactus Wren High School',
    '2014-09-01', '2018-06-01', 'Tucson, AZ', NULL, '[]'::jsonb, '[]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'ServSafe Food Handler Certification', 'National Restaurant Association',
    '2019-02-01', NULL, NULL, NULL, '[]'::jsonb, '[]'::jsonb
  );

INSERT INTO public.experience (
  user_id, resume_id, created_at, updated_at, position, company, location,
  start_date, end_date, responsibilities
) VALUES
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa1',
    '2019-03-10 09:00:00+00', '2019-03-10 09:00:00+00',
    'Server', 'Corner Diner', 'Tucson, AZ',
    '2018-06-15', NULL,
    '["Took orders and served food for a 40-seat restaurant during breakfast and lunch rushes", "Handled cash and card payments and balanced the till at the end of each shift", "Helped train two new servers on menu items and table sections", "Regularly received positive feedback from regular customers"]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa2',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'Server', 'Corner Diner', 'Tucson, AZ',
    '2018-06-15', '2019-09-30',
    '["Took orders and served food during breakfast and lunch rushes for a 40-seat restaurant", "Handled cash and card payments and balanced the till at the end of each shift", "Helped train two new servers on menu items and table sections"]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa2',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'Shift Lead', 'Corner Diner', 'Tucson, AZ',
    '2019-10-01', NULL,
    '["Oversee four to six staff members per shift, assigning sections and covering breaks", "Built the weekly staff schedule and adjusted it around call-outs", "Counted the register and prepared the nightly deposit", "Stepped in to handle customer complaints when a manager was not available"]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'Sales Associate', 'TrailMix Outfitters', 'Tucson, AZ',
    '2021-11-08', '2023-04-14',
    '["Assisted customers with gear selection for hiking and camping trips", "Restocked shelves and helped with twice-yearly full-store inventory counts", "Consistently met individual sales goals during the spring and summer season"]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'Assistant Store Manager', 'TrailMix Outfitters', 'Tucson, AZ',
    '2023-04-15', NULL,
    '["Help manage a team of eight part-time and full-time sales associates", "Build the monthly staff schedule and approve time-off requests", "Track weekly inventory counts and place reorders for fast-moving items", "Reduced late vendor deliveries by adjusting the store order schedule", "Step in for the store manager during vacations and sick days"]'::jsonb
  );

INSERT INTO public.projects (
  user_id, resume_id, created_at, updated_at, name, url,
  start_date, end_date, highlights
) VALUES (
  '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
  '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
  'Backroom Inventory Reorganization', NULL,
  '2024-03-01', '2024-05-01',
  '["Reorganized the backroom storage layout to group items by category", "Cut the time it takes staff to locate reorder stock by roughly a third", "Trained the rest of the team on the new system"]'::jsonb
);

INSERT INTO public.reviews (
  created_at, analysis, type, resume_id, user_id
) VALUES (
  '2026-02-10 09:00:00+00',
  '{
    "overall_score": 72,
    "strengths": [
      "Clear progression from server to shift lead to assistant manager makes the career growth easy to follow",
      "The backroom reorganization project gives a concrete example of initiative beyond day-to-day duties"
    ],
    "suggestions": [
      "Add a specific number to the vendor delivery improvement if you can recall or estimate it",
      "Consider trimming the sales associate bullet points now that assistant manager is the most relevant role",
      "A short one-line summary of what kind of store or team size you are looking for next could help focus the resume"
    ]
  }'::jsonb,
  'general',
  '11111111-1111-1111-1111-aaaaaaaaaaa3',
  '11111111-1111-1111-1111-111111111111'
);


-- ============================================================================
-- DAVID CHEN — Receptionist -> Administrative Assistant -> Office Manager
-- ============================================================================

INSERT INTO public.resumes (
  id, user_id, created_at, updated_at, name, email, phone, location,
  portfolio, summary, linkedin, github, skills, is_public, style,
  nickname, exp_before_edu
) VALUES
  (
    '22222222-2222-2222-2222-aaaaaaaaaaa1', '22222222-2222-2222-2222-222222222222',
    '2018-08-20 09:00:00+00', '2018-08-20 09:00:00+00',
    'David Chen', 'david.chen@example.com', '(614) 555-0176', 'Columbus, OH',
    NULL,
    'Recent business administration graduate looking for an entry-level office role. Comfortable with scheduling software, basic bookkeeping tasks, and greeting clients professionally.',
    NULL, NULL,
    '["Microsoft Office", "Scheduling Software", "Phone Etiquette", "Data Entry", "Basic Bookkeeping", "Customer Service"]'::jsonb,
    false, 'modern', 'Receptionist Resume (2018)', false
  ),
  (
    '22222222-2222-2222-2222-aaaaaaaaaaa2', '22222222-2222-2222-2222-222222222222',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'David Chen', 'david.chen@example.com', '(614) 555-0176', 'Columbus, OH',
    NULL,
    'Administrative professional with about three years of office experience, including front desk and general administrative support. Comfortable juggling scheduling, correspondence, and vendor coordination without much oversight.',
    'linkedin.com/in/david-chen-cbus', NULL,
    '["Microsoft Office", "Calendar Management", "Vendor Coordination", "Data Entry", "Basic Bookkeeping", "Correspondence Drafting", "Customer Service"]'::jsonb,
    false, 'modern', 'Administrative Assistant Resume (2021)', true
  ),
  (
    '22222222-2222-2222-2222-aaaaaaaaaaa3', '22222222-2222-2222-2222-222222222222',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'David Chen', 'david.chen@example.com', '(614) 555-0176', 'Columbus, OH',
    NULL,
    'Office manager with about seven years of administrative experience, including two years managing office operations and supervising support staff for a small insurance agency. Focused on keeping the office running smoothly so agents can focus on clients.',
    'linkedin.com/in/david-chen-cbus', NULL,
    '["Office Operations", "Budget Tracking", "Staff Supervision", "Vendor Contract Management", "Onboarding", "Microsoft Excel", "Calendar Management", "Process Improvement"]'::jsonb,
    false, 'technical', 'Office Manager Resume (2025)', true
  );

INSERT INTO public.education (
  user_id, resume_id, created_at, updated_at, certification, institution,
  start_date, end_date, location, field_of_study, notable_courses, awards
) VALUES
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa1',
    '2018-08-20 09:00:00+00', '2018-08-20 09:00:00+00',
    'Associate of Applied Science, Business Administration', 'Riverside Community College',
    '2016-09-01', '2018-05-15', 'Columbus, OH', 'Business Administration',
    '["Business Communications", "Introduction to Bookkeeping", "Business Law Basics"]'::jsonb,
    '["Honor Roll, Fall 2017"]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa2',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'Associate of Applied Science, Business Administration', 'Riverside Community College',
    '2016-09-01', '2018-05-15', 'Columbus, OH', 'Business Administration',
    '["Business Communications", "Introduction to Bookkeeping", "Business Law Basics"]'::jsonb,
    '["Honor Roll, Fall 2017"]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Associate of Applied Science, Business Administration', 'Riverside Community College',
    '2016-09-01', '2018-05-15', 'Columbus, OH', 'Business Administration',
    '["Business Communications", "Introduction to Bookkeeping", "Business Law Basics"]'::jsonb,
    '["Honor Roll, Fall 2017"]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Certificate in Office Administration', 'Riverside Community College - Continuing Education',
    '2023-01-10', '2023-05-20', 'Columbus, OH', NULL,
    '["Office Budgeting Basics", "Business Writing"]'::jsonb, '[]'::jsonb
  );

INSERT INTO public.experience (
  user_id, resume_id, created_at, updated_at, position, company, location,
  start_date, end_date, responsibilities
) VALUES
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa1',
    '2018-08-20 09:00:00+00', '2018-08-20 09:00:00+00',
    'Front Desk Receptionist', 'Bright Smiles Family Dental', 'Columbus, OH',
    '2018-06-04', NULL,
    '["Greet patients and manage the front desk for a two-dentist practice", "Schedule and confirm appointments for a full daily calendar", "Enter patient information and insurance details into the practice management system", "Answer phones and route calls to the right staff member"]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa2',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'Front Desk Receptionist', 'Bright Smiles Family Dental', 'Columbus, OH',
    '2018-06-04', '2020-01-17',
    '["Greeted patients and managed the front desk for a two-dentist practice", "Scheduled and confirmed appointments for a full daily calendar", "Entered patient information and insurance details into the practice management system"]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa2',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'Administrative Assistant', 'Meridian Insurance Group', 'Columbus, OH',
    '2020-02-03', NULL,
    '["Support a team of six insurance agents with scheduling and correspondence", "Coordinate with outside vendors for office supplies and equipment maintenance", "Draft routine client letters and internal memos", "Maintain digital and paper filing for active client policies"]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Administrative Assistant', 'Meridian Insurance Group', 'Columbus, OH',
    '2020-02-03', '2023-06-30',
    '["Supported a team of six insurance agents with scheduling and correspondence", "Coordinated with outside vendors for office supplies and equipment maintenance", "Maintained digital and paper filing for active client policies"]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Office Manager', 'Meridian Insurance Group', 'Columbus, OH',
    '2023-07-01', NULL,
    '["Manage day-to-day office operations for a nine-person branch", "Supervise two administrative support staff, including onboarding and scheduling", "Track the branch office budget and review monthly expense reports", "Negotiated a renewed copier and supply contract that lowered monthly costs slightly", "Point of contact for building management and office equipment vendors"]'::jsonb
  );

INSERT INTO public.projects (
  user_id, resume_id, created_at, updated_at, name, url,
  start_date, end_date, highlights
) VALUES (
  '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
  '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
  'Digital Filing Transition', NULL,
  '2024-02-01', '2024-06-01',
  '["Led the move from paper client files to a shared digital document system for the branch", "Trained agents and support staff on the new folder structure and naming conventions", "Reduced time spent searching for client documents during the transition period"]'::jsonb
);

INSERT INTO public.reviews (
  created_at, analysis, type, resume_id, user_id
) VALUES (
  '2025-11-04 09:00:00+00',
  '{
    "overall_score": 76,
    "strengths": [
      "Strong progression from receptionist to administrative assistant to office manager is easy to follow at a glance",
      "The digital filing project is a good concrete example of leading change, not just maintaining it"
    ],
    "suggestions": [
      "The cost savings from the copier contract renewal could use a rough number or percentage if you have one",
      "Consider adding one line about the size of the budget you track for extra context",
      "A skills section this long is fine, but grouping related skills together could make it easier to scan"
    ]
  }'::jsonb,
  'general',
  '22222222-2222-2222-2222-aaaaaaaaaaa3',
  '22222222-2222-2222-2222-222222222222'
);


-- ============================================================================
-- AISHA BENNETT — Accounts Payable Clerk -> Bookkeeper -> Staff Accountant
-- ============================================================================

INSERT INTO public.resumes (
  id, user_id, created_at, updated_at, name, email, phone, location,
  portfolio, summary, linkedin, github, skills, is_public, style,
  nickname, exp_before_edu
) VALUES
  (
    '33333333-3333-3333-3333-aaaaaaaaaaa1', '33333333-3333-3333-3333-333333333333',
    '2019-01-22 09:00:00+00', '2019-01-22 09:00:00+00',
    'Aisha Bennett', 'aisha.bennett@example.com', '(503) 555-0134', 'Portland, OR',
    NULL,
    'Recent accounting graduate with hands-on experience from a school internship. Detail-oriented and comfortable working with spreadsheets and basic accounting software. Looking for an entry-level accounts payable or bookkeeping role.',
    NULL, NULL,
    '["Microsoft Excel", "Data Entry", "Accounts Payable Basics", "Attention to Detail", "QuickBooks (Basic)"]'::jsonb,
    false, 'modern', 'Accounts Payable Clerk Resume (2019)', false
  ),
  (
    '33333333-3333-3333-3333-aaaaaaaaaaa2', '33333333-3333-3333-3333-333333333333',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Aisha Bennett', 'aisha.bennett@example.com', '(503) 555-0134', 'Portland, OR',
    NULL,
    'Bookkeeper with about four years of accounting experience, including full-cycle bookkeeping for a small dental practice. Comfortable handling payroll, reconciliations, and month-end reporting with minimal supervision.',
    'linkedin.com/in/aisha-bennett-pdx', NULL,
    '["QuickBooks Online", "Payroll Processing", "Accounts Payable and Receivable", "Bank Reconciliation", "Basic Financial Reporting", "Microsoft Excel"]'::jsonb,
    false, 'modern', 'Bookkeeper Resume (2022)', true
  ),
  (
    '33333333-3333-3333-3333-aaaaaaaaaaa3', '33333333-3333-3333-3333-333333333333',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'Aisha Bennett', 'aisha.bennett@example.com', '(503) 555-0134', 'Portland, OR',
    NULL,
    'Staff accountant with about seven years of bookkeeping and accounting experience, now supporting month-end close and tax season work for multiple small-business clients at a local accounting firm. Comfortable managing several clients at once without losing track of details.',
    'linkedin.com/in/aisha-bennett-pdx', NULL,
    '["Month-End Close", "Multi-Client Bookkeeping", "QuickBooks Online", "Payroll Processing", "Tax Season Support", "Bank Reconciliation", "Client Communication"]'::jsonb,
    false, 'technical', 'Staff Accountant Resume (2026)', true
  );

INSERT INTO public.education (
  user_id, resume_id, created_at, updated_at, certification, institution,
  start_date, end_date, location, field_of_study, notable_courses, awards
) VALUES
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa1',
    '2019-01-22 09:00:00+00', '2019-01-22 09:00:00+00',
    'Associate Degree in Accounting', 'Westbrook Community College',
    '2016-09-01', '2018-12-15', 'Portland, OR', 'Accounting',
    '["Financial Accounting I", "Payroll Fundamentals", "Business Tax Basics"]'::jsonb, '[]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa2',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Associate Degree in Accounting', 'Westbrook Community College',
    '2016-09-01', '2018-12-15', 'Portland, OR', 'Accounting',
    '["Financial Accounting I", "Payroll Fundamentals", "Business Tax Basics"]'::jsonb, '[]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa2',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'QuickBooks Online Certification', 'Intuit',
    '2021-04-01', NULL, NULL, NULL, '[]'::jsonb, '[]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'Associate Degree in Accounting', 'Westbrook Community College',
    '2016-09-01', '2018-12-15', 'Portland, OR', 'Accounting',
    '["Financial Accounting I", "Payroll Fundamentals", "Business Tax Basics"]'::jsonb, '[]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'QuickBooks Online Certification', 'Intuit',
    '2021-04-01', NULL, NULL, NULL, '[]'::jsonb, '[]'::jsonb
  );

INSERT INTO public.experience (
  user_id, resume_id, created_at, updated_at, position, company, location,
  start_date, end_date, responsibilities
) VALUES
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa1',
    '2019-01-22 09:00:00+00', '2019-01-22 09:00:00+00',
    'Accounts Payable Clerk', 'Hallwell Construction Co.', 'Portland, OR',
    '2018-09-10', NULL,
    '["Process vendor invoices and match them against purchase orders", "Enter and code invoices in the accounting system for a mid-size construction company", "Respond to vendor questions about payment status", "Assist with the monthly accounts payable aging report"]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa2',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Accounts Payable Clerk', 'Hallwell Construction Co.', 'Portland, OR',
    '2018-09-10', '2020-06-19',
    '["Processed vendor invoices and matched them against purchase orders", "Entered and coded invoices in the accounting system", "Assisted with the monthly accounts payable aging report"]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa2',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Bookkeeper', 'Lakeview Family Dentistry', 'Portland, OR',
    '2020-07-06', NULL,
    '["Handle full-cycle bookkeeping for a two-dentist practice, including AP, AR, and payroll for fifteen employees", "Reconcile bank and credit card statements each month", "Prepare basic monthly financial reports for the practice owner", "Coordinate with the outside CPA firm during tax season"]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'Bookkeeper', 'Lakeview Family Dentistry', 'Portland, OR',
    '2020-07-06', '2023-09-15',
    '["Handled full-cycle bookkeeping for a two-dentist practice, including AP, AR, and payroll for fifteen employees", "Reconciled bank and credit card statements each month", "Coordinated with the outside CPA firm during tax season"]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'Staff Accountant', 'Coastal Tax and Accounting Partners', 'Portland, OR',
    '2023-10-02', NULL,
    '["Manage month-end close for a portfolio of about ten small-business clients", "Prepare account reconciliations and basic financial statements for client review", "Support the tax team by organizing client records during filing season", "Trained one new hire on the firm standard bookkeeping checklist"]'::jsonb
  );

INSERT INTO public.projects (
  user_id, resume_id, created_at, updated_at, name, url,
  start_date, end_date, highlights
) VALUES (
  '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
  '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
  'Client QuickBooks Migration', NULL,
  '2024-01-08', '2024-04-15',
  '["Helped migrate twelve small-business clients from spreadsheets to QuickBooks Online ahead of tax season", "Built a standard chart of accounts template used across similar clients", "Reduced back-and-forth with clients by documenting a simple monthly checklist for them to follow"]'::jsonb
);

INSERT INTO public.reviews (
  created_at, analysis, type, resume_id, user_id
) VALUES (
  '2026-01-20 09:00:00+00',
  '{
    "overall_score": 78,
    "strengths": [
      "The QuickBooks migration project shows initiative that goes beyond routine bookkeeping work",
      "Consistent use of specific numbers, like client counts and employee counts, makes the experience easy to picture"
    ],
    "suggestions": [
      "Consider adding roughly how much time the new monthly checklist saved, even as a rough estimate",
      "The staff accountant summary could mention what industries your current clients are in, if that varies",
      "A short note about comfort with tax software, if any, could round out the skills section for accounting-firm roles"
    ]
  }'::jsonb,
  'general',
  '33333333-3333-3333-3333-aaaaaaaaaaa3',
  '33333333-3333-3333-3333-333333333333'
);