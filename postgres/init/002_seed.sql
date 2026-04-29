--
-- PostgreSQL database dump
--

\restrict Tf0c0b9B7Vf8CYMkKuRZZ6ZFUpaZnU8IFvoTqt4Jh3lyjTkfockdW7NtwC6ozTu

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

--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.roles (id, role_key, role_name, description) VALUES (1, 'admin', '系統管理員', '具最高權限，可管理所有系統設定與使用者');
INSERT INTO public.roles (id, role_key, role_name, description) VALUES (2, 'doctor', '醫生', '負責醫療診斷與醫療紀錄輸入');
INSERT INTO public.roles (id, role_key, role_name, description) VALUES (3, 'therapist', '物理復健師', '負責復健項目操作與紀錄');
INSERT INTO public.roles (id, role_key, role_name, description) VALUES (4, 'normal', '一般使用者', '基本角色，僅能使用一般功能');


--
-- Data for Name: system_runtime_settings; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (3, 'lease_timeout_seconds', '1800', 'int', 'token 租約逾時秒數（30 分鐘）', true, '2026-02-13 08:10:42.625324+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (4, 'script_waiting_retry_base_seconds', '10', 'int', 'waiting 重試基礎秒數', true, '2026-02-13 08:10:42.625324+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (5, 'script_waiting_retry_max_seconds', '120', 'int', 'waiting 重試最大秒數', true, '2026-02-13 08:10:42.625324+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (6, 'script_waiting_retry_jitter_seconds', '5', 'int', 'waiting 重試 jitter 秒數', true, '2026-02-13 08:10:42.625324+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (2, 'metrics_stale_threshold_seconds', '20', 'int', '第一道防線狀態過期秒數', true, '2026-02-13 08:16:40.772595+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (8, 'metrics_interval_seconds', '10', 'int', '第一道防線輪詢派發秒數', true, '2026-02-13 08:16:40.772595+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (1, 'gpu_required_vram_mb', '3891', 'int', '每個任務最低 VRAM 門檻（MB）', true, '2026-02-13 08:10:42.625324+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (9, 'script_token_hold_scope', 'full_task', 'string', 'Token 釋放策略：full_task(任務完成釋放) / gpu_only(GPU階段後釋放)', true, '2026-02-13 09:05:46.572187+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (10, 'video_pipeline_token_mode', 'per_video', 'string', '影片流程 token 模式：per_task(2D/3D 與 humanpose 各自拿放 token) / per_video(整支影片共用同一顆 token)', true, '2026-02-14 04:26:16.185536+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (11, 'video_transcode_use_gpu', 'false', 'bool', '影片轉檔是否使用 GPU（true=NVENC, false=libx264 CPU）', true, '2026-02-18 07:12:50.78027+00');
INSERT INTO public.system_runtime_settings (id, setting_key, setting_value, value_type, description, is_active, updated_at) VALUES (7, 'script_waiting_retry_max_attempts', '3', 'int', 'waiting 最大重試次數，0 表示不限制', true, '2026-02-13 08:10:42.625324+00');


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: system_runtime_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.system_runtime_settings_id_seq', 16, true);


--
-- PostgreSQL database dump complete
--

\unrestrict Tf0c0b9B7Vf8CYMkKuRZZ6ZFUpaZnU8IFvoTqt4Jh3lyjTkfockdW7NtwC6ozTu

