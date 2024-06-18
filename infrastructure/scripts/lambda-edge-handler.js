'use strict';

exports.handler = async (event) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    // Check if the response is HTML
    if (response.status === '200' && headers['content-type'] && headers['content-type'][0].value.includes('text/html')) {
        // Decode the response body
        const body = Buffer.from(response.body, response.bodyEncoding === 'base64' ? 'base64' : 'utf8');
        const bodyStr = body.toString('utf8');

        // Insert JavaScript code before the closing </body> tag
        const script = `<script>alert('Hello from Lambda@Edge!');</script>`;
        const modifiedBodyStr = bodyStr.replace('</body>', `${script}</body>`);

        // Encode the modified body back to base64 if it was originally base64 encoded
        const modifiedBody = Buffer.from(modifiedBodyStr, 'utf8').toString(response.bodyEncoding === 'base64' ? 'base64' : 'utf8');

        // Update the response body
        response.body = modifiedBody;
    }

    return response;
};
