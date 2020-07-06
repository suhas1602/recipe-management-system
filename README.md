This is the backend application for my Recipe Management System. The frontend repository can be found here https://github.com/suhas1602/recipe-management-system-frontend.

## Technology Stack
 
 Server Framework = Node.js and Express
 Testing Framework = Mocha, Chai and Sinon
 Data Base = PostgreSQL

## Build Instructions
 
 Steps:-
 1. Navigate to src/
 2. Run the command "node index.js" to start the server

## Deploy Instructions

 Steps:- 
 1. Create a postgres role (eg. ccwebapp) by running the following from the psql shell "createuser --interactive --pwprompt"
 2. Create a new database by running "createdb -O <username> <dbname>"
 3. Create a file by the name .env in the root directory of the app and store the database config parameters there.	
 4. Ensure that node.js is installed on your machine. Run "npm install" from the root directory to install required node packages. 


## Running Tests

 1. Install Mocha globally by running "npm install -g mocha".
 2. From the root directory of the app run "mocha tests/test.js". Tests are written in the tests/test.js file.

## CI/CD

 1. CircleCI build is handled by config.yml in .config directory
 2. CodeDeploy steps are defined in appspec.yml

## Infrastructure as Code

 1. All infrastructure as code scripts can be found in infrastructure/aws folder.


