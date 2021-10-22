
const getHeaders = (origin) => {
  return {
    "Content-type": "application/json",
    'Access-Control-Allow-Credentials': true,
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Methods": "OPTIONS,POST",
    "Access-Control-Allow-Headers": "Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token"
  }
};

const success = (bodyData) => {
  return {
    headers: getHeaders("*"),
    statusCode: 200,
    body: JSON.stringify(bodyData),
  }
}

const error = (err) => {
  return {
    headers: getHeaders("*"),
    statusCode: 500,
    body: JSON.stringify(err)
  };
}

module.exports = {
  success: success,
  failure: error
}