-- =============================================
-- Backup Database Initialization Script
-- Generated: 2025-12-23T02:22:33.148Z
-- Primary DB: https://kefpksvgkelzoqfiejsi.supabase.co
-- =============================================
-- This script sets up the backup database schema.
-- Run this in the SQL editor of your backup Supabase project.

-- =============================================
-- STEP 1: Enable required extensions
-- =============================================
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- =============================================
-- STEP 2: Create enum types
-- =============================================
DO $$ BEGIN
  CREATE TYPE app_role AS ENUM ('admin', 'moderator', 'user');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE subscription_plan AS ENUM ('guest', 'traveler', 'knowledge_seeker', 'psychologist');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- =============================================
-- STEP 3: Create Tables
-- =============================================

-- Table: profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  username TEXT,
  full_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  telegram_id TEXT,
  telegram_username TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  gender TEXT DEFAULT 'брат'::text,
  islam_level TEXT DEFAULT 'начальный'::text,
  madhab TEXT DEFAULT 'ханафитский'::text,
  location_mode TEXT DEFAULT 'автоматически'::text,
  location_country TEXT,
  location_city TEXT,
  PRIMARY KEY (id)
);

-- Table: user_roles
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  role app_role DEFAULT 'user'::app_role NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: notification_settings
CREATE TABLE IF NOT EXISTS public.notification_settings (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  email_enabled BOOLEAN DEFAULT false,
  telegram_enabled BOOLEAN DEFAULT false,
  prayer_notifications_enabled BOOLEAN DEFAULT false,
  schedule_notifications_enabled BOOLEAN DEFAULT false,
  minutes_before INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  notifications_enabled BOOLEAN DEFAULT true,
  sms_enabled BOOLEAN DEFAULT false,
  push_enabled BOOLEAN DEFAULT false,
  ihsan_notifications_enabled BOOLEAN DEFAULT false,
  PRIMARY KEY (id)
);

-- Table: backup_settings
CREATE TABLE IF NOT EXISTS public.backup_settings (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  auto_backup_enabled BOOLEAN DEFAULT true,
  backup_schedule TEXT DEFAULT '0 2 * * *'::text,
  retention_days INTEGER DEFAULT 30,
  backup_type TEXT DEFAULT 'full'::text,
  notification_enabled BOOLEAN DEFAULT true,
  last_backup_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: backups
CREATE TABLE IF NOT EXISTS public.backups (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  backup_type TEXT NOT NULL,
  status TEXT DEFAULT 'in_progress'::text NOT NULL,
  file_path TEXT,
  file_size BIGINT,
  tables_included JSONB DEFAULT '[]'::jsonb,
  error_message TEXT,
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB DEFAULT '{}'::jsonb,
  PRIMARY KEY (id)
);

-- Table: system_errors
CREATE TABLE IF NOT EXISTS public.system_errors (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  error_type TEXT NOT NULL,
  error_message TEXT NOT NULL,
  error_details JSONB,
  function_name TEXT,
  user_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMP WITH TIME ZONE,
  resolved_by UUID,
  PRIMARY KEY (id)
);

-- Table: system_settings
CREATE TABLE IF NOT EXISTS public.system_settings (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  key VARCHAR NOT NULL,
  value TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: ai_router_instructions
CREATE TABLE IF NOT EXISTS public.ai_router_instructions (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  instruction_text TEXT NOT NULL,
  forbidden_topics JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: ai_scenarios
CREATE TABLE IF NOT EXISTS public.ai_scenarios (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  trigger_conditions JSONB DEFAULT '{}'::jsonb NOT NULL,
  vector_collections JSONB DEFAULT '[]'::jsonb,
  response_template TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: ai_commands
CREATE TABLE IF NOT EXISTS public.ai_commands (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  phrases JSONB DEFAULT '[]'::jsonb NOT NULL,
  action_type TEXT NOT NULL,
  action_data JSONB DEFAULT '{}'::jsonb,
  scenario_id UUID,
  is_active BOOLEAN DEFAULT true,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  router_prompt TEXT,
  PRIMARY KEY (id)
);

-- Table: llm_instructions
CREATE TABLE IF NOT EXISTS public.llm_instructions (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  instruction_text TEXT NOT NULL,
  temperature NUMERIC DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 1000,
  model TEXT DEFAULT 'google/gemini-2.5-pro'::text,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  max_tokens_per_conversation INTEGER DEFAULT 8000,
  PRIMARY KEY (id)
);

-- Table: llm_additional_prompts
CREATE TABLE IF NOT EXISTS public.llm_additional_prompts (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  key TEXT NOT NULL,
  content TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: app_sections
CREATE TABLE IF NOT EXISTS public.app_sections (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  section_key TEXT NOT NULL,
  section_name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: section_capabilities
CREATE TABLE IF NOT EXISTS public.section_capabilities (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  section_key TEXT NOT NULL,
  capability_name TEXT NOT NULL,
  capability_description TEXT NOT NULL,
  example_command TEXT,
  priority INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: section_admin_instructions
CREATE TABLE IF NOT EXISTS public.section_admin_instructions (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  section_key TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: section_llm_prompts
CREATE TABLE IF NOT EXISTS public.section_llm_prompts (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  section_id UUID,
  name TEXT NOT NULL,
  instruction_text TEXT NOT NULL,
  model TEXT DEFAULT 'google/gemini-2.5-flash'::text,
  temperature NUMERIC DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 1500,
  max_tokens_per_conversation INTEGER DEFAULT 8000,
  is_active BOOLEAN DEFAULT false,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  special_instruction TEXT,
  PRIMARY KEY (id)
);

-- Table: section_router_prompts
CREATE TABLE IF NOT EXISTS public.section_router_prompts (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  section_id UUID,
  name TEXT NOT NULL,
  instruction_text TEXT NOT NULL,
  forbidden_topics JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT false,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  special_instruction TEXT,
  PRIMARY KEY (id)
);

-- Table: section_prompts
CREATE TABLE IF NOT EXISTS public.section_prompts (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  section_key TEXT NOT NULL,
  prompt_type TEXT NOT NULL,
  name TEXT DEFAULT ''::text NOT NULL,
  prompt_text TEXT DEFAULT ''::text NOT NULL,
  model TEXT DEFAULT 'google/gemini-2.5-flash'::text,
  temperature NUMERIC DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 1000,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: content_blocks
CREATE TABLE IF NOT EXISTS public.content_blocks (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  block_key TEXT NOT NULL,
  block_name TEXT NOT NULL,
  content_type TEXT DEFAULT 'text'::text,
  content TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: emotional_help
CREATE TABLE IF NOT EXISTS public.emotional_help (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  emotion_key TEXT NOT NULL,
  emotion_title TEXT NOT NULL,
  icon_name TEXT NOT NULL,
  quick_help_content TEXT NOT NULL,
  support_content TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: ihsan_character
CREATE TABLE IF NOT EXISTS public.ihsan_character (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  vice TEXT NOT NULL,
  root TEXT,
  virtue TEXT NOT NULL,
  ayahs JSONB DEFAULT '[]'::jsonb,
  hadiths JSONB DEFAULT '[]'::jsonb,
  stories JSONB DEFAULT '[]'::jsonb,
  tasks JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  duas JSONB DEFAULT '[]'::jsonb,
  quality_type VARCHAR DEFAULT 'vice'::character varying,
  quality_name VARCHAR,
  PRIMARY KEY (id)
);

-- Table: psychologists
CREATE TABLE IF NOT EXISTS public.psychologists (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  photo_url TEXT,
  short_description TEXT NOT NULL,
  full_description TEXT NOT NULL,
  contacts JSONB DEFAULT '{}'::jsonb,
  rating NUMERIC DEFAULT 0.00,
  subscription_required BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  telegram TEXT,
  phone TEXT,
  PRIMARY KEY (id)
);

-- Table: psychologist_conversations
CREATE TABLE IF NOT EXISTS public.psychologist_conversations (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  psychologist_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: psychologist_messages
CREATE TABLE IF NOT EXISTS public.psychologist_messages (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  conversation_id UUID,
  user_id UUID NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: courses
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  photo_url TEXT,
  short_description TEXT NOT NULL,
  full_description TEXT,
  rating NUMERIC DEFAULT 0.00,
  subject_key TEXT NOT NULL,
  website_url TEXT,
  contacts JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  subscription_required BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: course_subscriptions
CREATE TABLE IF NOT EXISTS public.course_subscriptions (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  course_id UUID NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: subscription_plans
CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  plan_type subscription_plan NOT NULL,
  name TEXT NOT NULL,
  price_monthly INTEGER DEFAULT 0 NOT NULL,
  features JSONB DEFAULT '[]'::jsonb NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: subscription_features
CREATE TABLE IF NOT EXISTS public.subscription_features (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  feature_key TEXT NOT NULL,
  feature_name TEXT NOT NULL,
  description TEXT,
  min_plan_required subscription_plan DEFAULT 'guest'::subscription_plan NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: subscription_limits
CREATE TABLE IF NOT EXISTS public.subscription_limits (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  plan_type subscription_plan NOT NULL,
  daily_chat_requests INTEGER DEFAULT 10 NOT NULL,
  context_messages_limit INTEGER DEFAULT 3 NOT NULL,
  max_tokens_per_request INTEGER DEFAULT 1000 NOT NULL,
  voice_enabled BOOLEAN DEFAULT false NOT NULL,
  rag_search_enabled BOOLEAN DEFAULT false NOT NULL,
  web_search_enabled BOOLEAN DEFAULT false NOT NULL,
  diary_enabled BOOLEAN DEFAULT false NOT NULL,
  ihsan_enabled BOOLEAN DEFAULT false NOT NULL,
  medrese_enabled BOOLEAN DEFAULT false NOT NULL,
  library_enabled BOOLEAN DEFAULT false NOT NULL,
  psychologist_enabled BOOLEAN DEFAULT false NOT NULL,
  favorites_storage_mb INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  model_router TEXT DEFAULT 'gemini-2.5-flash-lite'::text,
  model_chat TEXT DEFAULT 'gemini-2.5-flash-lite'::text,
  model_medrese TEXT DEFAULT 'gemini-2.5-flash-lite'::text,
  model_diary TEXT DEFAULT 'gemini-2.5-flash-lite'::text,
  model_help TEXT DEFAULT 'gemini-2.5-flash-lite'::text,
  model_ihsan TEXT DEFAULT 'gemini-2.5-flash-lite'::text,
  memory_enabled BOOLEAN DEFAULT false,
  commands_enabled BOOLEAN DEFAULT false,
  voice_commands_enabled BOOLEAN DEFAULT false,
  PRIMARY KEY (id)
);

-- Table: user_subscriptions
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  plan_type subscription_plan DEFAULT 'guest'::subscription_plan NOT NULL,
  status TEXT DEFAULT 'active'::text NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  last_checked_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: user_usage
CREATE TABLE IF NOT EXISTS public.user_usage (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  usage_date DATE DEFAULT CURRENT_DATE NOT NULL,
  chat_requests INTEGER DEFAULT 0 NOT NULL,
  voice_requests INTEGER DEFAULT 0 NOT NULL,
  rag_requests INTEGER DEFAULT 0 NOT NULL,
  total_tokens_used INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: conversations
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  title TEXT DEFAULT 'Новый разговор'::text,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: messages
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  conversation_id UUID NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: chat_conversations
CREATE TABLE IF NOT EXISTS public.chat_conversations (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  section TEXT NOT NULL,
  diary_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  title TEXT DEFAULT 'Новый диалог'::text,
  total_tokens INTEGER DEFAULT 0,
  summary TEXT,
  PRIMARY KEY (id)
);

-- Table: chat_messages
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  context_type TEXT,
  context_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  conversation_id UUID,
  PRIMARY KEY (id)
);

-- Table: intentions
CREATE TABLE IF NOT EXISTS public.intentions (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  category TEXT DEFAULT 'daily'::text,
  priority INTEGER DEFAULT 1,
  PRIMARY KEY (id)
);

-- Table: big_intentions
CREATE TABLE IF NOT EXISTS public.big_intentions (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  target_date DATE,
  category TEXT DEFAULT 'spiritual'::text,
  status TEXT DEFAULT 'active'::text,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: diary_entries
CREATE TABLE IF NOT EXISTS public.diary_entries (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  date DATE NOT NULL,
  intentions TEXT,
  tomorrow_intention TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: daily_tasks
CREATE TABLE IF NOT EXISTS public.daily_tasks (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  diary_date DATE NOT NULL,
  task_text TEXT NOT NULL,
  task_type TEXT DEFAULT 'virtue'::text,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: daily_test_responses
CREATE TABLE IF NOT EXISTS public.daily_test_responses (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  diary_date DATE NOT NULL,
  emotional_state JSONB,
  control_rating INTEGER,
  virtue_rating INTEGER,
  study_answers JSONB,
  tomorrow_intention TEXT,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: notes
CREATE TABLE IF NOT EXISTS public.notes (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  content TEXT NOT NULL,
  diary_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  category TEXT DEFAULT 'general'::text,
  title TEXT,
  PRIMARY KEY (id)
);

-- Table: schedule_events
CREATE TABLE IF NOT EXISTS public.schedule_events (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  diary_date DATE NOT NULL,
  time TIME NOT NULL,
  event TEXT NOT NULL,
  notifications_enabled BOOLEAN DEFAULT false,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  category TEXT DEFAULT 'general'::text,
  priority INTEGER DEFAULT 1,
  description TEXT,
  PRIMARY KEY (id)
);

-- Table: ihsan_plans
CREATE TABLE IF NOT EXISTS public.ihsan_plans (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  status VARCHAR DEFAULT 'draft'::character varying,
  current_day INTEGER DEFAULT 0,
  week_start_date DATE DEFAULT CURRENT_DATE,
  total_days INTEGER DEFAULT 40,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: ihsan_user_plans
CREATE TABLE IF NOT EXISTS public.ihsan_user_plans (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  status TEXT DEFAULT 'active'::text,
  selected_vices JSONB DEFAULT '[]'::jsonb NOT NULL,
  selected_virtues JSONB DEFAULT '[]'::jsonb NOT NULL,
  current_day INTEGER DEFAULT 0,
  total_days INTEGER DEFAULT 30,
  daily_dua TEXT,
  daily_cards JSONB DEFAULT '[]'::jsonb NOT NULL,
  telegram_notifications_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: notification_queue
CREATE TABLE IF NOT EXISTS public.notification_queue (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  notification_type TEXT NOT NULL,
  scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL,
  event_id UUID,
  message TEXT NOT NULL,
  sent BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: rag_sections
CREATE TABLE IF NOT EXISTS public.rag_sections (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  rating INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: rag_documents
CREATE TABLE IF NOT EXISTS public.rag_documents (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  section_id UUID NOT NULL,
  title TEXT NOT NULL,
  file_path TEXT,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  book_id UUID,
  doc_type TEXT DEFAULT 'book_generic'::text,
  lang TEXT DEFAULT 'ar'::text,
  PRIMARY KEY (id)
);

-- Table: rag_chunks
CREATE TABLE IF NOT EXISTS public.rag_chunks (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  document_id UUID NOT NULL,
  chunk_text TEXT NOT NULL,
  lang TEXT DEFAULT 'ar'::text NOT NULL,
  section_type TEXT,
  meta JSONB DEFAULT '{}'::jsonb,
  embedding vector,
  embedded BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: rag_embeddings
CREATE TABLE IF NOT EXISTS public.rag_embeddings (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  document_id UUID NOT NULL,
  section_id UUID NOT NULL,
  content TEXT NOT NULL,
  embedding vector,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: rag_settings
CREATE TABLE IF NOT EXISTS public.rag_settings (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  embedding_model TEXT DEFAULT 'text-embedding-3-small'::text,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: library_books
CREATE TABLE IF NOT EXISTS public.library_books (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  title TEXT NOT NULL,
  author TEXT,
  lang TEXT DEFAULT 'ar'::text NOT NULL,
  category TEXT NOT NULL,
  priority INTEGER DEFAULT 5,
  status TEXT DEFAULT 'planned'::text,
  description TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  total_chunks INTEGER DEFAULT 0,
  processed_chunks INTEGER DEFAULT 0,
  vectorization_started_at TIMESTAMP WITH TIME ZONE,
  vectorization_completed_at TIMESTAMP WITH TIME ZONE,
  last_error TEXT,
  total_pages INTEGER,
  processed_pages INTEGER DEFAULT 0,
  current_batch_start INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

-- Table: library_book_sources
CREATE TABLE IF NOT EXISTS public.library_book_sources (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  book_id UUID NOT NULL,
  url TEXT NOT NULL,
  source_type TEXT NOT NULL,
  is_trusted BOOLEAN DEFAULT false,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: temp_book_downloads
CREATE TABLE IF NOT EXISTS public.temp_book_downloads (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  session_id UUID NOT NULL,
  search_query TEXT NOT NULL,
  file_path TEXT,
  source_url TEXT,
  title TEXT,
  author TEXT,
  file_size BIGINT,
  preview_text TEXT,
  is_downloaded BOOLEAN DEFAULT false,
  registration_url TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_surahs
CREATE TABLE IF NOT EXISTS public.quran_surahs (
  surah INTEGER NOT NULL,
  name_arabic TEXT,
  name_simple TEXT,
  name_ru TEXT,
  revelation_place TEXT,
  verses_count INTEGER,
  pages INTEGER[],
  juz INTEGER[],
  meta JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (surah)
);

-- Table: quran_verses
CREATE TABLE IF NOT EXISTS public.quran_verses (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  sura INTEGER NOT NULL,
  ayah INTEGER NOT NULL,
  text_ar TEXT NOT NULL,
  text_ru_official TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: quran_verses_v2
CREATE TABLE IF NOT EXISTS public.quran_verses_v2 (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  verse_key TEXT NOT NULL,
  surah INTEGER NOT NULL,
  ayah INTEGER NOT NULL,
  arabic_uthmani TEXT NOT NULL,
  arabic_simple TEXT,
  juz_number INTEGER,
  hizb_number INTEGER,
  rub_el_hizb_number INTEGER,
  page_number INTEGER,
  sajdah_type TEXT,
  word_count INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_ayah_metadata
CREATE TABLE IF NOT EXISTS public.quran_ayah_metadata (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  surah INTEGER NOT NULL,
  ayah INTEGER NOT NULL,
  juz INTEGER,
  hizb INTEGER,
  rub INTEGER,
  manzil INTEGER,
  ruku INTEGER,
  ruku_name_ar TEXT,
  ruku_name_en TEXT,
  is_sajda BOOLEAN DEFAULT false,
  sajda_type TEXT,
  topics JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  ayah_text_ar TEXT,
  ayah_text_ru TEXT,
  ayah_transliteration TEXT,
  word_meanings JSONB,
  surah_name_ar TEXT,
  surah_name_ru TEXT,
  page_number INTEGER,
  hizb_quarter INTEGER,
  PRIMARY KEY (id)
);

-- Table: quran_sources
CREATE TABLE IF NOT EXISTS public.quran_sources (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  source_type TEXT NOT NULL,
  source_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  name_ru TEXT,
  author_name TEXT,
  language_code TEXT NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 0,
  meta JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_content_sources
CREATE TABLE IF NOT EXISTS public.quran_content_sources (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  source_key TEXT NOT NULL,
  source_type TEXT NOT NULL,
  name_ru TEXT NOT NULL,
  name_en TEXT,
  author TEXT,
  language_code TEXT NOT NULL,
  api_source TEXT,
  api_resource_id INTEGER,
  is_enabled BOOLEAN DEFAULT true,
  download_status TEXT DEFAULT 'not_started'::text,
  total_items INTEGER DEFAULT 6236,
  downloaded_items INTEGER DEFAULT 0,
  chunked_items INTEGER DEFAULT 0,
  embedded_items INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  import_file TEXT,
  PRIMARY KEY (id)
);

-- Table: quran_raw_data
CREATE TABLE IF NOT EXISTS public.quran_raw_data (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  surah INTEGER NOT NULL,
  ayah INTEGER NOT NULL,
  arabic TEXT NOT NULL,
  translations JSONB DEFAULT '{}'::jsonb,
  tafsirs JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  processing_status TEXT DEFAULT 'loaded'::text,
  PRIMARY KEY (id)
);

-- Table: quran_tafsir_data
CREATE TABLE IF NOT EXISTS public.quran_tafsir_data (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  source_key TEXT NOT NULL,
  surah INTEGER NOT NULL,
  ayah_from INTEGER NOT NULL,
  ayah_to INTEGER NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_chunks
CREATE TABLE IF NOT EXISTS public.quran_chunks (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  surah INTEGER NOT NULL,
  ayah_from INTEGER NOT NULL,
  ayah_to INTEGER NOT NULL,
  chunk_text TEXT NOT NULL,
  topic TEXT,
  meta JSONB DEFAULT '{}'::jsonb,
  keywords TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  arabic_text TEXT,
  linked_tafsir_ids TEXT[],
  linked_audio_ids TEXT[],
  embedding vector,
  linked_tafsir_keys TEXT[] DEFAULT '{}'::text[],
  chunk_index INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

-- Table: quran_audio
CREATE TABLE IF NOT EXISTS public.quran_audio (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  surah INTEGER NOT NULL,
  ayah INTEGER NOT NULL,
  qari TEXT NOT NULL,
  quality TEXT DEFAULT '128kbps'::text NOT NULL,
  file_path TEXT NOT NULL,
  file_size BIGINT,
  duration_seconds INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_pages
CREATE TABLE IF NOT EXISTS public.quran_pages (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  page_number INTEGER NOT NULL,
  file_path TEXT NOT NULL,
  file_size BIGINT,
  surah_start INTEGER,
  ayah_start INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_download_state
CREATE TABLE IF NOT EXISTS public.quran_download_state (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  stage TEXT NOT NULL,
  qari TEXT,
  current_item INTEGER DEFAULT 0,
  total_items INTEGER NOT NULL,
  status TEXT DEFAULT 'pending'::text,
  last_error TEXT,
  checkpoint JSONB DEFAULT '{}'::jsonb,
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_verse_translations
CREATE TABLE IF NOT EXISTS public.quran_verse_translations (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  verse_key TEXT NOT NULL,
  source_id UUID NOT NULL,
  text TEXT NOT NULL,
  footnotes JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: quran_verse_tafsirs
CREATE TABLE IF NOT EXISTS public.quran_verse_tafsirs (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  verse_key TEXT NOT NULL,
  source_id UUID NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (id)
);

-- Table: tafsir_chunks
CREATE TABLE IF NOT EXISTS public.tafsir_chunks (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  tafsir_source TEXT NOT NULL,
  surah INTEGER NOT NULL,
  ayah_from INTEGER NOT NULL,
  ayah_to INTEGER NOT NULL,
  chunk_text TEXT NOT NULL,
  meta JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  embedding vector,
  PRIMARY KEY (id)
);

-- Table: chunking_queue
CREATE TABLE IF NOT EXISTS public.chunking_queue (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  source_key TEXT NOT NULL,
  surah INTEGER NOT NULL,
  ayah_from INTEGER NOT NULL,
  ayah_to INTEGER NOT NULL,
  text TEXT NOT NULL,
  status TEXT DEFAULT 'pending'::text,
  attempts INTEGER DEFAULT 0,
  result JSONB,
  error TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  processed_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  worker_id TEXT,
  original_length INTEGER,
  sent_at TIMESTAMP WITH TIME ZONE,
  PRIMARY KEY (id)
);

-- Table: content_source_configs
CREATE TABLE IF NOT EXISTS public.content_source_configs (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  source_key TEXT NOT NULL,
  chunking_prompt TEXT,
  system_prompt TEXT,
  short_text_threshold INTEGER DEFAULT 2000,
  optimal_chunk_min INTEGER DEFAULT 800,
  optimal_chunk_max INTEGER DEFAULT 1500,
  max_chunk_size INTEGER DEFAULT 2000,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  chunking_method TEXT DEFAULT 'direct'::text,
  PRIMARY KEY (id)
);

-- Table: hadith_items
CREATE TABLE IF NOT EXISTS public.hadith_items (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  collection TEXT NOT NULL,
  number TEXT NOT NULL,
  text_ar TEXT NOT NULL,
  text_ru TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: support_tickets
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  ticket_type TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT DEFAULT 'открыто'::text NOT NULL,
  admin_response TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: telegram_ai_responses
CREATE TABLE IF NOT EXISTS public.telegram_ai_responses (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  comment_id UUID,
  router_action TEXT DEFAULT 'pending'::text,
  router_reason TEXT,
  router_processed_at TIMESTAMP WITH TIME ZONE,
  ai_model_used TEXT,
  ai_response_text TEXT,
  ai_response_tokens INTEGER,
  response_sent BOOLEAN DEFAULT false,
  response_message_id BIGINT,
  sent_at TIMESTAMP WITH TIME ZONE,
  moderation_status TEXT DEFAULT 'auto_approved'::text,
  moderated_by UUID,
  moderated_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: telegram_blocked_users
CREATE TABLE IF NOT EXISTS public.telegram_blocked_users (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_telegram_id BIGINT NOT NULL,
  username TEXT,
  blocked_reason TEXT,
  blocked_by UUID,
  blocked_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  PRIMARY KEY (id)
);

-- Table: telegram_channel_posts
CREATE TABLE IF NOT EXISTS public.telegram_channel_posts (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  channel_id BIGINT NOT NULL,
  message_id BIGINT NOT NULL,
  post_text TEXT,
  media_type TEXT,
  media_file_id TEXT,
  author_name TEXT,
  posted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  PRIMARY KEY (id)
);

-- Table: telegram_comments
CREATE TABLE IF NOT EXISTS public.telegram_comments (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  post_id UUID,
  parent_comment_id UUID,
  chat_id BIGINT NOT NULL,
  message_id BIGINT NOT NULL,
  reply_to_message_id BIGINT,
  user_telegram_id BIGINT NOT NULL,
  username TEXT,
  first_name TEXT,
  last_name TEXT,
  text TEXT NOT NULL,
  is_bot_response BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  edited_at TIMESTAMP WITH TIME ZONE,
  thread_level INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

-- Table: telegram_conversation_context
CREATE TABLE IF NOT EXISTS public.telegram_conversation_context (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  post_id UUID,
  thread_root_comment_id UUID,
  conversation_summary TEXT,
  participants_count INTEGER DEFAULT 0,
  messages_count INTEGER DEFAULT 0,
  last_message_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  sentiment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: telegram_rate_limit
CREATE TABLE IF NOT EXISTS public.telegram_rate_limit (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  chat_id TEXT NOT NULL,
  request_count INTEGER DEFAULT 1,
  window_start TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: web_search_logs
CREATE TABLE IF NOT EXISTS public.web_search_logs (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID,
  query TEXT NOT NULL,
  results_count INTEGER,
  search_engine TEXT,
  processing_time_ms INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: web_search_settings
CREATE TABLE IF NOT EXISTS public.web_search_settings (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  api_key TEXT,
  search_engine TEXT DEFAULT 'google'::text,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: phone_otp_codes
CREATE TABLE IF NOT EXISTS public.phone_otp_codes (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  phone TEXT NOT NULL,
  code TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (now() + '00:10:00'::interval),
  verified BOOLEAN DEFAULT false,
  attempts INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

-- Table: request_logs
CREATE TABLE IF NOT EXISTS public.request_logs (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID,
  request_type TEXT NOT NULL,
  command_used TEXT,
  scenario_triggered UUID,
  processing_time_ms INTEGER,
  tokens_used INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: daily_statistics
CREATE TABLE IF NOT EXISTS public.daily_statistics (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  date DATE NOT NULL,
  total_users INTEGER DEFAULT 0,
  new_users_today INTEGER DEFAULT 0,
  total_requests INTEGER DEFAULT 0,
  requests_today INTEGER DEFAULT 0,
  voice_requests_total INTEGER DEFAULT 0,
  voice_requests_today INTEGER DEFAULT 0,
  commands_used_total INTEGER DEFAULT 0,
  commands_used_today INTEGER DEFAULT 0,
  scenarios_triggered_total INTEGER DEFAULT 0,
  scenarios_triggered_today INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: admin_audit_log
CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  admin_user_id UUID NOT NULL,
  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- Table: admin_users_archived
CREATE TABLE IF NOT EXISTS public.admin_users_archived (
  id UUID DEFAULT gen_random_uuid() NOT NULL,
  user_id UUID NOT NULL,
  role TEXT DEFAULT 'admin'::text,
  permissions JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (id)
);

-- =============================================
-- STEP 4: Database Functions (13 functions)
-- NOTE: Functions must be created BEFORE RLS policies that reference them
-- =============================================

-- Function: is_admin_secure
CREATE OR REPLACE FUNCTION public.is_admin_secure(_user_id uuid DEFAULT auth.uid())
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = 'admin'::app_role
  )
$function$;

-- Function: has_role
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$function$;

-- Function: check_expired_subscriptions
CREATE OR REPLACE FUNCTION public.check_expired_subscriptions()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  expired_count INTEGER;
BEGIN
  -- Обновляем статус истёкших подписок на 'expired' и понижаем до guest
  UPDATE public.user_subscriptions
  SET 
    status = 'expired',
    updated_at = now()
  WHERE 
    status = 'active'
    AND expires_at IS NOT NULL
    AND expires_at < now();
  
  GET DIAGNOSTICS expired_count = ROW_COUNT;
  
  -- Логируем результат
  IF expired_count > 0 THEN
    RAISE NOTICE 'Expired % subscriptions', expired_count;
  END IF;
  
  -- Для истёкших подписок понижаем до guest
  UPDATE public.user_subscriptions
  SET 
    plan_type = 'guest',
    status = 'active',
    expires_at = NULL,
    updated_at = now(),
    last_checked_at = now()
  WHERE status = 'expired';
END;
$function$;

-- Function: reset_failed_tafsir_tasks
CREATE OR REPLACE FUNCTION public.reset_failed_tafsir_tasks(p_source_key text)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_count integer;
BEGIN
  UPDATE tafsir_processor
  SET 
    status = 'pending',
    attempts = 0,
    worker_id = NULL,
    locked_at = NULL,
    last_error = NULL,
    updated_at = NOW()
  WHERE source_key = p_source_key
    AND status IN ('failed', 'ai_retry');
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$function$;

-- Function: increment_user_usage
CREATE OR REPLACE FUNCTION public.increment_user_usage(p_user_id uuid, p_chat_requests integer DEFAULT 0, p_voice_requests integer DEFAULT 0, p_rag_requests integer DEFAULT 0, p_tokens integer DEFAULT 0)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_limit INTEGER;
  v_current INTEGER;
  v_plan_type subscription_plan;
BEGIN
  -- Получаем тип подписки
  SELECT COALESCE(us.plan_type, 'guest'::subscription_plan)
  INTO v_plan_type
  FROM public.user_subscriptions us
  WHERE us.user_id = p_user_id AND us.status = 'active';
  
  IF v_plan_type IS NULL THEN
    v_plan_type := 'guest';
  END IF;
  
  -- Проверяем лимит чат-запросов
  IF p_chat_requests > 0 THEN
    SELECT sl.daily_chat_requests INTO v_limit
    FROM public.subscription_limits sl
    WHERE sl.plan_type = v_plan_type;
    
    SELECT COALESCE(chat_requests, 0) INTO v_current
    FROM public.user_usage
    WHERE user_id = p_user_id AND usage_date = CURRENT_DATE;
    
    IF v_current >= v_limit THEN
      RETURN FALSE; -- Лимит превышен
    END IF;
  END IF;
  
  -- Вставляем или обновляем использование
  INSERT INTO public.user_usage (user_id, usage_date, chat_requests, voice_requests, rag_requests, total_tokens_used)
  VALUES (p_user_id, CURRENT_DATE, p_chat_requests, p_voice_requests, p_rag_requests, p_tokens)
  ON CONFLICT (user_id, usage_date)
  DO UPDATE SET
    chat_requests = user_usage.chat_requests + EXCLUDED.chat_requests,
    voice_requests = user_usage.voice_requests + EXCLUDED.voice_requests,
    rag_requests = user_usage.rag_requests + EXCLUDED.rag_requests,
    total_tokens_used = user_usage.total_tokens_used + EXCLUDED.total_tokens_used,
    updated_at = now();
  
  RETURN TRUE;
END;
$function$;

-- Function: get_table_columns
CREATE OR REPLACE FUNCTION public.get_table_columns()
 RETURNS TABLE(table_name text, column_name text, data_type text, column_default text, is_nullable text, udt_name text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT 
    c.table_name::text,
    c.column_name::text,
    c.data_type::text,
    c.column_default::text,
    c.is_nullable::text,
    c.udt_name::text
  FROM information_schema.columns c
  WHERE c.table_schema = 'public'
  ORDER BY c.table_name, c.ordinal_position
$function$;

-- Function: get_user_subscription_with_limits
CREATE OR REPLACE FUNCTION public.get_user_subscription_with_limits(p_user_id uuid)
 RETURNS TABLE(plan_type subscription_plan, status text, expires_at timestamp with time zone, daily_chat_requests integer, context_messages_limit integer, max_tokens_per_request integer, voice_enabled boolean, rag_search_enabled boolean, web_search_enabled boolean, diary_enabled boolean, ihsan_enabled boolean, medrese_enabled boolean, library_enabled boolean, psychologist_enabled boolean, favorites_storage_mb integer, today_chat_requests integer, model_router text, model_chat text, model_medrese text, model_diary text, model_help text, model_ihsan text, memory_enabled boolean, commands_enabled boolean, voice_commands_enabled boolean)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_plan_type subscription_plan;
BEGIN
  -- Получаем тип подписки пользователя
  SELECT COALESCE(us.plan_type, 'guest'::subscription_plan)
  INTO v_plan_type
  FROM public.user_subscriptions us
  WHERE us.user_id = p_user_id AND us.status = 'active'
  LIMIT 1;
  
  -- Если подписки нет, используем guest
  IF v_plan_type IS NULL THEN
    v_plan_type := 'guest';
  END IF;
  
  RETURN QUERY
  SELECT 
    v_plan_type,
    COALESCE(us.status, 'active')::TEXT,
    us.expires_at,
    sl.daily_chat_requests,
    sl.context_messages_limit,
    sl.max_tokens_per_request,
    sl.voice_enabled,
    sl.rag_search_enabled,
    sl.web_search_enabled,
    sl.diary_enabled,
    sl.ihsan_enabled,
    sl.medrese_enabled,
    sl.library_enabled,
    sl.psychologist_enabled,
    sl.favorites_storage_mb,
    COALESCE(uu.chat_requests, 0),
    sl.model_router,
    sl.model_chat,
    sl.model_medrese,
    sl.model_diary,
    sl.model_help,
    sl.model_ihsan,
    sl.memory_enabled,
    sl.commands_enabled,
    sl.voice_commands_enabled
  FROM public.subscription_limits sl
  LEFT JOIN public.user_subscriptions us ON us.user_id = p_user_id AND us.status = 'active'
  LEFT JOIN public.user_usage uu ON uu.user_id = p_user_id AND uu.usage_date = CURRENT_DATE
  WHERE sl.plan_type = v_plan_type;
END;
$function$;

-- Function: get_enum_types
CREATE OR REPLACE FUNCTION public.get_enum_types()
 RETURNS TABLE(type_name text, enum_labels text[])
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT 
    t.typname::text AS type_name,
    array_agg(e.enumlabel ORDER BY e.enumsortorder)::text[] AS enum_labels
  FROM pg_type t
  JOIN pg_enum e ON e.enumtypid = t.oid
  JOIN pg_namespace n ON n.oid = t.typnamespace
  WHERE n.nspname = 'public'
  GROUP BY t.typname
  ORDER BY t.typname
$function$;

-- Function: get_table_primary_keys
CREATE OR REPLACE FUNCTION public.get_table_primary_keys()
 RETURNS TABLE(table_name text, pk_columns text[])
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT
    tc.table_name::text,
    array_agg(kcu.column_name::text ORDER BY kcu.ordinal_position)::text[] AS pk_columns
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
   AND tc.table_name = kcu.table_name
  WHERE tc.table_schema = 'public'
    AND tc.constraint_type = 'PRIMARY KEY'
  GROUP BY tc.table_name
  ORDER BY tc.table_name
$function$;

-- Function: create_default_subscription
CREATE OR REPLACE FUNCTION public.create_default_subscription()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  INSERT INTO public.user_subscriptions (user_id, plan_type, status, started_at)
  VALUES (NEW.user_id, 'guest', 'active', now())
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$function$;

-- Function: claim_tafsir_task
CREATE OR REPLACE FUNCTION public.claim_tafsir_task(p_source_key text, p_worker_id text)
 RETURNS TABLE(id uuid, source_key text, surah integer, ayah_from integer, ayah_to integer, cleaned_text text, char_length integer, class text, status text, attempts integer, parent_tafsir_id uuid)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id uuid;
  v_lock_timeout interval := interval '5 minutes';
BEGIN
  -- Атомарно находим и блокируем одну запись (ai_chunk, long_chunk или mechanical_split)
  -- Приоритет: long_chunk и mechanical_split обрабатываем первыми (они уже предварительно разделены)
  SELECT tp.id INTO v_id
  FROM tafsir_processor tp
  WHERE tp.source_key = p_source_key
    AND tp.class IN ('ai_chunk', 'long_chunk', 'mechanical_split')
    AND tp.status IN ('pending', 'ai_retry')
    AND (tp.locked_at IS NULL OR tp.locked_at < NOW() - v_lock_timeout)
  ORDER BY 
    CASE 
      WHEN tp.class = 'long_chunk' THEN 0 
      WHEN tp.class = 'mechanical_split' THEN 1
      ELSE 2 
    END,
    tp.surah, tp.ayah_from
  LIMIT 1
  FOR UPDATE SKIP LOCKED;
  
  IF v_id IS NOT NULL THEN
    UPDATE tafsir_processor tp
    SET 
      status = 'ai_processing',
      worker_id = p_worker_id,
      locked_at = NOW(),
      updated_at = NOW()
    WHERE tp.id = v_id;
    
    RETURN QUERY
    SELECT 
      tp.id,
      tp.source_key,
      tp.surah,
      tp.ayah_from,
      tp.ayah_to,
      tp.cleaned_text,
      tp.char_length,
      tp.class,
      tp.status,
      tp.attempts,
      tp.parent_tafsir_id
    FROM tafsir_processor tp
    WHERE tp.id = v_id;
  END IF;
  
  RETURN;
END;
$function$;

-- Function: update_updated_at_column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

-- Function: handle_new_user
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  -- Создаём профиль
  INSERT INTO public.profiles (user_id, full_name, phone)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'full_name',
    NEW.phone
  );
  
  -- Создаём роль пользователя
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'user');
  
  -- Создаём подписку guest по умолчанию
  INSERT INTO public.user_subscriptions (user_id, plan_type, status, expires_at)
  VALUES (NEW.id, 'guest', 'active', NULL);
  
  RETURN NEW;
END;
$function$;

-- =============================================
-- STEP 5: RLS Policies (220 policies)
-- =============================================

-- profiles
ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile" ON public.profiles
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

-- user_roles
ALTER TABLE IF EXISTS public.user_roles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
CREATE POLICY "Users can view their own roles" ON public.user_roles
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;
CREATE POLICY "Admins can view all roles" ON public.user_roles
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role))
;

DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;
CREATE POLICY "Admins can manage roles" ON public.user_roles
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
;

-- conversations
ALTER TABLE IF EXISTS public.conversations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own conversations" ON public.conversations;
CREATE POLICY "Users can view their own conversations" ON public.conversations
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can create their own conversations" ON public.conversations;
CREATE POLICY "Users can create their own conversations" ON public.conversations
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own conversations" ON public.conversations;
CREATE POLICY "Users can update their own conversations" ON public.conversations
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can delete their own conversations" ON public.conversations;
CREATE POLICY "Users can delete their own conversations" ON public.conversations
  FOR DELETE
  USING ((auth.uid() = user_id))
;

-- messages
ALTER TABLE IF EXISTS public.messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON public.messages;
CREATE POLICY "Users can view messages in their conversations" ON public.messages
  FOR SELECT
  USING ((EXISTS ( SELECT 1
   FROM conversations
  WHERE ((conversations.id = messages.conversation_id) AND (conversations.user_id = auth.uid())))))
;

DROP POLICY IF EXISTS "Users can create messages in their conversations" ON public.messages;
CREATE POLICY "Users can create messages in their conversations" ON public.messages
  FOR INSERT
  WITH CHECK ((EXISTS ( SELECT 1
   FROM conversations
  WHERE ((conversations.id = messages.conversation_id) AND (conversations.user_id = auth.uid())))));

-- intentions
ALTER TABLE IF EXISTS public.intentions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can update their own intentions" ON public.intentions;
CREATE POLICY "Users can update their own intentions" ON public.intentions
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own intentions" ON public.intentions;
CREATE POLICY "Users can view their own intentions" ON public.intentions
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can create their own intentions" ON public.intentions;
CREATE POLICY "Users can create their own intentions" ON public.intentions
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can delete their own intentions" ON public.intentions;
CREATE POLICY "Users can delete their own intentions" ON public.intentions
  FOR DELETE
  USING ((auth.uid() = user_id))
;

-- subscription_plans
ALTER TABLE IF EXISTS public.subscription_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage plans" ON public.subscription_plans;
CREATE POLICY "Admins can manage plans" ON public.subscription_plans
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view active plans" ON public.subscription_plans;
CREATE POLICY "Anyone can view active plans" ON public.subscription_plans
  FOR SELECT
  USING ((is_active = true))
;

-- user_subscriptions
ALTER TABLE IF EXISTS public.user_subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can update subscriptions" ON public.user_subscriptions;
CREATE POLICY "Admins can update subscriptions" ON public.user_subscriptions
  FOR UPDATE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Admins can view all subscriptions" ON public.user_subscriptions;
CREATE POLICY "Admins can view all subscriptions" ON public.user_subscriptions
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Service role can manage subscriptions" ON public.user_subscriptions;
CREATE POLICY "Service role can manage subscriptions" ON public.user_subscriptions
  FOR ALL
  USING (true)
;

DROP POLICY IF EXISTS "Users can view their own subscription" ON public.user_subscriptions;
CREATE POLICY "Users can view their own subscription" ON public.user_subscriptions
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- subscription_features
ALTER TABLE IF EXISTS public.subscription_features ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage features" ON public.subscription_features;
CREATE POLICY "Admins can manage features" ON public.subscription_features
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view active features" ON public.subscription_features;
CREATE POLICY "Anyone can view active features" ON public.subscription_features
  FOR SELECT
  USING ((is_active = true))
;

-- big_intentions
ALTER TABLE IF EXISTS public.big_intentions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own big intentions" ON public.big_intentions;
CREATE POLICY "Users can create their own big intentions" ON public.big_intentions
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can delete their own big intentions" ON public.big_intentions;
CREATE POLICY "Users can delete their own big intentions" ON public.big_intentions
  FOR DELETE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can update their own big intentions" ON public.big_intentions;
CREATE POLICY "Users can update their own big intentions" ON public.big_intentions
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own big intentions" ON public.big_intentions;
CREATE POLICY "Users can view their own big intentions" ON public.big_intentions
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- notes
ALTER TABLE IF EXISTS public.notes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own notes" ON public.notes;
CREATE POLICY "Users can create their own notes" ON public.notes
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can delete their own notes" ON public.notes;
CREATE POLICY "Users can delete their own notes" ON public.notes
  FOR DELETE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can update their own notes" ON public.notes;
CREATE POLICY "Users can update their own notes" ON public.notes
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own notes" ON public.notes;
CREATE POLICY "Users can view their own notes" ON public.notes
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- diary_entries
ALTER TABLE IF EXISTS public.diary_entries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own diary entries" ON public.diary_entries;
CREATE POLICY "Users can create their own diary entries" ON public.diary_entries
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own diary entries" ON public.diary_entries;
CREATE POLICY "Users can update their own diary entries" ON public.diary_entries
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own diary entries" ON public.diary_entries;
CREATE POLICY "Users can view their own diary entries" ON public.diary_entries
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- daily_tasks
ALTER TABLE IF EXISTS public.daily_tasks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own daily tasks" ON public.daily_tasks;
CREATE POLICY "Users can create their own daily tasks" ON public.daily_tasks
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own daily tasks" ON public.daily_tasks;
CREATE POLICY "Users can update their own daily tasks" ON public.daily_tasks
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own daily tasks" ON public.daily_tasks;
CREATE POLICY "Users can view their own daily tasks" ON public.daily_tasks
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- daily_test_responses
ALTER TABLE IF EXISTS public.daily_test_responses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own test responses" ON public.daily_test_responses;
CREATE POLICY "Users can create their own test responses" ON public.daily_test_responses
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own test responses" ON public.daily_test_responses;
CREATE POLICY "Users can update their own test responses" ON public.daily_test_responses
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own test responses" ON public.daily_test_responses;
CREATE POLICY "Users can view their own test responses" ON public.daily_test_responses
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- schedule_events
ALTER TABLE IF EXISTS public.schedule_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own schedule events" ON public.schedule_events;
CREATE POLICY "Users can create their own schedule events" ON public.schedule_events
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can delete their own schedule events" ON public.schedule_events;
CREATE POLICY "Users can delete their own schedule events" ON public.schedule_events
  FOR DELETE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can update their own schedule events" ON public.schedule_events;
CREATE POLICY "Users can update their own schedule events" ON public.schedule_events
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own schedule events" ON public.schedule_events;
CREATE POLICY "Users can view their own schedule events" ON public.schedule_events
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- notification_settings
ALTER TABLE IF EXISTS public.notification_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can insert their own notification settings" ON public.notification_settings;
CREATE POLICY "Users can insert their own notification settings" ON public.notification_settings
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own notification settings" ON public.notification_settings;
CREATE POLICY "Users can update their own notification settings" ON public.notification_settings
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own notification settings" ON public.notification_settings;
CREATE POLICY "Users can view their own notification settings" ON public.notification_settings
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- notification_queue
ALTER TABLE IF EXISTS public.notification_queue ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view queued notifications" ON public.notification_queue;
CREATE POLICY "Users can view queued notifications" ON public.notification_queue
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notification_queue;
CREATE POLICY "Users can view their own notifications" ON public.notification_queue
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "notifications_service_delete" ON public.notification_queue;
CREATE POLICY "notifications_service_delete" ON public.notification_queue
  FOR DELETE
  USING (true)
;

DROP POLICY IF EXISTS "notifications_service_insert" ON public.notification_queue;
CREATE POLICY "notifications_service_insert" ON public.notification_queue
  FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "notifications_service_update" ON public.notification_queue;
CREATE POLICY "notifications_service_update" ON public.notification_queue
  FOR UPDATE
  USING (true)
;

-- chat_conversations
ALTER TABLE IF EXISTS public.chat_conversations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own conversations" ON public.chat_conversations;
CREATE POLICY "Users can create their own conversations" ON public.chat_conversations
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can delete their own conversations" ON public.chat_conversations;
CREATE POLICY "Users can delete their own conversations" ON public.chat_conversations
  FOR DELETE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can update their own conversations" ON public.chat_conversations;
CREATE POLICY "Users can update their own conversations" ON public.chat_conversations
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own conversations" ON public.chat_conversations;
CREATE POLICY "Users can view their own conversations" ON public.chat_conversations
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- section_admin_instructions
ALTER TABLE IF EXISTS public.section_admin_instructions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view instructions" ON public.section_admin_instructions;
CREATE POLICY "Anyone can view instructions" ON public.section_admin_instructions
  FOR SELECT
  USING (true)
;

DROP POLICY IF EXISTS "Admins can manage instructions" ON public.section_admin_instructions;
CREATE POLICY "Admins can manage instructions" ON public.section_admin_instructions
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

-- chat_messages
ALTER TABLE IF EXISTS public.chat_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create their own chat messages" ON public.chat_messages;
CREATE POLICY "Users can create their own chat messages" ON public.chat_messages
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can create their own messages" ON public.chat_messages;
CREATE POLICY "Users can create their own messages" ON public.chat_messages
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can delete their own messages" ON public.chat_messages;
CREATE POLICY "Users can delete their own messages" ON public.chat_messages
  FOR DELETE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can update their own chat messages" ON public.chat_messages;
CREATE POLICY "Users can update their own chat messages" ON public.chat_messages
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can update their own messages" ON public.chat_messages;
CREATE POLICY "Users can update their own messages" ON public.chat_messages
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own chat messages" ON public.chat_messages;
CREATE POLICY "Users can view their own chat messages" ON public.chat_messages
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own messages" ON public.chat_messages;
CREATE POLICY "Users can view their own messages" ON public.chat_messages
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- app_sections
ALTER TABLE IF EXISTS public.app_sections ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage sections" ON public.app_sections;
CREATE POLICY "Admins can manage sections" ON public.app_sections
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view active sections" ON public.app_sections;
CREATE POLICY "Anyone can view active sections" ON public.app_sections
  FOR SELECT
  USING ((is_active = true))
;

-- ai_scenarios
ALTER TABLE IF EXISTS public.ai_scenarios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "ai_scenarios_admin" ON public.ai_scenarios;
CREATE POLICY "ai_scenarios_admin" ON public.ai_scenarios
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "ai_scenarios_view" ON public.ai_scenarios;
CREATE POLICY "ai_scenarios_view" ON public.ai_scenarios
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- ai_commands
ALTER TABLE IF EXISTS public.ai_commands ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "ai_commands_admin" ON public.ai_commands;
CREATE POLICY "ai_commands_admin" ON public.ai_commands
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "ai_commands_view" ON public.ai_commands;
CREATE POLICY "ai_commands_view" ON public.ai_commands
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- ai_router_instructions
ALTER TABLE IF EXISTS public.ai_router_instructions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "ai_router_admin" ON public.ai_router_instructions;
CREATE POLICY "ai_router_admin" ON public.ai_router_instructions
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "ai_router_view" ON public.ai_router_instructions;
CREATE POLICY "ai_router_view" ON public.ai_router_instructions
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- llm_instructions
ALTER TABLE IF EXISTS public.llm_instructions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Only admins can view system settings" ON public.llm_instructions;
CREATE POLICY "Only admins can view system settings" ON public.llm_instructions
  FOR SELECT
  USING ((is_admin_secure(auth.uid()) OR (is_active = true)))
;

DROP POLICY IF EXISTS "llm_admin" ON public.llm_instructions;
CREATE POLICY "llm_admin" ON public.llm_instructions
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "llm_view" ON public.llm_instructions;
CREATE POLICY "llm_view" ON public.llm_instructions
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- llm_additional_prompts
ALTER TABLE IF EXISTS public.llm_additional_prompts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "llm_additional_prompts_admin" ON public.llm_additional_prompts;
CREATE POLICY "llm_additional_prompts_admin" ON public.llm_additional_prompts
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "llm_additional_prompts_view" ON public.llm_additional_prompts;
CREATE POLICY "llm_additional_prompts_view" ON public.llm_additional_prompts
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- section_llm_prompts
ALTER TABLE IF EXISTS public.section_llm_prompts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage LLM prompts" ON public.section_llm_prompts;
CREATE POLICY "Admins can manage LLM prompts" ON public.section_llm_prompts
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view prompts" ON public.section_llm_prompts;
CREATE POLICY "Anyone can view prompts" ON public.section_llm_prompts
  FOR SELECT
  USING (true)
;

-- section_router_prompts
ALTER TABLE IF EXISTS public.section_router_prompts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage router prompts" ON public.section_router_prompts;
CREATE POLICY "Admins can manage router prompts" ON public.section_router_prompts
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view router prompts" ON public.section_router_prompts;
CREATE POLICY "Anyone can view router prompts" ON public.section_router_prompts
  FOR SELECT
  USING (true)
;

-- section_capabilities
ALTER TABLE IF EXISTS public.section_capabilities ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage capabilities" ON public.section_capabilities;
CREATE POLICY "Admins can manage capabilities" ON public.section_capabilities
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view active capabilities" ON public.section_capabilities;
CREATE POLICY "Anyone can view active capabilities" ON public.section_capabilities
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- content_blocks
ALTER TABLE IF EXISTS public.content_blocks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "content_blocks_admin" ON public.content_blocks;
CREATE POLICY "content_blocks_admin" ON public.content_blocks
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "content_blocks_view" ON public.content_blocks;
CREATE POLICY "content_blocks_view" ON public.content_blocks
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- request_logs
ALTER TABLE IF EXISTS public.request_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role can insert request logs" ON public.request_logs;
CREATE POLICY "Service role can insert request logs" ON public.request_logs
  FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "request_logs_admin_delete" ON public.request_logs;
CREATE POLICY "request_logs_admin_delete" ON public.request_logs
  FOR DELETE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "request_logs_admin_select" ON public.request_logs;
CREATE POLICY "request_logs_admin_select" ON public.request_logs
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

-- admin_audit_log
ALTER TABLE IF EXISTS public.admin_audit_log ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role can insert audit logs" ON public.admin_audit_log;
CREATE POLICY "Service role can insert audit logs" ON public.admin_audit_log
  FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "admins_view_audit_log" ON public.admin_audit_log;
CREATE POLICY "admins_view_audit_log" ON public.admin_audit_log
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role))
;

DROP POLICY IF EXISTS "service_role_audit_log_insert" ON public.admin_audit_log;
CREATE POLICY "service_role_audit_log_insert" ON public.admin_audit_log
  FOR INSERT
  WITH CHECK (true);

-- admin_users_archived
ALTER TABLE IF EXISTS public.admin_users_archived ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Only admins can delete admin_users" ON public.admin_users_archived;
CREATE POLICY "Only admins can delete admin_users" ON public.admin_users_archived
  FOR DELETE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Only admins can insert admin_users" ON public.admin_users_archived;
CREATE POLICY "Only admins can insert admin_users" ON public.admin_users_archived
  FOR INSERT
  WITH CHECK (is_admin_secure(auth.uid()));

DROP POLICY IF EXISTS "Only admins can update admin_users" ON public.admin_users_archived;
CREATE POLICY "Only admins can update admin_users" ON public.admin_users_archived
  FOR UPDATE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Only admins can view admin_users" ON public.admin_users_archived;
CREATE POLICY "Only admins can view admin_users" ON public.admin_users_archived
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

-- daily_statistics
ALTER TABLE IF EXISTS public.daily_statistics ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "daily_stats_admin_view" ON public.daily_statistics;
CREATE POLICY "daily_stats_admin_view" ON public.daily_statistics
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "daily_stats_service" ON public.daily_statistics;
CREATE POLICY "daily_stats_service" ON public.daily_statistics
  FOR ALL
  WITH CHECK (true);

-- system_errors
ALTER TABLE IF EXISTS public.system_errors ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can update system errors" ON public.system_errors;
CREATE POLICY "Admins can update system errors" ON public.system_errors
  FOR UPDATE
  USING ((EXISTS ( SELECT 1
   FROM user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND (user_roles.role = 'admin'::app_role)))))
;

DROP POLICY IF EXISTS "Admins can view system errors" ON public.system_errors;
CREATE POLICY "Admins can view system errors" ON public.system_errors
  FOR SELECT
  USING ((EXISTS ( SELECT 1
   FROM user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND (user_roles.role = 'admin'::app_role)))))
;

DROP POLICY IF EXISTS "Admins can manage system errors" ON public.system_errors;
CREATE POLICY "Admins can manage system errors" ON public.system_errors
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

-- psychologists
ALTER TABLE IF EXISTS public.psychologists ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage psychologists" ON public.psychologists;
CREATE POLICY "Admins can manage psychologists" ON public.psychologists
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view active psychologists" ON public.psychologists;
CREATE POLICY "Anyone can view active psychologists" ON public.psychologists
  FOR SELECT
  USING ((is_active = true))
;

-- quran_audio
ALTER TABLE IF EXISTS public.quran_audio ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read quran_audio" ON public.quran_audio;
CREATE POLICY "Public read quran_audio" ON public.quran_audio
  FOR SELECT
  USING (true)
;

-- backups
ALTER TABLE IF EXISTS public.backups ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can create backups" ON public.backups;
CREATE POLICY "Admins can create backups" ON public.backups
  FOR INSERT
  WITH CHECK (is_admin_secure(auth.uid()));

DROP POLICY IF EXISTS "Admins can delete backups" ON public.backups;
CREATE POLICY "Admins can delete backups" ON public.backups
  FOR DELETE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Admins can update backups" ON public.backups;
CREATE POLICY "Admins can update backups" ON public.backups
  FOR UPDATE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Admins can view backups" ON public.backups;
CREATE POLICY "Admins can view backups" ON public.backups
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

-- backup_settings
ALTER TABLE IF EXISTS public.backup_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can update backup settings" ON public.backup_settings;
CREATE POLICY "Admins can update backup settings" ON public.backup_settings
  FOR UPDATE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Admins can view backup settings" ON public.backup_settings;
CREATE POLICY "Admins can view backup settings" ON public.backup_settings
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Service role can update backup settings" ON public.backup_settings;
CREATE POLICY "Service role can update backup settings" ON public.backup_settings
  FOR UPDATE
  USING (true)
;

-- phone_otp_codes
ALTER TABLE IF EXISTS public.phone_otp_codes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role can manage OTP codes" ON public.phone_otp_codes;
CREATE POLICY "Service role can manage OTP codes" ON public.phone_otp_codes
  FOR ALL
  USING (true)
;

-- support_tickets
ALTER TABLE IF EXISTS public.support_tickets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can update all tickets" ON public.support_tickets;
CREATE POLICY "Admins can update all tickets" ON public.support_tickets
  FOR UPDATE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Admins can view all tickets" ON public.support_tickets;
CREATE POLICY "Admins can view all tickets" ON public.support_tickets
  FOR SELECT
  USING ((is_admin_secure(auth.uid()) OR (auth.uid() = user_id)))
;

DROP POLICY IF EXISTS "Users can create their own tickets" ON public.support_tickets;
CREATE POLICY "Users can create their own tickets" ON public.support_tickets
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can view their own tickets" ON public.support_tickets;
CREATE POLICY "Users can view their own tickets" ON public.support_tickets
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- emotional_help
ALTER TABLE IF EXISTS public.emotional_help ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage emotions" ON public.emotional_help;
CREATE POLICY "Admins can manage emotions" ON public.emotional_help
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view active emotions" ON public.emotional_help;
CREATE POLICY "Anyone can view active emotions" ON public.emotional_help
  FOR SELECT
  USING ((is_active = true))
;

-- psychologist_conversations
ALTER TABLE IF EXISTS public.psychologist_conversations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view all psychologist conversations" ON public.psychologist_conversations;
CREATE POLICY "Admins can view all psychologist conversations" ON public.psychologist_conversations
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Users can create their own psychologist conversations" ON public.psychologist_conversations;
CREATE POLICY "Users can create their own psychologist conversations" ON public.psychologist_conversations
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own psychologist conversations" ON public.psychologist_conversations;
CREATE POLICY "Users can update their own psychologist conversations" ON public.psychologist_conversations
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can view their own psychologist conversations" ON public.psychologist_conversations;
CREATE POLICY "Users can view their own psychologist conversations" ON public.psychologist_conversations
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- psychologist_messages
ALTER TABLE IF EXISTS public.psychologist_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view all psychologist messages" ON public.psychologist_messages;
CREATE POLICY "Admins can view all psychologist messages" ON public.psychologist_messages
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Users can create their own psychologist messages" ON public.psychologist_messages;
CREATE POLICY "Users can create their own psychologist messages" ON public.psychologist_messages
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can view their own psychologist messages" ON public.psychologist_messages;
CREATE POLICY "Users can view their own psychologist messages" ON public.psychologist_messages
  FOR SELECT
  USING (((auth.uid() = user_id) OR (EXISTS ( SELECT 1
   FROM psychologist_conversations
  WHERE ((psychologist_conversations.id = psychologist_messages.conversation_id) AND (psychologist_conversations.user_id = auth.uid()))))))
;

-- courses
ALTER TABLE IF EXISTS public.courses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage courses" ON public.courses;
CREATE POLICY "Admins can manage courses" ON public.courses
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view active courses" ON public.courses;
CREATE POLICY "Anyone can view active courses" ON public.courses
  FOR SELECT
  USING ((is_active = true))
;

-- course_subscriptions
ALTER TABLE IF EXISTS public.course_subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage all subscriptions" ON public.course_subscriptions;
CREATE POLICY "Admins can manage all subscriptions" ON public.course_subscriptions
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Users can view their own subscriptions" ON public.course_subscriptions;
CREATE POLICY "Users can view their own subscriptions" ON public.course_subscriptions
  FOR SELECT
  USING ((auth.uid() = user_id))
;

-- web_search_settings
ALTER TABLE IF EXISTS public.web_search_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "web_search_settings_admin" ON public.web_search_settings;
CREATE POLICY "web_search_settings_admin" ON public.web_search_settings
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "web_search_settings_view" ON public.web_search_settings;
CREATE POLICY "web_search_settings_view" ON public.web_search_settings
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- web_search_logs
ALTER TABLE IF EXISTS public.web_search_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "web_search_logs_admin_delete" ON public.web_search_logs;
CREATE POLICY "web_search_logs_admin_delete" ON public.web_search_logs
  FOR DELETE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "web_search_logs_admin_select" ON public.web_search_logs;
CREATE POLICY "web_search_logs_admin_select" ON public.web_search_logs
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "web_search_logs_insert" ON public.web_search_logs;
CREATE POLICY "web_search_logs_insert" ON public.web_search_logs
  FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "web_search_logs_select_own" ON public.web_search_logs;
CREATE POLICY "web_search_logs_select_own" ON public.web_search_logs
  FOR SELECT
  USING (((auth.uid() = user_id) OR (user_id IS NULL)))
;

-- quran_surahs
ALTER TABLE IF EXISTS public.quran_surahs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage surahs" ON public.quran_surahs;
CREATE POLICY "Admins can manage surahs" ON public.quran_surahs
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view surahs" ON public.quran_surahs;
CREATE POLICY "Anyone can view surahs" ON public.quran_surahs
  FOR SELECT
  USING (true)
;

-- quran_verses
ALTER TABLE IF EXISTS public.quran_verses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage quran verses" ON public.quran_verses;
CREATE POLICY "Admins can manage quran verses" ON public.quran_verses
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view quran verses" ON public.quran_verses;
CREATE POLICY "Anyone can view quran verses" ON public.quran_verses
  FOR SELECT
  USING (true)
;

-- quran_verses_v2
ALTER TABLE IF EXISTS public.quran_verses_v2 ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage verses" ON public.quran_verses_v2;
CREATE POLICY "Admins can manage verses" ON public.quran_verses_v2
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view verses" ON public.quran_verses_v2;
CREATE POLICY "Anyone can view verses" ON public.quran_verses_v2
  FOR SELECT
  USING (true)
;

-- quran_sources
ALTER TABLE IF EXISTS public.quran_sources ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage sources" ON public.quran_sources;
CREATE POLICY "Admins can manage sources" ON public.quran_sources
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view enabled sources" ON public.quran_sources;
CREATE POLICY "Authenticated users can view enabled sources" ON public.quran_sources
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_enabled = true)))
;

-- quran_verse_translations
ALTER TABLE IF EXISTS public.quran_verse_translations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage translations" ON public.quran_verse_translations;
CREATE POLICY "Admins can manage translations" ON public.quran_verse_translations
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view translations" ON public.quran_verse_translations;
CREATE POLICY "Anyone can view translations" ON public.quran_verse_translations
  FOR SELECT
  USING (true)
;

-- quran_verse_tafsirs
ALTER TABLE IF EXISTS public.quran_verse_tafsirs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage tafsirs" ON public.quran_verse_tafsirs;
CREATE POLICY "Admins can manage tafsirs" ON public.quran_verse_tafsirs
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view tafsirs" ON public.quran_verse_tafsirs;
CREATE POLICY "Anyone can view tafsirs" ON public.quran_verse_tafsirs
  FOR SELECT
  USING (true)
;

-- quran_content_sources
ALTER TABLE IF EXISTS public.quran_content_sources ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage content sources" ON public.quran_content_sources;
CREATE POLICY "Admins can manage content sources" ON public.quran_content_sources
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Users can view content sources" ON public.quran_content_sources;
CREATE POLICY "Users can view content sources" ON public.quran_content_sources
  FOR SELECT
  USING ((is_enabled = true))
;

-- quran_tafsir_data
ALTER TABLE IF EXISTS public.quran_tafsir_data ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage tafsir data" ON public.quran_tafsir_data;
CREATE POLICY "Admins can manage tafsir data" ON public.quran_tafsir_data
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Users can view tafsir data" ON public.quran_tafsir_data;
CREATE POLICY "Users can view tafsir data" ON public.quran_tafsir_data
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- quran_pages
ALTER TABLE IF EXISTS public.quran_pages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read quran_pages" ON public.quran_pages;
CREATE POLICY "Public read quran_pages" ON public.quran_pages
  FOR SELECT
  USING (true)
;

-- quran_download_state
ALTER TABLE IF EXISTS public.quran_download_state ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read quran_download_state" ON public.quran_download_state;
CREATE POLICY "Public read quran_download_state" ON public.quran_download_state
  FOR SELECT
  USING (true)
;

DROP POLICY IF EXISTS "Service role manage download_state" ON public.quran_download_state;
CREATE POLICY "Service role manage download_state" ON public.quran_download_state
  FOR ALL
  USING ((auth.role() = 'service_role'::text))
;

-- quran_ayah_metadata
ALTER TABLE IF EXISTS public.quran_ayah_metadata ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage ayah metadata" ON public.quran_ayah_metadata;
CREATE POLICY "Admins can manage ayah metadata" ON public.quran_ayah_metadata
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view ayah metadata" ON public.quran_ayah_metadata;
CREATE POLICY "Authenticated users can view ayah metadata" ON public.quran_ayah_metadata
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

DROP POLICY IF EXISTS "Service role can manage ayah metadata" ON public.quran_ayah_metadata;
CREATE POLICY "Service role can manage ayah metadata" ON public.quran_ayah_metadata
  FOR ALL
  USING ((auth.role() = 'service_role'::text))
;

-- quran_raw_data
ALTER TABLE IF EXISTS public.quran_raw_data ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage quran raw data" ON public.quran_raw_data;
CREATE POLICY "Admins can manage quran raw data" ON public.quran_raw_data
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view quran raw data" ON public.quran_raw_data;
CREATE POLICY "Authenticated users can view quran raw data" ON public.quran_raw_data
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- quran_chunks
ALTER TABLE IF EXISTS public.quran_chunks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage quran chunks" ON public.quran_chunks;
CREATE POLICY "Admins can manage quran chunks" ON public.quran_chunks
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view quran chunks" ON public.quran_chunks;
CREATE POLICY "Authenticated users can view quran chunks" ON public.quran_chunks
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- tafsir_chunks
ALTER TABLE IF EXISTS public.tafsir_chunks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage tafsir chunks" ON public.tafsir_chunks;
CREATE POLICY "Admins can manage tafsir chunks" ON public.tafsir_chunks
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view tafsir chunks" ON public.tafsir_chunks;
CREATE POLICY "Authenticated users can view tafsir chunks" ON public.tafsir_chunks
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- hadith_items
ALTER TABLE IF EXISTS public.hadith_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage hadith items" ON public.hadith_items;
CREATE POLICY "Admins can manage hadith items" ON public.hadith_items
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view hadith items" ON public.hadith_items;
CREATE POLICY "Anyone can view hadith items" ON public.hadith_items
  FOR SELECT
  USING (true)
;

-- rag_sections
ALTER TABLE IF EXISTS public.rag_sections ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "rag_sections_admin" ON public.rag_sections;
CREATE POLICY "rag_sections_admin" ON public.rag_sections
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "rag_sections_view" ON public.rag_sections;
CREATE POLICY "rag_sections_view" ON public.rag_sections
  FOR SELECT
  USING (((auth.uid() IS NOT NULL) AND (is_active = true)))
;

-- rag_settings
ALTER TABLE IF EXISTS public.rag_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "rag_settings_admin" ON public.rag_settings;
CREATE POLICY "rag_settings_admin" ON public.rag_settings
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "rag_settings_view" ON public.rag_settings;
CREATE POLICY "rag_settings_view" ON public.rag_settings
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- library_books
ALTER TABLE IF EXISTS public.library_books ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage library books" ON public.library_books;
CREATE POLICY "Admins can manage library books" ON public.library_books
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view library books" ON public.library_books;
CREATE POLICY "Authenticated users can view library books" ON public.library_books
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- library_book_sources
ALTER TABLE IF EXISTS public.library_book_sources ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage book sources" ON public.library_book_sources;
CREATE POLICY "Admins can manage book sources" ON public.library_book_sources
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view book sources" ON public.library_book_sources;
CREATE POLICY "Authenticated users can view book sources" ON public.library_book_sources
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- rag_documents
ALTER TABLE IF EXISTS public.rag_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "rag_documents_admin" ON public.rag_documents;
CREATE POLICY "rag_documents_admin" ON public.rag_documents
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "rag_documents_view" ON public.rag_documents;
CREATE POLICY "rag_documents_view" ON public.rag_documents
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- rag_embeddings
ALTER TABLE IF EXISTS public.rag_embeddings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "rag_embeddings_admin" ON public.rag_embeddings;
CREATE POLICY "rag_embeddings_admin" ON public.rag_embeddings
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "rag_embeddings_view" ON public.rag_embeddings;
CREATE POLICY "rag_embeddings_view" ON public.rag_embeddings
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- rag_chunks
ALTER TABLE IF EXISTS public.rag_chunks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage rag chunks" ON public.rag_chunks;
CREATE POLICY "Admins can manage rag chunks" ON public.rag_chunks
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Authenticated users can view rag chunks" ON public.rag_chunks;
CREATE POLICY "Authenticated users can view rag chunks" ON public.rag_chunks
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

-- chunking_queue
ALTER TABLE IF EXISTS public.chunking_queue ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can delete from chunking queue" ON public.chunking_queue;
CREATE POLICY "Admins can delete from chunking queue" ON public.chunking_queue
  FOR DELETE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Admins can view chunking queue" ON public.chunking_queue;
CREATE POLICY "Admins can view chunking queue" ON public.chunking_queue
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Service role can manage chunking queue" ON public.chunking_queue;
CREATE POLICY "Service role can manage chunking queue" ON public.chunking_queue
  FOR ALL
  USING ((auth.role() = 'service_role'::text))
;

-- content_source_configs
ALTER TABLE IF EXISTS public.content_source_configs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage configs" ON public.content_source_configs;
CREATE POLICY "Admins can manage configs" ON public.content_source_configs
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Service role access" ON public.content_source_configs;
CREATE POLICY "Service role access" ON public.content_source_configs
  FOR ALL
  USING ((auth.role() = 'service_role'::text))
;

-- temp_book_downloads
ALTER TABLE IF EXISTS public.temp_book_downloads ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage temp downloads" ON public.temp_book_downloads;
CREATE POLICY "Admins can manage temp downloads" ON public.temp_book_downloads
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

-- telegram_channel_posts
ALTER TABLE IF EXISTS public.telegram_channel_posts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage posts" ON public.telegram_channel_posts;
CREATE POLICY "Admins can manage posts" ON public.telegram_channel_posts
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view posts" ON public.telegram_channel_posts;
CREATE POLICY "Anyone can view posts" ON public.telegram_channel_posts
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

DROP POLICY IF EXISTS "Service role can insert posts" ON public.telegram_channel_posts;
CREATE POLICY "Service role can insert posts" ON public.telegram_channel_posts
  FOR INSERT
  WITH CHECK (true);

-- telegram_comments
ALTER TABLE IF EXISTS public.telegram_comments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage comments" ON public.telegram_comments;
CREATE POLICY "Admins can manage comments" ON public.telegram_comments
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view comments" ON public.telegram_comments;
CREATE POLICY "Anyone can view comments" ON public.telegram_comments
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

DROP POLICY IF EXISTS "Service role can insert comments" ON public.telegram_comments;
CREATE POLICY "Service role can insert comments" ON public.telegram_comments
  FOR INSERT
  WITH CHECK (true);

-- telegram_ai_responses
ALTER TABLE IF EXISTS public.telegram_ai_responses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can update moderation" ON public.telegram_ai_responses;
CREATE POLICY "Admins can update moderation" ON public.telegram_ai_responses
  FOR UPDATE
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Admins can view ai responses" ON public.telegram_ai_responses;
CREATE POLICY "Admins can view ai responses" ON public.telegram_ai_responses
  FOR SELECT
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Service role can manage ai responses" ON public.telegram_ai_responses;
CREATE POLICY "Service role can manage ai responses" ON public.telegram_ai_responses
  FOR ALL
  WITH CHECK (true);

-- telegram_conversation_context
ALTER TABLE IF EXISTS public.telegram_conversation_context ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage conversation context" ON public.telegram_conversation_context;
CREATE POLICY "Admins can manage conversation context" ON public.telegram_conversation_context
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

DROP POLICY IF EXISTS "Anyone can view conversation context" ON public.telegram_conversation_context;
CREATE POLICY "Anyone can view conversation context" ON public.telegram_conversation_context
  FOR SELECT
  USING ((auth.uid() IS NOT NULL))
;

DROP POLICY IF EXISTS "Service role can manage conversation context" ON public.telegram_conversation_context;
CREATE POLICY "Service role can manage conversation context" ON public.telegram_conversation_context
  FOR ALL
  WITH CHECK (true);

-- telegram_blocked_users
ALTER TABLE IF EXISTS public.telegram_blocked_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage blocked users" ON public.telegram_blocked_users;
CREATE POLICY "Admins can manage blocked users" ON public.telegram_blocked_users
  FOR ALL
  USING (is_admin_secure(auth.uid()))
;

-- telegram_rate_limit
ALTER TABLE IF EXISTS public.telegram_rate_limit ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "service_role_telegram_rate_limit" ON public.telegram_rate_limit;
CREATE POLICY "service_role_telegram_rate_limit" ON public.telegram_rate_limit
  FOR ALL
  WITH CHECK (true);

-- ihsan_plans
ALTER TABLE IF EXISTS public.ihsan_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own ihsan plans" ON public.ihsan_plans;
CREATE POLICY "Users can view their own ihsan plans" ON public.ihsan_plans
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can create their own ihsan plans" ON public.ihsan_plans;
CREATE POLICY "Users can create their own ihsan plans" ON public.ihsan_plans
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own ihsan plans" ON public.ihsan_plans;
CREATE POLICY "Users can update their own ihsan plans" ON public.ihsan_plans
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can delete their own ihsan plans" ON public.ihsan_plans;
CREATE POLICY "Users can delete their own ihsan plans" ON public.ihsan_plans
  FOR DELETE
  USING ((auth.uid() = user_id))
;

-- system_settings
ALTER TABLE IF EXISTS public.system_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can manage system_settings" ON public.system_settings;
CREATE POLICY "Admins can manage system_settings" ON public.system_settings
  FOR ALL
  USING (is_admin_secure())
;

-- user_usage
ALTER TABLE IF EXISTS public.user_usage ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own usage" ON public.user_usage;
CREATE POLICY "Users can view their own usage" ON public.user_usage
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Service role can manage all usage" ON public.user_usage;
CREATE POLICY "Service role can manage all usage" ON public.user_usage
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- ihsan_user_plans
ALTER TABLE IF EXISTS public.ihsan_user_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own ihsan plans" ON public.ihsan_user_plans;
CREATE POLICY "Users can view their own ihsan plans" ON public.ihsan_user_plans
  FOR SELECT
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can create their own ihsan plans" ON public.ihsan_user_plans;
CREATE POLICY "Users can create their own ihsan plans" ON public.ihsan_user_plans
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

DROP POLICY IF EXISTS "Users can update their own ihsan plans" ON public.ihsan_user_plans;
CREATE POLICY "Users can update their own ihsan plans" ON public.ihsan_user_plans
  FOR UPDATE
  USING ((auth.uid() = user_id))
;

DROP POLICY IF EXISTS "Users can delete their own ihsan plans" ON public.ihsan_user_plans;
CREATE POLICY "Users can delete their own ihsan plans" ON public.ihsan_user_plans
  FOR DELETE
  USING ((auth.uid() = user_id))
;

-- ihsan_character
ALTER TABLE IF EXISTS public.ihsan_character ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read active ihsan characters" ON public.ihsan_character;
CREATE POLICY "Anyone can read active ihsan characters" ON public.ihsan_character
  FOR SELECT
  USING (true)
;

DROP POLICY IF EXISTS "Admins can manage ihsan characters" ON public.ihsan_character;
CREATE POLICY "Admins can manage ihsan characters" ON public.ihsan_character
  FOR ALL
  USING ((EXISTS ( SELECT 1
   FROM profiles
  WHERE (profiles.user_id = auth.uid()))))
;

-- section_prompts
ALTER TABLE IF EXISTS public.section_prompts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read section_prompts" ON public.section_prompts;
CREATE POLICY "Anyone can read section_prompts" ON public.section_prompts
  FOR SELECT
  USING (true)
;

DROP POLICY IF EXISTS "Authenticated users can modify section_prompts" ON public.section_prompts;
CREATE POLICY "Authenticated users can modify section_prompts" ON public.section_prompts
  FOR ALL
  USING ((auth.role() = 'authenticated'::text))
  WITH CHECK ((auth.role() = 'authenticated'::text));

-- subscription_limits
ALTER TABLE IF EXISTS public.subscription_limits ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view limits" ON public.subscription_limits;
CREATE POLICY "Anyone can view limits" ON public.subscription_limits
  FOR SELECT
  USING (true)
;

DROP POLICY IF EXISTS "Admins can manage limits" ON public.subscription_limits;
CREATE POLICY "Admins can manage limits" ON public.subscription_limits
  FOR ALL
  USING (is_admin_secure())
;

-- subscription_system_messages
ALTER TABLE IF EXISTS public.subscription_system_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Все пользователи могут читать соо" ON public.subscription_system_messages;
CREATE POLICY "Все пользователи могут читать соо" ON public.subscription_system_messages
  FOR SELECT
  USING (true)
;

-- chunking_methods
ALTER TABLE IF EXISTS public.chunking_methods ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Chunking methods viewable by all" ON public.chunking_methods;
CREATE POLICY "Chunking methods viewable by all" ON public.chunking_methods
  FOR SELECT
  USING (true)
;

-- tafsir_processor
ALTER TABLE IF EXISTS public.tafsir_processor ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Service role can manage tafsir_processor" ON public.tafsir_processor;
CREATE POLICY "Service role can manage tafsir_processor" ON public.tafsir_processor
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- =============================================
-- INITIALIZATION COMPLETE
-- =============================================
