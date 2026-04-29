INSERT INTO public.users (
    user_id,
    user_account,
    user_password_hash,
    user_name,
    role_id,
    is_active,
    created_at,
    updated_at,
    password_updated_at
)
VALUES (
    'admin01',
    'admin01',
    'pbkdf2_sha256$390000$kvgh_init_admin$wElgtsqbqgSux+L2jvR68ML62dWdYobp3wwswI2ShzY=',
    '系統管理員',
    1,
    TRUE,
    NOW(),
    NOW(),
    NOW()
)
ON CONFLICT (user_account) DO NOTHING;

SELECT pg_catalog.setval(
    'public.users_id_seq',
    GREATEST(
        COALESCE((SELECT MAX(id) FROM public.users), 1),
        1
    ),
    TRUE
);
