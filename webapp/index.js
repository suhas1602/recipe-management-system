const dotenv = require("dotenv");
const express = require("express");
const bodyParser = require("body-parser");
dotenv.config();
const app = express();
const port = 3000;

const api = require("./api");

app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

// app.get("/", (request, response) => {
//   response.json({ info: "Node.js, Express, and Postgres API" });
// });
app.post("/v1/user/", api.createUser);
app.get("/v1/user/self", api.getUserDetails);

app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});

module.exports = app;