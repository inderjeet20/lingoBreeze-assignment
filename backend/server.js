const express = require('express');
const cors = require('cors');
const {
  getApps,
  initializeApp,
  applicationDefault,
  cert,
} = require('firebase-admin/app');
const {
  getFirestore,
  FieldValue,
} = require('firebase-admin/firestore');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

function initializeFirestore() {
  if (getApps().length > 0) {
    return getFirestore();
  }

  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;
  const projectId = process.env.FIREBASE_PROJECT_ID;

  if (serviceAccountJson) {
    const serviceAccount = JSON.parse(serviceAccountJson);

    if (serviceAccount.private_key) {
      serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
    }

    initializeApp({
      credential: cert(serviceAccount),
      projectId: serviceAccount.project_id || projectId,
    });
  } else {
    initializeApp({
      credential: applicationDefault(),
      projectId,
    });
  }

  return getFirestore();
}

const firestore = initializeFirestore();
const wordsCollection = firestore.collection('vocabulary');

function getWordPayload(body) {
  return {
    word: String(body.word || '').trim(),
    meaning: String(body.meaning || '').trim(),
    translation: String(body.translation || '').trim(),
  };
}

function hasMissingRequiredFields(payload) {
  return !payload.word || !payload.meaning || !payload.translation;
}

function serializeError(error) {
  return {
    name: error?.name || 'Error',
    code: error?.code || 'unknown',
    message: error?.message || 'Unknown error',
  };
}

function serializeWordDoc(doc) {
  const data = doc.data() || {};
  const createdAt = data.createdAt?.toDate?.();

  return {
    id: doc.id,
    word: data.word || '',
    meaning: data.meaning || '',
    translation: data.translation || '',
    ...(createdAt ? { createdAt: createdAt.toISOString() } : {}),
  };
}

app.get('/', (req, res) => {
  res.send('Backend Working');
});

app.get('/words', async (req, res) => {
  try {
    const snapshot = await wordsCollection.get();
    const words = snapshot.docs.map(serializeWordDoc);

    words.sort((a, b) => {
      const aTime = a.createdAt ? new Date(a.createdAt).getTime() : 0;
      const bTime = b.createdAt ? new Date(b.createdAt).getTime() : 0;
      return bTime - aTime;
    });

    res.json(words);
  } catch (error) {
    console.error('Failed to fetch words from Firestore:', error?.stack || error);
    res.status(500).json({
      error: 'Failed to fetch words',
      details: serializeError(error),
    });
  }
});

app.post('/words', async (req, res) => {
  try {
    const payload = getWordPayload(req.body);

    if (hasMissingRequiredFields(payload)) {
      return res.status(400).json({
        error: 'Missing required fields',
        required: ['word', 'meaning', 'translation'],
      });
    }

    const docRef = await wordsCollection.add({
      ...payload,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    const savedDoc = await docRef.get();
    res.status(201).json(serializeWordDoc(savedDoc));
  } catch (error) {
    console.error('Failed to save word to Firestore:', error?.stack || error);
    res.status(500).json({
      error: 'Failed to save word',
      details: serializeError(error),
    });
  }
});

app.put('/words/:id', async (req, res) => {
  try {
    const payload = getWordPayload(req.body);

    if (hasMissingRequiredFields(payload)) {
      return res.status(400).json({
        error: 'Missing required fields',
        required: ['word', 'meaning', 'translation'],
      });
    }

    const docRef = wordsCollection.doc(req.params.id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({ error: 'Word not found' });
    }

    await docRef.update({
      ...payload,
      updatedAt: FieldValue.serverTimestamp(),
    });

    const updatedDoc = await docRef.get();
    res.json(serializeWordDoc(updatedDoc));
  } catch (error) {
    console.error('Failed to update word in Firestore:', error?.stack || error);
    res.status(500).json({
      error: 'Failed to update word',
      details: serializeError(error),
    });
  }
});

app.delete('/words/:id', async (req, res) => {
  try {
    const docRef = wordsCollection.doc(req.params.id);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      return res.status(404).json({ error: 'Word not found' });
    }

    await docRef.delete();
    res.status(204).send();
  } catch (error) {
    console.error('Failed to delete word from Firestore:', error?.stack || error);
    res.status(500).json({
      error: 'Failed to delete word',
      details: serializeError(error),
    });
  }
});

app.get('/health', async (req, res) => {
  try {
    const snapshot = await wordsCollection.get();
    res.json({
      ok: true,
      words: snapshot.size,
    });
  } catch (error) {
    console.error('Failed to read health metrics:', error?.stack || error);
    res.status(500).json({
      ok: false,
      error: 'Failed to read health metrics',
      details: serializeError(error),
    });
  }
});

const PORT = Number(process.env.PORT) || 3000;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`Server running on http://${HOST}:${PORT}`);
});

module.exports = app;
