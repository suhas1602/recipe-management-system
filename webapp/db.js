const Pool = require("pg").Pool;
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST_NAME,
  database: process.env.DB_DATABASE_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT
});

const getAllEmail = async () => {
  const res = await pool.query("SELECT email from public.user");
  return res;
}

const createUser = async (createUserInput) => {
  const res = await pool.query("INSERT INTO public.user (id, email, firstname, lastname, password, account_created, account_updated)" +
  "VALUES ($1,$2,$3,$4,$5,$6,$7)", [
    createUserInput.id, 
    createUserInput.email, 
    createUserInput.firstname, 
    createUserInput.lastname, 
    createUserInput.password, 
    createUserInput.account_created, 
    createUserInput.account_updated
  ]);

  return res;
}

const getUserDetails = async (email) => {
  const res = await pool.query("SELECT * FROM public.user WHERE email=$1", [email]);

  return res;
}

const updateUserDetails = async (updatdeUserDetailsInput) => {
  const res = await pool.query("UPDATE public.user SET firstname = $2, lastname = $3, password = $4, account_updated = $5 WHERE email = $1",
    [
    updatdeUserDetailsInput.email,
    updatdeUserDetailsInput.newFirstname,
    updatdeUserDetailsInput.newLastname,
    updatdeUserDetailsInput.newPassword,
    updatdeUserDetailsInput.account_updated
    ]);

  return res;
}

const createRecipe = async (recipeInput) => {
  try {
    const res = await pool.query("INSERT INTO public.recipe (id, created_ts, updated_ts, author_id, cook_time_in_min, prep_time_in_min, total_time_in_min, title, cusine, servings, ingredients)" +
    "VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)",[
      recipeInput.id,
      recipeInput.created_ts,
      recipeInput.updated_ts,
      recipeInput.author_id,
      recipeInput.cook_time_in_min,
      recipeInput.prep_time_in_min,
      recipeInput.total_time_in_min,
      recipeInput.title,
      recipeInput.cusine,
      recipeInput.servings,
      recipeInput.ingredients
    ]);

    return res;
  } catch(err) {
    console.log(err);
    throw err;
  }
};

const createRecipeStep = async (stepInput) => {
  try{
    return await pool.query("INSERT INTO public.steps (id, position, items, recipe_id) VALUES ($1,$2,$3,$4)", [
      stepInput.id,
      stepInput.position,
      stepInput.items,
      stepInput.recipe_id,
    ]);
  } catch(err) {
    console.log(err);
  }
}

const createRecipeNutritionInformation = async (nutritionInput) => {
  try{
    return await pool.query("INSERT INTO public.nutrition_information (id, calories, cholestrol_in_mg, sodium_in_mg, carbohydrates_in_grams, protein_in_grams, recipe_id) VALUES ($1,$2,$3,$4,$5,$6,$7)", [
      nutritionInput.id,
      nutritionInput.calories,
      nutritionInput.cholestrol_in_mg,
      nutritionInput.sodium_in_mg,
      nutritionInput.carbohydrates_in_grams,
      nutritionInput.protein_in_grams,
      nutritionInput.recipeId
    ]);
  } catch (err) {
    console.log(err)
    throw err;
  }
}

module.exports = {
  getAllEmail,
  createUser,
  getUserDetails,
  updateUserDetails,
  createRecipe,
  createRecipeStep,
  createRecipeNutritionInformation,
}
