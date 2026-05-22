import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function test() {
  const { data: branches } = await supabase.from('branches').select('*');
  console.log("Branches:", branches);
  const { data: inventory } = await supabase.from('branch_inventory').select('id, branch_id, product_id, stock');
  console.log("Inventory:", inventory);
}
test();
