import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function testRecs() {
  const product_id = 'c100fcde-b6d0-42e2-830f-9622f087c3e5';
  const branchId = '4c283eb2-d9b4-454c-b41a-d04ac3e47b0a'; // bahirdar
  const quantity = 10;
  const type = 'request';

  const { data: branches } = await supabase.from('branches').select('*');
  const { data: invData } = await supabase.from('branch_inventory').select('branch_id, stock').eq('product_id', product_id);

  const branchStockMap = {};
  (invData || []).forEach(item => {
    if (!branchStockMap[item.branch_id]) branchStockMap[item.branch_id] = 0;
    branchStockMap[item.branch_id] += Number(item.stock);
  });

  let recs = (branches || [])
    .filter(b => b.id !== branchId)
    .map(b => ({
      branch_id: b.id,
      branch_name: b.name,
      available_stock: branchStockMap[b.id] || 0
    }));

  if (type === 'request') {
    recs = recs.filter(b => b.available_stock >= quantity);
    recs.sort((a, b) => b.available_stock - a.available_stock);
  } else {
    recs.sort((a, b) => a.available_stock - b.available_stock);
  }
  console.log("Recommendations:", recs);
}
testRecs();
