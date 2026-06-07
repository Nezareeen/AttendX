-- Run this in your Supabase SQL Editor to fix the leave synchronization issues

-- Grant basic CRUD permissions to the 'anon' role for the leaves table
GRANT SELECT, INSERT, UPDATE, DELETE ON public.leaves TO anon;

-- Disable Row Level Security (RLS) on the leaves table for testing
ALTER TABLE public.leaves DISABLE ROW LEVEL SECURITY;
