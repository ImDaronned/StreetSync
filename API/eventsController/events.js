require('dotenv').config()

const express = require('express')
const router = express.Router()

const jwt = require('jsonwebtoken');
const mssql = require('mssql')

router.use(express.json())


const tags = ["Sport", "Party", "Music", "Movies", "Theater","Walk","Other"]

const errorMessage = {
    events: {
        createdName: "You must have a 'name' field with a string value",
        createdTags: "You must have a 'tags' field with an array of tags(string) that can be get at the following url: https://streetsyncsql.database.windows.net/events/tags",
        createdDate: "You must have a 'date' field with a date(string format: yyyy-mm-dd)",
        updatedName: "You need a 'name' field to update the event's name but it must be a string",
        updatedTags: "You need a 'tags' field to update the event's tags but it must be an array of tags(string) that can be get at the following url: https://streetsyncsql.database.windows.net/events/tags",
        updatedDate: "You need a 'date' field to update the event's date but it must be a date(string format: yyyy-mm-dd)",
        description: "You can have a 'description' field but it must be a string value",
        imageLink: "You can have a 'imageLink' field but it must be a string value",
        queryId: "Give and id, ?id='event id' at the end of the url",
        ownError: "you need to own the event to delete it",
        reservationFormat: "you need to have a 'event_id' in your url with a number"
    },
    token: {
        noAuthHeader: "You must have the header 'Authorization' in your request with the following string format: 'name token'",
        invalidToken: "You must have a valid token in your request header, Token expire in 1d so please re-login to refresh your token"
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
            if(userInfo == null){return}
            const userCoord = await parseStringCoord(userInfo.coord)

            let reqResult = await getEvents(pool, req, res, null)
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
                    result.push({
                        id: reqResult[i].id, 
                        Name: reqResult[i].Name,
                        Description: reqResult[i].Description,
                        Tags: strNumberToTagTab(reqResult[i].Tags),
                        Date: reqResult[i].Date,
                        ImageLink: reqResult[i].ImageLink,
                        Owner: reqResult[i].firstname + " " + reqResult[i].name
                        })
                }
            }
            console.log(`Send successfuly`)
            res.set('Content-Type', 'application/json')
            return res.status(200).json({result: result})
        })

        router.post("/", checkJsonHeader, authenticateToken, async (req, res) => {
            res.set('Content-Type', 'application/json');
            if(checkEventsBody(req, res)){
                req.body.tags = tagTabToStrNumber(req.body.tags, res)
                if(await createdEvent(pool, req, res)){
                    console.log(`Events: POST, created a new event`)
                    return res.status(201).json({created: true})
                }
            }
            return
        })

        router.patch("/", checkJsonHeader, authenticateToken,async (req, res) => {
            res.set('Content-Type', 'application/json');

            if(req.query.id == null){
                console.error(`Events: PATCH, error: ${errorMessage.events.queryId}`)
                return res.status(400).json({updated: false, error: errorMessage.events.queryId})
            }

            let queryParams = ""
            let hasParams = false

            let sqlQuery = pool.request()

            let info = checkEventBodyName(req, res)
            if(info == null){return}
            if(info){
                queryParams = "Name=@Name,"
                sqlQuery.input("Name",req.body.name)
                hasParams = true
            }

            info = checkEventBodyDescription(req, res)
            if(info == null){return}
            if(info){
                queryParams = "Description=@Description,"
                sqlQuery.input("Description", req.body.description)
                hasParams = true
            }

            info = checkEventBodyTags(req, res)
            if(info == null){return}
            if(info){
                queryParams += "Tags=@Tags,"
                    
                const parsedTags = tagTabToStrNumber(req.body.tags)
                if(parsedTags == null){return}

                sqlQuery.input("Tags", parsedTags)
                hasParams = true
            }

            info=checkEventBodyDate(req, res)
            if(info == null){return}
            if(info){
                queryParams += "Date=@Date,"
                    sqlQuery.input("Date", req.body.date)
                    hasParams = true
            }

            info=checkEventBodyImageLink(req, res)
            if(info == null){return}
            if(info){
                    queryParams += "ImageLink=@Image,"
                    sqlQuery.input("Image", req.body.imageLink)
                    hasParams = true
            }
            
            if(!hasParams){
                console.error(`Events: updateOne, no update colums given`)
                return res.status(400).json({updated: false, error: "give at least one parameter to update your event"})
            }
            else{
                const result = await updatedEvent(sqlQuery, req, res, queryParams)
                if(result == null){return}
                console.log(`Events, postOne, update successfuly`);
                return res.status(200).json({ updated: true, event: result.recordset });
            }
        })

        router.delete("/", authenticateToken,async (req, res) => {
            res.set('Content-Type', 'application/json');

            if(req.query.id == null){
                console.error(`Events: DELETE, error: ${errorMessage.events.queryId}`);
                return res.status(400).json({deleted: false, error: errorMessage.events.queryId})
            }

            const result = await deletedEvent(pool, req, res)
            if(result == null){return}
            console.log(`Events: deleteOne, deleted successfully`);
            return res.status(200).json({ deleted: true, message: `Deleted successfully`});
            
        })

        router.get("/reservation", authenticateToken, async (req, res) =>{
            const registeredEvents = await getEventsReservations(pool, req, res)
            if(registeredEvents == null){return}
            let result = []
            for (let i = 0; i < registeredEvents.length; i++) {
                req.query.owner = null
                req.query.name = null
                const eventId = registeredEvents[i].events_id
                const info = await getEvents(pool, req, res, eventId)
                if(info == null){return}
                result.push(info)
            }
            console.log(`Reservation: GET, send successfuly`)
            return res.status(200).json({result: result})
        })

        router.post("/reservation", authenticateToken ,async (req, res) => {
            const check = await checkEventsReservation(pool, req, res)
            if(check){
                const result = await createReservation(pool, req, res)
                if(result == null){return}
                console.log(`Reservations: CreateOne, created successfuly`)
                return res.status(200).json({created: true, message: `Created successfuly`})
            }
            else if(check == false){
                console.error(`Reservations: CreateOne, already exist`)
                return res.status(400).json({error: "you have already registered to this events"})
            }
        })

        router.delete("/reservation", authenticateToken, async (req, res) => {
            const check = await checkEventsReservation(pool, req, res)
            if(check == false){
                const result = await deleteReservation(pool, req, res)
                if(result == null){return}
                console.log(`Reservations: DeleteOne, deleted successfuly`)
                return res.status(200).json({deleted: true, message: "deleted successfuly"})
            }
            else if(check){
                console.error(`Reservations: DeleteOne, not exist`)
                return res.status(400).json({error: "you have not registered to this event"})
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

function checkEventsBody(req, res) {
    try {
        if (req.body.name == null || typeof(req.body.name) != typeof "" || req.body.name ==  "") {
            console.error(`Events, createOne, error: ${errorMessage.events.createdName}`);
            res.status(400).json({ created: false, error: errorMessage.events.createdName });
            return false;
        }

        if (req.body.tags == null || typeof req.body.tags != typeof ["", ""]) {
            console.error(`Events, createOne, error: ${errorMessage.events.createdTags}`);
            res.status(400).json({ created: false, error: errorMessage.events.createdTags });
            return false;
        }

        if (req.body.date == null || typeof(req.body.date) != typeof "" || req.body.date.length != 10) {
            console.error(`Events, createOne, error: ${errorMessage.events.createdDate}`);
            res.status(400).json({ created: false, error: errorMessage.events.createdDate});
            return false;
        }

        const descCheck = checkEventBodyDescription(req, res);
        const imgCheck = checkEventBodyImageLink(req, res);

        return descCheck != null && imgCheck != null
    } catch (err) {
        console.error(`Events, checkEventsBody, error: ${err.message}`);
        res.status(500).json({ created: false, error: "Internal server error" });
        return false;
    }
}


function checkEventBodyName(req, res){
    if(req.body.name != null){
        if(typeof(req.body.name) != typeof("") || req.body.name == ""){
            console.error(`Events: updateOne, error: ${errorMessage.events.updatedName}`)
            res.status(400).json({updated: false, error: errorMessage.events.updatedName})
            return null
        }
        else{
            return true
        }
    }
    return false
}
function checkEventBodyDescription(req, res){
    if(req.body.description != null){
        if( typeof(req.body.description) != typeof("")){
            console.error(`Events, createOne, error: ${errorMessage.events.description}`)
            res.status(400).json({created: false, error: errorMessage.events.description})
            return null;
        }
        return true;
    }
    return false;
}

function checkEventBodyTags(req, res){
    if(req.body.tags != null){
        if(typeof(req.body.tags) != typeof(["",""])){
            console.error(`Events: updateOne, error: ${errorMessage.events.updatedTags}`)
            res.status(400).json({updated: false, error: errorMessage.events.updatedTags})
            return null;
        }
        return true;
    }
    return false;
}

function checkEventBodyDate(req, res){
    if(req.body.date != null){
        if(typeof(req.body.date) != typeof "" || req.body.date.length != 10){
            console.error(`Events: updateOne, error: ${errorMessage.events.updatedDate}`)
            res.status(400).json({updated: false, error: errorMessage.events.updatedDate})
            return null
        }
        return true;
    }
    return false
}

function checkEventBodyImageLink(req, res){
    if(req.body.imageLink != null){
            if(typeof(req.body.imageLink) != typeof("")){
            console.error(`Events, createOne, error: ${errorMessage.events.imageLink}`)
            res.status(400).json({created: false, error: errorMessage.events.imageLink})
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

async function deletedEvent(pool, req, res) {
    try {
        const query = "DELETE FROM events WHERE id=@id AND Owner=@Owner";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("id", req.query.id)
                .input("Owner", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if (result.rowsAffected[0] < 1) {
                        reject(errorMessage.events.ownError);
                    } else {
                        resolve(true);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Events, deleteOne, error: ${err}`);
        res.status(400).json({ deleted: false, error: err });
        return null;
    }
}


async function updatedEvent(request, req, res, queryParams) {
    try {
        const query = `UPDATE events SET ${queryParams.substring(0,queryParams.length-1)} WHERE id=@id AND Owner=@Owner`;
        const result = await new Promise((resolve, reject) => {
            request.input("Owner", req.user.name)
                .input("id", req.query.id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if (result.rowsAffected[0] < 1) {
                        reject(errorMessage.events.ownError);
                    } else {
                        resolve(result);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Events, postOne, error: ${err}`);
        res.status(400).json({ updated: false, error: err });
        return null;
    }
}


async function createdEvent(pool, req, res) {
    try {
        const query = "INSERT INTO events (Name, Description, Tags, Date, ImageLink, Owner) VALUES (@Name, @Description, @Tags, @Date, @Image, @Owner)";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("Name", req.body.name)
                .input("Description", req.body.description)
                .input("Tags", req.body.tags)
                .input("Date", req.body.date)
                .input("Image", req.body.imageLink)
                .input("Owner", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else {
                        const queryResult = true;
                        resolve(queryResult);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Events: createOne, error: ${err}`);
        res.status(400).json({ created: false, error: err });
        return null;
    }
}


async function getEvents(pool, req, res, id){
    let query = "SELECT events.*, users.firstname, users.name FROM events JOIN users ON events.Owner = users.user_id";

    let infoQuery = false

    let queryId = id
    if(queryId == null){
        queryId = req.query.id
    }
    if (queryId != null && Number.isInteger(parseInt(queryId))) {
        query += " WHERE events.id=@id"
        infoQuery = true
    }

    const queryOwner = req.query.owner
    if(queryOwner != null && typeof queryOwner == typeof "" && queryOwner == "true"){
        if(infoQuery){
            query += " AND events.Owner=@user_id"
        } else{
            query += " WHERE events.Owner=@user_id"
        }
        infoQuery = true
    }

    const queryName = req.query.name
    if(queryName != null && typeof queryName == typeof ""){
        if(infoQuery){
            query += " AND events.Name=@name"
        } else{
            query += " WHERE events.Name=@name"
        }
        infoQuery = true
    }

    try {
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("id", queryId)
                .input("name", req.query.name)
                .input("user_id", req.user.name)
                .query(query, (err, result) => {
                    if (err) {
                        console.error(`Function: getEvents, error: ${err.message}`);
                        reject(err.message);
                    } else {
                        resolve(result.recordset);
                    }
                });
        });
        return result;
    } catch (err) {
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
                    resolve(result.recordset[0])
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

async function checkEventsReservation(pool, req, res){
    try{
        events_id = req.query.event_id
        if(typeof events_id != typeof ""){
            console.log(`Function: checkEventsReservation, error: ${errorMessage.events.reservationFormat}`)
            res.status(400).json({error: errorMessage.events.reservationFormat})
            return null
        }
        const result =  await new Promise((resolve, reject) => {
            const query = "SELECT * FROM events_reservations WHERE user_id=@user_id AND events_id=@events_id"
            pool.request()
                .input("user_id", req.user.name)
                .input("events_id", events_id)
                .query(query, (err, result) => {
                    if(err){
                        reject(err.message)
                    }
                    else if(result.recordset.length > 0){
                       resolve(false)
                    } else {
                        resolve(true)
                    }
                })
        })
        return result;
    } catch(err){
        console.error(`Function: checkReservation, error: ${err}`)
        res.set('Content-Type', 'application/json')
        res.status(400).json({error: err})
        return null
    }

}

async function createReservation(pool, req, res){
    try {
        const query = "INSERT INTO events_reservations (user_id, events_id) VALUES (@user_id, @events_id)";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .input("events_id", req.body.events_id)
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
        console.error(`Events: createOne, error: ${err}`);
        res.status(400).json({ created: false, error: err });
        return null;
    }
}

async function deleteReservation(pool, req, res){
    try {
        const query = "DELETE FROM events_reservations WHERE user_id=@user_id AND events_id=@events_id";
        const result = await new Promise((resolve, reject) => {
            pool.request()
                .input("user_id", req.user.name)
                .input("events_id", req.body.events_id)
                .query(query, (err, result) => {
                    if (err) {
                        reject(err.message);
                    } else if(result.rowsAffected[0] < 1){
                        reject("You are not registered to this events")
                    }
                    else{
                        resolve(true);
                    }
                });
        });
        return result;
    } catch (err) {
        console.error(`Events: createOne, error: ${err}`);
        res.status(400).json({ created: false, error: err });
        return null;
    }
}

async function getEventsReservations(pool, req, res){
    try{
        const result =  await new Promise((resolve, reject) => {
            const query = "SELECT events_id FROM events_reservations WHERE user_id=@user_id"
            pool.request()
                .input("user_id", req.user.name)
                .query(query, (err, result) => {
                    if(err){
                        reject(err.message)
                    }
                    resolve(result.recordset)
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

module.exports = router