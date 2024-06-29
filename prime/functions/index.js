const {
  verificationDocumentWritten,
} = require("./verificationDocumentFunctions");

const {
  carDocumentWritten,
} = require("./carFunctions");

const {
  issueReportDocumentWritten,
} = require("./issueReportFunctions");

const {
  carRentalDocumentWritten,
} = require("./carRentalFunctions");

const {
  createUser,
} = require("./createUserFunctions");


exports.verificationDocumentWritten = verificationDocumentWritten;

exports.carDocumentWritten = carDocumentWritten;

exports.issueReportDocumentWritten = issueReportDocumentWritten;

exports.carRentalDocumentWritten = carRentalDocumentWritten;

exports.createUser = createUser;
