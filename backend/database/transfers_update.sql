-- Add a column to track who initiated the transfer (a 'send' or a 'request')
ALTER TABLE transfers ADD COLUMN IF NOT EXISTS transfer_type VARCHAR(50) DEFAULT 'send';
