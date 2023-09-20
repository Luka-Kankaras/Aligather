import mongoose from "mongoose";

const EventSchema = new mongoose.Schema(
    {
        hostId: {
            type: String,
            required: true,
        },
        name: {
            type: String,
            required: true,
            min: 2,
            max: 50,
        },
        description: {
            type: String,
            required: true,
            max: 300,
        },
        location: {
            type: String,
            required: true,
        },
        hostName: {
            type: String,
            required: true,
        },
        picturePath: {
            type: String,
            required: true,
        },
        attends: {
            type: Array,
            of: String,
            default: [],
        },
    },
    { timestamps: true }
);

const Event = mongoose.model("Event", EventSchema);
export default Event;