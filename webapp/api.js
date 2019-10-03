const uuid = require("uuid");
const bcrypt = require("bcrypt");
const Joi = require('joi');
const lodash = require('lodash');
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

const checkEmail = (email) =>  (/[a-zA-Z0-9_\.\+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-\.]+/.test(email));

const authorizeMiddleware = async (req, res, next) => {
	const auth = req.get('Authorization');

	if(lodash.isEmpty(auth)) return res.sendStatus(401);
	
	const token = auth.split(' ')[1];

	const credentials = Buffer.from(token, 'base64').toString().split(':');

	const email = credentials[0];
	const password = credentials[1];

	if(!password || !email) return res.sendStatus(401);
  
	 const {rows: emails} = await db.getAllEmail();
  
	 if(!emails.map(e => e.email).includes(email))  return res.sendStatus(401);
  
	 const {rows: users} = await db.getUserDetails(email);
	 const result = await bcrypt.compare(password, users[0].password);
  
	 if(result) {
		 res.locals.email = email;
	 } else {
		 return res.sendStatus(401);
	 }
  
	 next();
  }
    

const createUser = (request, response) => {
	const email = request.body.email;
	const firstname = request.body.firstname;
	const lastname = request.body.lastname;
	const password = request.body.password;

	if(!checkEmail(email)){
		response.status(400).send("Email does not meet criteria");
	 } else{

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
  
}

const getUserDetails = async (req, res) => {
	const email = res.locals.email;

	const {rows: [user]} = await db.getUserDetails(email);

	res.status(200).send({
		id: user.id,
		email: user.email,
		firstname: user.firstname,
		lastname: user.lastname,
		account_created: user.account_created,
		account_updated: user.account_updated,
	});
}

const updateUserDetails = async (req, res) => {
	const email = res.locals.email;

	const schema = {
		email: Joi.string().forbidden(),
		firstname: Joi.string().optional(),
		lastname: Joi.string().optional(),
		password: Joi.string().regex(/^[a-zA-Z0-9]{8,30}$/).optional(),
		account_created: Joi.date().forbidden(),
		account_updated: Joi.date().forbidden(),
	};

	const validationResult = Joi.validate(req.body, schema);


	if(validationResult.error || lodash.isEmpty(req.body)) return res.sendStatus(400);

	const {rows: [details]} = await db.getUserDetails(email);
                            
	const now = new Date();
	
	const newFirstname = req.body.firstname ? req.body.firstname : details.firstname;
	const newLastname = req.body.lastname ? req.body.lastname : details.lastname;
	
	let hashedPassword;
	if(req.body.password) {
		hashedPassword = await bcrypt.hash(req.body.password, saltRounds);
	}
	const newPassword = req.body.password ? hashedPassword : details.password;
    const updateUserDetailsInput = {
    	email,
    	newFirstname,
		newLastname,
		newPassword,
		account_updated: now,
	}
    
	db.updateUserDetails(updateUserDetailsInput).then(() => {
        res.status(204).send();
	});

}

const createRecipe = async (req, res) => {
	const email = res.locals.email;

	const stepsSchema = Joi.object().keys({
		position: Joi.number().min(1).required(),
		items: Joi.string().required(),
	})

	const nutritionSchema = Joi.object().keys({
		calories: Joi.number().integer().required(),
		cholestrol_in_mg: Joi.number().required(),
		sodium_in_mg: Joi.number().integer().required(),
		carbohydrates_in_grams: Joi.number().required(),
		protein_in_grams: Joi.number().required(),
	}).required();

	const schema = {
		cook_time_in_min: Joi.number().multiple(5).required(),
		prep_time_in_min: Joi.number().multiple(5).required(),
		title: Joi.string().required(),
		cusine: Joi.string().required(),
		servings: Joi.number().min(1).max(5).required(),
		ingredients: Joi.array().required(),
		steps: Joi.array().items(stepsSchema).required(),
		nutrition_information: nutritionSchema,
	};

	const { error } = Joi.validate(req.body, schema);

	if(error) return res.status(400).send(error.details[0].message);

	try{
		const {rows: [user]} = await db.getUserDetails(email);
		const now = new Date();
	
		const recipeInput = {
			id: uuid(),
			created_ts: now,
			updated_ts: now,
			author_id: user.id,
			cook_time_in_min: req.body.cook_time_in_min,
			prep_time_in_min: req.body.prep_time_in_min,
			total_time_in_min: req.body.cook_time_in_min + req.body.prep_time_in_min,
			title: req.body.title,
			cusine: req.body.cusine,
			servings: req.body.servings,
			ingredients: req.body.ingredients,
		};

	  	await db.createRecipe(recipeInput);

		for(const step of req.body.steps) {
			const stepInput = {
				id: uuid(),
				position: step.position,
				items: step.items,
				recipe_id: recipeInput.id,
			};

			await db.createRecipeStep(stepInput);
		}

		const nutritionInput = {
			id: uuid(),
			...req.body.nutrition_information,
			recipeId: recipeInput.id,
		};

		await db.createRecipeNutritionInformation(nutritionInput);
	
		res.status(201).send({
			...recipeInput,
			steps: req.body.steps,
			nutrition_information: req.body.nutrition_information,
		});
	} catch(err) {
		console.log(err);
		res.sendStatus(500);
	}
}



const getRecipeDetails = async (req, res) => {
	const id = req.params.id;

    const {rows: [recipe]} = await db.getRecipeDetails(id);
    const {rows: recipeSteps} = await db.getRecipeSteps(id);
    const {rows: recipeNutritionInformaiton} = await db.getRecipeNutritionInformation(id);

    res.status(200).send({
		    id: recipe.id,
			created_ts: recipe.created_ts,
			updated_ts: recipe.updated_ts,
			author_id: recipe.author_id,
			cook_time_in_min: recipe.cook_time_in_min,
			prep_time_in_min: recipe.prep_time_in_min,
			total_time_in_min: recipe.total_time_in_min,
			title: recipe.title,
			cusine: recipe.cusine,
			servings: recipe.servings,
			ingredients: recipe.ingredients,
			steps: recipeSteps.map(item => ({
				position: item.position,
				items: item.items
			})),
			nutrition_information: recipeNutritionInformaiton.map(item =>({
				calories: item.calories,
				cholestrol_in_mg: item.cholestrol_in_mg,
				sodium_in_mg: item.sodium_in_mg,
				carbohydrates_in_grams: item.carbohydrates_in_grams,
				protein_in_grams: item.protein_in_grams
			}))
	});
}

const updateRecipe = async (req, res) => {
	const email = res.locals.email;
	const id = req.params.id;
	
	const stepsSchema = Joi.object().keys({
		position: Joi.number().min(1).required(),
		items: Joi.string().required(),
	})
	
	const nutritionSchema = Joi.object().keys({
		calories: Joi.number().integer().required(),
		cholestrol_in_mg: Joi.number().required(),
		sodium_in_mg: Joi.number().integer().required(),
		carbohydrates_in_grams: Joi.number().required(),
		protein_in_grams: Joi.number().required(),
	}).optional();

	const schema = {
		cook_time_in_min: Joi.number().multiple(5).optional(),
		prep_time_in_min: Joi.number().multiple(5).optional(),
		title: Joi.string().optional(),
		cusine: Joi.string().optional(),
		servings: Joi.number().min(1).max(5).optional(),
		ingredients: Joi.array().optional(),
		steps: Joi.array().items(stepsSchema).optional(),
		nutrition_information: nutritionSchema,
	};

	const {rows: [user]} = await db.getUserDetails(email);
	const {rows: recipeDetails} = await db.getRecipeDetails(id);

	if(lodash.isEmpty(recipeDetails)) return res.sendStatus(404);

	if(user.id !== recipeDetails[0].author_id) return res.sendStatus(401);

	if(lodash.isEmpty(req.body)) return res.status(400).send("Cannot send empty request object");

	const validationResult = Joi.validate(req.body, schema);

	if(validationResult.error) return res.status(400).send(validationResult.error.details[0].message);

   	const now = new Date();
	const recipe = recipeDetails[0];
   	const newCookTime = req.body.cook_time_in_min ? req.body.cook_time_in_min : recipe.cook_time_in_min;
   	const newPrepTime = req.body.prep_time_in_min ? req.body.prep_time_in_min : recipe.prep_time_in_min;
   	const newTitle = req.body.title ? req.body.title : recipe.title;
   	const newCusine = req.body.cusine ? req.body.cusine : recipe.cusine;
   	const newServings = req.body.servings ? req.body.servings : recipe.servings;
   	const newIngredients = req.body.ingredients ? req.body.ingredients : recipe.ingredients;
	
   	const updateRecipeInput = {
   		created_ts: recipe.created_ts,
   		updated_ts: now,
   	    author_id: user.id,
   	    cook_time_in_min: newCookTime,
   	    prep_time_in_min: newPrepTime,
   	    total_time_in_min: newCookTime + newPrepTime,
   	    title: newTitle,
   	    cusine: newCusine,
   	    servings: newServings,
   	    ingredients: newIngredients
   	}
   	await db.updateRecipe(updateRecipeInput, id);

	if(req.body.steps) {
		await db.deleteRecipeOldSteps(id);

		for(const step of req.body.steps) {
			const stepInformation = {
				id: uuid(),
				position: step.position,
				items: step.items,
				recipe_id: id,
			};

			await db.createRecipeStep(stepInformation);
		}
	}   

   	if(req.body.nutrition_information) {
		await db.updateRecipeNutritionInformation(req.body.nutrition_information, id);
	}

	res.sendStatus(200);
}

const deleteRecipe = async (req, res) => {
	const email = res.locals.email;
	const recipeId = req.params.id;

	const {rows: [user]} = await db.getUserDetails(email);

	const {rows: recipeDetails} = await db.getRecipeDetails(recipeId);

	if(lodash.isEmpty(recipeDetails)) return res.sendStatus(404);

	if(user.id !== recipeDetails[0].author_id) return res.sendStatus(401);

	await db.deleteRecipe(recipeId);

	res.sendStatus(204);
}

module.exports = {
	authorizeMiddleware,
	createUser,
	getUserDetails,
	updateUserDetails,
	createRecipe,
	getRecipeDetails,
	deleteRecipe,
	updateRecipe
};
