require('dotenv').config()

const express = require('express')
const { token } = require('morgan')
const router = express.Router()

const jwt = require('jsonwebtoken')
const mssql = require('mssql')
const paypal = require('@paypal/checkout-server-sdk')

router.use(express.json())


router.post("/", (req, res) => {
    const request = new paypal.orders.OrdersCreateRequest()
})





function authenticateToken(req, res, next){
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if(token == null){
        res.set('Content-Type', 'application/json');
        console.error(`Function: authenticateToken, error: ${errorMessage.token.noAuthHeader}`);
        return res.status(401).json({error: errorMessage.token.noAuthHeader});
    }
    var decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        if(err){
            res.set('Content-Type', 'application/json');
            console.error(`Function: authenticateToken, error: ${errorMessage.token.invalidToken}`);
            return res.status(403).json({error : errorMessage.token.invalidToken});
        }
        else{
            req.user = user;
            next();
        } 
    })
}

module.exports = router