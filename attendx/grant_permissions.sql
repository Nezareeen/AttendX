-- Run this in your Supabase SQL Editor to fix the permission denied error

-- Grant basic CRUD permissions to the 'anon' role since your app does not use Supabase Auth
GRANT SELECT, INSERT, UPDATE, DELETE ON public.attendance TO anon;

-- Alternatively, if Row Level Security (RLS) is enabled, you might need to disable it for testing:
ALTER TABLE public.attendance DISABLE ROW LEVEL SECURITY;
