const mongoose = require('mongoose');

const wordSchema = new mongoose.Schema({
  id: {
    type: Number,
    required: true,
    unique: true
  },
  en: {
    type: String,
    required: true
  },
  vn: {
    type: String,
    required: true
  },
  image: {
    type: String,
    required: true
  }
}, {
  timestamps: true // Adds createdAt and updatedAt automatically
});

module.exports = mongoose.model('Word', wordSchema);