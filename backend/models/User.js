import mongoose from "mongoose";

const userSchema = mongoose.Schema(
    {
        name: {
            type: String,
            required: [true, "Name is required!"],
            trim: true,
            minLength: [2, "Name must have at least 2 characters!"],
        },

        email: {
            type: String,
            required: [true, "Email is required!"],
            trim: true,
            unique: [true, "Email must be unique!"],
            minLength: [5, "Email must have 5 letters!"],
            lowercase: true,
        },

        password: {
            type: String,
            required: [true, "Password must be provided!"],
            trim: false,
            select: false,
        },

        profilePic: {
            type: String,
            default: "https://res.cloudinary.com/demo/image/upload/default-avatar.png",
        },

        uuid: {
            type: String,
            trim: true,
            unique: true,
            index: true,
            required: [true, 'UUID is required!'],
            minlength: [8, 'UUID must be 8 characters long'],
            maxlength: [8, 'UUID must be 8 characters long'],
            match: [/^[A-Z0-9]{8}$/, 'UUID must be 8 uppercase alphanumeric characters'],
        },

        verified: {
            type: Boolean,
            default: false,
        },

        verificationCode: {
            type: String,
            select: false,
        },

        verificationCodeValidation: {
            type: Number,
            select: false,
        },

        forgotPasswordCode: {
            type: String,
            select: false,
        },

        forgotPasswordCodeValidation: {
            type: Number,
            select: false,
        },

        // Payment methods (for when user is a leader)
        savedPaymentMethods: [{
            type: {
                type: String,
                enum: ['bank', 'easypaisa', 'jazzcash', 'nayapay', 'sadapay'],
            },
            accountTitle: String,
            accountNumber: String,
            iban: String,
            bankName: String,
            isDefault: { type: Boolean, default: false },
        }],

        // Relationships
        friends: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],

        friendRequests: [{
            from: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
            status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
            createdAt: { type: Date, default: Date.now },
        }],

        rooms: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Room' }],

        groupsAsLeader: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Group' }],
        groupsAsMember: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Group' }],
    },
    {
        timestamps: true,
    }
);

const User = mongoose.model("User", userSchema);
export default User;