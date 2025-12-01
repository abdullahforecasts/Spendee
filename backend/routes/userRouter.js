import express from "express";
import userController from "../controllers/userController.js";
import { identifier } from "../middlewares/identification.js";

const router = express.Router();

// Search
router.get('/search', identifier, userController.searchUsers);

// Friends
router.post('/friend-request/:friendId', identifier, userController.sendFriendRequest);
router.get('/friend-requests', identifier, userController.getFriendRequests);
router.patch('/friend-request/:requestId', identifier, userController.respondToFriendRequest);
router.get('/friends', identifier, userController.getMyFriends);
router.delete('/friends/:friendId', identifier, userController.removeFriend);

// Payment Methods
router.post('/payment-methods', identifier, userController.addPaymentMethod);
router.get('/payment-methods', identifier, userController.getMyPaymentMethods);
router.delete('/payment-methods/:methodId', identifier, userController.deletePaymentMethod);
router.patch('/payment-methods/:methodId', identifier, userController.updatePaymentMethod);

export default router;