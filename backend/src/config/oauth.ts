export const googleOAuthConfig = {
  clientID: process.env.GOOGLE_CLIENT_ID || '',
  clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
  callbackURL: process.env.GOOGLE_CALLBACK_URL || 'http://localhost:3000/api/auth/google/callback',
};

export const lineOAuthConfig = {
  channelID: process.env.LINE_CHANNEL_ID || '',
  channelSecret: process.env.LINE_CHANNEL_SECRET || '',
  callbackURL: process.env.LINE_CALLBACK_URL || 'http://localhost:3000/api/auth/line/callback',
};

export const yahooOAuthConfig = {
  clientID: process.env.YAHOO_CLIENT_ID || '',
  clientSecret: process.env.YAHOO_CLIENT_SECRET || '',
  callbackURL: process.env.YAHOO_CALLBACK_URL || 'http://localhost:3000/api/auth/yahoo/callback',
};
