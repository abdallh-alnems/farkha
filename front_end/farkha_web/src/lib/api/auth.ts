import { apiPost } from "./client";

export interface LoginResponse {
  success: boolean;
  status?: string;
  user?: {
    name: string | null;
    phone: string | null;
    email?: string | null;
  };
  data?: {
    user?: {
      name: string | null;
      phone: string | null;
    };
  };
}

export interface SendOtpResponse {
  success: boolean;
  message?: string;
  session_token?: string;
  session_id?: string;
  resend_allowed_at?: string;
  attempts_remaining?: number;
  cooldown_remaining?: number;
  cooldown_message?: string;
  error?: {
    code?: string;
    message?: string;
    retry_after_seconds?: number;
    session_token?: string;
  };
}

export interface VerifyOtpResponse {
  success: boolean;
  message?: string;
  verified?: boolean;
  attempts_remaining?: number;
  lockout_remaining?: number;
}

export async function loginWithToken(token: string): Promise<LoginResponse> {
  return apiPost<LoginResponse>("app/auth/login.php", { token });
}

export async function sendOtp(
  token: string,
  phone: string,
): Promise<SendOtpResponse> {
  return apiPost<SendOtpResponse>("app/auth/send_otp.php", {
    token,
    phone,
  });
}

export async function verifyOtp(
  token: string,
  sessionToken: string,
  otpCode: string,
): Promise<VerifyOtpResponse> {
  return apiPost<VerifyOtpResponse>("app/auth/verify_otp.php", {
    token,
    session_token: sessionToken,
    otp_code: otpCode,
  });
}

export async function resendOtp(
  token: string,
  sessionToken: string,
): Promise<SendOtpResponse> {
  return apiPost<SendOtpResponse>("app/auth/resend_otp.php", {
    token,
    session_token: sessionToken,
  });
}

export async function updateName(
  token: string,
  name: string,
): Promise<{ success: boolean }> {
  return apiPost<{ success: boolean }>("app/auth/update_name.php", {
    token,
    name,
  });
}

export async function updatePhone(
  token: string,
  phone: string,
): Promise<{ success: boolean }> {
  return apiPost<{ success: boolean }>("app/auth/update_phone.php", {
    token,
    phone,
  });
}

export async function deleteAccount(
  token: string,
): Promise<{ success: boolean }> {
  return apiPost<{ success: boolean }>("app/auth/delete_account.php", {
    token,
  });
}

export async function updateFcmToken(
  token: string,
  fcmToken: string,
): Promise<{ success: boolean }> {
  return apiPost<{ success: boolean }>("app/auth/update_fcm_token.php", {
    token,
    fcm_token: fcmToken,
  });
}
