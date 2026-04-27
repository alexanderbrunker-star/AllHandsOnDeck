import { initializeApp } from 'firebase/app';
import { getDatabase } from 'firebase/database';

const app = initializeApp({
  apiKey: 'AIzaSyD81t0Dhx6IXrbwsRI1XTB82BVTUQROk5w',
  authDomain: 'all-hands-on-deck-ae29e.firebaseapp.com',
  databaseURL: 'https://all-hands-on-deck-ae29e-default-rtdb.firebaseio.com',
  projectId: 'all-hands-on-deck-ae29e',
  storageBucket: 'all-hands-on-deck-ae29e.firebasestorage.app',
  messagingSenderId: '177613029935',
  appId: '1:177613029935:web:947e28a9e5399f0fdd7cda',
});

export const db = getDatabase(app);
