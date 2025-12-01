import { v2 as cloudinary } from 'cloudinary';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import multer from 'multer';
import dotenv from 'dotenv';

dotenv.config();

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Storage for profile pictures
const profileStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'spendee/profiles',
        allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
        transformation: [{ width: 500, height: 500, crop: 'fill' }],
    },
});

// Storage for payment proofs
const proofStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'spendee/payment-proofs',
        allowed_formats: ['jpg', 'jpeg', 'png', 'pdf'],
    },
});

export const uploadProfile = multer({ storage: profileStorage });
export const uploadProof = multer({ storage: proofStorage });
export default cloudinary;
