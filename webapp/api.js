const uuid = require("uuid");
const bcrypt = require("bcrypt");
const saltRounds = 10;

const db = require("./db");

const checkPassword = (password) => {
	if(password.length <= 8) return false;
	const hasUpperCase = /[A-Z]/.test(password);
	const hasLowerCase = /[a-z]/.test(password);
	const hasNumbers = /\d/.test(password);
	const hasNonalphas = /\W/.test(password);
	if (hasUpperCase + hasLowerCase + hasNumbers + hasNonalphas < 3)
		  return false;
		  
	return true;	  
}

const createUser = (request, response) => {
	const email = request.body.email;
	const firstname = request.body.firstname;
	const lastname = request.body.lastname;
	const password = request.body.password;

	if(!checkPassword(password)) {
		response.status(400).send("Password does not meet criteria");
	} else {
		db.getAllEmail().then(res => {
			const allEmails = res.rows.map(item => item.email);
			if(!allEmails.includes(email)) {
				bcrypt.hash(password,saltRounds).then(hashedPassword => {
					const now = new Date();
					const createUserInput = {
						id: uuid(),
						email,
						firstname,
						lastname,
						password:hashedPassword,
						account_created: now,
						account_updated: now,
					};
	
					db.createUser(createUserInput)
						.then(res => {
							response.status(201).json({
								id: createUserInput.id,
								email,
								firstname,
								lastname,
								account_created: createUserInput.account_created,
								account_updated: createUserInput.account_updated,
							});
						})
						.catch(err => {
							console.log(err);
							response.status(400).send("Error");
						})
				});
			} else {
				response.status(400).send("Email already exists");
			}
		}).catch(err => {
			console.log(err);
			response.status(400).send("Error");
		});
	}
}

const getUserDetails = (req, res) => {
	const encodedToken = req.headers.authorization;

	const decodedToken = Buffer.from(encodedToken, "base64").toString();

	const email = decodedToken.slice(0, decodedToken.indexOf("|"));
	const password = decodedToken.slice(decodedToken.indexOf("|") + 1, decodedToken.length);	
	
	db.getUserDetails(email)
		.then(result => {
			if(result.rows.length === 0) {
				res.status(401).send("Unauthorized");
			} else {
				const details = result.rows[0];
				bcrypt.compare(password, details.password)
					.then(hash => {
						if(hash) {
							res.status(200).send({
								id: details.id,
								email,
								firstname: details.firstname,
								lastname: details.lastname,
								account_created: details.account_created,
								account_updated: details.account_updated,	
							});	
						} else {
							res.status(401).send("Unauthorized");
						}
					})
					.catch(err => {
						console.log(err);
						res.status(401).send("Unauthorized");
					});
			}
		})
		.catch(err => {
			console.log(err);
			res.status(401).send("Unauthorized");
		})
}

const updateUserDetails = (req, res) => {
    const encodedToken = req.headers.authorization;

	const decodedToken = Buffer.from(encodedToken, "base64").toString();

	const email = decodedToken.slice(0, decodedToken.indexOf("|"));
	const password = decodedToken.slice(decodedToken.indexOf("|") + 1, decodedToken.length);

	const newFirstname = req.body.firstname;
	const newLastname = req.body.lastname;
	const newPassword = req.body.password;

	db.getUserDetails(email)
		.then(result => {
			if(result.rows.length === 0) {
				res.status(401).send("Unauthorized");
			} else {
				const details = result.rows[0];
				bcrypt.compare(password, details.password)
					.then(async hash => {
						if(hash) {
                           const hashedPassword = await bcrypt.hash(newPassword,saltRounds); 
                           const now = new Date();
                           const updateUserDetailsInput = {
                           		email,
                           		newFirstname,
						    	newLastname,
						    	newPassword: hashedPassword,
						    	account_updated: now,
                           };

							db.updateUserDetails(updateUserDetailsInput).then(() =>{

                                res.status(204).send({
                                	email,
                                	firstname: newFirstname,
                                	lastname: newLastname,
                                	account_updated : updateUserDetailsInput.account_updated,
                                });

							});

						} else {
							res.status(401).send("Unauthorized");
						}
					})
					.catch(err => {
						console.log(err);
						res.status(401).send("Unauthorized");
					});
			}
		})
		.catch(err => {
			console.log(err);
			res.status(401).send("Unauthorized");
		})

}

module.exports = {
	createUser,
	getUserDetails,
	updateUserDetails
};
