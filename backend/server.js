// all packages: npm i express bcryptjs cookie-parser cors helmet
//joi jsonwebtoken mongoose nodemailer
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import helmet from "helmet";
import cookieParser from "cookie-parser";
import authRouter from "./routes/authRouter.js"
import connectDB from "./config/db.js";

dotenv.config();
const PORT = process.env.PORT || 3000;

const app = express();
app.use(cors());
app.use(helmet());
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({extended: true}));


connectDB();


app.get('/', (req, res) => {
    res.json({message: "Hello from the server"});
});

app.use('/api/auth',authRouter);


app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server started on http://localhost:${PORT}`);
})