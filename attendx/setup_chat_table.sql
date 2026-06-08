-- Run this in your Supabase SQL Editor to set up the chat feature

-- 1. Create the messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id INT8 REFERENCES public.employees(id) ON DELETE CASCADE,
    receiver_id INT8 REFERENCES public.employees(id) ON DELETE CASCADE,
    is_group BOOLEAN DEFAULT false,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies
-- Policy: Users can read messages if they are the sender, the receiver, or if it's a group message
CREATE POLICY "Users can read their own or group messages"
    ON public.messages
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT auth_id FROM public.employees WHERE id = sender_id OR id = receiver_id
        ) OR is_group = true
        -- Note: If you don't have auth_id in employees mapped to Supabase auth,
        -- you might need to adjust this depending on how you enforce auth in RLS.
        -- If you only do client-side filtering for now, you can use:
        -- true
    );

-- Since there is no clear auth link in the current schema (employees has `password`), 
-- we will just allow all authenticated users to select/insert for the time being,
-- and rely on client-side filtering. If you use Supabase Auth, replace `true` with the proper check.
DROP POLICY IF EXISTS "Users can read their own or group messages" ON public.messages;
CREATE POLICY "Enable read access for all users" ON public.messages FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON public.messages FOR INSERT WITH CHECK (true);

-- 4. Enable Realtime for the messages table
-- This enables broadcasting changes so the Flutter app receives them instantly
alter publication supabase_realtime add table public.messages;
