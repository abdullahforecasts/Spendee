import Joi from "joi";

export const signupSchema = Joi.object({
    name: Joi.string().min(2).max(50).required(),
    email: Joi.string().min(6).max(60).required().email({
        tlds: { allow: ['com', 'net', 'org', 'pk'] }
    }),
    password: Joi.string().required().pattern(new RegExp("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")),
});

export const signinSchema = Joi.object({
    email: Joi.string().min(6).max(60).required().email({
        tlds: { allow: ['com', 'net', 'org', 'pk'] }
    }),
    password: Joi.string().required().pattern(new RegExp("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")),
});

export const acceptCodeSchema = Joi.object({
    email: Joi.string().min(6).max(60).required().email({
        tlds: { allow: ['com', 'net', 'org', 'pk'] }
    }),
    providedCode: Joi.number().required(),
});

export const changePasswordSchema = Joi.object({
    newPassword: Joi.string().required().pattern(new RegExp("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")),
    oldPassword: Joi.string().required().pattern(new RegExp("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")),
});

export const acceptFPCodeSchema = Joi.object({
    email: Joi.string().min(6).max(60).required().email({
        tlds: { allow: ['com', 'net', 'org', 'pk'] },
    }),
    providedCode: Joi.number().required(),
    newPassword: Joi.string().required().pattern(new RegExp('^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$')),
});

export const createRoomSchema = Joi.object({
    name: Joi.string().min(2).max(50).required(),
    description: Joi.string().max(200).optional(),
    memberIds: Joi.array().items(Joi.string()).min(1).required(),
    color: Joi.string().optional(),
    icon: Joi.string().optional(),
});

export const createGroupSchema = Joi.object({
    name: Joi.string().min(3).max(60).required(),
    description: Joi.string().max(500).optional(),
    goalAmount: Joi.number().min(1).required(),
    memberIds: Joi.array().items(Joi.string()).min(1).required(),
    splitMethod: Joi.string().valid('equal', 'custom').required(),
    customShares: Joi.array().items(Joi.number().min(0)).optional(),
    deadline: Joi.date().optional(),
    sourceRoomId: Joi.string().optional(),
});

export const addPaymentMethodSchema = Joi.object({
    type: Joi.string().valid('bank', 'easypaisa', 'jazzcash', 'nayapay', 'sadapay').required(),
    accountTitle: Joi.string().required(),
    accountNumber: Joi.string().optional(),
    iban: Joi.string().optional(),
    bankName: Joi.string().optional(),
});