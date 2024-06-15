import React from 'react';
import { render } from '@testing-library/react';
import App from '../src/App';
import Login from '../src/components/Login';

// Mock the Login component
jest.mock('../src/components/Login', () => {
    return () => <div>Login Component</div>;
});

describe('App Component', () => {
    it('should render the App component correctly', () => {
        const { getByText } = render(<App />);
        
        // Check if the Login component is rendered
        expect(getByText('Login Component')).toBeInTheDocument();
    });
});
