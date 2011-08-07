### Tower Tests ###
basedir = '../../'
Tower = (require basedir + 'controllers/towers.js').Tower
TowerModel = require basedir + 'models/tower-model.js'
Mob = (require basedir + 'controllers/mobs.js').Mob
MobModel = require basedir + 'models/mob-model.js'

Obj = (require basedir + 'controllers/utils/object.js').Obj



# Unit Tests
describe 'Towers towers.js', ->
  beforeEach ->
    global.world = new Obj # Required because maps relies on 'world' for some events
    
    # Stub data
    @name = 'Cannon Tower'
    @id = 'cannon'
    @active = 1
    @symbol = 'C'
    @damage = 5
    @range = 2

    @fakeMob = new Obj   # Load a fake mob to emit events
    @fakeMob.symbol = 'm'
    
    @tower = new Tower @id

  it 'Loads a new tower called Cannon Tower', ->
    expect(@tower.id).toEqual(@id)
    expect(@tower.name).toEqual(@name)
    expect(@tower.active).toEqual(@active)
    expect(@tower.damage).toEqual(@damage)
    expect(@tower.range).toEqual(@range)

  it 'Saves itself to the DB once loaded', ->
    self = @
    TowerModel.find { id: @id }, (err, res) ->
      expect(res[0].name).toEqual self.name
  
  it 'Spawns itself on the map at 5, 4', ->
    self = @
    @tower.on 'spawn', (type, loc, callback) ->
      expect(self.tower.loc).toEqual([5, 4])
    @tower.spawn [5, 4], (callback) ->  

  ### TODO - Find a way to gracefully clear the DB before tests run
  it 'Finds no targets when none are in range', ->
    
    # Spawn the tower    
    @tower.spawn [5, 4], (callback) ->      
    
    # Spawn a fake mob
    fakeMob = new Mob 'warrior'

    fakeMob.spawn [0, 0], (callback) ->
    
    @tower.checkTargets (res) ->
      expect(res).toEqual []
  ###

  it 'Finds targets when one is in range', ->
    # Spawn the tower    
    @tower.spawn [5, 4], (callback) ->      
  
    # Spawn a fake mob
    fakeMob = new Mob 'warrior'

    fakeMob.spawn [5, 5], (callback) ->


    @tower.checkTargets (res) ->
      expect(res[0].id).toEqual 'warrior'