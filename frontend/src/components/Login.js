import React, { useState } from 'react';
import { getToken } from '../services/tokenService';
import { verifyToken, handleError } from '../helpers/jwtHelper';

const Login = () => {
    const [userId, setUserId] = useState('');

    const handleSubmit = async (event) => {
        event.preventDefault();

        try {
            const token = await getToken(userId);
            const isValid = verifyToken(token);

            if (isValid) {
                localStorage.setItem('authToken', token);
                window.location.href = '/';
            } else {
                throw new Error('Invalid token');
            }
        } catch (error) {
            handleError(error);
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <input
                type="text"
                value={userId}
                onChange={(e) => setUserId(e.target.value)}
                placeholder="User ID"
            />
            <button type="submit">Login</button>
        </form>
    );
};

export default Login;
