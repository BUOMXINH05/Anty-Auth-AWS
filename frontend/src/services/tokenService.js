import { API_BASE_URL } from '../env';
import { handleError } from '../helpers/errorHandler';

export const getToken = async (userId) => {
    try {
        const response = await fetch(`${API_BASE_URL}/getToken`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ userId })
        });

        if (!response.ok) {
            throw new Error('Failed to fetch token from server');
        }

        const data = await response.json();
        return data.token;
    } catch (error) {
        handleError(error);
        throw error;
    }
};
