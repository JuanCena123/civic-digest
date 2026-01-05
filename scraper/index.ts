import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

// URL tells the client what db to connect to
// KEY gives client access to db
const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

// function to test connection to supabase
async function testConnection() {
  const { data, error } = await supabase
    .from('documents')
    .select('id')
    .limit(1);

  if (error) {
    console.error('❌ Supabase error:', error);
  } else {
    console.log('✅ Supabase connected. Sample data:', data);
  }
}

testConnection();
