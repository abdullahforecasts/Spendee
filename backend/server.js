import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import helmet from "helmet";
import cookieParser from "cookie-parser";
import authRouter from "./routes/authRouter.js";
import userRouter from "./routes/userRouter.js";
import roomRouter from "./routes/roomRouter.js";
import groupRouter from "./routes/groupRouter.js";
import feedbackRouter from "./routes/feedbackRouter.js";
import connectDB from "./config/db.js";

dotenv.config();
const PORT = process.env.PORT || 3000;

const app = express();

// Middleware
app.use(cors({
    origin: process.env.CLIENT_URL || '*',
    credentials: true,
}));
app.use(helmet());
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database
connectDB();

// Routes
app.get('/', (req, res) => {
    res.json({ message: "Spendee API - v1.0" });
});

app.use('/api/auth', authRouter);
app.use('/api/users', userRouter);
app.use('/api/rooms', roomRouter);
app.use('/api/groups', groupRouter);
app.use('/api/feedback', feedbackRouter);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Something went wrong!',
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ success: false, message: 'Route not found!' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Spendee Server running on http://localhost:${PORT}`);
});