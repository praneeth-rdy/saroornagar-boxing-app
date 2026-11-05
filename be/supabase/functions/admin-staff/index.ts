// admin-staff: an admin creates staff accounts, resets their passwords and blocks or
// unblocks them. The Auth admin API needs the service role, which must never reach the app,
// so these actions live here instead of in SQL functions.

import { createClient, type SupabaseClient } from '@supabase/supabase-js';

type ErrorCode = 'BXPRM' | 'BXVAL' | 'BXNTF' | 'BXDUP' | 'BXERR';
type StaffRole = 'admin' | 'coach';

interface Profile {
  id: string;
  full_name: string;
  phone: string;
  role: StaffRole;
  is_blocked: boolean;
  created_at: string;
  updated_at: string;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  // x-client-info is sent by the Supabase client libraries on every call.
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Long enough to be permanent; "none" lifts it.
const BAN_FOREVER = '876000h';
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const MAX_BODY_BYTES = 16 * 1024;

// Thrown for any expected failure; the handler turns it into the JSON error body.
class HttpError extends Error {
  constructor(readonly status: number, readonly code: ErrorCode, message: string) {
    super(message);
  }
}

const invalid = (message: string) => new HttpError(400, 'BXVAL', message);

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing environment variable ${name}`);
  return value;
}

// Character count as Postgres sees it (code points), not UTF-16 units.
const charLength = (value: string) => Array.from(value).length;

// Same rule as private.normalize_phone: digits only, 10 digits get the 91 prefix.
function normalizePhone(value: unknown): string {
  const digits = typeof value === 'string' ? value.replace(/[^0-9]/g, '') : '';
  if (digits.length === 10) return `91${digits}`;
  if (digits.length === 12 && digits.startsWith('91')) return digits;
  throw invalid('Enter a 10-digit mobile number');
}

function requireFullName(value: unknown): string {
  const name = typeof value === 'string' ? value.trim() : '';
  const length = charLength(name);
  if (length < 2 || length > 80) throw invalid('Enter a name between 2 and 80 characters');
  return name;
}

// Auth hashes with bcrypt, which reads at most 72 bytes, so the upper bound is in bytes too.
function requirePassword(value: unknown): string {
  if (
    typeof value !== 'string' ||
    charLength(value) < 8 ||
    new TextEncoder().encode(value).length > 72
  ) {
    throw invalid('Enter a password of 8 to 72 characters');
  }
  return value;
}

function requireRole(value: unknown): StaffRole {
  if (value === 'admin' || value === 'coach') return value;
  throw invalid('Choose a role');
}

function requireUserId(value: unknown): string {
  if (typeof value === 'string' && UUID_PATTERN.test(value)) return value.toLowerCase();
  throw invalid('Choose a staff member');
}

function requireBoolean(value: unknown): boolean {
  if (typeof value === 'boolean') return value;
  throw invalid('Choose block or unblock');
}

async function readBody(req: Request): Promise<Record<string, unknown>> {
  const text = await req.text();
  if (new TextEncoder().encode(text).length > MAX_BODY_BYTES) {
    throw invalid('The request is too large');
  }
  let body: unknown;
  try {
    body = JSON.parse(text);
  } catch {
    throw invalid('Send a JSON body');
  }
  if (body === null || typeof body !== 'object' || Array.isArray(body)) {
    throw invalid('Send a JSON body');
  }
  return body as Record<string, unknown>;
}

async function findProfile(admin: SupabaseClient, userId: string): Promise<Profile | null> {
  const { data, error } = await admin
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .maybeSingle<Profile>();
  if (error) throw error;
  return data;
}

async function requireProfile(admin: SupabaseClient, userId: string): Promise<Profile> {
  const profile = await findProfile(admin, userId);
  if (!profile) throw new HttpError(404, 'BXNTF', 'Staff member not found');
  return profile;
}

// Returns the caller's id, or fails with 401 when the token is missing, expired or revoked.
async function authenticate(req: Request, url: string, anonKey: string): Promise<string> {
  const header = req.headers.get('Authorization') ?? '';
  const match = header.match(/^Bearer\s+(\S+)$/i);
  const signInAgain = new HttpError(401, 'BXPRM', 'Sign in again');
  if (!match) throw signInAgain;

  const userClient = createClient(url, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
    global: { headers: { Authorization: header } },
  });
  const { data, error } = await userClient.auth.getUser(match[1]);
  if (error) {
    // An Auth outage is not the caller's fault; report it as a server error, not a sign-out.
    const status = (error as { status?: number }).status;
    if (status === undefined || status >= 500) throw error;
    throw signInAgain;
  }
  if (!data.user) throw signInAgain;
  return data.user.id;
}

async function createStaff(admin: SupabaseClient, body: Record<string, unknown>) {
  const fullName = requireFullName(body.full_name);
  const phone = normalizePhone(body.phone);
  const password = requirePassword(body.password);
  const role = requireRole(body.role);

  // The on_auth_user_created trigger reads the role from app_metadata, which only the
  // service role can write, so a self sign-up never becomes staff.
  const { data, error } = await admin.auth.admin.createUser({
    phone,
    password,
    phone_confirm: true,
    app_metadata: { role, full_name: fullName },
    user_metadata: { full_name: fullName },
  });
  if (error) {
    if (error.code === 'phone_exists') {
      throw new HttpError(409, 'BXDUP', 'A staff member with this number already exists');
    }
    throw error;
  }

  const profile = await findProfile(admin, data.user.id);
  if (!profile) throw new Error(`No profile created for new user ${data.user.id}`);
  return json(200, { profile });
}

async function resetPassword(admin: SupabaseClient, body: Record<string, unknown>) {
  const userId = requireUserId(body.user_id);
  const password = requirePassword(body.password);

  await requireProfile(admin, userId);

  const { error } = await admin.auth.admin.updateUserById(userId, { password });
  if (error) {
    if (error.code === 'user_not_found') {
      throw new HttpError(404, 'BXNTF', 'Staff member not found');
    }
    throw error;
  }
  return json(200, { ok: true });
}

async function setBlocked(admin: SupabaseClient, callerId: string, body: Record<string, unknown>) {
  const userId = requireUserId(body.user_id);
  const blocked = requireBoolean(body.blocked);

  await requireProfile(admin, userId);
  // A self-block would lock the caller out mid-request and could leave no admin.
  if (userId === callerId) throw invalid('You cannot block yourself');

  // The ban ends refresh-token use; the profile flag closes RLS and every SQL function.
  // Both steps are idempotent, so a retry after a partial failure converges.
  const { error: banError } = await admin.auth.admin.updateUserById(userId, {
    ban_duration: blocked ? BAN_FOREVER : 'none',
  });
  if (banError) {
    if (banError.code === 'user_not_found') {
      throw new HttpError(404, 'BXNTF', 'Staff member not found');
    }
    throw banError;
  }

  const { data: profile, error } = await admin
    .from('profiles')
    .update({ is_blocked: blocked })
    .eq('id', userId)
    .select('*')
    .maybeSingle<Profile>();
  if (error) throw error;
  if (!profile) throw new HttpError(404, 'BXNTF', 'Staff member not found');
  return json(200, { profile });
}

async function handle(req: Request): Promise<Response> {
  if (req.method !== 'POST') throw new HttpError(405, 'BXVAL', 'Use POST');

  const url = requireEnv('SUPABASE_URL');
  const anonKey = requireEnv('SUPABASE_ANON_KEY');
  const serviceRoleKey = requireEnv('SUPABASE_SERVICE_ROLE_KEY');

  const callerId = await authenticate(req, url, anonKey);

  const admin = createClient(url, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
  });

  const caller = await findProfile(admin, callerId);
  if (!caller || caller.role !== 'admin' || caller.is_blocked) {
    throw new HttpError(403, 'BXPRM', 'Only an admin can manage staff');
  }

  const body = await readBody(req);
  switch (body.action) {
    case 'create':
      return await createStaff(admin, body);
    case 'reset_password':
      return await resetPassword(admin, body);
    case 'set_blocked':
      return await setBlocked(admin, callerId, body);
    default:
      throw invalid('Unknown action');
  }
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    return await handle(req);
  } catch (err) {
    if (err instanceof HttpError) {
      return json(err.status, { code: err.code, message: err.message });
    }
    // The real cause goes to the function log only; request bodies hold passwords, so never log them.
    console.error('admin-staff failed:', err);
    return json(500, { code: 'BXERR', message: 'Something went wrong' });
  }
});
