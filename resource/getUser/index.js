const db = require('./helpers/dbOpreation')
const res = require('./helpers/res');
const axios = require('axios')

exports.handler = async (event) => {
    const { email, country } = event.queryStringParameters;
    const url = process.env.URL;
    try {
        const { data } = await axios.get(url);
        var params = {
            TableName: process.env.TABLE_NAME || "xray-user",
            Key: {
                "PK": `USER#${email}`,
                "SK": `COUNTRY#${country}`
            }
        };
        const { Item } = await db.read(params);
        return res.success({ msg: "User record", status: true, data: { mock: data, db: Item } });
    } catch (error) {
        return res.failure({ msg: "Something went wrong , Please try again", status: false, data: {} });
    }
}