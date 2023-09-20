import Event from "../models/Event.js";
import {request, response} from "express";
import User from "../models/User.js";

export const addEvent = async (request, response) => {
    try {
        const {
            hostId,
            name,
            description,
            location,
            hostName,
            picturePath,
        } = request.body;

        const newEvent = new Event({
            hostId,
            name,
            description,
            location,
            hostName,
            picturePath,
        });

        const savedEvent = await newEvent.save();

        response.status(201).json(savedEvent);
    }
    catch (e) {
        response.status(500).json({error: e});
    }
}

export const getAllEvents = async (request, response) => {
    try {
        const events = await Event.find();

        response.status(200).json(events);
    }
    catch (e) {
        response.status(400).json({error: e});
    }
}

export const getEvent = async (request, response) => {
    try {
        const {
            eventId
        } = request.body;

        const event = await Event.findById(eventId);

        if(event) {
            response.status(200).json(event);
        }
        else {
            response.status(400).json({error: 'No event with given id.'});
        }
    }
    catch (e) {
        response.status(400).json({ error: e });
    }
}

export const ultimo = async (request, response) => {
    try {
        const {
            eventId,
            eventAttends,
            userId,
            userAttends
        } = request.body;

        const eventUpdated = await Event.findByIdAndUpdate(
            eventId,
            { attends: eventAttends }, // Update the attends field with the new list
        );

        const userUpdated = User.findByIdAndUpdate(
            userId,
            { attends: userAttends }, // Update the attends field with the new list
            { new: true } // To return the updated event
        );

        await Promise.all([eventUpdated, userUpdated]);

        response.status(200).json({ message: "Success" });
    }
    catch (e) {
        response.status(404).json({ error: e });
    }
}

export const updateAttends = async (request, response) => {
    try {
        const {
            eventId,
            attends
        } = request.body;

        const updatedEvent = await Event.findByIdAndUpdate(
            eventId,
            { attends: attends }, // Update the attends field with the new list
            { new: true } // To return the updated event
        );

        if (!updatedEvent) {
            return response.status(404).json({ error: 'Event not found' });
        }

        response.status(200).json(updatedEvent);
    }
    catch (e) {
        response.status(404).json({ error: e });
    }
}

export const getUserHostedEvents = async (request, response) => {
    try {
        const {
            userId
        } = request.body;

        const events = await Event.find({ hostId: userId });
        response.status(200).json(events);
    }
    catch (e) {
        response.status(400).json({error: e});
    }
}

export const getEvents = async (request, response) => {
    try {
        const {
            eventIds
        } = request.body;

        const events = await Event.find({ _id: { $in: eventIds } });

        response.status(200).json(events);
    }
    catch (e) {
        response.status(404).json({ error: e });
    }
}

export const getUserEvents = async (request, response) => {
    try {
        const {
            userId,
            attendedEventIds,
        } = request.body;

        // Create promises for both sets of events
        const userHostedEventsPromise = Event.find({ hostId: userId });
        const userAttendedEventsPromise = Event.find({ _id: { $in: attendedEventIds } });

        // Use Promise.all to execute both queries concurrently
        const [userHostedEvents, userAttendedEvents] = await Promise.all([
            userHostedEventsPromise,
            userAttendedEventsPromise,
        ]);

        // Respond with both sets of events
        response.status(200).json({ "attended": userAttendedEvents, "hosted": userHostedEvents });
    }
    catch (e) {
        response.status(400).json({ error: e });
    }
}
