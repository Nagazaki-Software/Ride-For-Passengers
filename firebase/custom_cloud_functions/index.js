const admin = require("firebase-admin/app");
admin.initializeApp();

const classificarDocBahamas = require("./classificar_doc_bahamas.js");
exports.classificarDocBahamas = classificarDocBahamas.classificarDocBahamas;
