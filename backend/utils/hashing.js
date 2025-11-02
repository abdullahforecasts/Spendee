import {createHmac} from "crypto";
import {compare, hash} from "bcryptjs";

export function toHash(value, saltValue) {
	const result = hash(value, saltValue);
    return result;
};

export function doHashValidation(value, hashedValue){
    const result = compare(value, hashedValue);
    return result;
}

export function hmacProcess(value, key) {
    const result = createHmac('sha256', key).update(value).digest('hex');
    return result;
}