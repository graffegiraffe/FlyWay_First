CREATE TABLE public.user_credentials
(
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES public.users (id) ON DELETE CASCADE,
    login VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    CONSTRAINT user_credentials_unique_user UNIQUE (user_id)
);