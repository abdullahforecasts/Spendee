import mongoose from "mongoose";

const userSchema = mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
        },
        email: {
            type: String,
            required: true,
            unique: true,
        },
        password: {
            minLength: 8,
            type: String,
            required: true,
        },
    },
    { timestamps: true }
);