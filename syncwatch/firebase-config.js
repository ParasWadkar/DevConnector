// ─────────────────────────────────────────────────────────────
//  FILL IN YOUR FIREBASE PROJECT VALUES HERE
//  Get them from: Firebase Console → Project Settings → Your apps
// ─────────────────────────────────────────────────────────────
window.FIREBASE_CONFIG = {
  apiKey:            "YOUR_API_KEY",
  authDomain:        "YOUR_PROJECT.firebaseapp.com",
  databaseURL:       "https://YOUR_PROJECT-default-rtdb.firebaseio.com",
  projectId:         "YOUR_PROJECT",
  storageBucket:     "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId:             "YOUR_APP_ID",
};

// YouTube Data API v3 key
// Get it from: Google Cloud Console → APIs & Services → Credentials
//
// ⚠️ This key is served to the browser and is visible to anyone who views source.
//    To stop it being stolen and your quota/billing abused, you MUST restrict it
//    in Google Cloud Console → Credentials → (your key):
//      • Application restrictions → "Websites" → add your exact domain
//        (e.g. https://your-site.example/*  and  http://localhost:3000/*  for testing)
//      • API restrictions → "Restrict key" → allow ONLY "YouTube Data API v3"
//    For a fully locked-down setup, proxy search through a small backend so the
//    key never reaches the browser at all.
window.YOUTUBE_API_KEY = "YOUR_YOUTUBE_DATA_API_KEY";
