import bcrypt from "bcrypt"
import jwt from "jsonwebtoken"
import User from "../models/User.js";
import {request, response} from "express";
import Event from "../models/Event.js";

export const register = async (request, response) => {
    try {
        const {
            name,
            email,
            password,
            location
        } = request.body;

        const salt = await bcrypt.genSalt();
        const passwordHash = await bcrypt.hash(password, salt);

        const newUser = new User({
            name, email, password: passwordHash, location
        });

        const savedUser = await newUser.save();
        response.status(201).json(savedUser);
    }
    catch(err) {
        response.status(500).json({ error: err.message });
    }
}

export const login = async (request, response) => {
    try {
        const { email, password } = request.body;

        const user = await User.findOne({ email: email });
        if(!user) return response.status(400).json({ msg: "User does not exist." });

        const isMatch = await bcrypt.compare(password, user.password);
        if(!isMatch) return response.status(400).json({ msg: "Invalid credentials." });

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
        delete user.password;
        response.status(200).json({ token, user });
    }
    catch(err) {
        response.status(500).json({ error: err.message });
    }
}

export const getUser = async (request, response) => {
    try {
        const {
            userId
        } = request.body;

        const user = await User.findById(userId);

        if(user) {
            response.status(200).json(user);
        }
        else {
            response.status(400).json({ error: 'No user with given id.' });
        }
    }
    catch (e) {
        response.status(400).json({ error: e.message });
    }
}

export const updateAttends = async (request, response) => {
    try {
        const {
            userId,
            attends
        } = request.body;

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { attends: attends }, // Update the attends field with the new list
            { new: true } // To return the updated event
        );

        if(updatedUser) {
            response.status(200).json(updatedUser);
        }
        else {
            response.status(404).json({ error: 'Failed to update user attends' });
        }
    }
    catch (e) {
        response.status(404).json({ error: e });
    }
}

export const test = async (request, response) => {
    response.status(200).json({text: "Success"});
}