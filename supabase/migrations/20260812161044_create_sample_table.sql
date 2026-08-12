-- Create sample test table for Supabase migration testing
CREATE TABLE test_table (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on email for faster lookups
CREATE INDEX idx_test_table_email ON test_table(email);

-- Create index on status for filtering
CREATE INDEX idx_test_table_status ON test_table(status);

-- Insert sample test data
INSERT INTO test_table (name, email, description, status) VALUES
('John Doe', 'john@example.com', 'Test user one', 'active'),
('Jane Smith', 'jane@example.com', 'Test user two', 'active'),
('Bob Johnson', 'bob@example.com', 'Test user three', 'inactive');
