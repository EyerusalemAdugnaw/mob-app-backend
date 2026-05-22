import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function testTransfers() {
  const { data: transfers, error } = await supabase.from('transfers').select('*');
  console.log("Transfers:", transfers, "Error:", error);
}
testTransfers();
