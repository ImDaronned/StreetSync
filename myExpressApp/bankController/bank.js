require('dotenv').config()

const express = require('express')
const { token } = require('morgan')
const router = express.Router()

const jwt = require('jsonwebtoken')
const mssql = require('mssql')

router.use(express.json())

const errorMessage = {
    token: {
        noAuthHeader: "You must have the header 'Authorization' in your request with the following string format: 'name token'",
        invalidToken: "You must have a valid token in your request header, Token expire in 1d so please re-login to refresh your token"
    },
    bank:{
        card_cvc: "You must have a 'card_cvc' field that is a cvc type(an int between 100 and 999)",
        card_expDate: "You must have a 'card_expDate' field with the date, following this string format: yyyy-mm",
        card_name: "You must have a 'card_name' field that should be a string",
        card_number: "You must have a 'card_number' field with the number of your card in a string format"
    }

}

const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    server: process.env.DB_SERVER, // Adresse du serveur SQL Azure
    database: process.env.DB_DB,
    options: {
        encrypt: true, // Active le cryptage SSL
        trustServerCertificate: true // Utilisez-le si vous utilisez Azure SQL et que vous rencontrez des problèmes de certificat
    }
}


mssql.connect(config)
    .then(pool => {

        router.get("/", authenticateToken, async (req, res) => {
            const result = await getUserBank(pool, req, res)
            if(result == null){return}
            console.log(`Bank: GET, send successfuly`)
            return res.status(200).json({bank: result})
        })

        router.post("/", authenticateToken, async (req, res) => {
            console.log(req.body.card_name)
            const check = await checkBodyBank(req, res)
            if(check == null){return}

            const result = await createUserBank(pool, req, res)
            if(result == null){return}

            console.log(`Bank: POST, created successfuly`)
            return res.status(200).json({created: true})
        })

        router.patch("/", authenticateToken, async (req, res) =>{
            const check = await checkBodyBank(req, res)
            if(check == null){return}

            const result = await updateUserBank(pool, req, res)
            if(result == null){return}

            console.log(`Bank: PATCH, updated successfuly`)
            return res.status(200).json({updated: true})
        })

        router.delete("/", authenticateToken, async (req, res) =>{
            const result = await deleteUserBank(pool, req, res)
            if(result == null){return}

            console.log(`Bank: DELETE, deleted successfuly`)
            return res.status(200).json({deleted: true})
        })

        process.on('SIGINT', () => {
            mssql.close()
                .catch(err => console.error('Erreur lors de la fermeture de la connexion à la base de données:', err));
        });
    })
    .catch(err => {
        console.error('Erreur de connexion à la base de données:', err);
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

async function checkBodyBank(req, res) {
    const card_name = req.body.card_name;
    if (!card_name || typeof card_name !== 'string' || card_name.trim() === '') {
        console.error(`Function: checkBodyBank, error: ${errorMessage.bank.card_name}`);
        res.status(400).json({ error: errorMessage.bank.card_name });
        return null;
    }

    const card_number = req.body.card_number;
    if (!card_number || typeof card_number !== 'string' || card_number.trim() === '') {
        console.error(`Function: checkBodyBank, error: ${errorMessage.bank.card_number}`);
        res.status(400).json({ error: errorMessage.bank.card_number });
        return null;
    }

    const card_expDate = req.body.card_expDate;
    if (!card_expDate || typeof card_expDate !== 'string' || card_expDate.length !== 7) {
        console.error(`Function: checkBodyBank, error: ${errorMessage.bank.card_expDate}`);
        res.status(400).json({ error: errorMessage.bank.card_expDate });
        return null;
    }

    const card_cvc = req.body.card_cvc;
    if (card_cvc === null || Number.isNaN(Number(card_cvc)) || !Number.isInteger(Number(card_cvc)) || card_cvc < 100 || card_cvc > 999) {
        console.error(`Function: checkBodyBank, error: ${errorMessage.bank.card_cvc}`);
        res.status(400).json({ error: errorMessage.bank.card_cvc });
        return null;
    }

    return true;
}



async function createUserBank(pool, req, res) {
    try {
        const query = "INSERT INTO bank_info (user_id, card_number, card_name, card_expDate, card_cvc) VALUES (@user_id, @card_number, @card_name, @card_expDate, @card_cvc)";
        return await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .input("card_number", req.body.card_number)
                .input("card_name", req.body.card_name)
                .input("card_expDate", req.body.card_expDate + "-01") // Supposant que card_expDate est une année et un mois (AAAA-MM)
                .input("card_cvc", req.body.card_cvc)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(true);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: createUserBank, error: ${err}`);
        res.status(400).json({ error: err });
        return null
    }
}


async function updateUserBank(pool, req, res){
    try {
        const query = "UPDATE bank_info SET card_number=@card_number,card_name=@card_name,card_expDate=@card_expDate,card_cvc=@card_cvc WHERE user_id=@user_id";
        return await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .input("card_number", req.body.card_number)
                .input("card_name", req.body.card_name)
                .input("card_expDate", req.body.card_expDate + "-01")
                .input("card_cvc", req.body.card_cvc)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if(result.rowsAffected[0] < 1){
                        reject("you don't have the permission to access")
                    } else{
                        resolve(true);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: updateUserBank, error: ${err}`);
        res.status(400).json({ error: err });
        return null
    }
}

async function getUserBank(pool, req, res) {
    try {
        const query = "SELECT money, card_number, card_name, card_expDate, card_cvc FROM bank_info WHERE user_id=@user_id";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if (result.recordset.length < 1) {
                        reject("Cannot find your bank info");
                    } else {
                        resolve(result.recordset[0])
                    }
                });
        });
        return result
    } catch (err) {
        console.error(`Function: getUserBank, error: ${err}`);
        res.status(400).json({ error: err });
        return null;
    }
}

async function deleteUserBank(pool, req, res) {
    try {
        const query = "DELETE FROM bank_info WHERE user_id=@user_id";
        return await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if(result.rowsAffected[0] < 1){
                        reject("you don't have the permission to access")
                    } else{
                        resolve(result);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: deleteUserBank, error: ${err}`);
        res.status(400).json({ error: err });
    }
}

module.exports = router