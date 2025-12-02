import { transport } from '../middlewares/sendMail.js';

const sendFeedback = async (req, res) => {
    try {
        const { name, email, message } = req.body;

        if (!message || message.toString().trim().length === 0) {
            return res.status(400).json({ success: false, message: 'Message is required' });
        }

        // Build email
        const senderName = name ? String(name).trim() : 'Anonymous';
        const senderEmail = email ? String(email).trim() : 'Not provided';
        const userId = req.user && req.user.userId ? req.user.userId : null;

        const mailOptions = {
            from: process.env.SENDING_EMAIL_ADDRESS,
            to: process.env.RECEIVING_EMAIL_ADDRESS || process.env.SENDING_EMAIL_ADDRESS,
            subject: `App Feedback from ${senderName}`,
            html: `
                <p><strong>Sender:</strong> ${senderName} ${senderEmail !== 'Not provided' ? `(&lt;${senderEmail}&gt;)` : ''}</p>
                ${userId ? `<p><strong>User ID:</strong> ${userId}</p>` : ''}
                <p><strong>Message:</strong></p>
                <p>${String(message).replace(/\n/g, '<br/>')}</p>
                <hr/>
                <p>Received on: ${new Date().toISOString()}</p>
            `,
        };

        await transport.sendMail(mailOptions);

        return res.json({ success: true, message: 'Feedback submitted. Thank you!' });
    } catch (error) {
        console.error('Failed to send feedback email:', error);
        return res.status(500).json({ success: false, message: 'Failed to submit feedback' });
    }
};

export default { sendFeedback };
