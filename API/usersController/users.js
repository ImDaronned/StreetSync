require('dotenv').config()

const express = require('express')
const router = express.Router()

const mssql = require('mssql')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken');
const fs = require('fs')
const { register } = require('module')
const { type } = require('express/lib/response')

router.use(express.json())

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

// Se connecter à la base de données
mssql.connect(config)
    .then(pool => {
        console.log('Connecté à la base de données');

        router.get('/profile',  authenticateToken,(req, res) => {
            res.set('Content-Type', 'application/json');
            const query = "SELECT email,firstname,name FROM users WHERE user_id=@id"
            pool.request()
                .input("id", req.user.name)
                .query(query, (err, result) => {
                    if(err) {
                        console.log(`Users: profil, ${err.message}`)
                        res.status(400).json({profil: null, error: err.message})
                    }
                    else{
                        console.log(`Users: profil, send profil succesfuly`)
                        res.status(200).json({profil: result.recordset[0]})
                    }
                })
        })

        //register
        router.post('/signup', checkJsonHeader,async (req, res) => {
            res.set('Content-Type', 'application/json');
            if(req.body.password == null || typeof(req.body.password) != typeof("") || req.body.password == ""){
                console.log('Users: register, wrong password format')
                return res.status(400).json({registered: false, error: "wrong passsword format"})
            }
            else if(req.body.email == null || typeof(req.body.email) != typeof("") || req.body.email == ""){
                console.log('Users: register, wrong email format')
                return res.status(400).json({registered: false, error: "wrong email format"})
            }
            else if(req.body.firstname == null || typeof(req.body.firstname) != typeof("") || req.body.firstname == ""){
                console.log('Users: register, wrong firstname format')
                return res.status(400).json({registered: false, error: "wrong firstname format"})
            }
            else if(req.body.name == null || typeof(req.body.name) != typeof("") || req.body.name == ""){
                console.log('Users: register, wrong name format')
                return res.status(400).json({registered: false, error: "wrong name format"})
            }
            else try {

                const hashedPassword = await bcrypt.hash(req.body.password, 10)

                const query = "INSERT INTO users (user_id,email,password,firstname,name) VALUES (@user_id,@email,@password,@firstname,@name)"
                pool.request()
                    .input('user_id', Date.now().toString())
                    .input('email', req.body.email)
                    .input('password', hashedPassword)
                    .input('firstname', req.body.firstname)
                    .input('name', req.body.name)
                    .query(query, (err, result) => {
                        if (err) {
                            console.log(`Users: register, ${err.message}`)
                            return res.status(400).json({registered: false, error : err.message})
                        } else {
                            console.log('Users: register, new user registered succesfuly')
                            return res.status(201).json({registered: true, message: `${req.body.firstname} ${req.body.name} has been succesfully registered`})
                        }
                    })
            } catch (error){
                console.log(error.message)
                return res.status(500).json({registered: false, error : error.message})
            }
        })

        //login
        router.post('/signin', checkJsonHeader,async (req, res) => {
            res.set('Content-Type', 'application/json');
            if(req.body.email == null || typeof(req.body.email) != typeof("") || req.body.email == ""){
                console.log('Users: login, wrong email format')
                return res.status(400).json({token: null, error: "wrong email format"})
            }
            else if(req.body.password == null || typeof(req.body.password) != typeof("") || req.body.password == ""){
                console.log('Users: login, wrong password format')
                return res.status(400).json({token: null, error: "wrong password format"})
            }
            else if(req.body.coord == null || typeof req.body.coord != typeof ""){
                console.log('Users: login, wrong coord format')
                return res.status(400).json({error: "you must have a 'coord' field with the following string format: 'latitude-longitude'"})
            }
            else{
                const query = "SELECT firstname,password,user_id,name FROM users WHERE email = @email"
                pool.request()
                    .input('email', req.body.email)
                    .query(query, async (err, result) => {
                        if (err) {
                            console.log(`Users: login, ${err.message}`)
                            return res.status(400).json({token : null, error: err.message})
                        }
                        if (result.recordset.length < 1) {
                            console.log(`Users: login, wrong password or email`)
                            return res.status(400).json({ token: null, error: "wrong email or password" })
                        }
                        try {
                            if (await bcrypt.compare(req.body.password, result.recordset[0].password)) {

                                const user = {name: result.recordset[0].user_id}
                                const token = jwt.sign(user, process.env.ACCESS_TOKEN_SECRET, {expiresIn : '1d'})

                                updateUserCoord(pool, user.name, req.body.coord)

                                console.log(`Users: login, ${result.recordset[0].firstname} connected`);
                                return res.status(200).json({token: token, message: `${result.recordset[0].firstname}, ${result.recordset[0].name} connected successfuly` })
                            } else {
                                console.log('Users: login, wrong password or email')
                                return res.status(400).json({token: null , error: "wrong email or password"})
                            }
                        } catch (error){
                            console.log(`Users: login, ${error.message}`)
                            return res.status(500).json({token: null, error: error.message})
                        }
                    })
            }
        })

        router.patch("/profile", checkJsonHeader, authenticateToken, async (req, res) => {
            res.set('Content-Type', 'application/json');
            let queryParams = ""
            let hasParams = false
            if(req.body.firstname != null){
                if(typeof(req.body.firstname) != typeof("") || req.body.firstname == ""){
                    console.log(`Users: patchProfile, wrong firstname format`)
                    return res.status(400).json({updated: false, error: 'Wrong format with the user firstname'})
                }
                else{
                    queryParams = "firstname=@firstname,"
                    hasParams = true
                }
            }

            if(req.body.name != null){
                if(typeof(req.body.name) != typeof("") || req.body.name == ""){
                    console.log(`Users: patchProfile, wrong name format`)
                    return res.status(400).json({updated: false, error: "Wrong format with the user name"})
                }
                else{
                    queryParams += "name=@name,"
                    hasParams = true
                }
            }

            if(req.body.email != null){
                if(typeof(req.body.email) != typeof("") || req.body.email == ""){
                    console.log(`Users: patchProfile, wrong email format`)
                    return res.status(400).json({updated: false, error: "you need to have a field 'email' that should be a string if you want to update the user email"})
                }
                else{
                    queryParams += "email=@email,"
                    hasParams = true
                }
            }
            let hashedPassword = "";
            if(req.body.password != null){
                if(typeof(req.body.password) != typeof("") || req.body.password == ""){
                    console.log(`Users: patchProfile, wrong name format`)
                    return res.status(400).json({updated: false, error: "you need to have a field 'password' that should be a string if you want to update the user password"})
                }
                else{
                    queryParams += "password=@password,"
                    hasParams = true
                    hashedPassword = await bcrypt.hash(req.body.password, 10)
                }
            }

            if(hasParams){
                const query = `UPDATE users SET ${queryParams.substring(0,queryParams.length-1)} WHERE user_id=@user_id`

                console.log(query)

                pool.request()
                    .input("user_id", req.user.name)
                    .input("firstname", req.body.firstname)
                    .input("name", req.body.name)
                    .input("email", req.body.email)
                    .input("password", hashedPassword)
                    .query(query, (err, result) => {
                        if(err){
                            console.log(`Users: patchProfile, ${err.message}`)
                            res.status(400).json({updated: false, error: err.message})
                        }
                        else if(result.rowsAffected[0] < 1){
                            console.log(`Users: patchProfile, User doesn't exist`)
                            res.status(400).json({updated: false, error:"The user doesn't exist"})
                        }
                        else{
                            console.log(`Users: patchProfile, user updated successfuly`)
                            res.status(200).json({updated: true})
                        }
                    })
            }
        })

        router.delete("/profile", authenticateToken, (req, res) => {
            res.set('Content-Type', 'application/json');
            const query = "DELETE FROM users WHERE user_id = @user_id"
            pool.request()
                .input("user_id", req.user.name)
                .query(query, (err, result) => {
                    if(err){
                        console.log(`Users: deleteProfile, ${err.message}`)
                        res.status(400).json({deleted: false, error: err.message})
                    }
                    else if (result.rowsAffected[0] < 1){
                        console.log(`Users: deleteProfile, User doesn't exist`)
                        res.status(200).json({deleted: false, error: "The user doesn't exist"})
                    }
                    else{
                        console.log(`Users: deleteProfile, User deleted successfuly`)
                        res.status(200).json({deleted: true})
                    }
                })
        })


        // Déconnexion de la base de données lorsque l'application se termine
        process.on('SIGINT', () => {
            mssql.close()
                .then(() => console.log('Connexion à la base de données fermée'))
                .catch(err => console.error('Erreur lors de la fermeture de la connexion à la base de données:', err));
        });
    })
    .catch(err => {
        console.error('Erreur de connexion à la base de données:', err);
    });

function checkJsonHeader(req, res, next){
    /*const contentTypeHeader = req.headers['Content-Type']
    console.log(contentTypeHeader)
    if(contentTypeHeader == null || contentTypeHeader != "application/json"){
        res.set('Content-Type', 'application/json');
        console.log(`Content-TypeVerification: wrong content-type headers`)
        return res.status(415).json({error: "Need Content-Type Header with application/json"})
    }
    else{
        
    }*/
    next()
}

function authenticateToken(req, res, next){
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if(token == null){
        res.set('Content-Type', 'application/json');
        console.log('TokenVerification: No token');
        return res.status(401).json({error: "No token in the header 'Authorization'"});
    }
    var decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        if(err){
            res.set('Content-Type', 'application/json');
            console.log('TokenVerification: wron token');
            return res.status(403).json({error : "the token is not valid"});
        }
        else{
            req.user = user;
            console.log(req.user)
            next();
        } 
    })
    console.log(decoded)
}

function updateUserCoord(pool, user_id, coord){
    const query = "UPDATE users SET coord=@coord WHERE user_id=@user_id"
    pool.request()
        .input("coord", coord)
        .input("user_id", user_id)
        .query(query, (err, result) =>{
            if(err){
                console.log(`Function: updateUserCoord, error: ${err.message}`)
            } else{
                console.log(`Function: updateUserCoord, user coord updated successfuly`)
            }
        })
}

module.exports = router
