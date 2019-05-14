const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
var db = admin.firestore();


exports.addPrivateUser = functions.firestore
    .document('private-experiences/{userId}')
    .onCreate(event => {
        console.log('UserId: ' + event.params.userId);
        const userId = event.params.userId;
        const docRef = admin.firestore().document('private-experiences');
        return docRef.get().then(snap => {
            const newNumUsers = snap.data().numUsers + 1;
            const data = {newNumUsers};
            return docRef.update({numUsers: newNumUsers})
        })
    });

exports.deletePrivateUser = functions.firestore
    .document('private-experiences/{userId}')
    .onDelete(event => {
        console.log('UserId: ' + event.params.userId);
        const userId = event.params.userId;
        const docRef = admin.firestore().document('private-experiences');
        return docRef.get().then(snap => {
            const newNumUsers = snap.data().numUsers - 1;
            const data = {newNumUsers};
            return docRef.update({numUsers: newNumUsers})
        })
    });


exports.addGroupMood = functions.firestore
    .document('groups-experiences/{groupId}/years/{year}/days/{dayNum}/users/{userId}')
    .onCreate((event, context) => {
        return aggregateGroupFromEvent(event, context, false)
    });

exports.updateGroupMood = functions.firestore
    .document('groups-experiences/{groupId}/years/{year}/days/{dayNum}/users/{userId}')
    .onUpdate((event, context) => {
        return aggregateGroupFromEvent(event, context,  true)
    });

exports.addPrivateMood = functions.firestore
    .document('private-experiences/{userId}/years/{year}/days/{dayNum}')
    .onCreate((event, context) => {
        return aggregateFromEvent(event, context, false)
    });

exports.updatePrivateMood = functions.firestore
    .document('private-experiences/{userId}/years/{year}/days/{dayNum}')
    .onUpdate((event, context) => {
        return aggregateFromEvent(event, context, true)
    });

function getWeek(date) {
    var dateInt = new Date(date.getTime());
    dateInt.setHours(0, 0, 0, 0);
    dateInt.setDate(dateInt.getDate() + 3 - (dateInt.getDay() + 6) % 7);
    var week1 = new Date(getFullYear(dateInt), 0, 4);
    return 1 + Math.round(((dateInt.getTime() - week1.getTime()) / 86400000
        - 3 + (week1.getDay() + 6) % 7) / 7);
}

function getFullYear(date) {
    var dateInt = new Date(date.getTime());
    dateInt.setDate(dateInt.getDate() + 3 - (dateInt.getDay() + 6) % 7);
    return dateInt.getFullYear();
}


function aggregateGroupFromEvent(event, context, isUpdate) {

    const userId = context.params.userId
    const groupId = context.params.groupId
    const year = context.params.year
    const dayNum = context.params.dayNum
    const mood = isUpdate?event.after.data().mood:event.data().mood;
    var previousMood = undefined
    var date = new Date(year, 0);
    var dayDate = new Date(date.setDate(dayNum))
    const month = dayDate.getMonth() + 1
    const week = getWeek(dayDate)


    if (isUpdate) {
        previousMood = event.before.data().mood
        console.log('Updating [GroupId: ' + groupId + ' UserId: ' + userId + '] Day:' + dayNum + ' Week:' + week + ' Month:' + month + ' Mood: ' + mood + ' PreviousMood: ' + previousMood)
    } else {
        console.log('Creating [GroupId: ' + groupId+ 'UserId: ' + userId + '] Day:' + dayNum + ' Week:' + week + ' Month:' + month + ' Mood: ' + mood)
    }

    const DOC_BASE = 'groups-experiences/'
    const yearDocRefStr =   DOC_BASE + groupId + '/years/' + year
    const weekDocRefStr =   DOC_BASE + groupId + '/years/' + year + '/weeks/' + week
    const dayDocRefStr =   DOC_BASE + groupId + '/years/' + year + '/days/' + dayNum
    const monthDocRefStr =  DOC_BASE + groupId + '/years/' + year + '/month/' + month

    const promiseDay = aggreggate(dayDocRefStr, mood, previousMood)
    const promiseWeek = aggreggate(weekDocRefStr, mood, previousMood)
    const promiseMonth = aggreggate(monthDocRefStr, mood, previousMood)
    const promiseYear = aggreggate(yearDocRefStr, mood, previousMood)

    return Promise.all([promiseDay, promiseWeek, promiseMonth, promiseYear])
}


function aggregateFromEvent(event, context, isUpdate) {
    const userId = context.params.userId;
    const year = context.params.year;
    const dayNum = context.params.dayNum;
    const mood = event.after.data().mood;
    var previousMood = undefined;
    var date = new Date(year, 0);
    var dayDate = new Date(date.setDate(dayNum));
    const month = dayDate.getMonth() + 1;
    const week = getWeek(dayDate);
    const subAdminArea = event.after.data().subAdminArea;

    if (isUpdate) {
        previousMood = event.before.data().mood
        console.log('Updating [UserId: ' + userId + '] Day:' + dayNum + ' Week:' + week + ' Month:' + month + ' Mood: ' + mood + ' PreviousMood: ' + previousMood)
    } else {
        console.log('Creating [UserId: ' + userId + '] Day:' + dayNum + ' Week:' + week + ' Month:' + month + ' Mood: ' + mood)
    }

    const DOC_BASE = 'private-experiences/'
    const yearDocRefStr =   DOC_BASE + userId + '/years/' + year
    const weekDocRefStr =   DOC_BASE + userId + '/years/' + year + '/weeks/' + week
    const weekSubAdminAreaDocRefStr =   DOC_BASE + userId + '/years/' + year + '/weeks/' + week + '/sub-admin-areas/' + subAdminArea
    const monthDocRefStr =  DOC_BASE + userId + '/years/' + year + '/months/' + month

    const promiseWeek = aggreggate(weekDocRefStr, mood, previousMood)
    //const promiseWeekSubAdminArea = aggreggate(weekSubAdminAreaDocRefStr, mood, previousMood)
    const promiseMonth = aggreggate(monthDocRefStr, mood, previousMood)
    const promiseYear = aggreggate(yearDocRefStr, mood, previousMood)

    //return Promise.all([isUpdate?promiseUpdates:new Promise(), promiseWeek, promiseMonth, promiseYear])
    return Promise.all([promiseWeek, promiseMonth, promiseYear])
}

function aggreggate(docRefStr, mood, previousMood) {
    console.log(`Aggregating ${docRefStr} Mood: ${mood}, PreviousMood: ${previousMood}`);
    if (previousMood) {
        console.log('Updating '+ docRefStr)
    } else {
        console.log('Creating ' + docRefStr)
    }
    const docRef = admin.firestore().doc(docRefStr)

    var promise = docRef.get().then(snap => {
        if (snap.exists) {
            console.log(`Doc ${docRefStr} already exists.`);
            var currentAvgMood = snap.data().avgMood
            if (currentAvgMood === undefined) currentAvgMood = 0
            var currentNumMoods = snap.data().numMoods
            if (currentNumMoods === undefined) currentNumMoods = 0

            if (previousMood)  {
                const newAvgMood = (((currentAvgMood * currentNumMoods) - previousMood) + mood) / currentNumMoods;
                return docRef.update({avgMood: newAvgMood})
            } else {
                var newNumMoods = currentNumMoods + 1;
                var newAvgMood = ((currentAvgMood * currentNumMoods) + mood) / newNumMoods;
                return docRef.update({numMoods: newNumMoods, avgMood: newAvgMood})
            }
        } else {
            console.log(`Doc ${docRefStr} does not exists.`);
            if (previousMood) {
                console.log(`Already previousMood`);
                return docRef.update({avgMood: mood})
            } else {
                console.log(`No previousMood.`);
                return docRef.create({numMoods: 1, avgMood: mood})
            }
        }
    })
    return promise;
}