import dayjs from "dayjs"

export const now = () => dayjs();

/** @param {dayjs.Dayjs} d */
export const format = (d) => d.format();