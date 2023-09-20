import express from "express";
import {register, login, getUser, updateAttends} from "../controllers/auth.js";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.post("/user/get", getUser);
router.post("/user/update_attends", updateAttends);

export default router;