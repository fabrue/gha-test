const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');
const https = require('https');
const http = require('http');
const AWS = require('aws-sdk')
const ssm = new AWS.SSM();

const fetchPasswordFromSsm = async () => {
    const password = await ssm.getParameter({Name: '${basic_auth_password_ssm_path}', WithDecryption: true}).promise();
    return password.Parameter.Value
  }

const apiCanaryBlueprint = async function () {
    const postData = "{}";

    const redactAuthorizationHeader = function(requestOptions) {
        const {headers: Authorization, ...redactedRequestOptions} = requestOptions;
        return redactedRequestOptions
    }

    const verifyRequest = async function (requestOption) {
      return new Promise((resolve, reject) => {
        log.info("Making request with options (Headers redacted):" + JSON.stringify(redactAuthorizationHeader(requestOption)))
        const req = https.request(requestOption);

        req.on('response', (res) => {
          log.info(`Status Code: $${res.statusCode}`)
          log.info(`Response Headers: $${JSON.stringify(res.headers)}`)
          if (res.statusCode !== 200) {
             reject("Failed: " + requestOption.path);
          }
          res.on('data', (d) => {
            log.info("Response: " + JSON.stringify(d));
          });
          res.on('end', () => {
            resolve();
          })
        });

        req.on('error', (error) => {
          reject(error);
        });

        if (postData) {
          req.write(postData);
        }
        req.end();
      });
    }

    // Prepare Authorization Header
    const password = await fetchPasswordFromSsm();
    const username = '${basic_auth_username}';
    const creds = username + ":" + password;
    const base64creds = Buffer.from(creds).toString('base64')

    // Set Request Options
    const requestOptions = {
        hostname: '${endpoint_url}',
        port: 443,
        path: '/v1/order-confirmed',
        method: 'POST',
        headers: { "Authorization": `Basic $${base64creds}`, "User-Agent": `$${synthetics.getCanaryUserAgentString()}`}
    }

    await verifyRequest(requestOptions);
};

exports.handler = async () => {
    return await apiCanaryBlueprint();
};
