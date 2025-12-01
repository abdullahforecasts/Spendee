import Room from "../models/Room.js";
import User from "../models/User.js";
import { createRoomSchema } from "../middlewares/validator.js";

const createRoom = async (req, res) => {
    const { userId } = req.user;
    const { name, description, memberIds, color, icon } = req.body;

    try {
        const { error } = createRoomSchema.validate({ name, description, memberIds, color, icon });
        if (error) {
            return res.status(400).json({ success: false, message: error.details[0].message });
        }

        // Validate all members exist and are friends
        const members = await User.find({ _id: { $in: memberIds } });
        if (members.length !== memberIds.length) {
            return res.status(404).json({ success: false, message: 'Some members not found!' });
        }

        const user = await User.findById(userId);
        
        // Check if all members are friends
        const nonFriends = memberIds.filter(id => 
            !user.friends.includes(id) && id !== userId
        );

        if (nonFriends.length > 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'You can only add friends to a room!' 
            });
        }

        const newRoom = new Room({
            name,
            description: description || '',
            createdBy: userId,
            members: [...new Set([userId, ...memberIds])], // Include creator + remove duplicates
            color: color || '#3B82F6',
            icon: icon || '👥',
        });

        await newRoom.save();

        // Add room to all members' rooms array
        await User.updateMany(
            { _id: { $in: newRoom.members } },
            { $push: { rooms: newRoom._id } }
        );

        const populatedRoom = await Room.findById(newRoom._id)
            .populate('createdBy', 'name email profilePic')
            .populate('members', 'name email profilePic');

        res.status(201).json({
            success: true,
            message: 'Room created!',
            room: populatedRoom,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const getMyRooms = async (req, res) => {
    const { userId } = req.user;

    try {
        const rooms = await Room.find({ members: userId })
            .populate('createdBy', 'name email profilePic')
            .populate('members', 'name email profilePic')
            .sort({ createdAt: -1 });

        res.json({ success: true, rooms });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const getRoomDetails = async (req, res) => {
    const { roomId } = req.params;
    const { userId } = req.user;

    try {
        const room = await Room.findById(roomId)
            .populate('createdBy', 'name email profilePic')
            .populate('members', 'name email profilePic');

        if (!room) {
            return res.status(404).json({ success: false, message: 'Room not found!' });
        }

        // Check if user is a member
        if (!room.members.some(m => m._id.toString() === userId)) {
            return res.status(403).json({ success: false, message: 'Access denied!' });
        }

        res.json({ success: true, room });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const addMembersToRoom = async (req, res) => {
    const { roomId } = req.params;
    const { memberIds } = req.body;
    const { userId } = req.user;

    try {
        if (!memberIds || memberIds.length === 0) {
            return res.status(400).json({ success: false, message: 'Member IDs required!' });
        }

        const room = await Room.findById(roomId);
        if (!room) {
            return res.status(404).json({ success: false, message: 'Room not found!' });
        }

        // Only creator can add members
        if (room.createdBy.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Only room creator can add members!' });
        }

        // Check if all new members are friends
        const user = await User.findById(userId);
        const nonFriends = memberIds.filter(id => !user.friends.includes(id));

        if (nonFriends.length > 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'You can only add friends to the room!' 
            });
        }

        // Add new members (avoid duplicates)
        const newMembers = memberIds.filter(id => !room.members.includes(id));
        room.members.push(...newMembers);
        await room.save();

        // Update users' rooms array
        await User.updateMany(
            { _id: { $in: newMembers } },
            { $push: { rooms: roomId } }
        );

        const populatedRoom = await Room.findById(roomId)
            .populate('createdBy', 'name email profilePic')
            .populate('members', 'name email profilePic');

        res.json({
            success: true,
            message: 'Members added!',
            room: populatedRoom,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const removeMemberFromRoom = async (req, res) => {
    const { roomId, memberId } = req.params;
    const { userId } = req.user;

    try {
        const room = await Room.findById(roomId);
        if (!room) {
            return res.status(404).json({ success: false, message: 'Room not found!' });
        }

        // Only creator can remove members, or member can remove themselves
        if (room.createdBy.toString() !== userId && memberId !== userId) {
            return res.status(403).json({ success: false, message: 'Access denied!' });
        }

        // Cannot remove creator
        if (memberId === room.createdBy.toString()) {
            return res.status(400).json({ 
                success: false, 
                message: 'Cannot remove room creator!' 
            });
        }

        room.members = room.members.filter(m => m.toString() !== memberId);
        await room.save();

        // Remove room from user's rooms array
        await User.findByIdAndUpdate(memberId, {
            $pull: { rooms: roomId }
        });

        const populatedRoom = await Room.findById(roomId)
            .populate('createdBy', 'name email profilePic')
            .populate('members', 'name email profilePic');

        res.json({
            success: true,
            message: 'Member removed!',
            room: populatedRoom,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const updateRoom = async (req, res) => {
    const { roomId } = req.params;
    const { name, description, color, icon } = req.body;
    const { userId } = req.user;

    try {
        const room = await Room.findById(roomId);
        if (!room) {
            return res.status(404).json({ success: false, message: 'Room not found!' });
        }

        if (room.createdBy.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Only creator can update room!' });
        }

        if (name) room.name = name;
        if (description !== undefined) room.description = description;
        if (color) room.color = color;
        if (icon) room.icon = icon;

        await room.save();

        const populatedRoom = await Room.findById(roomId)
            .populate('createdBy', 'name email profilePic')
            .populate('members', 'name email profilePic');

        res.json({ success: true, message: 'Room updated!', room: populatedRoom });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const deleteRoom = async (req, res) => {
    const { roomId } = req.params;
    const { userId } = req.user;

    try {
        const room = await Room.findById(roomId);
        if (!room) {
            return res.status(404).json({ success: false, message: 'Room not found!' });
        }

        if (room.createdBy.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Only creator can delete room!' });
        }

        // Remove room from all members' rooms array
        await User.updateMany(
            { _id: { $in: room.members } },
            { $pull: { rooms: roomId } }
        );

        await Room.findByIdAndDelete(roomId);

        res.json({ success: true, message: 'Room deleted!' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

export default {
    createRoom,
    getMyRooms,
    getRoomDetails,
    addMembersToRoom,
    removeMemberFromRoom,
    updateRoom,
    deleteRoom,
};