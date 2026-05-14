export const SUPPORT = {
  whatsapp: "https://wa.me/201500998095",
  email: "support@nims-farkha.com",
  privacyPolicy: "https://www.nims-farkha.com/privacy-policy",
  termsOfService: "https://www.nims-farkha.com/terms",
} as const;

export const APP_VERSION = process.env.NEXT_PUBLIC_APP_VERSION ?? "6.4.0";
export const PLATFORM = process.env.NEXT_PUBLIC_PLATFORM ?? "web";
