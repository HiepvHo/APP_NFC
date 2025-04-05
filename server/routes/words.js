const express = require('express');
const router = express.Router();
const Word = require('../models/Word');

// GET all words
router.get('/', async (req, res) => {
  try {
    const words = await Word.find();
    res.json(words);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET one word
router.get('/:id', async (req, res) => {
  try {
    const word = await Word.findOne({ id: req.params.id });
    if (word) {
      res.json(word);
    } else {
      res.status(404).json({ message: 'Word not found' });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// CREATE word
router.post('/', async (req, res) => {
  const word = new Word({
    id: req.body.id,
    en: req.body.en,
    vn: req.body.vn,
    image: req.body.image
  });

  try {
    const newWord = await word.save();
    res.status(201).json(newWord);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// UPDATE word
router.put('/:id', async (req, res) => {
  try {
    const word = await Word.findOne({ id: req.params.id });
    if (word) {
      word.en = req.body.en || word.en;
      word.vn = req.body.vn || word.vn;
      word.image = req.body.image || word.image;
      
      const updatedWord = await word.save();
      res.json(updatedWord);
    } else {
      res.status(404).json({ message: 'Word not found' });
    }
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// DELETE word
router.delete('/:id', async (req, res) => {
  try {
    const word = await Word.findOne({ id: req.params.id });
    if (word) {
      await word.deleteOne();
      res.json({ message: 'Word deleted' });
    } else {
      res.status(404).json({ message: 'Word not found' });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;