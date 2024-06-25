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


exports.verificationDocumentWritten = verificationDocumentWritten;

exports.carDocumentWritten = carDocumentWritten;

exports.issueReportDocumentWritten = issueReportDocumentWritten;

exports.carRentalDocumentWritten = carRentalDocumentWritten;
