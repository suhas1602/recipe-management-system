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

module.exports = {
  getAllEmail,
  createUser,
  getUserDetails,
  updateUserDetails
}
