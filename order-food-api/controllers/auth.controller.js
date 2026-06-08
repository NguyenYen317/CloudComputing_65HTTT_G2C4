const authService = require("../services/auth.service");
const handleControllerError = require("../utils/controllerError");

async function register(req, res) {
  try {
    res.json(await authService.register(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function login(req, res) {
  try {
    res.json(await authService.login(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function googleLogin(req, res) {
  try {
    res.json(await authService.googleLogin(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function me(req, res) {
  try {
    const email = req.authUser?.email || req.query.email;
    res.json(await authService.getMe(email));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function listUsers(req, res) {
  try {
    res.json(await authService.listUsers());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function removeUser(req, res) {
  try {
    res.json(await authService.removeUser(req.params.email || req.params.userId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  register,
  login,
  googleLogin,
  me,
  listUsers,
  removeUser,
};
