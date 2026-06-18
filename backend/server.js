const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const baseWords = [
  { word: "Apple", meaning: "A sweet fruit", translation: "Manzana" },
  { word: "Beautiful", meaning: "Pleasing to look at", translation: "Hermoso/Hermosa" },
  { word: "Happy", meaning: "Feeling joy", translation: "Feliz" },
  { word: "Sun", meaning: "The star our planet orbits", translation: "Sol" },
  { word: "Moon", meaning: "Earth's natural satellite", translation: "Luna" },
  { word: "Water", meaning: "A clear liquid", translation: "Agua" },
  { word: "Fire", meaning: "Hot glowing gas from combustion", translation: "Fuego" },
  { word: "Book", meaning: "Pages bound together", translation: "Libro" },
  { word: "House", meaning: "A building for human habitation", translation: "Casa" },
  { word: "Car", meaning: "A four-wheeled motor vehicle", translation: "Coche" }
];

let wordsArray = [];
for (let i = 0; i < 200; i++) {
  const wordTemplate = baseWords[i % baseWords.length];
  wordsArray.push({
    id: String(i + 1),
    word:
      wordTemplate.word +
      (i >= baseWords.length ? ` ${Math.floor(i / baseWords.length) + 1}` : ''),
    meaning: wordTemplate.meaning,
    translation: wordTemplate.translation,
  });
}

app.get('/words', (req, res) => {
  res.json(wordsArray);
});

app.post('/words', (req, res) => {
  const word = String(req.body.word || '').trim();
  const meaning = String(req.body.meaning || '').trim();
  const translation = String(req.body.translation || '').trim();

  if (!word || !meaning || !translation) {
    return res.status(400).json({
      error: 'Missing required fields',
      required: ['word', 'meaning', 'translation'],
    });
  }

  const newWord = {
    id: String(wordsArray.length + 1),
    word,
    meaning,
    translation,
  };

  wordsArray.unshift(newWord);
  res.status(201).json(newWord);
});

app.get('/health', (req, res) => {
  res.json({
    ok: true,
    words: wordsArray.length,
  });
});

const PORT = Number(process.env.PORT) || 3000;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`Server running on http://${HOST}:${PORT}`);
});

module.exports = app;
