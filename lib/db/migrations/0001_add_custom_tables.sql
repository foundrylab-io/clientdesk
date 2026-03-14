CREATE TABLE IF NOT EXISTS agencies (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  name varchar(100) NOT NULL,
  logo text,
  brand_color varchar(7),
  stripe_connect_account_id text,
  stripe_connect_onboarded boolean DEFAULT false,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS clients (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  agency_id integer NOT NULL,
  name varchar(100) NOT NULL,
  email varchar(255) NOT NULL,
  company varchar(100),
  phone varchar(20),
  status varchar(20) NOT NULL DEFAULT 'active',
  invited_at timestamp,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS projects (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  agency_id integer NOT NULL,
  client_id integer NOT NULL,
  name varchar(100) NOT NULL,
  description text,
  status varchar(20) NOT NULL DEFAULT 'active',
  start_date date,
  end_date date,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS proposals (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  agency_id integer NOT NULL,
  project_id integer NOT NULL,
  client_id integer NOT NULL,
  title varchar(200) NOT NULL,
  description text,
  terms text,
  total_amount numeric(10, 2) NOT NULL,
  status varchar(20) NOT NULL DEFAULT 'draft',
  shareable_token varchar(100) UNIQUE,
  expiry_date date,
  approved_at timestamp,
  rejected_at timestamp,
  rejection_reason text,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS proposal_line_items (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  proposal_id integer NOT NULL,
  description varchar(200) NOT NULL,
  quantity numeric(8, 2) NOT NULL,
  rate numeric(10, 2) NOT NULL,
  total numeric(10, 2) NOT NULL,
  created_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS invoices (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  agency_id integer NOT NULL,
  project_id integer NOT NULL,
  client_id integer NOT NULL,
  proposal_id integer,
  invoice_number varchar(50) NOT NULL UNIQUE,
  title varchar(200) NOT NULL,
  description text,
  total_amount numeric(10, 2) NOT NULL,
  status varchar(20) NOT NULL DEFAULT 'unpaid',
  due_date date NOT NULL,
  stripe_payment_intent_id text,
  stripe_payment_link_id text,
  paid_at timestamp,
  notes text,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS invoice_line_items (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  invoice_id integer NOT NULL,
  description varchar(200) NOT NULL,
  quantity numeric(8, 2) NOT NULL,
  rate numeric(10, 2) NOT NULL,
  total numeric(10, 2) NOT NULL,
  created_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS files (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  agency_id integer NOT NULL,
  project_id integer NOT NULL,
  file_name varchar(255) NOT NULL,
  original_name varchar(255) NOT NULL,
  file_type varchar(100) NOT NULL,
  file_size integer NOT NULL,
  storage_path text NOT NULL,
  uploaded_by integer NOT NULL,
  created_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS activity_feed (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  agency_id integer NOT NULL,
  project_id integer NOT NULL,
  actor_id integer NOT NULL,
  actor_name varchar(100) NOT NULL,
  event_type varchar(50) NOT NULL,
  description text NOT NULL,
  metadata text,
  created_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS notifications (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  agency_id integer NOT NULL,
  type varchar(50) NOT NULL,
  title varchar(200) NOT NULL,
  message text NOT NULL,
  is_read boolean DEFAULT false,
  metadata text,
  created_at timestamp NOT NULL DEFAULT now()
);
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE agencies ADD CONSTRAINT agencies_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE clients ADD CONSTRAINT clients_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE clients ADD CONSTRAINT clients_agency_id_agencies_id_fk FOREIGN KEY (agency_id) REFERENCES agencies(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE projects ADD CONSTRAINT projects_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE projects ADD CONSTRAINT projects_agency_id_agencies_id_fk FOREIGN KEY (agency_id) REFERENCES agencies(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE projects ADD CONSTRAINT projects_client_id_clients_id_fk FOREIGN KEY (client_id) REFERENCES clients(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE proposals ADD CONSTRAINT proposals_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE proposals ADD CONSTRAINT proposals_agency_id_agencies_id_fk FOREIGN KEY (agency_id) REFERENCES agencies(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE proposals ADD CONSTRAINT proposals_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE proposals ADD CONSTRAINT proposals_client_id_clients_id_fk FOREIGN KEY (client_id) REFERENCES clients(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE proposal_line_items ADD CONSTRAINT proposal_line_items_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE proposal_line_items ADD CONSTRAINT proposal_line_items_proposal_id_proposals_id_fk FOREIGN KEY (proposal_id) REFERENCES proposals(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE invoices ADD CONSTRAINT invoices_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE invoices ADD CONSTRAINT invoices_agency_id_agencies_id_fk FOREIGN KEY (agency_id) REFERENCES agencies(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE invoices ADD CONSTRAINT invoices_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE invoices ADD CONSTRAINT invoices_client_id_clients_id_fk FOREIGN KEY (client_id) REFERENCES clients(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE invoices ADD CONSTRAINT invoices_proposal_id_proposals_id_fk FOREIGN KEY (proposal_id) REFERENCES proposals(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE invoice_line_items ADD CONSTRAINT invoice_line_items_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE invoice_line_items ADD CONSTRAINT invoice_line_items_invoice_id_invoices_id_fk FOREIGN KEY (invoice_id) REFERENCES invoices(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE files ADD CONSTRAINT files_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE files ADD CONSTRAINT files_agency_id_agencies_id_fk FOREIGN KEY (agency_id) REFERENCES agencies(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE files ADD CONSTRAINT files_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE files ADD CONSTRAINT files_uploaded_by_users_id_fk FOREIGN KEY (uploaded_by) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE activity_feed ADD CONSTRAINT activity_feed_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE activity_feed ADD CONSTRAINT activity_feed_agency_id_agencies_id_fk FOREIGN KEY (agency_id) REFERENCES agencies(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE activity_feed ADD CONSTRAINT activity_feed_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE activity_feed ADD CONSTRAINT activity_feed_actor_id_users_id_fk FOREIGN KEY (actor_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE notifications ADD CONSTRAINT notifications_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES users(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  ALTER TABLE notifications ADD CONSTRAINT notifications_agency_id_agencies_id_fk FOREIGN KEY (agency_id) REFERENCES agencies(id);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;