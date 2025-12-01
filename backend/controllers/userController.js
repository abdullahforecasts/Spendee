import User from "../models/User.js";

const searchUsers = async (req, res) => {
    const { query } = req.query;
    const { userId } = req.user;

    try {
        if (!query || query.trim().length < 2) {
            // allow exact uuid search even if it's short (8 chars)
            const isUuidLike = /^[A-Za-z0-9]{8}$/.test(query);
            if (!isUuidLike) {
                return res.status(400).json({
                    success: false,
                    message: 'Search query must be at least 2 characters or a valid UUID!'
                });
            }
        }

        let filter = { _id: { $ne: userId } };

        // If looks like our short 8-char UUID, search by exact uuid (case-insensitive)
        if (/^[A-Za-z0-9]{8}$/.test(query)) {
            filter.uuid = query.toString().toUpperCase();
        } else {
            filter.$or = [
                { name: { $regex: query, $options: 'i' } },
                { email: { $regex: query, $options: 'i' } },
            ];
        }

        const users = await User.find(filter)
            .select('name email profilePic uuid')
            .limit(20);

        res.json({ success: true, users });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const sendFriendRequest = async (req, res) => {
    const { userId } = req.user;
    const { friendId } = req.params;

    try {
        // allow friendId to be either ObjectId or the 8-char uuid
        let friend = null;
        if (/^[A-Za-z0-9]{8}$/.test(friendId)) {
            friend = await User.findOne({ uuid: friendId.toString().toUpperCase() });
        } else {
            friend = await User.findById(friendId);
        }

        if (!friend) {
            return res.status(404).json({ success: false, message: 'User not found!' });
        }

        if (userId === friend._id.toString()) {
            return res.status(400).json({
                success: false,
                message: 'Cannot send friend request to yourself!'
            });
        }

        const user = await User.findById(userId);

        // Check if already friends
        if (user.friends.includes(friend._id)) {
            return res.status(400).json({
                success: false,
                message: 'Already friends!'
            });
        }

        // Check if request already sent
        const existingRequest = friend.friendRequests.find(
            r => r.from.toString() === userId && r.status === 'pending'
        );

        if (existingRequest) {
            return res.status(400).json({
                success: false,
                message: 'Friend request already sent!'
            });
        }

        // Also check if friend has already sent a request to user (reverse case)
        const reverseRequest = user.friendRequests.find(
            r => r.from.toString() === friend._id.toString() && r.status === 'pending'
        );

        if (reverseRequest) {
            return res.status(400).json({
                success: false,
                message: 'This user has already sent you a friend request! Please check your requests.'
            });
        }

        // Add friend request
        friend.friendRequests.push({
            from: userId,
            status: 'pending',
        });

        await friend.save();

        res.json({ success: true, message: 'Friend request sent!' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const getFriendRequests = async (req, res) => {
    const { userId } = req.user;

    try {
        const user = await User.findById(userId)
            .populate('friendRequests.from', 'name email profilePic');

        const pendingRequests = user.friendRequests.filter(req => {
            return req.status === 'pending' && 
                   !user.friends.includes(req.from._id);
        });

        res.json({ success: true, requests: pendingRequests });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const respondToFriendRequest = async (req, res) => {
    const { userId } = req.user;
    const { requestId } = req.params;
    const { action } = req.body; // 'accept' or 'reject'

    try {
        if (!['accept', 'reject'].includes(action)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid action!'
            });
        }

        const user = await User.findById(userId);
        const request = user.friendRequests.id(requestId);

        if (!request) {
            return res.status(404).json({ success: false, message: 'Request not found!' });
        }

        if (request.status !== 'pending') {
            return res.status(400).json({
                success: false,
                message: 'Request already processed!'
            });
        }

        const requesterId = request.from; // The user who sent this request

        if (action === 'accept') {
            // Add to friends list (both ways)
            user.friends.push(requesterId);
            request.status = 'accepted';
            await user.save();

            const requester = await User.findById(requesterId);
            
            // Add user to requester's friends list
            requester.friends.push(userId);
            
            // Check if user (the one accepting) had also sent a friend request to the requester
            // If yes, update that request status to 'accepted' as well
            const reverseRequest = requester.friendRequests.find(
                r => r.from.toString() === userId.toString() && r.status === 'pending'
            );
            
            if (reverseRequest) {
                reverseRequest.status = 'accepted';
            }
            
            await requester.save();

            res.json({ success: true, message: 'Friend request accepted!' });

        } else {
            request.status = 'rejected';
            await user.save();

            res.json({ success: true, message: 'Friend request rejected!' });
        }

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const getMyFriends = async (req, res) => {
    const { userId } = req.user;

    try {
        const user = await User.findById(userId)
            .populate('friends', 'name email profilePic uuid');

        res.json({ success: true, friends: user.friends });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const removeFriend = async (req, res) => {
    const { userId } = req.user;
    const { friendId } = req.params;

    try {
        const user = await User.findById(userId);

        // resolve friendId which might be an 8-char uuid
        let friend = null;
        if (/^[A-Za-z0-9]{8}$/.test(friendId)) {
            friend = await User.findOne({ uuid: friendId.toString().toUpperCase() });
        } else {
            friend = await User.findById(friendId);
        }

        if (!friend) {
            return res.status(404).json({ success: false, message: 'User not found!' });
        }

        if (!user.friends.includes(friend._id)) {
            return res.status(400).json({
                success: false,
                message: 'Not in friends list!'
            });
        }

        // Remove from both users
        user.friends = user.friends.filter(id => id.toString() !== friend._id.toString());
        await user.save();

        await User.findByIdAndUpdate(friend._id, {
            $pull: { friends: userId }
        });

        res.json({ success: true, message: 'Friend removed!' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const addPaymentMethod = async (req, res) => {
    const { userId } = req.user;
    const { type, accountTitle, accountNumber, iban, bankName, isDefault } = req.body;

    try {
        const user = await User.findById(userId);

        // If setting as default, unset other defaults
        if (isDefault) {
            user.savedPaymentMethods.forEach(method => {
                method.isDefault = false;
            });
        }

        user.savedPaymentMethods.push({
            type,
            accountTitle,
            accountNumber: accountNumber || undefined,
            iban: iban || undefined,
            bankName: bankName || undefined,
            isDefault: isDefault || false,
        });

        await user.save();

        res.json({
            success: true,
            message: 'Payment method added!',
            paymentMethods: user.savedPaymentMethods
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const getMyPaymentMethods = async (req, res) => {
    const { userId } = req.user;

    try {
        const user = await User.findById(userId);
        res.json({ success: true, paymentMethods: user.savedPaymentMethods });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const deletePaymentMethod = async (req, res) => {
    const { userId } = req.user;
    const { methodId } = req.params;

    try {
        const user = await User.findById(userId);
        user.savedPaymentMethods = user.savedPaymentMethods.filter(
            method => method._id.toString() !== methodId
        );

        await user.save();

        res.json({ success: true, message: 'Payment method deleted!' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

const updatePaymentMethod = async (req, res) => {
    const { userId } = req.user;
    const { methodId } = req.params;
    const { accountTitle, accountNumber, iban, bankName, isDefault } = req.body;

    try {
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ success: false, message: 'User not found!' });

        const method = user.savedPaymentMethods.id(methodId);
        if (!method) return res.status(404).json({ success: false, message: 'Payment method not found!' });

        if (accountTitle !== undefined) method.accountTitle = accountTitle;
        if (accountNumber !== undefined) method.accountNumber = accountNumber;
        if (iban !== undefined) method.iban = iban;
        if (bankName !== undefined) method.bankName = bankName;

        if (isDefault === true) {
            // unset other defaults
            user.savedPaymentMethods.forEach(m => { m.isDefault = false; });
            method.isDefault = true;
        } else if (isDefault === false) {
            method.isDefault = false;
        }

        await user.save();

        res.json({ success: true, message: 'Payment method updated!', paymentMethods: user.savedPaymentMethods });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
};

export default {
    searchUsers,
    sendFriendRequest,
    getFriendRequests,
    respondToFriendRequest,
    getMyFriends,
    removeFriend,
    addPaymentMethod,
    getMyPaymentMethods,
    updatePaymentMethod,
    deletePaymentMethod,
};