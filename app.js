const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors()); // Allow Flutter app to connect

// MongoDB Compass (local) connection
const uri = 'mongodb://localhost:27017';
let client;

async function connectToMongo() {
  try {
    client = await MongoClient.connect(uri);
    console.log('Connected to MongoDB Compass (local)');
  } catch (err) {
    console.error('MongoDB connection error:', err);
    process.exit(1); // Exit if connection fails
  }
}

connectToMongo();

// POST /notes endpoint
app.post('/notes', async (req, res) => {
  try {
    if (!client) throw new Error('Database not connected');
    const db = client.db('dreamnotes');
    const notes = db.collection('dreamnotes');

    const { title, description, mood } = req.body;

    if (!title || !description || !mood) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const result = await notes.insertOne({
      title,
      description,
      mood,
      createdAt: new Date(),
    });

    res.status(201).json({ id: result.insertedId, message: 'Note created' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create note' });
  }
});

// GET /notes endpoint
app.get('/notes', async (req, res) => {
  try {
    if (!client) throw new Error('Database not connected');
    const db = client.db('dreamnotes');
    const notes = db.collection('dreamnotes');
    const noteList = await notes.find({}).toArray();
    res.status(200).json(noteList);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch notes' });
  }
});

// Start server
const port = 3000;
app.listen(port, () => console.log(`Server running on port ${port}`));