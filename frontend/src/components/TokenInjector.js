import React from 'react';
import { handleError } from '../helpers/errorHandler';

const TokenInjector = ({ token }) => {
    try {
        localStorage.setItem('authToken', token);
        window.location.href = '/';
    } catch (error) {
        handleError(error);
    }

    return null;
};

export default TokenInjector;
