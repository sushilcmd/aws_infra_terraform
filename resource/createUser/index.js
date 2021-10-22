const db = require('./helpers/dbOpreation');
const res = require('./helpers/res');
const axios = require('axios')

exports.handler = async (event) => {
    const body = JSON.parse(event.body);
    const { email, country } = body;

    try {
        const { data } = await axios.get(process.env.URL);
        let info = { ...body, ...data }
        const params = {
            TableName: process.env.TABLE_NAME,
            Item: {
                "PK": `USER#${email}`,
                "SK": `COUNTRY#${country}`,
                ...info
            }
        }
        const result = await db.create(params);
        return res.success({ msg: "Create new record successfully", status: true, data: { ...data, ...result } });
    } catch (error) {
        console.log(error)
        return res.failure({ msg: "Something went wrong , Please try again", status: false, data: {} });
    }
}