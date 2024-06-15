require('dotenv').config({ path: '../.env' });

export const API_BASE_URL = process.env.REACT_APP_API_BASE_URL;
export const JWT_SECRET = process.env.REACT_APP_JWT_SECRET;
