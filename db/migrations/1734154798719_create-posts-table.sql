-- Up Migration
CREATE TABLE IF NOT EXISTS "posts" (
  id VARCHAR(50) NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ,
  PRIMARY KEY (id)
);

-- Down Migration
DROP TABLE IF EXISTS "posts"