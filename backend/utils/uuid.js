import crypto from 'crypto';

const CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const UUID_LEN = 8;
const DIGIT_REGEX = /\d/;

export function generateShortUuid() {
    // generate until we get at least one digit
    while (true) {
        const buf = crypto.randomBytes(UUID_LEN);
        let id = '';
        for (let i = 0; i < UUID_LEN; i++) {
            id += CHARS[buf[i] % CHARS.length];
        }
        if (DIGIT_REGEX.test(id)) return id;
        // otherwise loop and try again
    }
}