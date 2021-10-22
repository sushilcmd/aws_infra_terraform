const AWS = require("aws-sdk");
const docClient = new AWS.DynamoDB.DocumentClient();

const insertRecord = (params) => {
    return new Promise((res, rej) => {
        docClient.put(params, function (err, data) {
            if (err) {
                rej(err)
            } else {
                res(data)
            }
        });
    })
}

const readRecord = (params) => {
    return new Promise((res, rej) => {
        docClient.get(params, function (err, data) {
            if (err) {
                rej(err)
            } else {
                res(data)
            }
        });
    })
}

module.exports = {
    create: insertRecord,
    read: readRecord
}