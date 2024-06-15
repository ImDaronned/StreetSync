const { name } = require('ejs');
const express = require('express');
const res = require('express/lib/response');
const router = express.Router()

const jwt = require('jsonwebtoken');
const { token } = require('morgan');
const mssql = require('mssql')
const nodeMailer = require('nodemailer')

router.use(express.json())


const tags = ["Dog Sitter", "Trash", "Handicraft", "Private teacher", "Other"]

const errorMessage = {
    services: {
        createdName: "You must have a 'name' field with a string value",
        createdTags: "You must have a 'tags' field with an array of tags(string) that can be get at the following url: https://streetsyncsql.database.windows.net/services/tags",
        createdPrice: "You must have a 'price' field with a number",
        updatedName: "You need a 'name' field to update the service's name but it must be a string",
        updatedTags: "You need a 'tags' field to update the service's tags but it must be an array of tags(string) that can be get at the following url: https://streetsyncsql.database.windows.net/services/tags",
        updatedPrice: "You need a 'price' field to update the service's price but it must be an int",
        description: "You can have a 'description' field but it must be a string value",
        imageLink: "You can have a 'imageLink' field but it must be a string value",
        queryId: "Give and id, ?id='service id' at the end of the url",
        ownError: "you need to own the service to delete it"
    },
    token: {
        noAuthHeader: "You must have the header 'Authorization' in your request with the following string format: 'name token'",
        invalidToken: "You must have a valid token in your request header, Token expire in 1d so please re-login to refresh your token"
    },
    score:{
        service_id: "You must have a field 'service_id' with and integer of the service id that you want to add a score",
        score: "You must have a field 'score' with a float (between 0.0 and 5.0) of the score that you want to give to the service",
        description: "You must have a field 'description', it must be a string in this field",
        wrongScoreUpdate: "you can only update an comment that you have already writen",
        updateCheck: "You have already commented on this service, please update your comment",
        createCheck: "You have not commented this service yet, Pls create a comment before updating it"
    },
    reservations:{
        date: "You must have a field date with a string that should be a date format, ex:'yy-mm-dd hh:mm'",
        duplicate: "You have already made a reservation to this services",
        service_id: "You must have a field service_id with a number",
        query: "You must have a 'user' field in your query with owner or registered",
        del: "You must have a service_id field in your query with the id of the service",
        notFind: "You cannot deleted this reservation",
        id: "You must have a 'reservation_id' field with a number",
        acceptError: "You cannot accept this reservation",
        paidError: "You cannot paid this reservation",
        participateOwn: "You cannot make a reservation to your own service"
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
            result = []

            const userInfo = await getUsers(pool, req.user.name, res);
            if(userInfo == null){return null}
            const userCoord = await parseStringCoord(userInfo.coord)

            const reqResult = await getServices(pool, req, res, null)
            if(reqResult == null){return}

            let proximity = false
            const queryLoc = req.query.localisation
            if(queryLoc != null && typeof queryLoc == typeof "" && queryLoc == "true"){
                proximity = true
            }

            for(let i = 0; i < reqResult.length; i++){

                const serviceCoord = await parseStringCoord(reqResult[i].coord)
                if(serviceCoord == null){return}
                if(!proximity || getDistanceBtwLatLong(userCoord[0], userCoord[1], serviceCoord[0], serviceCoord[1]) <= 10){
                    const score = await getServiceScore(pool, reqResult[i].id, res)
                    if(score == null){return}
                    let review = []
                    const parsedScore = await parseScore(pool, res, review, score)

                    result.push({
                        id: reqResult[i].id, 
                        Name: reqResult[i].Name,
                        Description: reqResult[i].Description,
                        Tags: strNumberToTagTab(reqResult[i].Tags),
                        Price: reqResult[i].Price,
                        ImageLink: reqResult[i].ImageLink,
                        Owner: reqResult[i].firstname + " " + reqResult[i].name, 
                        Score: parsedScore / 10,
                        Review: review
                        })
                }
            }
            console.log(`Send successfuly`)
            res.set('Content-Type', 'application/json')
            return res.status(200).json({result: result})
        })

        router.post("/", checkJsonHeader, authenticateToken, async (req, res) => {
            res.set('Content-Type', 'application/json');
            if(checkServicesBody(req, res)){
                req.body.tags = tagTabToStrNumber(req.body.tags, res)
                if(await createdService(pool, req, res)){
                    console.log(`Services: POST, created a new event`)
                    return res.status(201).json({created: true})
                }
            } 
            return null
        })

        router.patch("/", checkJsonHeader, authenticateToken,async (req, res) => {
            res.set('Content-Type', 'application/json');

            if(req.query.id == null){
                console.error(`Services: PATCH, error: ${errorMessage.services.queryId}`)
                return res.status(400).json({updated: false, error: errorMessage.services.queryId})
            }

            let queryParams = ""
            let hasParams = false

            let sqlQuery = pool.request()

            let info = checkServiceBodyName(req, res)
            if(info == null){return}
            if(info){
                queryParams = "Name=@Name,"
                sqlQuery.input("Name",req.body.name)
                hasParams = true
            }

            info = checkServiceBodyDescription(req, res)
            if(info == null){return}
            if(info){
                queryParams = "Description=@Description,"
                sqlQuery.input("Description", req.body.description)
                hasParams = true
            }

            info = checkServiceBodyTags(req, res)
            if(info == null){return}
            if(info){
                queryParams += "Tags=@Tags,"
                    
                const parsedTags = tagTabToStrNumber(req.body.tags)
                if(parsedTags == null){return}

                sqlQuery.input("Tags", parsedTags)
                hasParams = true
            }

            info=checkServiceBodyPrice(req, res)
            if(info == null){return}
            if(info){
                queryParams += "Price=@Price,"
                    sqlQuery.input("Price", req.body.price)
                    hasParams = true
            }

            info=checkServiceBodyImageLink(req, res)
            if(info == null){return}
            if(info){
                    queryParams += "ImageLink=@Image,"
                    sqlQuery.input("Image", req.body.imageLink)
                    hasParams = true
            }
            
            if(!hasParams){
                console.error(`Services: updateOne, no update colums given`)
                return res.status(400).json({updated: false, error: "give at least one parameter to update your service"})
            }
            else{
                const result = await updatedService(sqlQuery, req, res, queryParams)
                if(result == null){return}
                console.log(`Services, postOne, update successfuly`);
                return res.status(200).json({ updated: true, service: result.recordset });
            }
        })

        router.delete("/", authenticateToken,async (req, res) => {
            res.set('Content-Type', 'application/json');

            if(req.query.id == null){
                console.error(`Services: DELETE, error: ${errorMessage.services.queryId}`);
                return res.status(400).json({deleted: false, error: errorMessage.services.queryId})
            }

            const result = await deletedService(pool, req, res)
            if(result == null){return}
            console.log(`Service, deleteOne, deleted successfully`);
            return res.status(200).json({ deleted: true, message: `Deleted successfully`});
            
        })

        router.post("/score", authenticateToken, async (req, res) => {
            if(checkScoreBody(req, res)){
                const checkQuery = await getScoreService(pool, req, res, true)
                if(checkQuery){
                    const commentAdd = await addScoreService(pool, req, res)
                    if(commentAdd){
                        console.log(`Score: POST, score added successfuly`)
                        return res.status(201).json({created: true})
                    }
                }
            }
        
        })

        router.patch("/score" ,authenticateToken ,async (req, res) => {
            if(checkScoreBody(req, res)){
                const checkQuery = await getScoreService(pool, req, res, false)
                if(checkQuery){
                    const commentUpdate = await updateScoreService(pool, req, res)
                    if(commentUpdate){
                        console.log(`Score: POST, score updated successfuly`)
                        return res.status(200).json({updated: true})
                    }
                }
            }
        })

        router.get('/reservation', authenticateToken, async (req, res) => {
            const check = await queryCheck(req, res)
            if(check){
                const queryInfo = req.query.user
                if(queryInfo == "owner"){
                    const servicesInfo = await getServices(pool, req, res, "true")
                    if(servicesInfo == null){return}
                    let result = []
                    for (let i = 0; i < servicesInfo.length; i++) {
                        req.user.id = servicesInfo[i].id
                        const resultP = (await getServicesReservationsServices(pool, req, res)).recordset
                        if(resultP == null){return}
                        if(resultP.length > 0){
                            result.push({service: servicesInfo[i].id, reservations: resultP})
                        }
                        
                    }
                    console.log(`Reservations: GET, send successfuly`)
                    return res.status(200).json({result: result})
                }
                else{
                    const result = await getServicesReservationsUsers(pool, req, res)
                    if(result == null){return null}
                    console.log(`Reservations: GET, send successfuly`)
                    return res.status(200).json({result: result.recordset})
                }
            }
        })

        router.post("/reservation", authenticateToken, async (req, res) => {
            const check = await checkReservation(pool, req, res)
            if(check){
                const result = await createReservation(pool, req, res)
                if(result == null){return}
                const user = await getServicesOwner(pool, req, res)
                if(user == null){return}
                sendEmail(user.email, "Notification", `Someone make a reservation to your service`)
                console.log(`Reservation: POST, Created successfuly`)
                return res.status(200).json({created: true, message: "Created successfuly"})
            }
        })

        router.delete("/reservation", authenticateToken,async (req, res) => {
            const check = await checkReservationDel(req, res)
            if(check){
                const result = await deleteReservation(pool, req, res)
                if(result == null){return}
                console.log(`Reservation: DELETE, deleted successfuly`)
                return res.status(200).json({deleted: true, message:"deleted successfuly"})
            }
        })

        router.post("/accept", authenticateToken, async (req, res) => {
            const check = await checkReservationChange(pool, req, res)
            if(check){
                const result = await acceptReservation(pool, req, res)
                if(result == null){return}
                req.user.id = req.body.services_id
                const reservation = await getServicesReservationsServices(pool, req, res)
                if(reservation == null){return}
                if(reservation.recordset.length < 1){
                    console.error("you cannot acces this service")
                    return res.status(400).json({error: "you cannot access this service"})
                }
                const user = await getUsers(pool, reservation.recordset[0].user_id,res)
                sendEmail(user.email,"Notification","Your reservation got accepted")
                console.log(`Accept: POST, accepted successfuly`)
                return res.status(200).json({accpeted: true, message:"accepted successfuly"})
            }
        })

        router.post("/reject", authenticateToken, async (req, res) => {
            const check = await checkReservationChange(pool, req, res)
            if(check){
                const result = await rejectReservation(pool, req, res)
                if(result == null){return}
                req.user.id = req.body.services_id
                const reservation = await getServicesReservationsServices(pool, req, res)
                if(reservation == null){return}
                if(reservation.recordset.length < 1){
                    console.error("you cannot acces this service")
                    return res.status(400).json({error: "You cannot access this service"})
                }
                const user = await getUsers(pool, reservation.recordset[0].user_id,res)
                sendEmail(user.email,"Notification","Your reservation got rejected")
                console.log(`Reject: POST, rejected successfuly`)
                return res.status(200).json({rejected: true})
            }
        })

        router.post("/pay", authenticateToken, async (req, res) => {
            const check = await checkPayMethod(pool, req, res)
            if(check){
                const result = await payReservation(pool, req, res)
                if(result == null){return}
                const reservation = await getServicesReservationsUsers(pool, req, res)
                if(reservation == null){return}
                req.body.service_id = reservation.services_id
                const owner = getServicesOwner(pool, req, res)
                if(owner == null){return}
                sendEmail(owner.email, "Notification", "One of your reservation that you accept got paid")
                const user = getUsers(pool, req.user.name, res)
                sendEmail(user.email, "Notification", "Purchase confirmed")
                console.log(`Pay: POST, paid successfuly`)
                return res.status(200).json({paid: true})
            }
        })

        // Déconnexion de la base de données lorsque l'application se termine
        process.on('SIGINT', () => {
            mssql.close()
                .catch(err => console.error('Erreur lors de la fermeture de la connexion à la base de données:', err));
        });
    })
    .catch(err => {
        console.error('Erreur de connexion à la base de données:', err);
    });

router.get("/tags", (req, res) => {
    res.status(200).send(tags)
})

function checkJsonHeader(req, res, next){
    /*const contentTypeHeader = req.headers['Content-Type']
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

function checkScoreBody(req, res){

    const service_id = req.body.service_id
    if(service_id == null || typeof(service_id) != typeof(1)){
        console.error(`Score: POST, error: ${errorMessage.score.service_id}`)
        res.status(400).json({error: errorMessage.score.service_id})
        return false
    }

    const score = req.body.score
    if(score == null || typeof score != typeof 1.2 || score < 0.0 || score > 5.0){
        console.error(`Score: POST, error: ${errorMessage.score.score}`)
        res.status(400).json({error: errorMessage.score.score})
        return false
    }

    const desc = req.body.description
    if(desc != null || typeof desc != typeof ""){
        console.error(`Score: POST, error: ${errorMessage.score.description}`)
        res.status(400).json({error: errorMessage.score.description})
        return false
    }

    return true
}

function checkServicesBody(req, res) {
    try {
        if (req.body.name == null || typeof(req.body.name) != typeof "" || req.body.name ==  "") {
            console.error(`Services, createOne, error: ${errorMessage.services.createdName}`);
            res.status(400).json({ created: false, error: errorMessage.services.createdName });
            return false;
        }

        if (req.body.tags == null || typeof req.body.tags != typeof ["", ""]) {
            console.error(`Services, createOne, error: ${errorMessage.services.createdTags}`);
            res.status(400).json({ created: false, error: errorMessage.services.createdTags });
            return false;
        }

        if (req.body.price == null || typeof(req.body.price) != typeof 1) {
            console.error(`Services, createOne, error: ${errorMessage.services.createdPrice}`);
            res.status(400).json({ created: false, error: errorMessage.services.createdPrice });
            return false;
        }

        const descCheck = checkServiceBodyDescription(req, res);
        const imageCheck = checkServiceBodyImageLink(req, res);

        return descCheck != null && imageCheck != null
    } catch (err) {
        console.error(`Services, checkServicesBody, error: ${err.message}`);
        res.status(500).json({ created: false, error: "Internal server error" });
        return false;
    }
}


function checkServiceBodyName(req, res){
    if(req.body.name != null){
        if(typeof(req.body.name) != typeof("") || req.body.name == ""){
            console.error(`Services: updateOne, error: ${errorMessage.services.updatedName}`)
            res.status(400).json({updated: false, error: errorMessage.services.updatedName})
            return null
        }
        else{
            return true
        }
    }
    return false
}
function checkServiceBodyDescription(req, res){
    if(req.body.description != null){
        if( typeof(req.body.description) != typeof("")){
            console.error(`Services, createOne, error: ${errorMessage.services.description}`)
            res.status(400).json({created: false, error: errorMessage.services.description})
            return null;
        }
        return true;
    }
    return false;
}

function checkServiceBodyTags(req, res){
    if(req.body.tags != null){
        if(typeof(req.body.tags) != typeof(["",""])){
            console.error(`Services: updateOne, error: ${errorMessage.services.updatedTags}`)
            res.status(400).json({updated: false, error: errorMessage.services.updatedTags})
            return null;
        }
        return true;
    }
    return false;
}

function checkServiceBodyPrice(req, res){
    if(req.body.price != null){
        if(typeof(req.body.price) != typeof(1)){
            console.error(`Events: updateOne, error: ${errorMessage.services.updatedPrice}`)
            res.status(400).json({updated: false, error: errorMessage.services.updatedPrice})
            return null
        }
        return true;
    }
    return false
}

function checkServiceBodyImageLink(req, res){
    if(req.body.imageLink != null){
            if(typeof(req.body.imageLink) != typeof("")){
            console.error(`Services, createOne, error: Wrong imageLink format`)
            res.status(400).json({created: false, error: errorMessage.services.imageLink})
            return null
        }
        return true
    }
    return false
}

function tagTabToStrNumber(_tags, res){
    let result = ""

    for(let i = 0; i < _tags.length; i++){
        const info = tagToNumber(_tags[i], res)
        if(info == null){return null}

        result += info
    }
    return result
}

function tagToNumber(_tag, res){
    let j = 0;
    for(; j < tags.length && _tag != tags[j]; j++){    
    }

    if(j == tags.length){
        console.error(`Function: tagTabToStrNumber, error: Wrong tag ${_tag[i]}`)
        res.status(400).json({error: `${_tag[i]} is not an available tag`})
        return null
    } else{
        return `${j}-`
    }
}

function strNumberToTagTab(_strNbs){
    let result = []
    let check = _strNbs.split('-')

    for(let i = 0; i < check.length; i++){
        let _tag_ = tags[check[i]]
        if(_tag_ != null)
        result.push(_tag_)
    }

    return result
}

async function updateScoreService(pool, req, res){
    try{
        const query = "UPDATE services_score SET score=@score, description=@description WHERE user_id=@user_id AND services_id=@service_id"
        const result = await new Promise((resolve, reject) => {
            pool.request()
            .input("user_id", req.user.name)
            .input("service_id", req.body.service_id)
            .input("score", req.body.score * 10)
            .input("description", req.body.description)
            .query(query, (err, result) => {
                if(err){
                    reject(err.message)
                } else if(result.rowsAffected[0] < 1){
                    reject(errorMessage.score.wrongScoreUpdate)
                } else{
                    resolve(true)
                }
            })
        })
        return result;
    } catch (err){
        console.error(`Function: updateScoreService, error: ${err}`)
        res.status(400).json({error: err})
        return false
    }
}

async function addScoreService(pool, req, res) {
    try {
        const query = "INSERT INTO services_score (user_id, services_id, score, description) VALUES (@user_id, @service_id, @score, @description)";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .input("service_id", req.body.service_id)
                .input("score", req.body.score * 10)
                .input("description", req.body.description)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(true);
                    }
                });
        });
        return result
    } catch (err) {
        console.error(`Function: addScoreService, error: ${err}`);
        res.status(400).json({ error: err });
        return false
    }
}


async function getScoreService(pool, req, res, createdBool) {
    try {
        const checkQuery = "SELECT * FROM services_score WHERE user_id=@user_id AND services_id=@service_id";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .input("service_id", req.body.service_id)
                .query(checkQuery, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if(result.recordset.length > 0 ){
                        if(createdBool){
                            reject(errorMessage.score.updateCheck)
                        } else{
                            resolve(true)
                        }
                    } else{
                        if(createdBool){
                            resolve(true)
                        } else{
                            reject(errorMessage.score.createCheck)
                        }
                    }
                });
        });
        return result
    } catch (err) {
        console.error(`Function: getScoreService, error: ${err}`);
        res.status(400).json({ error: err });
        return false
    }
}


async function deletedService(pool, req, res) {
    try {
        const query = "DELETE FROM services WHERE id=@id AND Owner=@Owner";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("id", req.query.id)
                .input("Owner", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if (result.rowsAffected[0] < 1) {
                        reject(errorMessage.services.ownError);
                    } else {
                        resolve(true);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Services, deleteOne, error: ${err}`);
        res.status(400).json({ deleted: false, error: err });
        return null;
    }
}


async function updatedService(request, req, res, queryParams) {
    try {
        const query = `UPDATE services SET ${queryParams.substring(0,queryParams.length-1)} WHERE id=@id AND Owner=@Owner`;
        const result = await new Promise((resolve, reject) => {
            request.input("Owner", req.user.name)
                .input("id", req.query.id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if (result.rowsAffected[0] < 1) {
                        reject(errorMessage.services.ownError);
                    } else {
                        resolve(result);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Services, postOne, error: ${err}`);
        res.status(400).json({ updated: false, error: err });
        return null;
    }
}


async function createdService(pool, req, res) {
    try {
        const query = "INSERT INTO services (Name, Description, Tags, Price, ImageLink, Owner) VALUES (@Name, @Description, @Tags, @Price, @Image, @Owner)";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("Name", req.body.name)
                .input("Description", req.body.description)
                .input("Tags", req.body.tags)
                .input("Price", req.body.price)
                .input("Image", req.body.imageLink)
                .input("Owner", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(true);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Services: createOne, error: ${err}`);
        res.status(400).json({ created: false, error: err });
        return null;
    }
}


async function getServices(pool, req, res, owner){
    let query = "SELECT services.*, users.firstname, users.name FROM services JOIN users ON services.Owner = users.user_id";

    let infoQuery = false

    const queryId = req.query.id
    if (queryId != null && Number.isInteger(parseInt(queryId))) {
        query += " WHERE services.id=@id"
        infoQuery = true
    }

    let queryOwner = owner
    if(queryOwner == null){
        queryOwner = req.query.owner
    }
    if(queryOwner != null && typeof queryOwner == typeof "" && queryOwner == "true"){
        if(infoQuery){
            query += " AND services.Owner=@user_id"
        } else{
            query += " WHERE services.Owner=@user_id"
        }
        infoQuery = true
    }

    const queryName = req.query.name
    if(queryName != null && typeof queryName == typeof ""){
        if(infoQuery){
            query += " AND services.Name=@name"
        } else{
            query += " WHERE services.Name=@name"
        }
        infoQuery = true
    }
    

    try {
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("id", queryId)
                .input("user_id", req.user.name)
                .input("name", req.query.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(result.recordset);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Function: getServices, error: ${err}`);
        res.set('Content-Type', 'application/json');
        res.status(400).json({ error: err });
        return null;
    }
}

async function getUsers(pool, user_id, res){
    try{
        const result =  await new Promise((resolve, reject) => {
            const query = "SELECT * FROM users WHERE user_id=@user_id"
            pool.request()
                .input("user_id", user_id)
                .query(query, (err, result) => {
                    if(err){
                        reject(err.message)
                    }
                    else{
                        resolve(result.recordset[0])
                    }
                })
        })
        return result;
    } catch(err){
        console.error(`Function: getUsers, error: ${err}`)
        res.set('Content-Type', 'application/json')
        res.status(400).json({error: err})
        return null
    }
}

async function getServiceScore(pool, service_id, res) {
    try {
        return await new Promise((resolve, reject) => {
            const query = "SELECT score,description,user_id FROM services_score WHERE services_id=@id";
            pool.request()
                .input("id", service_id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(result.recordset);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: getServiceScore, error: ${err}`);
        res.set('Content-Type', 'application/json');
        res.status(400).json({ error: err });
        return null;
    }
}


function tabScoreSum(tab){
    let result = 0
    let i = 0;
    for(; i < tab.length; i++){
        result += tab[i].score
    }
    return [result,i]
}

function getDistanceBtwLatLong(lat1, lon1, lat2, lon2) {
    const R = 6371; // Rayon de la Terre en kilomètres

    // Conversion des degrés en radians
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;

    // Calcul des parties de la formule haversine
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    // Distance en kilomètres
    const distance = R * c;

    return distance;
}

async function parseStringCoord(stringCoord) {
    try {
        if (typeof stringCoord !== "string") {
            throw new Error(`${typeof stringCoord} type issues`);
        } else {
            // Insérer ici le code de traitement si nécessaire
            return stringCoord; // Par exemple, ici on pourrait faire un traitement sur la chaîne de caractères
        }
    } catch (err) {
        console.error(`Function: parseStringCoord, error: ${err.message}`);
        throw err; // Propager l'erreur pour la gérer à un niveau supérieur si nécessaire
    }
}

async function checkReservation(pool, req, res){
    const exp = "2024-06-04 14:30"
    if(typeof req.body.date != typeof "" || req.body.date.length != exp.length){
        console.error(`Function: checkReservation, error: ${errorMessage.reservations.date}`)
        res.status(400).json({error: errorMessage.reservations.date})
        return null
    }
    if(typeof req.body.service_id != typeof 1 || req.body.service_id < 0){
        console.error(`Function: checkReservation, error: ${errorMessage.reservations.service_id}`)
        res.status(400).json({error: errorMessage.reservations.service_id})
        return null
    }
    req.query.id = req.body.service_id
    req.query.owner = null
    req.query.name = null
    const check = await getServices(pool, req, res, null)
    if(check == null){return}
    if(check.length < 1){
        console.error(`ChekReservation: pls make a reservation on an existing service`)
        res.status(400).json({error: "pls make a reservation on an existing service"})
        return null
    }
    if(check[0].owner == req.user.name){
        console.error(`Function: checkReservation, error: ${errorMessage.reservations.participateOwn}`)
        res.status(400).json({error: errorMessage.reservations.participateOwn})
        return null
    }
    const result = await getServicesReservationsUsers(pool, req, res)
    if(result == null){return null}
    const getResult = result.recordset
    for (let i = 0; i < getResult.length; i++) {
        if(getResult[i].services_id == req.body.service_id){
            console.error(`Function: checkReservation, error: ${errorMessage.reservations.duplicate}`)
            res.status(400).json({error: errorMessage.reservations.duplicate})
            return null
        }
    }
    return true
}

async function getServicesReservationsUsers(pool, req, res){
    try {
        return await new Promise((resolve, reject) => {
            const query = "SELECT * FROM services_reservations WHERE user_id=@id";
            pool.request()
                .input("id", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(result);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: getServiceScore, error: ${err}`);
        res.set('Content-Type', 'application/json');
        res.status(400).json({ error: err });
        return null;
    }
}

async function getServicesReservationsServices(pool, req, res){
    try {
        return await new Promise((resolve, reject) => {
            const query = "SELECT * FROM services_reservations WHERE services_id=@id";
            pool.request()
                .input("id", req.user.id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(result);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: getServiceScore, error: ${err}`);
        res.set('Content-Type', 'application/json');
        res.status(400).json({ error: err });
        return null;
    }
}

async function queryCheck(req, res){
    if(typeof req.query.user != typeof "" || (req.query.user != "owner" && req.query.user != "registered")){
        console.error(`Function: queryCheck, error: ${errorMessage.reservations.query}`)
        res.status(400).json({error: errorMessage.reservations.query})
        return null
    }
    return true
}

async function createReservation(pool, req, res){
    try {
        const query = "INSERT INTO services_reservations (user_id,services_id,reservation_day) VALUES (@u_id,@s_id,@r_d)";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("u_id", req.user.name)
                .input("s_id", req.body.service_id)
                .input("r_d", req.body.date + ":00")
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        resolve(true);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Reservations: POST, error: ${err}`);
        res.status(400).json({ created: false, error: err });
        return null;
    }
}

async function checkReservationDel(req, res){
    if(typeof req.query.service_id != typeof ""){
        console.error(`Function: checkReservationDel, error: ${errorMessage.reservations.del}`)
        res.status(400).json({error: errorMessage.reservations.del})
        return null
    }
    return true
}

async function deleteReservation(pool, req, res){
    try {
        const query = "DELETE FROM services_reservations WHERE services_id=@s_id AND user_id=@u_id";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("u_id", req.user.name)
                .input("s_id", req.query.service_id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if (result.rowsAffected[0] < 1) {
                        reject(errorMessage.reservations.notFind);
                    } else {
                        resolve(true);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Reservation, DELETE, error: ${err}`);
        res.status(400).json({ deleted: false, error: err });
        return null;
    }
}

async function parseScore(pool, res, result, tab){
    let sumOfScores = 0;
    let info = 0

    for (let i = 0; i < tab.length; i++) {
        const item = tab[i]
        sumOfScores += item.score;
        info++
        if (item.description !== null) {
            const user = await getUsers(pool, item.user_id, res)
            result.push({description: item.description, score: item.score, user: `${user.firstname} ${user.name}`});
        }
    }
    return Math.round(sumOfScores / info);
}

async function checkReservationChange(pool, req, res){
    const reservation_id = req.body.reservation_id
    if(reservation_id == null || typeof reservation_id != typeof 1 || reservation_id < 0){
        console.error(`Function: checkReservationChange, error: ${errorMessage.reservations.id}`)
        res.status(400).json({error: errorMessage.reservations.id})
        return null
    }
    const result = await checkReservationOwner(pool, req, res)
    return result
}

async function checkReservationOwner(pool, req, res){
    try {
        return await new Promise((resolve, reject) => {
            const query = "SELECT s.owner FROM services s JOIN services_reservations sr ON s.id = sr.services_id WHERE sr.id=@r_i"
            pool.request()
            .input("r_i", req.body.reservation_id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if(result.recordset.length < 1 || result.recordset[0].owner != req.user.name){
                        reject(errorMessage.reservations.acceptError)
                    } else{
                        resolve(true);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: checkReservationOwner, error: ${err}`);
        res.set('Content-Type', 'application/json');
        res.status(400).json({ error: err });
        return null;
    }
}

async function acceptReservation(pool, req, res){
    try {
        const query = `UPDATE services_reservations SET accepted=1 WHERE id=@id AND accepted=0`;
        const result = await new Promise((resolve, reject) => {
                pool.request()
                    .input("id", req.body.reservation_id)
                    .query(query, (err, result) => {
                        if (err) {
                            reject(err.message);
                        } else if (result.rowsAffected[0] < 1) {
                            reject(errorMessage.reservations.acceptError);
                        } else {
                            resolve(true);
                        }
                    });
        });
        return result;
    } catch (err) {
        console.error(`Function: acceptReservation, error: ${err}`);
        res.status(400).json({ updated: false, error: err });
        return null;
    }
}

async function rejectReservation(pool, req, res){
    try {
        const query = "DELETE FROM services_reservations WHERE id=@id";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("id", req.body.reservation_id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if (result.rowsAffected[0] < 1) {
                        reject(errorMessage.reservations.notFind);
                    } else {
                        resolve(true);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Reservation, DELETE, error: ${err}`);
        res.status(400).json({ deleted: false, error: err });
        return null;
    }
}

async function payReservation(pool, req, res){
    try {
        const query = `UPDATE services_reservations SET paid=1 WHERE id=@id AND paid=0 AND accepted=1`;
        const result = await new Promise((resolve, reject) => {
                pool.request()
                    .input("id", req.body.reservation_id)
                    .query(query, (err, result) => {
                        if (err) {
                            reject(err.message);
                        } else if (result.rowsAffected[0] < 1) {
                            reject(errorMessage.reservations.paidError);
                        } else {
                            resolve(true);
                        }
                    });
        });
        return result;
    } catch (err) {
        console.error(`Function: payReservation, error: ${err}`);
        res.status(400).json({ updated: false, error: err });
        return null;
    }
}

async function sendEmail(to, subject, text, html) {
    try {
        let transporter = nodeMailer.createTransport({
            service:'gmail',
            host: 'smtp.gmail.com',
            port: 465,
            secure: true,
            auth: {
              user: process.env.SMTP_USER,
              pass: process.env.SMTP_PASS,
            },
        });
      
        let mailOptions = {
          from: {
            name: "StreetSync",
            address: process.env.SMTP_USER
          },
          to: to,
          subject: subject,
          text: text,
          html: html,
        };
      
        transporter.sendMail(mailOptions);
    } catch (error) {
        console.error(error)
    }
  }

async function getServicesOwner(pool, req, res){
    req.query.id = req.body.service_id
    req.query.owner = null
    req.query.name = null
    const services = await getServices(pool, req, res)
    if(services == null) {return null}
    const user = await getUsers(pool, services[0].Owner, res)
    if(user == null){return null}
    return user
}

async function checkPayMethod(pool, req, res){
    const reservation_id = req.body.reservation_id
    if(reservation_id == null || typeof reservation_id != typeof 1 || reservation_id < 0){
        console.error(`Function: checkReservationChange, error: ${errorMessage.reservations.id}`)
        res.status(400).json({error: errorMessage.reservations.id})
        return null
    }
    const result = await checkReservationUser(pool, req, res)
    return result
}

async function checkReservationUser(pool, req, res){
    try {
        return await new Promise((resolve, reject) => {
            const query = "SELECT user_id FROM services_reservations WHERE id=@r_i"
            pool.request()
            .input("r_i", req.body.reservation_id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if(result.recordset[0].user_id != req.user.name){
                        reject(errorMessage.reservations.acceptError)
                    } else{
                        resolve(true);
                    }
                });
        });
    } catch (err) {
        console.error(`Function: checkReservationUser, error: ${err}`);
        res.set('Content-Type', 'application/json');
        res.status(400).json({ error: err });
        return null;
    }
}

module.exports = router