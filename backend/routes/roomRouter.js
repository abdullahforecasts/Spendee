import express from "express";
import roomController from "../controllers/roomController.js";
import { identifier } from "../middlewares/identification.js";

const router = express.Router();

router.post('/create', identifier, roomController.createRoom);
router.get('/my-rooms', identifier, roomController.getMyRooms);
router.get('/:roomId', identifier, roomController.getRoomDetails);
router.patch('/:roomId/add-members', identifier, roomController.addMembersToRoom);
router.delete('/:roomId/members/:memberId', identifier, roomController.removeMemberFromRoom);
router.patch('/:roomId/update', identifier, roomController.updateRoom);
router.delete('/:roomId', identifier, roomController.deleteRoom);

export default router;