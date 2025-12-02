import express from 'express';
import feedbackController from '../controllers/feedbackController.js';
import { identifier } from '../middlewares/identification.js';

const router = express.Router();

// Public feedback endpoint. If client includes a valid token, identifier middleware
// will populate req.user — we support both authenticated and anonymous feedback.
router.post('/', (req, res, next) => {
    // Attempt to attach user if token provided, but do not fail if missing.
    // identifier expects token either in Authorization header or cookie; it returns 403
    // if missing, so we call it conditionally only when Authorization header exists.
    const authHeader = req.headers.authorization || req.headers['authorization'];
    if (authHeader) {
        return identifier(req, res, (err) => {
            // identifier doesn't pass an error, it either sets req.user or logs
            return feedbackController.sendFeedback(req, res, next);
        });
    }

    return feedbackController.sendFeedback(req, res, next);
});

export default router;
