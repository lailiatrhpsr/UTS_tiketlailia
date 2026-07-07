
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  username text NOT NULL UNIQUE,
  email text NOT NULL,
  role text NOT NULL DEFAULT 'user'::text CHECK (role = ANY (ARRAY['user'::text, 'admin'::text, 'helpdesk'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  full_name text,
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.tickets (
  id text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  status text NOT NULL DEFAULT 'open'::text CHECK (status = ANY (ARRAY['open'::text, 'assigned'::text, 'inProgress'::text, 'closed'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  attachment_path text,
  created_by uuid NOT NULL,
  assigned_helpdesk uuid,
  reporter_name text,
  channel text,
  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT tickets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id),
  CONSTRAINT tickets_assigned_helpdesk_fkey FOREIGN KEY (assigned_helpdesk) REFERENCES public.profiles(id)
);
CREATE TABLE public.ticket_comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id text NOT NULL,
  author_id uuid NOT NULL,
  message text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_comments_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_comments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.ticket_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id text NOT NULL,
  label text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_history_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_history_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.ticket_reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id text NOT NULL,
  helpdesk_id uuid NOT NULL,
  description text NOT NULL,
  photo_url text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ticket_reports_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_reports_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_reports_helpdesk_id_fkey FOREIGN KEY (helpdesk_id) REFERENCES public.profiles(id)
);