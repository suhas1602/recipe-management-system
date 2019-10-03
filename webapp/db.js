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

const getRecipeDetails = async (id) => {
  const res = await pool.query("SELECT * FROM public.recipe WHERE id=$1", [id]);

  return res;
}

const getRecipeSteps = async (id) => {
  const res = await pool.query("SELECT * FROM public.steps WHERE recipe_id=$1",[id]);

  return res;

}

const getRecipeNutritionInformation = async (id) => {
  const res = await pool.query("SELECT * FROM public.nutrition_information WHERE recipe_id=$1",[id]);

  return res;
}

// const updateRecipe = async(updateRecipeInput) => {
//   const res = await pool.query("UPDATE public.recipe SET id=$1, created_ts=$2, updated_ts=$3, author_id=$4, cook_time_in_min=$5, prep_time_in_min=$6, total_time_in_min=$7, title=$8, cusine=$9, servings=$10, ingredients=$11" +
//     "VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)",[
//       updateRecipeInput.id,
//       updateRecipeInput.created_ts,
//       updateRecipeInput.updated_ts,
//       updateRecipeInput.author_id,
//       updateRecipeInput.cook_time_in_min,
//       updateRecipeInput.prep_time_in_min,
//       updateRecipeInput.total_time_in_min,
//       updateRecipeInput.title,
//       updateRecipeInput.cusine,
//       updateRecipeInput.servings,
//       updateRecipeInput.ingredients
//     ]);

//     return res;

// }

// const updateRecipeStep = async(stepInput) => {
//   try{
//     return await pool.query("UPDATE public.steps SET id=$1, position=$2, items=$3, recipe_id=$4" + "VALUES ($1,$2,$3,$4)", [
//       stepInput.id,
//       stepInput.position,
//       stepInput.items,
//       stepInput.recipe_id,
//     ]);

//     return res;

//   } catch(err) {
//     console.log(err);
//   }
// }


// const updateRecipeNutritionInformation = async(nutritionInput) => {
//    try{
//     return await pool.query("UPDATE public.nutrition_information SET id=$1, calories=$2, cholestrol_in_mg=$3, sodium_in_mg=$4, carbohydrates_in_grams=$5, protein_in_grams=$6, recipe_id=$7" + "VALUES ($1,$2,$3,$4,$5,$6,$7)", [
//       nutritionInput.id,
//       nutritionInput.calories,
//       nutritionInput.cholestrol_in_mg,
//       nutritionInput.sodium_in_mg,
//       nutritionInput.carbohydrates_in_grams,
//       nutritionInput.protein_in_grams,
//       nutritionInput.recipeId
//     ]);
//   } catch (err) {
//     console.log(err)
//     throw err;
//   }
// }



module.exports = {
  getAllEmail,
  createUser,
  getUserDetails,
  updateUserDetails,
  createRecipe,
  createRecipeStep,
  createRecipeNutritionInformation,
  getRecipeDetails,
  getRecipeSteps,
  getRecipeNutritionInformation,
  // updateRecipe,
  // updateRecipeStep,
  // updateRecipeNutritionInformation
}
