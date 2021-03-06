cfg = require '../config/config.js'    # contains API keys, etc.
mongoose = require 'mongoose'
    
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

MapSchema = new Schema {
  name: { type: String, required: true },
  id: { type: String, required: true, unique: true },
  active: { type: Number, default: 1 },
  theme: { type: String, default: 'Water' },
  mobs: [ String ],  # A map can have many mobs
  end_x: { type: Number },
  end_y: { type: Number }
}

mongoose.model 'Maps', MapSchema
module.exports = db.model 'Maps' 