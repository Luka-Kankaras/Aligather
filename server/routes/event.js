import express from "express";
import {
    getEvent,
    getAllEvents,
    getUserHostedEvents,
    updateAttends,
    getEvents,
    ultimo,
    getUserEvents
} from "../controllers/event.js";

const router = express.Router();

router.post("/get", getEvent);
router.post("/get_multiple", getEvents);
router.post("/ultimo", ultimo);
router.post("/user/get", getUserHostedEvents);
router.post("/user/get_all", getUserEvents);
router.post("/update_attends", updateAttends);


router.get("/get_all", getAllEvents);

export default router;