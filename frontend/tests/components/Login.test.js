import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react';
import Login from '../../src/components/Login';
import { getToken } from '../../src/services/tokenService';
import { verifyToken } from '../../src/helpers/jwtHelper';

jest.mock('../../src/services/tokenService');
jest.mock('../../src/helpers/jwtHelper');

describe('Login Component', () => {
    it('should login and inject token', async () => {
        getToken.mockResolvedValue('test-token');
        verifyToken.mockReturnValue(true);

        const { getByPlaceholderText, getByText } = render(<Login />);
        const userIdInput = getByPlaceholderText('User ID');
        const loginButton = getByText('Login');

        fireEvent.change(userIdInput, { target: { value: 'user123' } });
        fireEvent.click(loginButton);

        await waitFor(() => {
            expect(getToken).toHaveBeenCalledWith('user123');
            expect(verifyToken).toHaveBeenCalledWith('test-token');
            expect(localStorage.setItem).toHaveBeenCalledWith('authToken', 'test-token');
        });
    });
});
