import cron from 'node-cron';
import { getSupabaseAdmin } from '../lib/supabaseAdmin.js';
import { sendPushNotification } from '../lib/pushNotification.js';

// This job runs every day at 8:00 AM. 
// For testing purposes, you can change '0 8 * * *' to '* * * * *' to run every minute.
export const startExpiryCronJob = () => {
  console.log('🕒 Expiry Cron Job scheduled to run daily at 8:00 AM.');

  cron.schedule('0 8 * * *', async () => {
    console.log('🔍 Running scheduled Expiry Check...');

    try {
      const supabaseAdmin = getSupabaseAdmin();
      
      // 1. Fetch all inventory that has stock > 0
      const { data: inventory, error: invError } = await supabaseAdmin
        .from('branch_inventory')
        .select(`
          id,
          batch_number,
          expiry_date,
          stock,
          product_id,
          products ( name ),
          branch_id
        `)
        .gt('stock', 0);

      if (invError) throw invError;

      if (!inventory || inventory.length === 0) {
        console.log('No active inventory found.');
        return;
      }

      const today = new Date();
      const threeDaysFromNow = new Date();
      threeDaysFromNow.setDate(today.getDate() + 3);

      for (const item of inventory) {
        if (!item.expiry_date) continue;
        
        const expiryDate = new Date(item.expiry_date);
        const productName = item.products?.name || 'Unknown Product';
        let notificationTitle = '';
        let notificationBody = '';

        // Check if expired
        if (expiryDate < today) {
          notificationTitle = 'Product Expired';
          notificationBody = `🛑 ${productName} ${item.batch_number ? '(Batch '+item.batch_number+') ' : ''}has expired!`;
        } 
        // Check if near expiry
        else if (expiryDate <= threeDaysFromNow) {
          notificationTitle = 'Near Expiry Alert';
          notificationBody = `⚠️ ${productName} ${item.batch_number ? '(Batch '+item.batch_number+') ' : ''}is near expiry.`;
        }

        if (notificationBody && item.branch_id) {
          // Find managers for this branch
          const { data: managers } = await supabaseAdmin
            .from('profiles')
            .select('fcm_token')
            .eq('branch_id', item.branch_id)
            .eq('role', 'branch_manager')
            .not('fcm_token', 'is', null);

          if (managers && managers.length > 0) {
            for (const manager of managers) {
              if (manager.fcm_token) {
                await sendPushNotification(manager.fcm_token, notificationTitle, notificationBody, { inventoryId: item.id });
              }
            }
          }
        }
      }

      console.log('✅ Expiry Check completed.');

    } catch (err) {
      console.error('❌ Error during Expiry Cron Job:', err);
    }
  });
};
