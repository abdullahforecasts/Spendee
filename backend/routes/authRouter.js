import express from "express";
import authController from "../controllers/authController.js";
import { identifier } from "../middlewares/identification.js";
import { uploadProfile } from "../config/cloudinary.js";

const router = express.Router();

router.post('/signup', uploadProfile.single('profilePic'), authController.signup);
router.post('/signin', authController.signin);
router.post('/signout', identifier, authController.signout);

router.patch('/send-verification-code', authController.sendVerificationCode);
router.patch('/verify-verification-code', authController.verifyVerificationCode);
router.patch('/change-password', identifier, authController.changePassword);

router.patch('/send-forgot-password-code', authController.sendForgotPasswordCode);
router.patch('/verify-forgot-password-code', authController.verifyForgotPasswordCode);

router.get('/profile', identifier, authController.getProfile);
router.patch('/profile', identifier, uploadProfile.single('profilePic'), authController.updateProfile);

export default router;