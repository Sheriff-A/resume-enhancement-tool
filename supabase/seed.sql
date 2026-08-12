-- ============================================================================
-- Local demo seed data — Resume Enhancement Tool
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
--
-- Shape note: skills = [{name, type}], and responsibilities/notable_courses/
-- awards/highlights = [{text, last_suggestion?}] per the app's ExtResume
-- types. last_suggestion is transient: it is only present while an AI
-- suggestion is awaiting the user's accept/deny decision. Most items are
-- plain {text}; each person's current resume has one or two items with a
-- pending last_suggestion, to show what an unresolved AI suggestion looks
-- like in the data.
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
    '[{"name":"Customer Service","type":"soft"},{"name":"Cash Handling","type":"hard"},{"name":"POS Systems","type":"hard"},{"name":"Time Management","type":"soft"},{"name":"Teamwork","type":"soft"},{"name":"Food Safety Basics","type":"hard"}]'::jsonb,
    false, 'modern', 'Server Resume (2019)', false
  ),
  (
    '11111111-1111-1111-1111-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111111',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'Maria Delgado', 'maria.delgado@example.com', '(520) 555-0142', 'Tucson, AZ',
    NULL,
    'Retail and food service professional with about four years of experience, including a year and a half leading shifts of four to six employees. Known for staying organized during busy periods and helping resolve customer issues before they become bigger problems.',
    'linkedin.com/in/maria-delgado-520', NULL,
    '[{"name":"Shift Supervision","type":"soft"},{"name":"Scheduling","type":"hard"},{"name":"Inventory Counts","type":"hard"},{"name":"Customer Service","type":"soft"},{"name":"Cash Handling","type":"hard"},{"name":"POS Systems","type":"hard"},{"name":"Conflict Resolution","type":"soft"},{"name":"Onboarding New Staff","type":"soft"}]'::jsonb,
    false, 'modern', 'Shift Lead Resume (2022)', true
  ),
  (
    '11111111-1111-1111-1111-aaaaaaaaaaa3', '11111111-1111-1111-1111-111111111111',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'Maria Delgado', 'maria.delgado@example.com', '(520) 555-0142', 'Tucson, AZ',
    NULL,
    'Retail manager with seven years of combined food service and retail experience, including nearly three years in supervisory and management roles. Comfortable managing a small team, tracking inventory, and keeping a store running smoothly during busy seasons.',
    'linkedin.com/in/maria-delgado-520', NULL,
    '[{"name":"Team Leadership","type":"soft"},{"name":"Inventory Management","type":"hard"},{"name":"Staff Scheduling","type":"hard"},{"name":"Hiring and Onboarding","type":"soft"},{"name":"Customer Service","type":"soft"},{"name":"Loss Prevention Basics","type":"hard"},{"name":"POS Systems","type":"hard"},{"name":"Vendor Communication","type":"soft"}]'::jsonb,
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
    '[{"text":"Took orders and served food for a 40-seat restaurant during breakfast and lunch rushes"},{"text":"Handled cash and card payments and balanced the till at the end of each shift"},{"text":"Helped train two new servers on menu items and table sections"},{"text":"Regularly received positive feedback from regular customers"}]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa2',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'Server', 'Corner Diner', 'Tucson, AZ',
    '2018-06-15', '2019-09-30',
    '[{"text":"Took orders and served food during breakfast and lunch rushes for a 40-seat restaurant"},{"text":"Handled cash and card payments and balanced the till at the end of each shift"},{"text":"Helped train two new servers on menu items and table sections"}]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa2',
    '2022-05-18 09:00:00+00', '2022-05-18 09:00:00+00',
    'Shift Lead', 'Corner Diner', 'Tucson, AZ',
    '2019-10-01', NULL,
    '[{"text":"Oversee four to six staff members per shift, assigning sections and covering breaks"},{"text":"Built the weekly staff schedule and adjusted it around call-outs"},{"text":"Counted the register and prepared the nightly deposit"},{"text":"Stepped in to handle customer complaints when a manager was not available"}]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'Sales Associate', 'TrailMix Outfitters', 'Tucson, AZ',
    '2021-11-08', '2023-04-14',
    '[{"text":"Assisted customers with gear selection for hiking and camping trips"},{"text":"Restocked shelves and helped with twice-yearly full-store inventory counts"},{"text":"Consistently met individual sales goals during the spring and summer season"}]'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
    '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
    'Assistant Store Manager', 'TrailMix Outfitters', 'Tucson, AZ',
    '2023-04-15', NULL,
    '[{"text":"Help manage a team of eight part-time and full-time sales associates"},{"text":"Build the monthly staff schedule and approve time-off requests"},{"text":"Track weekly inventory counts and place reorders for fast-moving items"},{"text":"Adjusted the store order schedule to help cut down on late vendor deliveries","last_suggestion":"Adjusted the store order schedule to cut late vendor deliveries by about 20 percent"},{"text":"Step in for the store manager during vacations and sick days","last_suggestion":"Provide full operational leadership coverage during manager absences"}]'::jsonb
  );

INSERT INTO public.projects (
  user_id, resume_id, created_at, updated_at, name, url,
  start_date, end_date, highlights
) VALUES (
  '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-aaaaaaaaaaa3',
  '2026-02-09 09:00:00+00', '2026-02-09 09:00:00+00',
  'Backroom Inventory Reorganization', NULL,
  '2024-03-01', '2024-05-01',
  '[{"text":"Reorganized the backroom storage layout to group items by category"},{"text":"Cut the time it takes staff to locate reorder stock by roughly a third"},{"text":"Trained the rest of the team on the new system"}]'::jsonb
);

INSERT INTO public.reviews (
  created_at, analysis, type, resume_id, user_id
) VALUES (
  '2026-02-10 09:00:00+00',
  '{
    "meta": {
      "report_type": "paid",
      "role_targeted": "Assistant Store Manager",
      "seniority_estimate": "mid",
      "confidence_level": "high"
    },
    "overall_score": {
      "value": 72,
      "label": "Good foundation with a few clear wins available",
      "explanation": "Your career progression from server to shift lead to assistant manager is easy to follow and shows real growth, but a few bullets are missing the specific numbers that would make your impact easier for a hiring manager to judge at a glance."
    },
    "subscores": {
      "ats_match": { "value": 68, "summary": "Core retail management keywords are present, but a few common terms like inventory management software or POS platform names are missing." },
      "role_alignment": { "value": 81, "summary": "Experience maps closely to typical assistant store manager postings, especially around scheduling, inventory, and staff supervision." },
      "clarity_impact": { "value": 66, "summary": "Bullets describe responsibilities well but under-use specific numbers to show impact." }
    },
    "key_gaps": {
      "missing_skills": ["Inventory Management Software", "Loss Prevention Reporting", "Basic P&L Awareness"],
      "experience_gaps": [
        "No mention of hiring or interviewing experience, even though onboarding is listed",
        "No example of handling a difficult customer escalation beyond day-to-day service"
      ]
    },
    "prioritized_improvements": [
      {
        "priority": "high",
        "title": "Add a specific number to the vendor delivery improvement bullet",
        "impact_score_gain_estimate": 6,
        "reason": "This is your strongest process-improvement example, but without a number it reads like a routine task rather than a measurable win."
      },
      {
        "priority": "medium",
        "title": "Trim the sales associate bullet points now that assistant manager is the more relevant role",
        "impact_score_gain_estimate": 3,
        "reason": "Recruiters spend more time on your most recent, most relevant role, so shorter earlier entries keep attention where it matters."
      },
      {
        "priority": "low",
        "title": "Add a one-line target statement about store size or team size you are looking for next",
        "impact_score_gain_estimate": 2,
        "reason": "Helps a recruiter quickly match you to the right opening without reading the full resume."
      }
    ],
    "career_strategy": {
      "application_advice": [
        "Apply directly to assistant and associate store manager openings rather than general retail postings",
        "Lead with the vendor delivery and inventory reorganization examples in your cover letter, since those show initiative beyond routine duties"
      ],
      "role_targeting_advice": [
        "Target mid-size specialty retail chains similar to your current employer before larger big-box chains, where management tracks are often more structured",
        "Store manager roles are likely one to two years away with continued growth in scheduling and P&L exposure"
      ],
      "market_readiness": "Ready to apply now for assistant store manager roles; would benefit from six months to a year of budget or P&L exposure before targeting full store manager positions."
    },
    "interview_signals": {
      "strengths": [
        "Clear, steady career progression within a single retail path shows reliability",
        "Concrete process-improvement example (backroom reorganization) gives a strong story for behavioral interview questions"
      ],
      "risk_areas": [
        "May be asked about formal budget or P&L experience, which is not yet reflected on the resume",
        "Limited experience managing a full-size store team; be ready to speak to how current team-of-eight experience would scale"
      ]
    },
    "confidence_note": "Based on the resume text provided; verifying actual metrics behind the vendor delivery and reorganization examples would strengthen this analysis further."
  }'::jsonb,
  'paid',
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
    '[{"name":"Microsoft Office","type":"hard"},{"name":"Scheduling Software","type":"hard"},{"name":"Phone Etiquette","type":"soft"},{"name":"Data Entry","type":"hard"},{"name":"Basic Bookkeeping","type":"hard"},{"name":"Customer Service","type":"soft"}]'::jsonb,
    false, 'modern', 'Receptionist Resume (2018)', false
  ),
  (
    '22222222-2222-2222-2222-aaaaaaaaaaa2', '22222222-2222-2222-2222-222222222222',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'David Chen', 'david.chen@example.com', '(614) 555-0176', 'Columbus, OH',
    NULL,
    'Administrative professional with about three years of office experience, including front desk and general administrative support. Comfortable juggling scheduling, correspondence, and vendor coordination without much oversight.',
    'linkedin.com/in/david-chen-cbus', NULL,
    '[{"name":"Microsoft Office","type":"hard"},{"name":"Calendar Management","type":"hard"},{"name":"Vendor Coordination","type":"soft"},{"name":"Data Entry","type":"hard"},{"name":"Basic Bookkeeping","type":"hard"},{"name":"Correspondence Drafting","type":"hard"},{"name":"Customer Service","type":"soft"}]'::jsonb,
    false, 'modern', 'Administrative Assistant Resume (2021)', true
  ),
  (
    '22222222-2222-2222-2222-aaaaaaaaaaa3', '22222222-2222-2222-2222-222222222222',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'David Chen', 'david.chen@example.com', '(614) 555-0176', 'Columbus, OH',
    NULL,
    'Office manager with about seven years of administrative experience, including two years managing office operations and supervising support staff for a small insurance agency. Focused on keeping the office running smoothly so agents can focus on clients.',
    'linkedin.com/in/david-chen-cbus', NULL,
    '[{"name":"Office Operations","type":"hard"},{"name":"Budget Tracking","type":"hard"},{"name":"Staff Supervision","type":"soft"},{"name":"Vendor Contract Management","type":"hard"},{"name":"Onboarding","type":"soft"},{"name":"Microsoft Excel","type":"hard"},{"name":"Calendar Management","type":"hard"},{"name":"Process Improvement","type":"soft"}]'::jsonb,
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
    '[{"text":"Business Communications"},{"text":"Introduction to Bookkeeping"},{"text":"Business Law Basics"}]'::jsonb,
    '[{"text":"Honor Roll, Fall 2017"}]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa2',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'Associate of Applied Science, Business Administration', 'Riverside Community College',
    '2016-09-01', '2018-05-15', 'Columbus, OH', 'Business Administration',
    '[{"text":"Business Communications"},{"text":"Introduction to Bookkeeping"},{"text":"Business Law Basics"}]'::jsonb,
    '[{"text":"Honor Roll, Fall 2017"}]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Associate of Applied Science, Business Administration', 'Riverside Community College',
    '2016-09-01', '2018-05-15', 'Columbus, OH', 'Business Administration',
    '[{"text":"Business Communications"},{"text":"Introduction to Bookkeeping"},{"text":"Business Law Basics"}]'::jsonb,
    '[{"text":"Honor Roll, Fall 2017"}]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Certificate in Office Administration', 'Riverside Community College - Continuing Education',
    '2023-01-10', '2023-05-20', 'Columbus, OH', NULL,
    '[{"text":"Office Budgeting Basics"},{"text":"Business Writing"}]'::jsonb, '[]'::jsonb
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
    '[{"text":"Greet patients and manage the front desk for a two-dentist practice"},{"text":"Schedule and confirm appointments for a full daily calendar"},{"text":"Enter patient information and insurance details into the practice management system"},{"text":"Answer phones and route calls to the right staff member"}]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa2',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'Front Desk Receptionist', 'Bright Smiles Family Dental', 'Columbus, OH',
    '2018-06-04', '2020-01-17',
    '[{"text":"Greeted patients and managed the front desk for a two-dentist practice"},{"text":"Scheduled and confirmed appointments for a full daily calendar"},{"text":"Entered patient information and insurance details into the practice management system"}]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa2',
    '2021-09-14 09:00:00+00', '2021-09-14 09:00:00+00',
    'Administrative Assistant', 'Meridian Insurance Group', 'Columbus, OH',
    '2020-02-03', NULL,
    '[{"text":"Support a team of six insurance agents with scheduling and correspondence"},{"text":"Coordinate with outside vendors for office supplies and equipment maintenance"},{"text":"Draft routine client letters and internal memos"},{"text":"Maintain digital and paper filing for active client policies"}]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Administrative Assistant', 'Meridian Insurance Group', 'Columbus, OH',
    '2020-02-03', '2023-06-30',
    '[{"text":"Supported a team of six insurance agents with scheduling and correspondence"},{"text":"Coordinated with outside vendors for office supplies and equipment maintenance"},{"text":"Maintained digital and paper filing for active client policies"}]'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
    '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
    'Office Manager', 'Meridian Insurance Group', 'Columbus, OH',
    '2023-07-01', NULL,
    '[{"text":"Manage day-to-day office operations for a nine-person branch"},{"text":"Supervise two administrative support staff, including onboarding and scheduling"},{"text":"Track the branch office budget and review monthly expense reports"},{"text":"Negotiated a renewed copier and supply contract that lowered monthly office costs","last_suggestion":"Negotiated a renewed copier and supply contract that lowered monthly office costs by about 8 percent"},{"text":"Point of contact for building management and office equipment vendors"}]'::jsonb
  );

INSERT INTO public.projects (
  user_id, resume_id, created_at, updated_at, name, url,
  start_date, end_date, highlights
) VALUES (
  '22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-aaaaaaaaaaa3',
  '2025-11-03 09:00:00+00', '2025-11-03 09:00:00+00',
  'Digital Filing Transition', NULL,
  '2024-02-01', '2024-06-01',
  '[{"text":"Led the move from paper client files to a shared digital document system for the branch"},{"text":"Trained agents and support staff on the new folder structure and naming conventions"},{"text":"Reduced time spent searching for client documents during the transition period"}]'::jsonb
);

INSERT INTO public.reviews (
  created_at, analysis, type, resume_id, user_id
) VALUES (
  '2025-11-04 09:00:00+00',
  '{
    "meta": {
      "report_type": "freemium",
      "role_targeted": "Office Manager",
      "seniority_estimate": "mid"
    },
    "overall_score": {
      "value": 76,
      "label": "Solid, needs a few targeted fixes"
    },
    "subscores": {
      "ats_match": "medium",
      "role_alignment": "high",
      "clarity_impact": "medium"
    },
    "top_issues": [
      "The copier contract savings line is missing a number, which weakens an otherwise strong bullet",
      "Skills section mixes hard and soft skills together with no grouping, making it harder to scan quickly",
      "Summary does not mention the size of the team or budget you manage"
    ],
    "career_fit_signal": {
      "summary": "Your background points clearly toward office manager and operations coordinator roles at small to mid-size companies."
    },
    "confidence_note": "Based on limited resume text alone; a cover letter or portfolio could sharpen this further."
  }'::jsonb,
  'freemium',
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
    '[{"name":"Microsoft Excel","type":"hard"},{"name":"Data Entry","type":"hard"},{"name":"Accounts Payable Basics","type":"hard"},{"name":"Attention to Detail","type":"soft"},{"name":"QuickBooks (Basic)","type":"hard"}]'::jsonb,
    false, 'modern', 'Accounts Payable Clerk Resume (2019)', false
  ),
  (
    '33333333-3333-3333-3333-aaaaaaaaaaa2', '33333333-3333-3333-3333-333333333333',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Aisha Bennett', 'aisha.bennett@example.com', '(503) 555-0134', 'Portland, OR',
    NULL,
    'Bookkeeper with about four years of accounting experience, including full-cycle bookkeeping for a small dental practice. Comfortable handling payroll, reconciliations, and month-end reporting with minimal supervision.',
    'linkedin.com/in/aisha-bennett-pdx', NULL,
    '[{"name":"QuickBooks Online","type":"hard"},{"name":"Payroll Processing","type":"hard"},{"name":"Accounts Payable and Receivable","type":"hard"},{"name":"Bank Reconciliation","type":"hard"},{"name":"Basic Financial Reporting","type":"hard"},{"name":"Microsoft Excel","type":"hard"}]'::jsonb,
    false, 'modern', 'Bookkeeper Resume (2022)', true
  ),
  (
    '33333333-3333-3333-3333-aaaaaaaaaaa3', '33333333-3333-3333-3333-333333333333',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'Aisha Bennett', 'aisha.bennett@example.com', '(503) 555-0134', 'Portland, OR',
    NULL,
    'Staff accountant with about seven years of bookkeeping and accounting experience, now supporting month-end close and tax season work for multiple small-business clients at a local accounting firm. Comfortable managing several clients at once without losing track of details.',
    'linkedin.com/in/aisha-bennett-pdx', NULL,
    '[{"name":"Month-End Close","type":"hard"},{"name":"Multi-Client Bookkeeping","type":"hard"},{"name":"QuickBooks Online","type":"hard"},{"name":"Payroll Processing","type":"hard"},{"name":"Tax Season Support","type":"hard"},{"name":"Bank Reconciliation","type":"hard"},{"name":"Client Communication","type":"soft"}]'::jsonb,
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
    '[{"text":"Financial Accounting I"},{"text":"Payroll Fundamentals"},{"text":"Business Tax Basics"}]'::jsonb, '[]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa2',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Associate Degree in Accounting', 'Westbrook Community College',
    '2016-09-01', '2018-12-15', 'Portland, OR', 'Accounting',
    '[{"text":"Financial Accounting I"},{"text":"Payroll Fundamentals"},{"text":"Business Tax Basics"}]'::jsonb, '[]'::jsonb
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
    '[{"text":"Financial Accounting I"},{"text":"Payroll Fundamentals"},{"text":"Business Tax Basics"}]'::jsonb, '[]'::jsonb
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
    '[{"text":"Process vendor invoices and match them against purchase orders"},{"text":"Enter and code invoices in the accounting system for a mid-size construction company"},{"text":"Respond to vendor questions about payment status"},{"text":"Assist with the monthly accounts payable aging report"}]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa2',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Accounts Payable Clerk', 'Hallwell Construction Co.', 'Portland, OR',
    '2018-09-10', '2020-06-19',
    '[{"text":"Processed vendor invoices and matched them against purchase orders"},{"text":"Entered and coded invoices in the accounting system"},{"text":"Assisted with the monthly accounts payable aging report"}]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa2',
    '2022-03-07 09:00:00+00', '2022-03-07 09:00:00+00',
    'Bookkeeper', 'Lakeview Family Dentistry', 'Portland, OR',
    '2020-07-06', NULL,
    '[{"text":"Handle full-cycle bookkeeping for a two-dentist practice, including AP, AR, and payroll for fifteen employees"},{"text":"Reconcile bank and credit card statements each month"},{"text":"Prepare basic monthly financial reports for the practice owner"},{"text":"Coordinate with the outside CPA firm during tax season"}]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'Bookkeeper', 'Lakeview Family Dentistry', 'Portland, OR',
    '2020-07-06', '2023-09-15',
    '[{"text":"Handled full-cycle bookkeeping for a two-dentist practice, including AP, AR, and payroll for fifteen employees"},{"text":"Reconciled bank and credit card statements each month"},{"text":"Coordinated with the outside CPA firm during tax season"}]'::jsonb
  ),
  (
    '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
    '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
    'Staff Accountant', 'Coastal Tax and Accounting Partners', 'Portland, OR',
    '2023-10-02', NULL,
    '[{"text":"Manage month-end close for a portfolio of about ten small-business clients"},{"text":"Prepare account reconciliations and basic financial statements for client review"},{"text":"Support the tax team by organizing client records during filing season"},{"text":"Trained one new hire on the firm standard bookkeeping checklist"}]'::jsonb
  );

INSERT INTO public.projects (
  user_id, resume_id, created_at, updated_at, name, url,
  start_date, end_date, highlights
) VALUES (
  '33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-aaaaaaaaaaa3',
  '2026-01-19 09:00:00+00', '2026-01-19 09:00:00+00',
  'Client QuickBooks Migration', NULL,
  '2024-01-08', '2024-04-15',
  '[{"text":"Helped migrate twelve small-business clients from spreadsheets to QuickBooks Online ahead of tax season"},{"text":"Built a standard chart of accounts template used across similar clients"},{"text":"Reduced back-and-forth emails with clients by documenting a simple monthly checklist for them to follow","last_suggestion":"Reduced back-and-forth emails with clients by about half by documenting a simple monthly checklist for them to follow"}]'::jsonb
);

INSERT INTO public.reviews (
  created_at, analysis, type, resume_id, user_id
) VALUES (
  '2026-01-20 09:00:00+00',
  '{
    "meta": {
      "report_type": "paid",
      "role_targeted": "Staff Accountant",
      "seniority_estimate": "mid",
      "confidence_level": "high"
    },
    "overall_score": {
      "value": 78,
      "label": "Strong, detail-oriented resume with a few polish opportunities",
      "explanation": "Consistent use of specific numbers, like client counts and employee counts, makes your experience easy to picture, and the QuickBooks migration project shows initiative beyond routine bookkeeping work."
    },
    "subscores": {
      "ats_match": { "value": 79, "summary": "Strong match on core bookkeeping and accounting keywords, including QuickBooks Online, reconciliation, and payroll." },
      "role_alignment": { "value": 83, "summary": "Experience aligns well with staff accountant postings at small firms and multi-client environments." },
      "clarity_impact": { "value": 74, "summary": "Bullets are specific and easy to follow, though a few could quantify time saved more precisely." }
    },
    "key_gaps": {
      "missing_skills": ["General Ledger Review", "Journal Entries", "Tax Software (e.g. Drake, ProSeries)"],
      "experience_gaps": [
        "No mention of direct client-facing meetings or calls, only email communication",
        "No mention of supervising or reviewing work completed by another bookkeeper"
      ]
    },
    "prioritized_improvements": [
      {
        "priority": "medium",
        "title": "Add a rough estimate of time saved by the new monthly client checklist",
        "impact_score_gain_estimate": 4,
        "reason": "You already quantify the reduction in emails; adding a time estimate would make the business impact even clearer."
      },
      {
        "priority": "medium",
        "title": "Mention what industries your current clients are in, if that varies",
        "impact_score_gain_estimate": 3,
        "reason": "Helps a hiring firm quickly see whether your client mix matches the industries they serve."
      },
      {
        "priority": "low",
        "title": "Add a line about comfort with tax preparation software, if any",
        "impact_score_gain_estimate": 2,
        "reason": "Many staff accountant roles at small firms expect some tax season involvement, and this is not yet addressed."
      }
    ],
    "career_strategy": {
      "application_advice": [
        "Lead with the QuickBooks migration project in your cover letter, since it shows process improvement rather than just day-to-day bookkeeping",
        "Apply to small and mid-size accounting firms and multi-client bookkeeping practices where your current experience is the closest match"
      ],
      "role_targeting_advice": [
        "Senior staff accountant or bookkeeping lead roles are a reasonable next step within one to two years, especially with more general ledger and journal entry exposure",
        "CPA-track roles would likely require additional coursework or certification before being competitive"
      ],
      "market_readiness": "Ready to apply now for staff accountant and senior bookkeeper roles at small to mid-size firms."
    },
    "interview_signals": {
      "strengths": [
        "Steady progression from accounts payable clerk to bookkeeper to staff accountant shows consistent growth",
        "Multi-client experience is a strong signal for public accounting firm interviews"
      ],
      "risk_areas": [
        "Limited exposure to tax preparation specifically, which may come up for firms with a heavy tax season workload",
        "No mention of reviewing or supervising other staff, which could be a gap for senior-level questions"
      ]
    },
    "confidence_note": "Based on the resume text provided; discussing specific software and client industry details in an interview would round out this picture."
  }'::jsonb,
  'paid',
  '33333333-3333-3333-3333-aaaaaaaaaaa3',
  '33333333-3333-3333-3333-333333333333'
);