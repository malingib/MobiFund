-- Platform-level admin + encrypted config store

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Platform admins (global)
CREATE TABLE IF NOT EXISTS public.platform_admins (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Encrypted platform configs (global)
-- value_encrypted is base64-encoded payload (iv+ciphertext) encrypted at Edge Function level.
CREATE TABLE IF NOT EXISTS public.platform_configs (
  key TEXT PRIMARY KEY,
  value_encrypted TEXT NOT NULL,
  updated_by UUID REFERENCES auth.users(id),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- updated_at trigger
DROP TRIGGER IF EXISTS update_platform_configs_updated_at ON public.platform_configs;
CREATE TRIGGER update_platform_configs_updated_at BEFORE UPDATE ON public.platform_configs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- RLS
ALTER TABLE public.platform_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_configs ENABLE ROW LEVEL SECURITY;

-- Platform admin can see their own record (used by app to show Super Admin menu)
DROP POLICY IF EXISTS platform_admins_select_self ON public.platform_admins;
CREATE POLICY platform_admins_select_self ON public.platform_admins
  FOR SELECT
  USING (user_id = auth.uid());

-- Platform admins can read platform configs (client side should not need secrets; still restricted)
DROP POLICY IF EXISTS platform_configs_select_admin ON public.platform_configs;
CREATE POLICY platform_configs_select_admin ON public.platform_configs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.platform_admins pa
      WHERE pa.user_id = auth.uid()
    )
  );

