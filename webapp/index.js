const dotenv = require("dotenv");
const express = require("express");
const bodyParser = require("body-parser");
dotenv.config();
const app = express();
const port = 3000;

const api = require("./api");

const unless = function(routes, middleware) {
  return function(req, res, next) {
      if (routes.find(r => req.path.startsWith(r.path) && req.method === r.method)) {
          return next();
      } else {
          return middleware(req, res, next);
      }
  };
};

app.use(unless([{path: '/v1/user', method: 'POST'}], api.authorizeMiddleware));

app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

// app.get("/", (request, response) => {
//   response.json({ info: "Node.js, Express, and Postgres API" });
// });
app.post("/v1/user", api.createUser);
app.get("/v1/user/self", api.getUserDetails);
app.put("/v1/user/self",api.updateUserDetails);

app.post("/v1/recipe", api.createRecipe);

app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});

module.exports = app;