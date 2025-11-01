import express from "express";
import connectDB from "./config/db.js";

const app = express();
app.use(express.json());

connectDB();

app.get('/', (req, res) => {
    res.send("Server is running");
})


app.listen(3000, () => {
    console.log("Server is sunning on http://localhost:3000");
});