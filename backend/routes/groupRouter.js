import express from "express";
import groupController from "../controllers/groupController.js";
import { identifier } from "../middlewares/identification.js";
import { uploadProof } from "../config/cloudinary.js";

const router = express.Router();

router.post('/create', identifier, groupController.createGroup);
router.post('/:groupId/payment-methods', identifier, groupController.addPaymentMethod);
router.get('/my-groups', identifier, groupController.getMyGroups);
router.get('/:groupId', identifier, groupController.getGroupDetails);
router.patch('/:groupId/members/:memberId/mark-paid', identifier, uploadProof.single('proof'), groupController.markPayment);
router.patch('/:groupId/status', identifier, groupController.updateGroupStatus);
router.delete('/:groupId', identifier, groupController.deleteGroup);

export default router;