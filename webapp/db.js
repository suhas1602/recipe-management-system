const Pool = require("pg").Pool;
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST_NAME,
  database: process.env.DB_DATABASE_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT
});

const createTableIfNotExists = async (tableName) => {
  const {rows: [result]} = await pool.query ("SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name=$1)", [tableName]);
  if(!result.exists) {
    switch(tableName) {
      case "user": 
        await pool.query("CREATE TABLE public.user (id uuid PRIMARY KEY, email varchar UNIQUE, firstname varchar, lastname varchar, password varchar, account_created timestamp, account_updated timestamp)");
        break;
      case "recipe":
        await pool.query("CREATE TABLE public.recipe (id uuid PRIMARY KEY, created_ts timestamp, updated_ts timestamp, author_id uuid, cook_time_in_min integer, prep_time_in_min integer, total_time_in_min integer, title varchar, cusine varchar, servings integer, ingredients varchar [], FOREIGN KEY (author_id) REFERENCES public.user (id))");
        break;
      case "steps":
          await pool.query("CREATE TABLE public.steps (id uuid PRIMARY KEY, position integer, items varchar, recipe_id uuid, FOREIGN KEY (recipe_id) REFERENCES public.recipe(id))");
          break;
      case "nutrition_information":
          await pool.query("CREATE TABLE public.nutrition_information (id uuid PRIMARY KEY, calories integer, cholestrol_in_mg float, sodium_in_mg integer, carbohydrates_in_grams float, protein_in_grams float, recipe_id uuid, FOREIGN KEY (recipe_id) REFERENCES public.recipe(id))");
          break;
      case "recipe_image":
          await pool.query("create table public.recipe_image (id uuid primary key,recipe_id uuid,url varchar, md5 varchar, size int, foreign key (recipe_id) references public.recipe(id))");
          break;
      default:
          console.log("No such table required by the app");                      
    }
  }
}

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

const deleteRecipe = async (recipeId) => {
  await pool.query("DELETE FROM public.recipe_image WHERE recipe_id=$1", [recipeId]);

  await pool.query("DELETE FROM public.nutrition_information WHERE recipe_id=$1", [recipeId]);

  await pool.query("DELETE FROM public.steps WHERE recipe_id=$1", [recipeId]);

  return await pool.query("DELETE FROM public.recipe WHERE id=$1", [recipeId]);
}

const updateRecipe = async(updateRecipeInput, recipeId) => {

  const res = await pool.query("UPDATE public.recipe SET  created_ts=$1, updated_ts=$2, author_id=$3, cook_time_in_min=$4, prep_time_in_min=$5, total_time_in_min=$6, title=$7, cusine=$8, servings=$9, ingredients=$10 WHERE id=$11" ,
    [
      updateRecipeInput.created_ts,
      updateRecipeInput.updated_ts,
      updateRecipeInput.author_id,
      updateRecipeInput.cook_time_in_min,
      updateRecipeInput.prep_time_in_min,
      updateRecipeInput.total_time_in_min,
      updateRecipeInput.title,
      updateRecipeInput.cusine,
      updateRecipeInput.servings,
      updateRecipeInput.ingredients,
      recipeId
    ]);

    return res;

}

const deleteRecipeOldSteps = async(id) => {
  return await pool.query("DELETE FROM public.steps WHERE recipe_id = $1", [id]);
}

const updateRecipeNutritionInformation = async(newNutrition_information, recipeId) => {
    const res = await pool.query("UPDATE public.nutrition_information SET calories=$1, cholestrol_in_mg=$2, sodium_in_mg=$3, carbohydrates_in_grams=$4, protein_in_grams=$5 WHERE recipe_id=$6", 
      [
      newNutrition_information.calories,
      newNutrition_information.cholestrol_in_mg,
      newNutrition_information.sodium_in_mg,
      newNutrition_information.carbohydrates_in_grams,
      newNutrition_information.protein_in_grams,
      recipeId
    ]);
  return res;
}

const saveImageForRecipe = async (imageInput) => {
  return await pool.query("INSERT INTO public.recipe_image (id,recipe_id,url,md5,size) VALUES ($1,$2,$3,$4,$5)", [
    imageInput.id,
    imageInput.recipeId,
    imageInput.imageUrl,
    imageInput.md5,
    imageInput.size,
  ]); 
}

const getAllImagesForRecipe = async (recipeId) => {
  return await pool.query("SELECT * FROM public.recipe_image WHERE recipe_id=$1", [
    recipeId,
  ]);
}

const getRecipeImage = async (recipeId, imageId) => {
  return await pool.query("SELECT * FROM public.recipe_image WHERE recipe_id=$1 AND id=$2", [
    recipeId,
    imageId,
  ]);
}

const deleteRecipeImage = async (recipeId, imageId) => {
  return await pool.query("DELETE FROM public.recipe_image WHERE recipe_id=$1 AND id=$2", [
    recipeId,
    imageId,
  ]);
}

const getAllRecipesForUser = async (userId) => {
  return await pool.query("SELECT id FROM public.recipe WHERE author_id=$1", [userId]);
}

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
  deleteRecipe,
  updateRecipe,
  deleteRecipeOldSteps,
  updateRecipeNutritionInformation,
  saveImageForRecipe,
  getRecipeImage,
  deleteRecipeImage,
  createTableIfNotExists,
  getAllImagesForRecipe,
  getAllRecipesForUser,
}
