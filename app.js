// Importing required libraries
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');

// Create an Express application
const app = express();
const port = 3005;

// Middleware to enable CORS and handle JSON requests
app.use(cors());
app.use(express.json());

// Serve static files (index.html and other frontend files)
app.use(express.static(path.join(__dirname, 'public')));

// MongoDB Atlas URI
const dbURI = 'mongodb+srv://admin:admin@cluster0.e4tlexr.mongodb.net/hi?retryWrites=true&w=majority';

// Connect to MongoDB Atlas
mongoose.connect(dbURI)
    .then(() => console.log('Connected to MongoDB Atlas'))
    .catch(err => console.log('MongoDB connection error:', err));

// Define the movie schema with 'rating' field added
const movieSchema = new mongoose.Schema({
    title: String,
    year: Number,
    genre: String,
    rating: {
        type: Number,  // rating will be a number
        min: 0,        // minimum rating is 0
        max: 10        // maximum rating is 10
    }
});

// Create the Movie model
const Movie = mongoose.model('Movie', movieSchema);

// Route to fetch all movies
app.get('/movies', async (req, res) => {
    try {
        const movies = await Movie.find();
        res.json(movies);
    } catch (err) {
        console.log('Error fetching movies:', err);
        res.status(500).json({ message: 'Error fetching movies' });
    }
});

// Route for serving the root (index.html)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname,  'index.html'));  // Serve the index.html file
});

// Route to handle movie addition
app.post('/add-movie', async (req, res) => {
    const { title, year, genre, rating } = req.body;
    
    if (!title || !year || !genre || rating === undefined) {
        return res.status(400).json({ message: "All fields (title, year, genre, and rating) are required." });
    }

    try {
        const newMovie = new Movie({ title, year, genre, rating });
        await newMovie.save();
        res.status(201).json({ message: "Movie added successfully", movie: newMovie });
    } catch (error) {
        console.error('Error adding movie:', error);
        res.status(500).json({ message: "Error adding movie" });
    }
});

// MongoDB Change Stream to log new movies added
const changeStream = Movie.watch();
changeStream.on('change', (changeEvent) => {
    const doc = changeEvent.fullDocument;
    console.log(`New movie added: ${doc.title}`);
});

// Start the Express server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
