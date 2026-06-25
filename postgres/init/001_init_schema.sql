--
-- PostgreSQL database dump
--

\restrict kbTClOgekOWsc7zWaLCUFVB8Z1yd4cyfIvyczYWi6Aq7WPzNbmv7xNl94pCK6UO

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gpu_token_leases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpu_token_leases (
    id bigint NOT NULL,
    task_id text NOT NULL,
    node_name text NOT NULL,
    gpu_uuid text NOT NULL,
    status text DEFAULT 'leased'::text NOT NULL,
    leased_at timestamp with time zone DEFAULT now() NOT NULL,
    released_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT gpu_token_leases_check CHECK ((((status = 'leased'::text) AND (released_at IS NULL)) OR ((status = ANY (ARRAY['released'::text, 'expired'::text])) AND (released_at IS NOT NULL)))),
    CONSTRAINT gpu_token_leases_status_check CHECK ((status = ANY (ARRAY['leased'::text, 'released'::text, 'expired'::text])))
);


--
-- Name: TABLE gpu_token_leases; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.gpu_token_leases IS 'GPU token 借用紀錄，用於釋放與異常清理。';


--
-- Name: COLUMN gpu_token_leases.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.gpu_token_leases.status IS 'leased/released/expired 三態。';


--
-- Name: gpu_token_leases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpu_token_leases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpu_token_leases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpu_token_leases_id_seq OWNED BY public.gpu_token_leases.id;


--
-- Name: rehab_example_video_annotation_inputs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_example_video_annotation_inputs (
    id integer NOT NULL,
    annotation_id integer NOT NULL,
    key character varying(8) NOT NULL,
    processed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: rehab_example_video_annotation_inputs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_example_video_annotation_inputs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_example_video_annotation_inputs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_example_video_annotation_inputs_id_seq OWNED BY public.rehab_example_video_annotation_inputs.id;


--
-- Name: rehab_example_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_example_videos (
    id bigint NOT NULL,
    uploader_id bigint NOT NULL,
    title character varying(100),
    description text,
    file_name character varying(255) NOT NULL,
    storage_path text NOT NULL,
    related_plan_id bigint,
    related_item_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    encode_status text DEFAULT 'pending'::text NOT NULL,
    encode_started_at timestamp with time zone,
    encode_finished_at timestamp with time zone,
    encode_error text,
    script_status text DEFAULT 'pending'::text NOT NULL,
    script_run_at timestamp with time zone,
    script_error text,
    CONSTRAINT rehab_example_videos_encode_status_check CHECK ((encode_status = ANY (ARRAY['pending'::text, 'processing'::text, 'done'::text, 'failed'::text]))),
    CONSTRAINT rehab_example_videos_script_status_check CHECK ((script_status = ANY (ARRAY['pending'::text, 'processing'::text, 'done'::text, 'failed'::text])))
);


--
-- Name: TABLE rehab_example_videos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.rehab_example_videos IS '上傳範例影片記錄';


--
-- Name: COLUMN rehab_example_videos.uploader_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.uploader_id IS '上傳範例影片人';


--
-- Name: COLUMN rehab_example_videos.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.title IS '影片標題 / 簡述';


--
-- Name: COLUMN rehab_example_videos.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.description IS '影片描述';


--
-- Name: COLUMN rehab_example_videos.file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.file_name IS '最終儲存的檔名（UUID）';


--
-- Name: COLUMN rehab_example_videos.storage_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.storage_path IS '影片實際路徑或 URL';


--
-- Name: COLUMN rehab_example_videos.related_plan_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.related_plan_id IS '可選：關聯某個 rehab_plan';


--
-- Name: COLUMN rehab_example_videos.related_item_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.related_item_id IS '可選：關聯某個 rehab_plan_item';


--
-- Name: COLUMN rehab_example_videos.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.created_at IS '計畫建立時間';


--
-- Name: COLUMN rehab_example_videos.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_example_videos.updated_at IS '計畫更新時間';


--
-- Name: rehab_example_videos_annotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_example_videos_annotations (
    id integer NOT NULL,
    video_id integer NOT NULL,
    status character varying(32) DEFAULT 'pending'::character varying NOT NULL,
    current_frame integer DEFAULT 0 NOT NULL,
    selected_frames jsonb DEFAULT '[]'::jsonb NOT NULL,
    last_key character varying(8),
    result_path text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: rehab_example_videos_annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_example_videos_annotations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_example_videos_annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_example_videos_annotations_id_seq OWNED BY public.rehab_example_videos_annotations.id;


--
-- Name: rehab_example_videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_example_videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_example_videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_example_videos_id_seq OWNED BY public.rehab_example_videos.id;


--
-- Name: rehab_patient_video_artifacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_patient_video_artifacts (
    id bigint NOT NULL,
    video_id bigint NOT NULL,
    category character varying(30) NOT NULL,
    artifact_type character varying(50) NOT NULL,
    file_name character varying(255) NOT NULL,
    storage_path text NOT NULL,
    mime_type character varying(100),
    json_path text,
    meta jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_category_not_blank CHECK ((length(TRIM(BOTH FROM category)) > 0))
);


--
-- Name: rehab_patient_video_artifacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_patient_video_artifacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_patient_video_artifacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_patient_video_artifacts_id_seq OWNED BY public.rehab_patient_video_artifacts.id;


--
-- Name: rehab_patient_video_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_patient_video_reviews (
    id bigint NOT NULL,
    video_id bigint NOT NULL,
    reviewer_id bigint,
    reviewer_name_snapshot text NOT NULL,
    comment text,
    score integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_review_score_range CHECK (((score IS NULL) OR ((score >= 0) AND (score <= 100))))
);


--
-- Name: rehab_patient_video_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_patient_video_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_patient_video_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_patient_video_reviews_id_seq OWNED BY public.rehab_patient_video_reviews.id;


--
-- Name: rehab_plan_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_plan_items (
    id bigint NOT NULL,
    rehab_plan_id bigint NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    sets integer,
    reps integer,
    hold_seconds integer,
    rest_seconds integer,
    example_video_id bigint,
    sort_order integer DEFAULT 0 NOT NULL,
    is_required boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: COLUMN rehab_plan_items.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.id IS '主鍵：計畫動作項目 ID（自動遞增）';


--
-- Name: COLUMN rehab_plan_items.rehab_plan_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.rehab_plan_id IS '復健計畫 ID：對應 rehab_plans.id（此動作屬於哪個計畫版本）';


--
-- Name: COLUMN rehab_plan_items.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.title IS '動作名稱：例如「膝關節伸展」、「直抬腿」';


--
-- Name: COLUMN rehab_plan_items.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.description IS '動作說明/注意事項：姿勢要點、禁忌、提醒等';


--
-- Name: COLUMN rehab_plan_items.sets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.sets IS '組數：例如 3 組';


--
-- Name: COLUMN rehab_plan_items.reps; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.reps IS '次數：例如 10 次/組（若是次數型）';


--
-- Name: COLUMN rehab_plan_items.hold_seconds; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.hold_seconds IS '停留秒數：例如 5 秒/次（若是停留型/拉伸）';


--
-- Name: COLUMN rehab_plan_items.rest_seconds; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.rest_seconds IS '組間休息秒數：例如 30 秒';


--
-- Name: COLUMN rehab_plan_items.example_video_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.example_video_id IS '範例影片 ID：可選，對應 rehab_example_videos.id（目前先一個）';


--
-- Name: COLUMN rehab_plan_items.sort_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.sort_order IS '顯示/執行排序：同一計畫底下動作的順序（數字越小越前）';


--
-- Name: COLUMN rehab_plan_items.is_required; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.is_required IS '是否必做：true=必做；false=選做/加做';


--
-- Name: COLUMN rehab_plan_items.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.created_at IS '建立時間：新增此動作項目的時間';


--
-- Name: COLUMN rehab_plan_items.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plan_items.updated_at IS '更新時間：最後修改時間（建議用 trigger 自動更新）';


--
-- Name: rehab_plan_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_plan_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_plan_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_plan_items_id_seq OWNED BY public.rehab_plan_items.id;


--
-- Name: rehab_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_plans (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    created_by bigint NOT NULL,
    diagnosis_record_id bigint,
    created_role character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    parent_plan_id bigint,
    plan_type character varying(30),
    diagnosis text,
    goal_summary text,
    pain_limit integer,
    start_date date,
    end_date date,
    review_due_date date,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: COLUMN rehab_plans.patient_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.patient_id IS '病人 user_id：對應 users.id（病人本人）';


--
-- Name: COLUMN rehab_plans.created_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.created_by IS '建立者 user_id：對應 users.id（醫師/治療師）';


--
-- Name: COLUMN rehab_plans.diagnosis_record_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.diagnosis_record_id IS '來源診斷紀錄 ID：對應 patient_diagnosis_records.id（醫師看診流程建立計畫時用於追溯來源，可為 NULL）';


--
-- Name: COLUMN rehab_plans.created_role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.created_role IS '建立者角色：doctor / therapist（用於快速辨識建立者身份）';


--
-- Name: COLUMN rehab_plans.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.status IS '計畫狀態：draft/active/paused/ended';


--
-- Name: COLUMN rehab_plans.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.is_active IS '是否為目前有效版本：true=目前使用中；false=已停用/被新版本取代';


--
-- Name: COLUMN rehab_plans.version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.version IS '計畫版本：同一計畫可能會被更新並產生新版本';


--
-- Name: COLUMN rehab_plans.parent_plan_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.parent_plan_id IS '父計畫 ID：來源/上一版計畫（複製或延伸而來時使用，可為 NULL）';


--
-- Name: COLUMN rehab_plans.plan_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.plan_type IS '計畫類型：knee/shoulder/general...（自行定義分類）';


--
-- Name: COLUMN rehab_plans.diagnosis; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.diagnosis IS '診斷/問題描述';


--
-- Name: COLUMN rehab_plans.goal_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.goal_summary IS '計畫目標摘要';


--
-- Name: COLUMN rehab_plans.pain_limit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.pain_limit IS '疼痛上限（0~10）：超過此分數建議停止或調整動作';


--
-- Name: COLUMN rehab_plans.start_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.start_date IS '計畫開始日：可選';


--
-- Name: COLUMN rehab_plans.end_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.end_date IS '計畫結束日：可選';


--
-- Name: COLUMN rehab_plans.review_due_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.review_due_date IS '下次回診/評估日：提醒追蹤計畫效果';


--
-- Name: COLUMN rehab_plans.note; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.note IS '其他備註：治療師/醫師補充說明';


--
-- Name: COLUMN rehab_plans.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.created_at IS '建立時間：新增計畫時寫入';


--
-- Name: COLUMN rehab_plans.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_plans.updated_at IS '更新時間：最後修改時間（建議用 trigger 自動更新）';


--
-- Name: rehab_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_plans_id_seq OWNED BY public.rehab_plans.id;


--
-- Name: rehab_user_uploaded_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rehab_user_uploaded_videos (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    rehab_plan_id bigint NOT NULL,
    rehab_plan_item_id bigint NOT NULL,
    file_name character varying(255) NOT NULL,
    storage_path text NOT NULL,
    patient_note text,
    is_processed_2d3d boolean DEFAULT false NOT NULL,
    processed_at_2d3d timestamp with time zone,
    processing_error_2d3d text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_processed_humanpose boolean DEFAULT false NOT NULL,
    processed_at_humanpose timestamp with time zone,
    processing_error_humanpose text,
    is_processing_2d3d boolean NOT NULL,
    processing_task_id_2d3d character varying(255),
    is_processing_humanpose boolean NOT NULL,
    processing_task_id_humanpose character varying(255),
    humanpose_keypoint_total integer,
    humanpose_keypoint_correct_count integer,
    humanpose_score_avg double precision,
    is_transcoding boolean DEFAULT false NOT NULL,
    transcoding_task_id character varying(255) DEFAULT NULL::character varying,
    CONSTRAINT ck_hpose_counts_non_negative CHECK ((((humanpose_keypoint_total IS NULL) OR (humanpose_keypoint_total >= 0)) AND ((humanpose_keypoint_correct_count IS NULL) OR (humanpose_keypoint_correct_count >= 0)))),
    CONSTRAINT ck_processed_at_when_done CHECK (((((is_processed_2d3d = false) AND (processed_at_2d3d IS NULL)) OR ((is_processed_2d3d = true) AND (processed_at_2d3d IS NOT NULL))) AND (((is_processed_humanpose = false) AND (processed_at_humanpose IS NULL)) OR ((is_processed_humanpose = true) AND (processed_at_humanpose IS NOT NULL)))))
);


--
-- Name: COLUMN rehab_user_uploaded_videos.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.user_id IS '病人（使用者）ID：對應 users.id（病人角色/上傳者）';


--
-- Name: COLUMN rehab_user_uploaded_videos.rehab_plan_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.rehab_plan_id IS '復健計畫 ID：必填（對應 rehab_plans.id）';


--
-- Name: COLUMN rehab_user_uploaded_videos.rehab_plan_item_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.rehab_plan_item_id IS '復健動作項目 ID：可選（對應 rehab_plan_items.id）';


--
-- Name: COLUMN rehab_user_uploaded_videos.file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.file_name IS '原始影片最終儲存檔名（建議 UUID.ext，避免同名覆蓋）';


--
-- Name: COLUMN rehab_user_uploaded_videos.storage_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.storage_path IS '原始影片實際存放位置（本機路徑或 URL），供後端/前端取得';


--
-- Name: COLUMN rehab_user_uploaded_videos.patient_note; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.patient_note IS '病人備註/問題描述（疼痛點、今天狀況、想詢問內容等）';


--
-- Name: COLUMN rehab_user_uploaded_videos.is_processed_2d3d; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.is_processed_2d3d IS '是否已完成後端處理（例如：2D/3D 關節影片、分析圖輸出等）';


--
-- Name: COLUMN rehab_user_uploaded_videos.processed_at_2d3d; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.processed_at_2d3d IS '處理完成時間（當 is_processed = true 時必須有值）';


--
-- Name: COLUMN rehab_user_uploaded_videos.processing_error_2d3d; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rehab_user_uploaded_videos.processing_error_2d3d IS '處理失敗原因（失敗時寫入；成功通常為 NULL）';


--
-- Name: rehab_user_uploaded_videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rehab_user_uploaded_videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rehab_user_uploaded_videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rehab_user_uploaded_videos_id_seq OWNED BY public.rehab_user_uploaded_videos.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    role_key character varying(50) NOT NULL,
    role_name character varying(50) NOT NULL,
    description text
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: system_runtime_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_runtime_settings (
    id bigint NOT NULL,
    setting_key text NOT NULL,
    setting_value text NOT NULL,
    value_type text DEFAULT 'int'::text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE system_runtime_settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_runtime_settings IS '系統 runtime 可調參數，覆蓋 settings.yaml 預設值。';


--
-- Name: COLUMN system_runtime_settings.setting_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_runtime_settings.setting_key IS '參數鍵值，程式依 key 讀取。';


--
-- Name: COLUMN system_runtime_settings.setting_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_runtime_settings.setting_value IS '參數值，依 value_type 轉型。';


--
-- Name: system_runtime_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_runtime_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_runtime_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_runtime_settings_id_seq OWNED BY public.system_runtime_settings.id;


--
-- Name: user_audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_audit_log (
    id bigint NOT NULL,
    action character varying(50) NOT NULL,
    reason text,
    performed_by character varying(50),
    snapshot jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    target_user_name character varying(50),
    target_user_account character varying(50)
);


--
-- Name: user_audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_audit_log_id_seq OWNED BY public.user_audit_log.id;


--
-- Name: user_login_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_login_log (
    id integer NOT NULL,
    user_id integer,
    ip character varying(50),
    is_success boolean NOT NULL,
    error_message text,
    user_agent text,
    device_id character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    attempted_user_account character varying(50)
);


--
-- Name: COLUMN user_login_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.id IS '流水號';


--
-- Name: COLUMN user_login_log.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.user_id IS '對應 users.id';


--
-- Name: COLUMN user_login_log.ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.ip IS 'IP 位址';


--
-- Name: COLUMN user_login_log.is_success; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.is_success IS '是否成功登入';


--
-- Name: COLUMN user_login_log.error_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.error_message IS '錯誤原因（Optional）';


--
-- Name: COLUMN user_login_log.user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.user_agent IS '裝置資訊（瀏覽器/系統）';


--
-- Name: COLUMN user_login_log.device_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.device_id IS '裝置識別碼';


--
-- Name: COLUMN user_login_log.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_login_log.created_at IS '建立時間';


--
-- Name: user_login_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_login_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_login_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_login_log_id_seq OWNED BY public.user_login_log.id;


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_sessions (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    session_token_hash character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    revoked_reason character varying(50),
    created_ip character varying(50),
    created_user_agent text,
    last_seen_ip character varying(50),
    last_seen_user_agent text,
    CONSTRAINT ck_user_sessions_expiry CHECK ((expires_at > created_at)),
    CONSTRAINT ck_user_sessions_token_hash_len CHECK ((char_length((session_token_hash)::text) = 64))
);


--
-- Name: TABLE user_sessions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_sessions IS '使用者登入 session 資料表，供 HttpOnly cookie 的 server-side session 驗證使用';


--
-- Name: COLUMN user_sessions.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.id IS 'Session 主鍵 UUID，由後端產生';


--
-- Name: COLUMN user_sessions.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.user_id IS '對應 users.id 的使用者主鍵';


--
-- Name: COLUMN user_sessions.session_token_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.session_token_hash IS 'Session token 的 SHA-256 十六進位雜湊值，不保存明文 token';


--
-- Name: COLUMN user_sessions.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.created_at IS 'Session 建立時間';


--
-- Name: COLUMN user_sessions.last_seen_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.last_seen_at IS '最近一次成功使用該 session 的時間，僅供審計，不作續期依據';


--
-- Name: COLUMN user_sessions.expires_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.expires_at IS 'Session 到期時間，超過後不可再使用';


--
-- Name: COLUMN user_sessions.revoked_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.revoked_at IS 'Session 被主動撤銷的時間；NULL 代表尚未撤銷';


--
-- Name: COLUMN user_sessions.revoked_reason; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.revoked_reason IS 'Session 撤銷原因，由後端控制，例如 logout、expired_cleanup、user_disabled';


--
-- Name: COLUMN user_sessions.created_ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.created_ip IS '建立 session 當下的來源 IP';


--
-- Name: COLUMN user_sessions.created_user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.created_user_agent IS '建立 session 當下的瀏覽器或客戶端資訊';


--
-- Name: COLUMN user_sessions.last_seen_ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.last_seen_ip IS '最近一次成功使用 session 的來源 IP';


--
-- Name: COLUMN user_sessions.last_seen_user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_sessions.last_seen_user_agent IS '最近一次成功使用 session 的瀏覽器或客戶端資訊';


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    user_id character varying(50) NOT NULL,
    user_account character varying(50) NOT NULL,
    user_password_hash character varying(255) NOT NULL,
    user_name character varying(50) NOT NULL,
    email character varying(100),
    identity_no_enc character varying(255),
    phone_1 character varying(20),
    phone_2 character varying(20),
    role_id integer NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    last_login_at timestamp without time zone,
    password_updated_at timestamp without time zone
);


--
-- Name: COLUMN users.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.id IS '系統流水號';


--
-- Name: COLUMN users.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.user_id IS '工號 / 員工代碼';


--
-- Name: COLUMN users.user_account; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.user_account IS '登入帳號';


--
-- Name: COLUMN users.user_password_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.user_password_hash IS '密碼 Argon2id PHC hash。';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.email IS '電子郵件（可選，唯一）';


--
-- Name: COLUMN users.identity_no_enc; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.identity_no_enc IS '身分證字號（AES 加密後存）';


--
-- Name: COLUMN users.role_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.role_id IS '使用者角色（外鍵）關聯 roles.id';


--
-- Name: COLUMN users.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.is_active IS '是否啟用';


--
-- Name: COLUMN users.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.created_at IS '建立時間';


--
-- Name: COLUMN users.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.updated_at IS '最後更新時間';


--
-- Name: COLUMN users.last_login_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.last_login_at IS '最後登入時間';


--
-- Name: COLUMN users.password_updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.password_updated_at IS '密碼更新時間';


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: worker_gpu_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_gpu_state (
    id bigint NOT NULL,
    node_name text NOT NULL,
    gpu_uuid text NOT NULL,
    gpu_index integer NOT NULL,
    gpu_name text,
    memory_total_mb integer NOT NULL,
    memory_used_mb integer NOT NULL,
    memory_free_mb integer NOT NULL,
    utilization_percent integer,
    temperature_c integer,
    token_capacity integer DEFAULT 0 NOT NULL,
    token_leased integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    idle_free_mb integer,
    CONSTRAINT worker_gpu_state_check CHECK ((token_leased <= token_capacity)),
    CONSTRAINT worker_gpu_state_memory_free_mb_check CHECK ((memory_free_mb >= 0)),
    CONSTRAINT worker_gpu_state_memory_total_mb_check CHECK ((memory_total_mb >= 0)),
    CONSTRAINT worker_gpu_state_memory_used_mb_check CHECK ((memory_used_mb >= 0)),
    CONSTRAINT worker_gpu_state_token_capacity_check CHECK ((token_capacity >= 0)),
    CONSTRAINT worker_gpu_state_token_leased_check CHECK ((token_leased >= 0)),
    CONSTRAINT worker_gpu_state_utilization_percent_check CHECK (((utilization_percent >= 0) AND (utilization_percent <= 100)))
);


--
-- Name: TABLE worker_gpu_state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.worker_gpu_state IS '各節點 GPU 最新狀態與 token 容量/使用量。';


--
-- Name: COLUMN worker_gpu_state.token_capacity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker_gpu_state.token_capacity IS '可同時執行任務名額。';


--
-- Name: COLUMN worker_gpu_state.token_leased; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker_gpu_state.token_leased IS '目前被任務占用的名額。';


--
-- Name: worker_gpu_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_gpu_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worker_gpu_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_gpu_state_id_seq OWNED BY public.worker_gpu_state.id;


--
-- Name: worker_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worker_nodes (
    id bigint NOT NULL,
    node_name text NOT NULL,
    host text,
    is_active boolean DEFAULT true NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE worker_nodes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.worker_nodes IS '可執行 Celery 任務的節點清單與心跳資訊。';


--
-- Name: COLUMN worker_nodes.node_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker_nodes.node_name IS '節點唯一識別名稱，建議使用 Celery hostname。';


--
-- Name: COLUMN worker_nodes.last_seen_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.worker_nodes.last_seen_at IS '節點最後回報時間，用於離線判斷。';


--
-- Name: worker_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worker_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worker_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.worker_nodes_id_seq OWNED BY public.worker_nodes.id;


--
-- Name: gpu_token_leases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpu_token_leases ALTER COLUMN id SET DEFAULT nextval('public.gpu_token_leases_id_seq'::regclass);


--
-- Name: rehab_example_video_annotation_inputs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_video_annotation_inputs ALTER COLUMN id SET DEFAULT nextval('public.rehab_example_video_annotation_inputs_id_seq'::regclass);


--
-- Name: rehab_example_videos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_videos ALTER COLUMN id SET DEFAULT nextval('public.rehab_example_videos_id_seq'::regclass);


--
-- Name: rehab_example_videos_annotations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_videos_annotations ALTER COLUMN id SET DEFAULT nextval('public.rehab_example_videos_annotations_id_seq'::regclass);


--
-- Name: rehab_patient_video_artifacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_patient_video_artifacts ALTER COLUMN id SET DEFAULT nextval('public.rehab_patient_video_artifacts_id_seq'::regclass);


--
-- Name: rehab_patient_video_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_patient_video_reviews ALTER COLUMN id SET DEFAULT nextval('public.rehab_patient_video_reviews_id_seq'::regclass);


--
-- Name: rehab_plan_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_plan_items ALTER COLUMN id SET DEFAULT nextval('public.rehab_plan_items_id_seq'::regclass);


--
-- Name: rehab_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_plans ALTER COLUMN id SET DEFAULT nextval('public.rehab_plans_id_seq'::regclass);


--
-- Name: rehab_user_uploaded_videos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_user_uploaded_videos ALTER COLUMN id SET DEFAULT nextval('public.rehab_user_uploaded_videos_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: system_runtime_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_runtime_settings ALTER COLUMN id SET DEFAULT nextval('public.system_runtime_settings_id_seq'::regclass);


--
-- Name: user_audit_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_audit_log ALTER COLUMN id SET DEFAULT nextval('public.user_audit_log_id_seq'::regclass);


--
-- Name: user_login_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_login_log ALTER COLUMN id SET DEFAULT nextval('public.user_login_log_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: worker_gpu_state id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_gpu_state ALTER COLUMN id SET DEFAULT nextval('public.worker_gpu_state_id_seq'::regclass);


--
-- Name: worker_nodes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_nodes ALTER COLUMN id SET DEFAULT nextval('public.worker_nodes_id_seq'::regclass);


--
-- Name: gpu_token_leases gpu_token_leases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpu_token_leases
    ADD CONSTRAINT gpu_token_leases_pkey PRIMARY KEY (id);


--
-- Name: gpu_token_leases gpu_token_leases_task_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpu_token_leases
    ADD CONSTRAINT gpu_token_leases_task_id_key UNIQUE (task_id);


--
-- Name: rehab_example_video_annotation_inputs rehab_example_video_annotation_inputs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_video_annotation_inputs
    ADD CONSTRAINT rehab_example_video_annotation_inputs_pkey PRIMARY KEY (id);


--
-- Name: rehab_example_videos_annotations rehab_example_videos_annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_videos_annotations
    ADD CONSTRAINT rehab_example_videos_annotations_pkey PRIMARY KEY (id);


--
-- Name: rehab_example_videos rehab_example_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_videos
    ADD CONSTRAINT rehab_example_videos_pkey PRIMARY KEY (id);


--
-- Name: rehab_patient_video_artifacts rehab_patient_video_artifacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_patient_video_artifacts
    ADD CONSTRAINT rehab_patient_video_artifacts_pkey PRIMARY KEY (id);


--
-- Name: rehab_patient_video_reviews rehab_patient_video_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_patient_video_reviews
    ADD CONSTRAINT rehab_patient_video_reviews_pkey PRIMARY KEY (id);


--
-- Name: rehab_plan_items rehab_plan_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_plan_items
    ADD CONSTRAINT rehab_plan_items_pkey PRIMARY KEY (id);


--
-- Name: rehab_plans rehab_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_plans
    ADD CONSTRAINT rehab_plans_pkey PRIMARY KEY (id);


--
-- Name: rehab_user_uploaded_videos rehab_user_uploaded_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_user_uploaded_videos
    ADD CONSTRAINT rehab_user_uploaded_videos_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_role_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_key_key UNIQUE (role_key);


--
-- Name: system_runtime_settings system_runtime_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_runtime_settings
    ADD CONSTRAINT system_runtime_settings_pkey PRIMARY KEY (id);


--
-- Name: system_runtime_settings system_runtime_settings_setting_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_runtime_settings
    ADD CONSTRAINT system_runtime_settings_setting_key_key UNIQUE (setting_key);


--
-- Name: user_audit_log user_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_audit_log
    ADD CONSTRAINT user_audit_log_pkey PRIMARY KEY (id);


--
-- Name: user_login_log user_login_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_login_log
    ADD CONSTRAINT user_login_log_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_user_account_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_account_key UNIQUE (user_account);


--
-- Name: users users_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_id_key UNIQUE (user_id);


--
-- Name: worker_gpu_state worker_gpu_state_node_name_gpu_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_gpu_state
    ADD CONSTRAINT worker_gpu_state_node_name_gpu_uuid_key UNIQUE (node_name, gpu_uuid);


--
-- Name: worker_gpu_state worker_gpu_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_gpu_state
    ADD CONSTRAINT worker_gpu_state_pkey PRIMARY KEY (id);


--
-- Name: worker_nodes worker_nodes_node_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_nodes
    ADD CONSTRAINT worker_nodes_node_name_key UNIQUE (node_name);


--
-- Name: worker_nodes worker_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_nodes
    ADD CONSTRAINT worker_nodes_pkey PRIMARY KEY (id);


--
-- Name: idx_annotation_inputs_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_annotation_inputs_pending ON public.rehab_example_video_annotation_inputs USING btree (annotation_id, processed_at);


--
-- Name: idx_annotation_video; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_annotation_video ON public.rehab_example_videos_annotations USING btree (video_id);


--
-- Name: idx_artifact_video_category_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_artifact_video_category_type ON public.rehab_patient_video_artifacts USING btree (video_id, category, artifact_type);


--
-- Name: idx_artifact_video_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_artifact_video_created ON public.rehab_patient_video_artifacts USING btree (video_id, created_at DESC);


--
-- Name: idx_gpu_token_leases_leased_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gpu_token_leases_leased_at ON public.gpu_token_leases USING btree (leased_at);


--
-- Name: idx_gpu_token_leases_node_gpu_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gpu_token_leases_node_gpu_status ON public.gpu_token_leases USING btree (node_name, gpu_uuid, status);


--
-- Name: idx_rehab_plan_items_example_video; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rehab_plan_items_example_video ON public.rehab_plan_items USING btree (example_video_id);


--
-- Name: idx_rehab_plan_items_plan; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rehab_plan_items_plan ON public.rehab_plan_items USING btree (rehab_plan_id, sort_order);


--
-- Name: idx_rehab_plans_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rehab_plans_patient ON public.rehab_plans USING btree (patient_id);


--
-- Name: idx_rehab_plans_patient_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rehab_plans_patient_active ON public.rehab_plans USING btree (patient_id, is_active, status);


--
-- Name: idx_review_reviewer_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_review_reviewer_created ON public.rehab_patient_video_reviews USING btree (reviewer_id, created_at DESC);


--
-- Name: idx_review_video_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_review_video_created ON public.rehab_patient_video_reviews USING btree (video_id, created_at DESC);


--
-- Name: idx_up_video_is_processed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_up_video_is_processed ON public.rehab_user_uploaded_videos USING btree (is_processed_2d3d, created_at DESC);


--
-- Name: idx_up_video_plan_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_up_video_plan_created ON public.rehab_user_uploaded_videos USING btree (rehab_plan_id, created_at DESC);


--
-- Name: idx_up_video_user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_up_video_user_created ON public.rehab_user_uploaded_videos USING btree (user_id, created_at DESC);


--
-- Name: idx_user_login_log_attempted_account_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_login_log_attempted_account_created_at ON public.user_login_log USING btree (attempted_user_account, created_at DESC) WHERE (attempted_user_account IS NOT NULL);


--
-- Name: idx_user_sessions_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sessions_expires_at ON public.user_sessions USING btree (expires_at);


--
-- Name: idx_user_sessions_revoked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sessions_revoked_at ON public.user_sessions USING btree (revoked_at);


--
-- Name: idx_user_sessions_user_active_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sessions_user_active_lookup ON public.user_sessions USING btree (user_id, revoked_at, expires_at DESC);


--
-- Name: idx_user_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sessions_user_id ON public.user_sessions USING btree (user_id);


--
-- Name: idx_worker_gpu_state_available; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worker_gpu_state_available ON public.worker_gpu_state USING btree (node_name, token_capacity, token_leased);


--
-- Name: idx_worker_gpu_state_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worker_gpu_state_updated_at ON public.worker_gpu_state USING btree (updated_at);


--
-- Name: idx_worker_nodes_last_seen_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worker_nodes_last_seen_at ON public.worker_nodes USING btree (last_seen_at);


--
-- Name: uq_user_sessions_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_user_sessions_token_hash ON public.user_sessions USING btree (session_token_hash);


--
-- Name: rehab_patient_video_artifacts fk_artifact_video; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_patient_video_artifacts
    ADD CONSTRAINT fk_artifact_video FOREIGN KEY (video_id) REFERENCES public.rehab_user_uploaded_videos(id) ON DELETE CASCADE;


--
-- Name: rehab_example_videos fk_media_uploader; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_videos
    ADD CONSTRAINT fk_media_uploader FOREIGN KEY (uploader_id) REFERENCES public.users(id);


--
-- Name: rehab_plan_items fk_rehab_plan_items_example_video; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_plan_items
    ADD CONSTRAINT fk_rehab_plan_items_example_video FOREIGN KEY (example_video_id) REFERENCES public.rehab_example_videos(id) ON DELETE SET NULL;


--
-- Name: rehab_plan_items fk_rehab_plan_items_plan; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_plan_items
    ADD CONSTRAINT fk_rehab_plan_items_plan FOREIGN KEY (rehab_plan_id) REFERENCES public.rehab_plans(id) ON DELETE CASCADE;


--
-- Name: rehab_plans fk_rehab_plans_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_plans
    ADD CONSTRAINT fk_rehab_plans_parent FOREIGN KEY (parent_plan_id) REFERENCES public.rehab_plans(id);


--
-- Name: rehab_patient_video_reviews fk_review_therapist; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_patient_video_reviews
    ADD CONSTRAINT fk_review_therapist FOREIGN KEY (reviewer_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: rehab_patient_video_reviews fk_review_video; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_patient_video_reviews
    ADD CONSTRAINT fk_review_video FOREIGN KEY (video_id) REFERENCES public.rehab_user_uploaded_videos(id) ON DELETE CASCADE;


--
-- Name: rehab_user_uploaded_videos fk_up_video_plan; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_user_uploaded_videos
    ADD CONSTRAINT fk_up_video_plan FOREIGN KEY (rehab_plan_id) REFERENCES public.rehab_plans(id) ON DELETE CASCADE;


--
-- Name: rehab_user_uploaded_videos fk_up_video_plan_item; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_user_uploaded_videos
    ADD CONSTRAINT fk_up_video_plan_item FOREIGN KEY (rehab_plan_item_id) REFERENCES public.rehab_plan_items(id) ON DELETE CASCADE;


--
-- Name: rehab_user_uploaded_videos fk_up_video_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_user_uploaded_videos
    ADD CONSTRAINT fk_up_video_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rehab_example_video_annotation_inputs rehab_example_video_annotation_inputs_annotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_video_annotation_inputs
    ADD CONSTRAINT rehab_example_video_annotation_inputs_annotation_id_fkey FOREIGN KEY (annotation_id) REFERENCES public.rehab_example_videos_annotations(id) ON DELETE CASCADE;


--
-- Name: rehab_example_videos_annotations rehab_example_videos_annotations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_videos_annotations
    ADD CONSTRAINT rehab_example_videos_annotations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: rehab_example_videos_annotations rehab_example_videos_annotations_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rehab_example_videos_annotations
    ADD CONSTRAINT rehab_example_videos_annotations_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.rehab_example_videos(id) ON DELETE CASCADE;


--
-- Name: user_login_log user_login_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_login_log
    ADD CONSTRAINT user_login_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: worker_gpu_state worker_gpu_state_node_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worker_gpu_state
    ADD CONSTRAINT worker_gpu_state_node_name_fkey FOREIGN KEY (node_name) REFERENCES public.worker_nodes(node_name) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict kbTClOgekOWsc7zWaLCUFVB8Z1yd4cyfIvyczYWi6Aq7WPzNbmv7xNl94pCK6UO

