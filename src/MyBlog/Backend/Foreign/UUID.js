import { v7 as uuidV7, validate } from "uuid";

export const genUUID = () => uuidV7();

export const validateImpl = (v) => validate(v);