import mongoose from "mongoose";

const groupSchema = mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true,
            minLength: 3,
            maxLength: 60,
        },

        description: {
            type: String,
            trim: true,
            maxLength: 500,
        },

        leader: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },

        members: [{
            user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
            shareAmount: { type: Number, required: true },
            amountPaid: { type: Number, default: 0 },
            hasPaid: { type: Boolean, default: false },
            lastPaymentDate: Date,
            paymentProof: String,
            joinedAt: { type: Date, default: Date.now },
        }],

        goalAmount: {
            type: Number,
            required: true,
            min: 0,
        },

        currentAmount: {
            type: Number,
            default: 0,
            min: 0,
        },

        splitMethod: {
            type: String,
            enum: ['equal', 'custom'],
            default: 'equal',
        },

        paymentMethods: [{
            type: {
                type: String,
                enum: ['bank', 'easypaisa', 'jazzcash', 'nayapay', 'sadapay'],
                required: true,
            },
            accountTitle: String,
            accountNumber: String,
            iban: String,
            bankName: String,
            deepLink: String,
            qrCode: String,
            isActive: { type: Boolean, default: true },
        }],

        deadline: Date,

        status: {
            type: String,
            enum: ['draft', 'active', 'completed', 'cancelled'],
            default: 'draft',
        },

        currency: {
            type: String,
            default: 'PKR',
        },

        sourceRoom: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Room',
        },

        expenses: [{
            description: String,
            estimatedAmount: Number,
            actualAmount: Number,
            receipt: String,
            paidOn: Date,
        }],

        coverImage: String,
    },
    {
        timestamps: true,
    }
);

const Group = mongoose.model("Group", groupSchema);
export default Group;