-- Run these commands in your Supabase SQL Editor to fix the database schema issues.

-- 1. Fix the leaves table
-- Drops the incorrect 1-to-1 foreign key constraint on the primary key
ALTER TABLE public.leaves DROP CONSTRAINT IF EXISTS leaves_id_fkey;

-- 2. Fix the attendance table
-- Drops the incorrect 1-to-1 foreign key constraint on the primary key
ALTER TABLE public.attendance DROP CONSTRAINT IF EXISTS attendance_id_fkey;
ALTER TABLE public.attendance DROP CONSTRAINT IF EXISTS attendance_employee_id_fkey;

-- Add a proper foreign key column so employees can have multiple attendance records
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS employee_id int8 REFERENCES public.employees(id);
