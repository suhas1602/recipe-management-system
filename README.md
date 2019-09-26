# CSYE 6225 - Fall 2019

## Team Information
 
|      Name       |   NEU ID  |    Email Address         |

| Abhishek kamble | 001400007 | kamble.a@husky.neu.edu   |
| Suhas Pasricha  | 001434745 | pasricha.s@husky.neu.edu |


## Technology Stack
 
 Server Framework = Node.js and Express
 Testing Framework = Mocha, Chai and Sinon
 Data Base = PostgreSQL

## Build Instructions
 
 Steps:-
 1. Navigate to ccwebapp/webapp
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


