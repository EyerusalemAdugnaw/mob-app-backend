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
      
      // 1. Fetch all batches that are currently active
      const { data: batches, error: batchError } = await supabaseAdmin
        .from('batches')
        .select(`
          id,
          batch_number,
          expiry_date,
          status,
          product_id,
          products ( name ),
          branch_id
        `)
        .eq('status', 'active');

      if (batchError) throw batchError;

      if (!batches || batches.length === 0) {
        console.log('No active batches found.');
        return;
      }

      const today = new Date();
      const threeDaysFromNow = new Date();
      threeDaysFromNow.setDate(today.getDate() + 3);

      for (const batch of batches) {
        const expiryDate = new Date(batch.expiry_date);
        const productName = batch.products?.name || 'Unknown Product';
        let notificationTitle = '';
        let notificationBody = '';

        // Check if expired
        if (expiryDate < today) {
          notificationTitle = 'Product Expired';
          notificationBody = `🛑 ${productName} batch ${batch.batch_number} has expired.`;
          
          // Optionally, update batch status to expired in DB here
          await supabaseAdmin.from('batches').update({ status: 'expired' }).eq('id', batch.id);

        } 
        // Check if near expiry (within 3 days and hasn't expired yet)
        else if (expiryDate <= threeDaysFromNow) {
          notificationTitle = 'Near Expiry Alert';
          notificationBody = `⚠️ ${productName} batch ${batch.batch_number} is near expiry.`;
        }

        // If we need to send a notification
        if (notificationBody && batch.branch_id) {
          // Find the branch manager for this branch
          const { data: branch, error: branchError } = await supabaseAdmin
            .from('branches')
            .select('manager_id')
            .eq('id', batch.branch_id)
            .single();
            
          if (!branchError && branch?.manager_id) {
            // Find the manager's FCM token
            const { data: profile } = await supabaseAdmin
              .from('profiles')
              .select('fcm_token')
              .eq('id', branch.manager_id)
              .single();
              
            if (profile?.fcm_token) {
              await sendPushNotification(profile.fcm_token, notificationTitle, notificationBody, { batchId: batch.id });
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
