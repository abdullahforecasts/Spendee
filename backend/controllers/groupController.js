import Group from "../models/Group.js";
import User from "../models/User.js";
import Room from "../models/Room.js";
import { createGroupSchema, addPaymentMethodSchema } from "../middlewares/validator.js";

const createGroup = async (req, res) => {
    const { userId } = req.user;
    const { name, description, goalAmount, memberIds, splitMethod, customShares, deadline, sourceRoomId } = req.body;

    try {
        const { error } = createGroupSchema.validate({
            name, description, goalAmount, memberIds, splitMethod, customShares, deadline, sourceRoomId
        });

        if (error) {
            return res.status(400).json({ success: false, message: error.details[0].message });
        }

        // Validate members exist
        const members = await User.find({ _id: { $in: memberIds } });
        if (members.length !== memberIds.length) {
            return res.status(404).json({ success: false, message: 'Some members not found!' });
        }

        let memberObjects = [];

        if (splitMethod === 'equal') {
            const sharePerPerson = goalAmount / memberIds.length;
            memberObjects = memberIds.map(id => ({
                user: id,
                shareAmount: sharePerPerson,
                amountPaid: 0,
                hasPaid: false,
            }));
        } else if (splitMethod === 'custom') {
            if (!customShares || customShares.length !== memberIds.length) {
                return res.status(400).json({
                    success: false,
                    message: 'Custom shares must match number of members!'
                });
            }

            const totalShares = customShares.reduce((a, b) => a + b, 0);
            if (Math.abs(totalShares - goalAmount) > 0.01) {
                return res.status(400).json({
                    success: false,
                    message: 'Custom shares must sum to goal amount!'
                });
            }

            memberObjects = memberIds.map((id, index) => ({
                user: id,
                shareAmount: customShares[index],
                amountPaid: 0,
                hasPaid: false,
            }));
        }

        const newGroup = new Group({
            name,
            description,
            leader: userId,
            members: memberObjects,
            goalAmount,
            currentAmount: 0,
            splitMethod,
            deadline: deadline || null,
            sourceRoom: sourceRoomId || null,
            status: 'draft', // Will be activated after payment methods are added
            coverImage: req.file ? req.file.path : undefined,
        });

        await newGroup.save();

        // Add group to leader's groupsAsLeader
        await User.findByIdAndUpdate(userId, {
            $push: { groupsAsLeader: newGroup._id }
        });

        // Add group to members' groupsAsMember
        await User.updateMany(
            { _id: { $in: memberIds } },
            { $push: { groupsAsMember: newGroup._id } }
        );

        const populatedGroup = await Group.findById(newGroup._id)
            .populate('leader', 'name email profilePic uuid')
            .populate('members.user', 'name email profilePic uuid');

        res.status(201).json({
            success: true,
            message: 'Group created! Add payment methods to activate.',
            group: populatedGroup,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const addPaymentMethod = async (req, res) => {
    const { userId } = req.user;
    const { groupId } = req.params;
    const { type, accountTitle, accountNumber, iban, bankName } = req.body;

    try {
        const { error } = addPaymentMethodSchema.validate({ type, accountTitle, accountNumber, iban, bankName });
        if (error) {
            return res.status(400).json({ success: false, message: error.details[0].message });
        }

        const group = await Group.findById(groupId);
        if (!group) {
            return res.status(404).json({ success: false, message: 'Group not found!' });
        }

        if (group.leader.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Only leader can add payment methods!' });
        }

        // Generate deep link based on type
        let deepLink = '';
        if (type === 'easypaisa') {
            deepLink = `easypaisa://pay?number=${accountNumber}`;
        } else if (type === 'jazzcash') {
            deepLink = `jazzcash://pay?number=${accountNumber}`;
        } else if (type === 'nayapay') {
            deepLink = `nayapay://pay?number=${accountNumber}`;
        } else if (type === 'sadapay') {
            deepLink = `sadapay://pay?number=${accountNumber}`;
        }

        const paymentMethod = {
            type,
            accountTitle,
            accountNumber: accountNumber || undefined,
            iban: iban || undefined,
            bankName: bankName || undefined,
            deepLink: deepLink || undefined,
            isActive: true,
        };

        group.paymentMethods.push(paymentMethod);

        // Activate group if it was in draft
        if (group.status === 'draft') {
            group.status = 'active';
        }

        await group.save();

        res.json({
            success: true,
            message: 'Payment method added!',
            group,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
const getMyGroups = async (req, res) => {
    const { userId } = req.user;
    try {
        const asLeader = await Group.find({ leader: userId })
            .populate('leader', 'name email profilePic uuid')
            .populate('members.user', 'name email profilePic uuid')
            .sort({ createdAt: -1 });

        const asMember = await Group.find({ 'members.user': userId })
            .populate('leader', 'name email profilePic uuid')
            .populate('members.user', 'name email profilePic uuid')
            .sort({ createdAt: -1 });

        res.json({
            success: true,
            asLeader,
            asMember,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
const getGroupDetails = async (req, res) => {
    const { groupId } = req.params;
    const { userId } = req.user;
    try {
        const group = await Group.findById(groupId)
            .populate('leader', 'name email profilePic uuid')
            .populate('members.user', 'name email profilePic uuid')
            .populate('sourceRoom', 'name');

        if (!group) {
            return res.status(404).json({ success: false, message: 'Group not found!' });
        }

        // Check if user is member or leader
        const isMember = group.members.some(m => m.user._id.toString() === userId);
        const isLeader = group.leader._id.toString() === userId;

        if (!isMember && !isLeader) {
            return res.status(403).json({ success: false, message: 'Access denied!' });
        }

        res.json({ success: true, group });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
const markPayment = async (req, res) => {
    const { groupId, memberId } = req.params;
    const { amount } = req.body;
    const { userId } = req.user;
    try {
        const group = await Group.findById(groupId);
        if (!group) {
            return res.status(404).json({ success: false, message: 'Group not found!' });
        }

        // Only leader or the member themselves can mark payment
        if (group.leader.toString() !== userId && memberId !== userId) {
            return res.status(403).json({ success: false, message: 'Access denied!' });
        }

        const member = group.members.find(m => m.user.toString() === memberId);
        if (!member) {
            return res.status(404).json({ success: false, message: 'Member not found!' });
        }

        member.amountPaid += amount;
        member.lastPaymentDate = Date.now();

        if (req.file) {
            member.paymentProof = req.file.path; // Cloudinary URL
        }

        if (member.amountPaid >= member.shareAmount) {
            member.hasPaid = true;
        }

        group.currentAmount += amount;

        if (group.currentAmount >= group.goalAmount) {
            group.status = 'completed';
        }

        await group.save();

        const populatedGroup = await Group.findById(groupId)
            .populate('leader', 'name email profilePic')
            .populate('members.user', 'name email profilePic');

        res.json({
            success: true,
            message: 'Payment recorded!',
            group: populatedGroup,
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
const updateGroupStatus = async (req, res) => {
    const { groupId } = req.params;
    const { status } = req.body;
    const { userId } = req.user;
    try {
        const group = await Group.findById(groupId);
        if (!group) {
            return res.status(404).json({ success: false, message: 'Group not found!' });
        }

        if (group.leader.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Only leader can update status!' });
        }

        if (!['active', 'completed', 'cancelled'].includes(status)) {
            return res.status(400).json({ success: false, message: 'Invalid status!' });
        }

        group.status = status;
        await group.save();

        res.json({ success: true, message: 'Status updated!', group });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
const deleteGroup = async (req, res) => {
    const { groupId } = req.params;
    const { userId } = req.user;
    try {
        const group = await Group.findById(groupId);
        if (!group) {
            return res.status(404).json({ success: false, message: 'Group not found!' });
        }

        if (group.leader.toString() !== userId) {
            return res.status(403).json({ success: false, message: 'Only leader can delete group!' });
        }

        // Remove group references from users
        await User.findByIdAndUpdate(userId, {
            $pull: { groupsAsLeader: groupId }
        });

        await User.updateMany(
            { _id: { $in: group.members.map(m => m.user) } },
            { $pull: { groupsAsMember: groupId } }
        );

        await Group.findByIdAndDelete(groupId);

        res.json({ success: true, message: 'Group deleted!' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
export default {
    createGroup,
    addPaymentMethod,
    getMyGroups,
    getGroupDetails,
    markPayment,
    updateGroupStatus,
    deleteGroup,
};