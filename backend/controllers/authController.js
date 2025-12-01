import jwt from "jsonwebtoken";
import { signupSchema, signinSchema, acceptCodeSchema, changePasswordSchema, acceptFPCodeSchema } from "../middlewares/validator.js";
import User from "../models/User.js";
import { toHash, doHashValidation, hmacProcess } from "../utils/hashing.js";
import { transport } from "../middlewares/sendMail.js";
import { generateShortUuid } from '../utils/uuid.js';
import dotenv from "dotenv";

dotenv.config();

const signup = async (req, res) => {
    const { name, email, password } = req.body;

    try {
        const { error, value } = signupSchema.validate({ name, email, password });

        if (error) {
            return res.status(401).json({ success: false, message: error.details[0].message })
        }

        const existingUser = await User.findOne({ email });

        if (existingUser) {
            return res.status(401).json({ success: false, message: "User already exists." });
        }

        const hashedPassword = await toHash(password, 12);

        const providedUuid = req.body.uuid ? req.body.uuid.toString().toUpperCase() : null;
        const uuidPattern = /^(?=[A-Z0-9]*\d)[A-Z0-9]{8}$/;
        const finalUuid = providedUuid && uuidPattern.test(providedUuid)
            ? providedUuid
            : generateShortUuid();

        const newUser = new User({
            name,
            email,
            password: hashedPassword,
            uuid: finalUuid,
            profilePic: req.file ? req.file.path : undefined, // Cloudinary URL
        });

        const result = await newUser.save();
        result.password = undefined;

        res.status(201).json({
            success: true,
            message: "Your account has been created successfully!",
            user: result,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
}

const signin = async (req, res) => {
    const { email, password } = req.body;

    try {
        const { error, value } = signinSchema.validate({ email, password });
        if (error) {
            return res.status(401).json({ success: false, message: error.details[0].message })
        }

        const existingUser = await User.findOne({ email }).select('+password');
        if (!existingUser) {
            return res.status(401).json({ success: false, message: "User does not exist." });
        }

        const result = await doHashValidation(password, existingUser.password);
        if (!result) {
            return res.status(401).json({ success: false, message: "Invalid credentials." });
        }

        const token = jwt.sign({
            userId: existingUser._id,
            email: existingUser.email,
            verified: existingUser.verified,
            name: existingUser.name,
        }, process.env.TOKEN_SECRET, {
            expiresIn: '8h',
        });

        res.cookie('Authorization', 'Bearer ' + token, {
            expires: new Date(Date.now() + 8 * 3600000),
            httpOnly: process.env.NODE_ENV === 'production',
            secure: process.env.NODE_ENV === 'production'
        }).json({
            success: true,
            token,
            user: {
                _id: existingUser._id,
                name: existingUser.name,
                email: existingUser.email,
                profilePic: existingUser.profilePic,
                verified: existingUser.verified,
            },
            message: 'Logged in successfully!'
        })
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
}

// Keep all other functions same...
const signout = async (req, res) => {
    res.clearCookie('Authorization').status(200).json({ success: true, message: "Logged out successfully!" });
};

const sendVerificationCode = async (req, res) => {
    const { email } = req.body;
    try {
        const existingUser = await User.findOne({ email });
        if (!existingUser) {
            return res.status(404).json({ success: false, message: 'User does not exist!' });
        }
        if (existingUser.verified) {
            return res.status(400).json({ success: false, message: 'You are already verified!' });
        }

        const codeValue = Math.floor(100000 + Math.random() * 900000).toString();

        let info = await transport.sendMail({
            from: process.env.SENDING_EMAIL_ADDRESS,
            to: existingUser.email,
            subject: 'Spendee — Your verification code',
            text: `Your Spendee verification code is: ${codeValue}. It expires in 5 minutes.`,
            html: `
          <div style="font-family:Arial,Helvetica,sans-serif;color:#222;line-height:1.5;background:#f5f7fb;padding:24px">
        <div style="max-width:600px;margin:0 auto;background:#ffffff;border-radius:10px;overflow:hidden;border:1px solid #eceff3;">
          <div style="padding:24px;text-align:center;background:linear-gradient(90deg,#2ed3a6 0%,#7ee8c9 100%);color:#fff;">
            <img src="${process.env.LOGO_URL || 'https://spendee.app/logo.png'}" alt="Spendee" style="height:40px;margin-bottom:8px;display:block;margin-left:auto;margin-right:auto;">
            <h1 style="margin:8px 0 0;font-size:20px;font-weight:600;">Email Verification</h1>
          </div>
          <div style="padding:28px;">
            <p style="margin:0 0 16px;">Hi ${existingUser.name || 'there'},</p>
            <p style="margin:0 0 20px;color:#555;">
              Use the one‑time verification code below to confirm your email address. The code is valid for <strong>5 minutes</strong>.
            </p>
            <div style="text-align:center;margin:24px 0;">
              <div style="display:inline-block;background:#f0fff7;border:1px solid #d9f6ea;padding:18px 28px;border-radius:8px;">
            <span style="font-size:28px;letter-spacing:6px;font-weight:700;color:#2ed3a6;">${codeValue}</span>
              </div>
            </div>
            <p style="margin:0 0 12px;color:#666;">If you did not request this, you can ignore this email.</p>
            <p style="margin:18px 0 0;color:#888;font-size:13px;">Need help? Visit <a href="${'Spendee App'}" style="color:#2ed3a6;text-decoration:none;">Spendee</a> or reply to this email.</p>
          </div>
          <div style="background:#eefaf5;padding:12px 24px;border-top:1px solid #eefaf5;text-align:center;font-size:12px;color:#999;">
            © ${new Date().getFullYear()} Spendee — All rights reserved.
          </div>
        </div>
          </div>
        `,
        });

        if (info.accepted[0] === existingUser.email) {
            const hashedCodeValue = hmacProcess(codeValue, process.env.HMAC_VERIFICATION_CODE_SECRET);
            existingUser.verificationCode = hashedCodeValue;
            existingUser.verificationCodeValidation = Date.now();
            await existingUser.save();
            return res.status(200).json({ success: true, message: 'Code sent!' });
        }
        res.status(400).json({ success: false, message: 'Code sent failed!' });
    } catch (error) {
        console.log(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const verifyVerificationCode = async (req, res) => {
    const { email, providedCode } = req.body;

    try {
        const { error, value } = acceptCodeSchema.validate({ email, providedCode });

        if (error) {
            return res.status(401).json({ success: false, message: error.details[0].message })
        }

        const codeValue = providedCode.toString();
        const existingUser = await User.findOne({ email }).select("+verificationCode +verificationCodeValidation");

        if (!existingUser) {
            return res.status(404).json({ success: false, message: 'User does not exist!' });
        }

        if (existingUser.verified) {
            return res.status(400).json({ success: false, message: "You are already verified!" });
        }

        if (!existingUser.verificationCode || !existingUser.verificationCodeValidation) {
            return res.status(400).json({ success: false, message: "Please request a verification code first!" });
        }

        if (Date.now() - existingUser.verificationCodeValidation > 5 * 60 * 1000) {
            return res.status(400).json({ success: false, message: "Code has been expired!" });
        }

        const hashedCodeValue = hmacProcess(codeValue, process.env.HMAC_VERIFICATION_CODE_SECRET);

        if (hashedCodeValue === existingUser.verificationCode) {
            existingUser.verified = true;
            existingUser.verificationCode = undefined;
            existingUser.verificationCodeValidation = undefined;
            await existingUser.save();
            return res.status(200).json({ success: true, message: "Your account has been verified!" });
        }

        return res.status(400).json({ success: false, message: "Invalid code!" });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
}

const changePassword = async (req, res) => {
    const { userId, verified } = req.user;
    const { oldPassword, newPassword } = req.body;

    try {
        const { error, value } = changePasswordSchema.validate({ oldPassword, newPassword });

        if (error) {
            return res.status(401).json({ success: false, message: error.details[0].message })
        }

        if (!verified) {
            return res.status(401).json({ success: false, message: "You are not verified!" });
        }

        const existingUser = await User.findOne({ _id: userId }).select("+password");

        if (!existingUser) {
            return res.status(404).json({ success: false, message: 'User does not exist!' });
        }

        const result = await doHashValidation(oldPassword, existingUser.password);
        if (!result) {
            return res.status(401).json({ success: false, message: "Invalid credentials!" })
        }

        const hashedPassword = await toHash(newPassword, 12);
        existingUser.password = hashedPassword;
        await existingUser.save();

        return res.status(200).json({ success: true, message: "Password updated!" })

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const sendForgotPasswordCode = async (req, res) => {
    const { email } = req.body;
    try {
        const existingUser = await User.findOne({ email });
        if (!existingUser) {
            return res.status(404).json({ success: false, message: 'User does not exist!' });
        }

        const codeValue = Math.floor(100000 + Math.random() * 900000).toString();

                let info = await transport.sendMail({
                        from: process.env.SENDING_EMAIL_ADDRESS,
                        to: existingUser.email,
                        subject: 'Spendee — Password reset code',
                        text: `Your Spendee password reset code is: ${codeValue}. It expires in 5 minutes.`,
                        html: `
                    <div style="font-family:Arial,Helvetica,sans-serif;color:#222;line-height:1.5;background:#f5f7fb;padding:24px">
                <div style="max-width:600px;margin:0 auto;background:#ffffff;border-radius:10px;overflow:hidden;border:1px solid #eceff3;">
                    <div style="padding:24px;text-align:center;background:linear-gradient(90deg,#2ed3a6 0%,#7ee8c9 100%);color:#fff;">
                        <img src="${process.env.LOGO_URL || 'https://spendee.app/logo.png'}" alt="Spendee" style="height:40px;margin-bottom:8px;display:block;margin-left:auto;margin-right:auto;">
                        <h1 style="margin:8px 0 0;font-size:20px;font-weight:600;">Password Reset Request</h1>
                    </div>
                    <div style="padding:28px;">
                        <p style="margin:0 0 16px;">Hi ${existingUser.name || 'there'},</p>
                        <p style="margin:0 0 20px;color:#555;">
                            We received a request to reset the password for your Spendee account. Use the one‑time code below to reset your password. The code is valid for <strong>5 minutes</strong>.
                        </p>
                        <div style="text-align:center;margin:24px 0;">
                            <div style="display:inline-block;background:#fff7f0;border:1px solid #fde6d9;padding:18px 28px;border-radius:8px;">
                        <span style="font-size:28px;letter-spacing:6px;font-weight:700;color:#ff7a3d;">${codeValue}</span>
                            </div>
                        </div>
                        <p style="margin:0 0 12px;color:#666;">If you did not request a password reset, you can ignore this email and no changes will be made to your account.</p>
                        <p style="margin:18px 0 0;color:#888;font-size:13px;">Need help? Visit <a href="${process.env.SUPPORT_URL || '#'}" style="color:#2ed3a6;text-decoration:none;">Spendee Support</a> or reply to this email.</p>
                    </div>
                    <div style="background:#eefaf5;padding:12px 24px;border-top:1px solid #eefaf5;text-align:center;font-size:12px;color:#999;">
                        © ${new Date().getFullYear()} Spendee — All rights reserved.
                    </div>
                </div>
                    </div>
                `,
                });

        if (info.accepted[0] === existingUser.email) {
            const hashedCodeValue = hmacProcess(codeValue, process.env.HMAC_VERIFICATION_CODE_SECRET);
            existingUser.forgotPasswordCode = hashedCodeValue;
            existingUser.forgotPasswordCodeValidation = Date.now();
            await existingUser.save();
            return res.status(200).json({ success: true, message: 'Code sent!' });
        }
        res.status(400).json({ success: false, message: 'Code sent failed!' });
    } catch (error) {
        console.log(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const verifyForgotPasswordCode = async (req, res) => {
    const { email, providedCode, newPassword } = req.body;

    try {
        const { error, value } = acceptFPCodeSchema.validate({ email, providedCode, newPassword });

        if (error) {
            return res.status(401).json({ success: false, message: error.details[0].message })
        }

        const codeValue = providedCode.toString();
        const existingUser = await User.findOne({ email }).select("+forgotPasswordCode +forgotPasswordCodeValidation");

        if (!existingUser) {
            return res.status(404).json({ success: false, message: 'User does not exist!' });
        }

        if (!existingUser.forgotPasswordCode || !existingUser.forgotPasswordCodeValidation) {
            return res.status(400).json({ success: false, message: "Please request a code first!" });
        }

        if (Date.now() - existingUser.forgotPasswordCodeValidation > 5 * 60 * 1000) {
            return res.status(400).json({ success: false, message: "Code has been expired!" });
        }

        const hashedCodeValue = hmacProcess(codeValue, process.env.HMAC_VERIFICATION_CODE_SECRET);

        if (hashedCodeValue === existingUser.forgotPasswordCode) {
            const hashedPassword = await toHash(newPassword, 12);
            existingUser.password = hashedPassword;
            existingUser.forgotPasswordCode = undefined;
            existingUser.forgotPasswordCodeValidation = undefined;
            await existingUser.save();
            return res.status(200).json({ success: true, message: "Your password has been updated!" });
        }

        return res.status(400).json({ success: false, message: "Invalid code!" });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
}

const updateProfile = async (req, res) => {
    const { userId } = req.user;
    const { name } = req.body;

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found!' });
        }

        if (name) user.name = name;
        if (req.file) user.profilePic = req.file.path; // Cloudinary URL

        await user.save();

        res.json({
            success: true,
            message: 'Profile updated!',
            user: {
                _id: user._id,
                name: user.name,
                email: user.email,
                uuid: user.uuid,
                profilePic: user.profilePic,
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const getProfile = async (req, res) => {
    const { userId } = req.user;

    try {
        const user = await User.findById(userId)
            .select('-password')
            .populate('friends', 'name email profilePic uuid')
            .populate('rooms');

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found!' });
        }

        res.json({ success: true, user });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

export default {
    signup,
    signin,
    signout,
    sendVerificationCode,
    verifyVerificationCode,
    changePassword,
    sendForgotPasswordCode,
    verifyForgotPasswordCode,
    updateProfile,
    getProfile,
}