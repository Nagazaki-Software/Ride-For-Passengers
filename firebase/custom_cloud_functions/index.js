const admin = require("firebase-admin/app");
admin.initializeApp();

const classificarDocBahamas = require("./classificar_doc_bahamas.js");
exports.classificarDocBahamas = classificarDocBahamas.classificarDocBahamas;
const passeUpdate = require("./passe_update.js");
exports.passeUpdate = passeUpdate.passeUpdate;
