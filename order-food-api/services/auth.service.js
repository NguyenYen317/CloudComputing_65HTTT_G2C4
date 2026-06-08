const userRepository = require("../repositories/user.repository");
const cartRepository = require("../repositories/cart.repository");
const { adminEmails } = require("../config/env");
const httpError = require("../utils/httpError");

function normalizeEmail(email) {
  return String(email || "").trim().toLowerCase();
}

function publicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    provider: user.provider,
    avatar: user.avatar || "",
    role: user.role || "customer",
  };
}

function createToken(user) {
  return Buffer.from(`${user.id}:${Date.now()}`).toString("base64url");
}

async function findUserByEmail(email) {
  return userRepository.findByEmail(normalizeEmail(email));
}

async function saveUser(user) {
  const normalizedEmail = normalizeEmail(user.email);
  const data = {
    ...user,
    email: normalizedEmail,
    role: adminEmails.has(normalizedEmail) ? "admin" : user.role || "customer",
  };

  return userRepository.save(data);
}

async function register({ name, email, password }) {
  const normalizedEmail = normalizeEmail(email);

  if (!name || !normalizedEmail || !password) {
    throw httpError(400, "Vui lòng nhập đầy đủ thông tin");
  }

  if (String(password).length < 6) {
    throw httpError(400, "Mật khẩu phải có ít nhất 6 ký tự");
  }

  if (await findUserByEmail(normalizedEmail)) {
    throw httpError(409, "Email đã được đăng ký");
  }

  const user = await saveUser({
    id: `U${Date.now().toString().slice(-8)}`,
    name: String(name).trim(),
    email: normalizedEmail,
    password: String(password),
    provider: "email",
    avatar: "",
    role: adminEmails.has(normalizedEmail) ? "admin" : "customer",
    createdAt: new Date().toISOString(),
  });

  return {
    message: "Đăng ký thành công",
    user: publicUser(user),
    token: createToken(user),
  };
}

async function login({ email, password }) {
  const normalizedEmail = normalizeEmail(email);
  const normalizedPassword = String(password || "");
  let user = await findUserByEmail(normalizedEmail);

  if (!user && normalizedEmail === "demo@orderfood.local" && normalizedPassword === "123456") {
    user = await saveUser({
      id: "U0001",
      name: "Demo User",
      email: normalizedEmail,
      password: normalizedPassword,
      provider: "email",
      avatar: "",
      role: adminEmails.has(normalizedEmail) ? "admin" : "customer",
      createdAt: new Date().toISOString(),
    });
  }

  if (!user || user.password !== normalizedPassword) {
    throw httpError(401, "Email hoặc mật khẩu không đúng");
  }

  return {
    message: "Đăng nhập thành công",
    user: publicUser(user),
    token: createToken(user),
  };
}

async function googleLogin({ email, name, avatar, idToken }) {
  const normalizedEmail = normalizeEmail(email);

  if (!normalizedEmail || !idToken) {
    throw httpError(400, "Thiếu thông tin Google Sign-In");
  }

  let user = await findUserByEmail(normalizedEmail);
  if (!user) {
    user = {
      id: `U${Date.now().toString().slice(-8)}`,
      name: String(name || "Google User").trim(),
      email: normalizedEmail,
      password: "",
      provider: "google",
      avatar: avatar || "",
      role: adminEmails.has(normalizedEmail) ? "admin" : "customer",
      createdAt: new Date().toISOString(),
    };
  } else {
    user = {
      ...user,
      name: String(name || user.name || "Google User").trim(),
      provider: "google",
      avatar: avatar || user.avatar || "",
      role: adminEmails.has(normalizedEmail) ? "admin" : user.role || "customer",
    };
  }

  user = await saveUser(user);
  return {
    message: "Đăng nhập Google thành công",
    user: publicUser(user),
    token: createToken(user),
  };
}

async function getMe(email) {
  const normalizedEmail = normalizeEmail(email);
  if (!normalizedEmail) {
    throw httpError(401, "Vui lòng đăng nhập");
  }

  const user = await findUserByEmail(normalizedEmail);
  if (!user) {
    throw httpError(404, "Không tìm thấy người dùng");
  }

  return { user: publicUser(user) };
}

async function listUsers(limit = 200) {
  const users = await userRepository.list(limit);
  return users.map(publicUser);
}

async function removeUser(email) {
  const normalizedEmail = normalizeEmail(email);
  if (!normalizedEmail) {
    throw httpError(400, "Email không hợp lệ");
  }

  const user = await findUserByEmail(normalizedEmail);
  if (!user) {
    throw httpError(404, "Không tìm thấy tài khoản");
  }

  if ((user.role || "customer") === "admin" || adminEmails.has(normalizedEmail)) {
    throw httpError(403, "Không thể xóa tài khoản admin");
  }

  await userRepository.remove(normalizedEmail);
  await cartRepository.remove(normalizedEmail);

  return {
    message: "Xóa tài khoản khách thành công",
    user: publicUser(user),
  };
}

module.exports = {
  normalizeEmail,
  publicUser,
  createToken,
  findUserByEmail,
  saveUser,
  register,
  login,
  googleLogin,
  getMe,
  listUsers,
  removeUser,
};
