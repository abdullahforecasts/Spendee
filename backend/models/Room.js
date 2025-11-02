import mongoose from "mongoose";

const roomSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    description: {
      type: String,
      default: "",
      trim: true,
    },

    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    members: [
      {
        user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        contribution: { type: Number, default: 0 },
        hasPaid: { type: Boolean, default: false },
      },
    ],

    // Total pool info
    goalAmount: {
      type: Number,
      required: true,
    },
    currentAmount: {
      type: Number,
      default: 0,
    },

    deadline: {
      type: Date,
      default: null,
    },

    // Status can be: "active", "completed", or "cancelled"
    status: {
      type: String,
      enum: ["active", "completed", "cancelled"],
      default: "active",
    },

    messages: [
      {
        sender: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        text: String,
        createdAt: { type: Date, default: Date.now },
      },
    ],
  },
  { timestamps: true }
);

export default mongoose.model("Room", roomSchema);
