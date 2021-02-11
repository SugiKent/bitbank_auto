import firebase from "firebase";

const firebaseConfig = {
  apiKey: process.env.REACT_APP_FB_API_KEY,
  authDomain: process.env.REACT_APP_FB_AUTH_DOMAIN,
  databaseURL: process.env.REACT_APP_FB_DB_URL,
  projectId: process.env.REACT_APP_FB_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FB_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FB_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FB_APP_ID,
  measurementId: process.env.REACT_APP_FB_MEASUREMENT_ID

};

firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();

export const fetchHistory = async () => {
  const querySnapshot = await db.collection('histories').orderBy('created_at', 'desc').get()
  let result: firebase.firestore.DocumentData[] = [];
  querySnapshot.forEach(doc => {
    result.push(doc.data())
  })

  return result;
}
