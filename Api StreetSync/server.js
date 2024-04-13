require('dotenv').config()

const express = require('express')
const app = express()
const PORT = 3000
const mysql = require('mysql')
const bcrypt = require('bcrypt')

app.use(express.json())

const sqlDb = mysql.createPool({
    connectionLimit : 10,
    user: 'root',
    password: '',
    database: 'StreetSync',
    host: 'localhost'
})


//register
app.post('/users/signup', async (req, res) => {
    try{

        const hashedPassword = await bcrypt.hash(req.body.password, 10)

        const query = "INSERT INTO users (hash,user_email,password,user_name,user_surname) VALUES (?,?,?,?,?)"
        sqlDb.query(query, 
        [
            Date.now().toString(),
            req.body.email,
            hashedPassword,
            req.body.name,
            req.body.surname
        ],
        (err, result) => {
            if(err){
                console.log(err)
                res.status(500).send('erreur')
            }
            else{
                console.log('utilisateur créer')
                res.status(201).send('oui') 
            }
        }) 
    }catch{
        res.status(500).send('non')
    }
})


//login
app.post('/users/signin', async (req, res) => {
    const query = "SELECT id, password FROM users WHERE user_email = ?"
    sqlDb.query(query, 
    [
        req.body.email
    ],
    async (err, result) => {
        if(err){
            console.log(err)
            return res.status(500).send('erreur')
        }
        if(result.length < 1){
            console.log(`email doesn't exist`)
            return res.status(400).json({connected : false, error : "this email doesn't exist, Please signin before signup"})
        }
        try{
            if(await bcrypt.compare(req.body.password, result[0].password)){
                console.log(result[0].id)
                res.status(201).json({connected : true})
            }
            else{
                console.log('wrong password')
                res.status(400).json({connected : false})
            }
        }catch{
            res.status(500).send('erreur')
        }
    })
    
    
})



app.listen(PORT, () => console.log("server started"))


