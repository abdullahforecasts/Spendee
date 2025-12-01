import mongoose from "mongoose";

const roomSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true,
            minLength: 2,
            maxLength: 50,
        },

        description: {
            type: String,
            default: "",
            trim: true,
            maxLength: 200,
        },

        createdBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },

        members: [{ 
            type: mongoose.Schema.Types.ObjectId, 
            ref: "User" 
        }],

        color: {
            type: String,
            default: '#3B82F6', // blue
        },

        icon: {
            type: String,
            default: '👥',
        },
    },
    { timestamps: true }
);

export default mongoose.model("Room", roomSchema);