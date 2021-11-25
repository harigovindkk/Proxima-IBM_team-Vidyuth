import { initializeApp } from "firebase/app";
import {getAuth} from "firebase/auth";
import { getFirestore } from "firebase/firestore";
const firebaseConfig = {
    apiKey: "AIzaSyBbOybM091oWvjtkjmI2p-M1lc-bbwOv4w",
    authDomain: "proxima-ibm.firebaseapp.com",
    projectId: "proxima-ibm",
    storageBucket: "proxima-ibm.appspot.com",
    messagingSenderId: "156424378104",
    appId: "1:156424378104:web:89f36f824f11d655790d0d"
  };
  
  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
  export const auth = getAuth(app);
  export default firebaseConfig;
  initializeApp(firebaseConfig);
  // console.log(app);

  export const db = getFirestore();