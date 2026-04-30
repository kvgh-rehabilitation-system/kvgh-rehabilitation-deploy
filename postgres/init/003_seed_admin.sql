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
    '$argon2id$v=19$m=65536,t=3,p=4$a3ZnaC1pbml0LWFkbWluMQ$m34tK1qSiaTxkJPQp53RsIZPMLqsTOfzwL2P9L7pU7g',
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
