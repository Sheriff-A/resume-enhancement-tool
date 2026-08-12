SET check_function_bodies = false;
COMMENT ON SCHEMA "public" IS 'standard public schema';
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE TYPE "public"."resume_style" AS ENUM ('technical', 'modern');
ALTER TYPE "public"."resume_style" OWNER TO "postgres";
COMMENT ON TYPE "public"."resume_style" IS 'List of Pre-Defined Resume Styles';
CREATE TYPE "public"."skill_type" AS ENUM ('hard', 'soft', 'other');
ALTER TYPE "public"."skill_type" OWNER TO "postgres";
COMMENT ON TYPE "public"."skill_type" IS 'Type of Skill under User Profiles';
CREATE OR REPLACE FUNCTION "public"."add_profile_on_user_signup"() RETURNS "trigger" LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public' AS $$ BEGIN
INSERT INTO public.profiles (user_id, name, email, created_at)
VALUES (
        NEW.id,
        coalesce(NEW.raw_user_meta_data->>'name', NEW.email),
        NEW.email,
        now()
    ) ON CONFLICT (user_id) DO NOTHING;
RETURN NEW;
END;
$$;
ALTER FUNCTION "public"."add_profile_on_user_signup"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger" LANGUAGE "plpgsql" AS $$ begin new.updated_at = now();
return new;
end;
$$;
ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."upsert_resume_data"("resume_data" "jsonb") RETURNS "jsonb" LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public' AS $$
DECLARE v_resume_id uuid;
-- resume_record JSONB := resume_data -> 'resume';
resume_record JSONB := resume_data;
experience_records JSONB := resume_data->'experience';
education_records JSONB := resume_data->'education';
project_records JSONB := resume_data->'projects';
v_user_id UUID := (
    SELECT auth.uid()
);
exp_record JSONB;
edu_record JSONB;
proj_record JSONB;
result JSONB;
BEGIN -- Check if resume exists
IF resume_record->>'id' IS NULL
OR resume_record->>'id' = '' THEN -- Insert new resume
INSERT INTO public.resumes (
        user_id,
        name,
        nickname,
        email,
        phone,
        location,
        portfolio,
        linkedin,
        github,
        skills,
        summary,
        style
    )
VALUES (
        v_user_id,
        resume_record->>'name',
        resume_record->>'nickname',
        resume_record->>'email',
        resume_record->>'phone',
        resume_record->>'location',
        resume_record->>'portfolio',
        resume_record->>'linkedin',
        resume_record->>'github',
        COALESCE(resume_record->'skills', '[]'::jsonb),
        resume_record->>'summary',
        COALESCE(
            (resume_record->>'style')::resume_style,
            'technical'::resume_style
        )
    )
RETURNING id INTO v_resume_id;
ELSE -- Update existing resume
v_resume_id := (resume_record->>'id')::uuid;
-- Verify ownership
IF NOT EXISTS (
    SELECT 1
    FROM public.resumes
    WHERE id = v_resume_id
        AND user_id = v_user_id
) THEN RAISE EXCEPTION 'Access denied: You do not own this resume';
END IF;
UPDATE public.resumes
SET name = resume_record->>'name',
    nickname = resume_record->>'nickname',
    email = resume_record->>'email',
    phone = resume_record->>'phone',
    location = resume_record->>'location',
    portfolio = resume_record->>'portfolio',
    linkedin = resume_record->>'linkedin',
    github = resume_record->>'github',
    skills = COALESCE(resume_record->'skills', '[]'::jsonb),
    summary = resume_record->>'summary',
    style = COALESCE(
        (resume_record->>'style')::resume_style,
        'technical'::resume_style
    ),
    updated_at = NOW()
WHERE id = v_resume_id
    AND user_id = v_user_id;
END IF;
-- Insert new experience records
IF experience_records IS NOT NULL
AND jsonb_array_length(experience_records) > 0 THEN FOR i IN 0..jsonb_array_length(experience_records) - 1 LOOP exp_record := experience_records->i;
IF exp_record->>'id' IS NULL
or exp_record->>'id' = '' THEN -- Insert new experience record
INSERT INTO public.experience (
        resume_id,
        user_id,
        company,
        position,
        location,
        start_date,
        end_date,
        responsibilities
    )
VALUES (
        v_resume_id,
        v_user_id,
        exp_record->>'company',
        exp_record->>'position',
        exp_record->>'location',
        (exp_record->>'start_date')::DATE,
        CASE
            WHEN exp_record->>'end_date' = '' THEN NULL
            ELSE (exp_record->>'end_date')::DATE
        END,
        COALESCE(exp_record->'responsibilities', '[]'::jsonb)
    );
ELSE -- Update existing experience
UPDATE public.experience
SET company = exp_record->>'company',
    position = exp_record->>'position',
    location = exp_record->>'location',
    start_date = (exp_record->>'start_date')::DATE,
    end_date = CASE
        WHEN exp_record->>'end_date' = '' THEN NULL
        ELSE (exp_record->>'end_date')::DATE
    END,
    responsibilities = COALESCE(exp_record->'responsibilities', '[]'::jsonb),
    updated_at = NOW()
WHERE id = (exp_record->>'id')::uuid
    AND resume_id = v_resume_id
    AND user_id = v_user_id;
END IF;
END LOOP;
END IF;
-- Insert new education records
IF education_records IS NOT NULL
AND jsonb_array_length(education_records) > 0 THEN FOR i IN 0..jsonb_array_length(education_records) - 1 LOOP edu_record := education_records->i;
IF edu_record->>'id' IS NULL
or edu_record->>'id' = '' THEN -- Insert new education record
INSERT INTO public.education (
        resume_id,
        user_id,
        certification,
        institution,
        field_of_study,
        start_date,
        end_date,
        location,
        notable_courses,
        awards
    )
VALUES (
        v_resume_id,
        v_user_id,
        edu_record->>'certification',
        edu_record->>'institution',
        edu_record->>'field_of_study',
        (edu_record->>'start_date')::DATE,
        CASE
            WHEN edu_record->>'end_date' = '' THEN NULL
            ELSE (edu_record->>'end_date')::DATE
        END,
        edu_record->>'location',
        COALESCE(edu_record->'notable_courses', '[]'::jsonb),
        COALESCE(edu_record->'awards', '[]'::jsonb)
    );
ELSE -- Update existing education record
UPDATE public.education
SET certification = edu_record->>'certification',
    institution = edu_record->>'institution',
    field_of_study = edu_record->>'field_of_study',
    start_date = (edu_record->>'start_date')::DATE,
    end_date = CASE
        WHEN edu_record->>'end_date' = '' THEN NULL
        ELSE (edu_record->>'end_date')::DATE
    END,
    location = edu_record->>'location',
    notable_courses = COALESCE(edu_record->'notable_courses', '[]'::jsonb),
    awards = COALESCE(edu_record->'awards', '[]'::jsonb),
    updated_at = NOW()
WHERE id = (edu_record->>'id')::uuid
    AND resume_id = v_resume_id
    AND user_id = v_user_id;
END IF;
END LOOP;
END IF;
-- Insert new project records
IF project_records IS NOT NULL
AND jsonb_array_length(project_records) > 0 THEN FOR i IN 0..jsonb_array_length(project_records) - 1 LOOP proj_record := project_records->i;
IF proj_record->>'id' IS NULL
or proj_record->>'id' = '' THEN -- Insert new project record
INSERT INTO public.projects (
        resume_id,
        user_id,
        name,
        url,
        start_date,
        end_date,
        highlights
    )
VALUES (
        v_resume_id,
        v_user_id,
        proj_record->>'name',
        proj_record->>'url',
        (proj_record->>'start_date')::DATE,
        CASE
            WHEN proj_record->>'end_date' = '' THEN NULL
            ELSE (proj_record->>'end_date')::DATE
        END,
        COALESCE(proj_record->'highlights', '[]'::jsonb)
    );
ELSE -- Update existing project record
UPDATE public.projects
SET name = proj_record->>'name',
    url = proj_record->>'url',
    start_date = (proj_record->>'start_date')::DATE,
    end_date = CASE
        WHEN proj_record->>'end_date' = '' THEN NULL
        ELSE (proj_record->>'end_date')::DATE
    END,
    highlights = COALESCE(proj_record->'highlights', '[]'::jsonb),
    updated_at = NOW()
WHERE id = (proj_record->>'id')::uuid
    AND resume_id = v_resume_id
    AND user_id = v_user_id;
END IF;
END LOOP;
END IF;
-- Return result
result := jsonb_build_object(
    'resume_id',
    v_resume_id,
    'status',
    'success',
    'message',
    'Resume data saved successfully'
);
RETURN result;
END;
$$;
ALTER FUNCTION "public"."upsert_resume_data"("resume_data" "jsonb") OWNER TO "postgres";
SET default_tablespace = '';
SET default_table_access_method = "heap";
CREATE TABLE IF NOT EXISTS "public"."education" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "resume_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "certification" "text" NOT NULL,
    "institution" "text" NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date",
    "location" "text",
    "field_of_study" "text",
    "notable_courses" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "awards" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL
);
ALTER TABLE "public"."education" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."experience" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "resume_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "position" "text" NOT NULL,
    "company" "text" NOT NULL,
    "location" "text" NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date",
    "responsibilities" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL
);
ALTER TABLE "public"."experience" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "name" "text" NOT NULL,
    "phone" "text",
    "email" "text" NOT NULL,
    "location" "text",
    "updated_at" timestamp with time zone,
    "portfolio" "text",
    "linkedin" "text",
    "github" "text"
);
ALTER TABLE "public"."profiles" OWNER TO "postgres";
COMMENT ON TABLE "public"."profiles" IS 'User Profiles';
COMMENT ON COLUMN "public"."profiles"."portfolio" IS 'User''s Portfolio Website';
CREATE TABLE IF NOT EXISTS "public"."projects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "resume_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "url" "text",
    "start_date" "date" NOT NULL,
    "end_date" "date",
    "highlights" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL
);
ALTER TABLE "public"."projects" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."resumes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "phone" "text",
    "location" "text",
    "portfolio" "text",
    "summary" "text",
    "linkedin" "text",
    "github" "text",
    "skills" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "is_public" boolean DEFAULT false NOT NULL,
    "style" "public"."resume_style" DEFAULT 'technical'::"public"."resume_style" NOT NULL,
    "nickname" "text" DEFAULT ''::"text" NOT NULL,
    "exp_before_edu" boolean DEFAULT false NOT NULL
);
ALTER TABLE "public"."resumes" OWNER TO "postgres";
COMMENT ON TABLE "public"."resumes" IS 'List of Client Resume Information';
CREATE TABLE IF NOT EXISTS "public"."reviews" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "analysis" "jsonb" NOT NULL,
    "type" "text" NOT NULL,
    "resume_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL
);
ALTER TABLE "public"."reviews" OWNER TO "postgres";
COMMENT ON TABLE "public"."reviews" IS 'Resume Reviews and Advice';
COMMENT ON COLUMN "public"."reviews"."resume_id" IS 'The connected resume';
COMMENT ON COLUMN "public"."reviews"."user_id" IS 'The owner';
ALTER TABLE ONLY "public"."education"
ADD CONSTRAINT "education_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."experience"
ADD CONSTRAINT "experiences_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."profiles"
ADD CONSTRAINT "profile_email_key" UNIQUE ("email");
ALTER TABLE ONLY "public"."profiles"
ADD CONSTRAINT "profile_pkey" PRIMARY KEY ("user_id");
ALTER TABLE ONLY "public"."projects"
ADD CONSTRAINT "projects_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."resumes"
ADD CONSTRAINT "resumes_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."reviews"
ADD CONSTRAINT "reviews_pkey" PRIMARY KEY ("id");
CREATE INDEX "education_resume_id_idx" ON "public"."education" USING "btree" ("resume_id");
CREATE INDEX "education_user_id_idx" ON "public"."education" USING "btree" ("user_id");
CREATE INDEX "experience_resume_id_idx" ON "public"."experience" USING "btree" ("resume_id");
CREATE INDEX "experience_user_id_idx" ON "public"."experience" USING "btree" ("user_id");
CREATE INDEX "projects_resume_id_idx" ON "public"."projects" USING "btree" ("resume_id");
CREATE INDEX "projects_user_id_idx" ON "public"."projects" USING "btree" ("user_id");
CREATE INDEX "resumes_public_idx" ON "public"."resumes" USING "btree" ("is_public");
CREATE INDEX "resumes_user_id_idx" ON "public"."resumes" USING "btree" ("user_id");
CREATE INDEX "reviews_resume_id_idx" ON "public"."reviews" USING "btree" ("resume_id");
CREATE INDEX "reviews_user_id_idx" ON "public"."reviews" USING "btree" ("user_id");
CREATE OR REPLACE TRIGGER "education_updated_at" BEFORE
UPDATE ON "public"."education" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();
CREATE OR REPLACE TRIGGER "experience_updated_at" BEFORE
UPDATE ON "public"."experience" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();
CREATE OR REPLACE TRIGGER "profiles_updated_at" BEFORE
UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();
CREATE OR REPLACE TRIGGER "projects_updated_at" BEFORE
UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();
CREATE OR REPLACE TRIGGER "resumes_updated_at" BEFORE
UPDATE ON "public"."resumes" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();
ALTER TABLE ONLY "public"."education"
ADD CONSTRAINT "education_resume_id_fkey" FOREIGN KEY ("resume_id") REFERENCES "public"."resumes"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."education"
ADD CONSTRAINT "education_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."experience"
ADD CONSTRAINT "experiences_resume_id_fkey" FOREIGN KEY ("resume_id") REFERENCES "public"."resumes"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."experience"
ADD CONSTRAINT "experiences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."profiles"
ADD CONSTRAINT "profile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY "public"."projects"
ADD CONSTRAINT "projects_resume_id_fkey" FOREIGN KEY ("resume_id") REFERENCES "public"."resumes"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."projects"
ADD CONSTRAINT "projects_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."resumes"
ADD CONSTRAINT "resumes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."reviews"
ADD CONSTRAINT "reviews_resume_id_fkey" FOREIGN KEY ("resume_id") REFERENCES "public"."resumes"("id") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY "public"."reviews"
ADD CONSTRAINT "reviews_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("user_id") ON UPDATE CASCADE ON DELETE CASCADE;
CREATE POLICY "Enable delete for users based on user_id" ON "public"."resumes" FOR DELETE TO "authenticated" USING (
    (
        (
            SELECT "auth"."uid"() AS "uid"
        ) = "user_id"
    )
);
CREATE POLICY "Enable insert for authenticated users only" ON "public"."profiles" FOR
INSERT TO "authenticated" WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to view their own data only" ON "public"."education" FOR
SELECT TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable read access for education on public resumes" ON "public"."education" FOR
SELECT USING (
        (
            EXISTS (
                SELECT 1
                FROM "public"."resumes"
                WHERE (
                        ("resumes"."id" = "education"."resume_id")
                        AND ("resumes"."is_public" = true)
                    )
            )
        )
    );
CREATE POLICY "Enable insert for users based on user_id" ON "public"."education" FOR
INSERT TO "authenticated" WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to update their own data only" ON "public"."education" FOR
UPDATE TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    ) WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable delete for users based on user_id" ON "public"."education" FOR DELETE TO "authenticated" USING (
    (
        (
            SELECT "auth"."uid"() AS "uid"
        ) = "user_id"
    )
);
CREATE POLICY "Enable users to view their own data only" ON "public"."experience" FOR
SELECT TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable read access for experience on public resumes" ON "public"."experience" FOR
SELECT USING (
        (
            EXISTS (
                SELECT 1
                FROM "public"."resumes"
                WHERE (
                        ("resumes"."id" = "experience"."resume_id")
                        AND ("resumes"."is_public" = true)
                    )
            )
        )
    );
CREATE POLICY "Enable insert for users based on user_id" ON "public"."experience" FOR
INSERT TO "authenticated" WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to update their own data only" ON "public"."experience" FOR
UPDATE TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    ) WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable delete for users based on user_id" ON "public"."experience" FOR DELETE TO "authenticated" USING (
    (
        (
            SELECT "auth"."uid"() AS "uid"
        ) = "user_id"
    )
);
CREATE POLICY "Enable users to view their own data only" ON "public"."projects" FOR
SELECT TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable read access for projects on public resumes" ON "public"."projects" FOR
SELECT USING (
        (
            EXISTS (
                SELECT 1
                FROM "public"."resumes"
                WHERE (
                        ("resumes"."id" = "projects"."resume_id")
                        AND ("resumes"."is_public" = true)
                    )
            )
        )
    );
CREATE POLICY "Enable insert for users based on user_id" ON "public"."projects" FOR
INSERT TO "authenticated" WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to update their own data only" ON "public"."projects" FOR
UPDATE TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    ) WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable delete for users based on user_id" ON "public"."projects" FOR DELETE TO "authenticated" USING (
    (
        (
            SELECT "auth"."uid"() AS "uid"
        ) = "user_id"
    )
);
CREATE POLICY "Enable users to view their own data only" ON "public"."reviews" FOR
SELECT TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable insert for users based on user_id" ON "public"."reviews" FOR
INSERT TO "authenticated" WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to update their own data only" ON "public"."reviews" FOR
UPDATE TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    ) WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable delete for users based on user_id" ON "public"."reviews" FOR DELETE TO "authenticated" USING (
    (
        (
            SELECT "auth"."uid"() AS "uid"
        ) = "user_id"
    )
);
CREATE POLICY "Enable insert for users based on user_id" ON "public"."resumes" FOR
INSERT TO "authenticated" WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable read access for all users on public resumes" ON "public"."resumes" FOR
SELECT USING (("is_public" = true));
CREATE POLICY "Enable update for users based on user_id" ON "public"."profiles" FOR
UPDATE TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    ) WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to update their own data only" ON "public"."resumes" FOR
UPDATE TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    ) WITH CHECK (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to view their own data only" ON "public"."profiles" FOR
SELECT TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
CREATE POLICY "Enable users to view their own data only" ON "public"."resumes" FOR
SELECT TO "authenticated" USING (
        (
            (
                SELECT "auth"."uid"() AS "uid"
            ) = "user_id"
        )
    );
ALTER TABLE "public"."education" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."experience" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."projects" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."resumes" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;
ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT ALL ON FUNCTION "public"."add_profile_on_user_signup"() TO "anon";
GRANT ALL ON FUNCTION "public"."add_profile_on_user_signup"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_profile_on_user_signup"() TO "service_role";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";
GRANT ALL ON FUNCTION "public"."upsert_resume_data"("resume_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_resume_data"("resume_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_resume_data"("resume_data" "jsonb") TO "service_role";
GRANT ALL ON TABLE "public"."education" TO "anon";
GRANT ALL ON TABLE "public"."education" TO "authenticated";
GRANT ALL ON TABLE "public"."education" TO "service_role";
GRANT ALL ON TABLE "public"."experience" TO "anon";
GRANT ALL ON TABLE "public"."experience" TO "authenticated";
GRANT ALL ON TABLE "public"."experience" TO "service_role";
GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";
GRANT ALL ON TABLE "public"."projects" TO "anon";
GRANT ALL ON TABLE "public"."projects" TO "authenticated";
GRANT ALL ON TABLE "public"."projects" TO "service_role";
GRANT ALL ON TABLE "public"."resumes" TO "anon";
GRANT ALL ON TABLE "public"."resumes" TO "authenticated";
GRANT ALL ON TABLE "public"."resumes" TO "service_role";
GRANT ALL ON TABLE "public"."reviews" TO "anon";
GRANT ALL ON TABLE "public"."reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."reviews" TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON SEQUENCES TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON FUNCTIONS TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public"
GRANT ALL ON TABLES TO "service_role";
drop extension if exists "pg_net";
CREATE TRIGGER user_signup_trigger
AFTER
INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.add_profile_on_user_signup();