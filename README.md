# User Authentication with JWT

This project implements a user authentication system using JWT with AWS services. It supports simulated browser environments with different devices and IPs.

## Project Structure

MAIN/
├── backend/
│ ├── handlers/
│ │ ├── authenticate.js
│ │ ├── refresh.js
│ │ ├── getToken.js
│ ├── services/
│ │ ├── authService.js
│ │ ├── tokenService.js
│ ├── utils/
│ │ ├── jwtHelper.js
│ │ ├── cognitoUtils.js
│ ├── tests/
│ │ ├── authenticate.test.js
│ │ ├── refresh.test.js
│ │ ├── getToken.test.js
│ │ ├── authService.test.js
│ │ ├── tokenService.test.js
│ ├── package.json
│ ├── node_modules/
├── frontend/
│ ├── public/
│ │ ├── index.html
│ │ ├── styles.css
│ ├── src/
│ │ ├── components/
│ │ │ ├── Login.js
│ │ │ ├── TokenInjector.js
│ │ ├── services/
│ │ │ ├── tokenService.js
│ │ ├── helpers/
│ │ │ ├── jwtHelper.js
│ │ │ ├── errorHandler.js
│ │ ├── App.js
│ │ ├── index.js
│ ├── tests/
│ │ ├── helpers/
│ │ │ ├── jwtHelper.test.js
│ │ ├── services/
│ │ │ ├── tokenService.test.js
│ │ ├── components/
│ │ │ ├── Login.test.js
│ │ ├── App.test.js
│ ├── package.json
│ ├── node_modules/
├── infrastructure/
│ ├── scripts/
│ │ ├── api-gateway-setup.ps1
│ │ ├── check-resources.ps1
│ │ ├── cleanup.ps1
│ │ ├── generate-config.ps1
│ │ ├── cloudfront-setup.ps1
│ │ ├── cognito-setup.ps1
│ │ ├── dynamodb-setup.ps1
│ │ ├── deploy-frontend.ps1
│ │ ├── lambda-deploy.ps1
│ │ ├── load-env.ps1
│ │ ├── s3-setup.ps1
│ ├── cloudformation/
│ │ ├── cognito.yaml
│ │ ├── dynamodb.yaml
│ │ ├── lambda.yaml
│ │ ├── s3.yaml
│ │ ├── api-gateway.yaml
│ │ ├── cloudfront.yaml
├── proxy/
│ ├── nginx.conf (if needed)
├── docs/
│ ├── injectTokenGuide.md
│ ├── getTokenGuide.md
├── .env
├── README.md
└── .gitignore



## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/your-repository.git
    cd your-repository
    ```

2. Install dependencies for both backend and frontend:
    ```sh
    cd backend
    npm install
    cd ../frontend
    npm install
    ```

3. Set up your environment variables. Create a `.env` file in the root directory with the following content:
    ```plaintext
    AWS_REGION=your-aws-region
    AWS_ACCOUNT_ID=your-aws-account-id
    COGNITO_USER_POOL_NAME=YourUserPoolName
    COGNITO_USER_POOL_CLIENT_NAME=YourUserPoolClientName
    S3_BUCKET_NAME=your-frontend-bucket-name
    ```

## Running the Project

1. Set up AWS services by running the scripts in `infrastructure/scripts/` in the specified order:
    ```sh
    # Load environment variables
    .\infrastructure\scripts\load-env.ps1
    
    # Set up Cognito
    .\infrastructure\scripts\cognito-setup.ps1
    
    # Set up DynamoDB
    .\infrastructure\scripts\dynamodb-setup.ps1
    
    # Deploy Lambda functions
    .\infrastructure\scripts\lambda-deploy.ps1
    
    # Set up API Gateway
    .\infrastructure\scripts\api-gateway-setup.ps1
    
    # Set up S3
    .\infrastructure\scripts\s3-setup.ps1
    
    # Deploy Frontend
    .\infrastructure\scripts\deploy-frontend.ps1
    
    # Set up CloudFront
    .\infrastructure\scripts\cloudfront-setup.ps1
    ```

2. Start the backend server:
    ```sh
    cd backend
    npm start
    ```

3. Start the frontend development server:
    ```sh
    cd frontend
    npm run start
    ```

## Testing

Run tests for both backend and frontend:

1. Backend tests:
    ```sh
    cd backend
    npm test
    ```

2. Frontend tests:
    ```sh
    cd frontend
    npm run test
    ```

## Deployment

1. Build the frontend for production:
    ```sh
    cd frontend
    npm run build
    ```

2. Deploy the backend and frontend to your chosen hosting service or follow the infrastructure setup scripts to deploy to AWS.

## License

This project is licensed under the MIT License.
