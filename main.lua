function love.load()
  gameState = 1
  sprites = {}
  sprites.player = love.graphics.newImage('assets/player.png')
  sprites.bullet = love.graphics.newImage('assets/bullet.png')
  sprites.zombie = love.graphics.newImage('assets/zombie.png')
  sprites.background = love.graphics.newImage('assets/background.png')

  player = {}
  player.x = love.graphics.getWidth()/2
  player.y = love.graphics.getHeight()/2
  player.speed = 120
  player.rotation = 0
  player.width = sprites.player:getWidth()/2
  player.height = sprites.player:getHeight()/2
  player.health = 100
  player.kills = 0
  player.skillPoints = 0
  player.damage = 0
  player.ammoType = 0
  player.ammoLevel = 0


  zombiesArray = {}
  bulletsArray = {}
  spawnMaxTime = 3
  spawnerTime = 0
  doneOnce = false
end


function love.draw()
  if gameState == 1 then
    love.graphics.printf("Click anywhere to start", 0, 50, love.graphics.getWidth(), "center")
  else
  love.graphics.draw(sprites.background)
  love.graphics.print("HP: ", love.graphics.getWidth()/2 - 20, love.graphics.getHeight() - 600, r, sx, sy, ox, oy, kx, ky)
  love.graphics.draw(sprites.player, player.x, player.y, player.rotation, nil, nil, player.width, player.height)
  love.graphics.print("You gain skill poit every 10 kills! Choose them wisely", 0, love.graphics.getHeight() - 600, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(player.health, love.graphics.getWidth()/2, love.graphics.getHeight() - 600, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("Kill Count: ", love.graphics.getWidth()/2 - 40, love.graphics.getHeight() - 590, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(player.kills, love.graphics.getWidth()/2 + 40, love.graphics.getHeight() - 590, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("SP avaible: ", 0, love.graphics.getHeight() - 590, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(player.skillPoints, 80, love.graphics.getHeight() - 590, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("Press Z to upgrade damage", 0, love.graphics.getHeight() - 580, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("Press X to add health ", 0, love.graphics.getHeight() - 570, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("Press C to upgrade movement speed ", 0, love.graphics.getHeight() - 560, r, sx, sy, ox, oy, kx, ky)


  for i,z in ipairs(zombiesArray) do
    love.graphics.draw(sprites.zombie, z.x, z.y , z.rotation, nil, nil, z.width, z.height)
    love.graphics.print(z.health, z.x, z.y - 30, nil, nil, nil, z.width, z.height)
  end

  for i,b in ipairs(bulletsArray) do
    love.graphics.draw(sprites.bullet, b.x, b.y,nil, 0.3, 0.3, b.width, b.height)
  end
end
end

function love.update(dt)
  if gameState == 2 then
  spawnerTime = spawnerTime + dt
  if player.health <= 0 then
    love.load()
  end

  if spawnerTime>=spawnMaxTime then
    SpawnZombie()
    spawnerTime=0
    if spawnMaxTime > 1 then
      spawnMaxTime = spawnMaxTime - 0.1
    end
  end
  UpdatePlayerRotation()
  ZombiesLogic(dt)
  BulletsLogic(dt)
  ZombieHealthLogic()
  CheckBulletCollisionWithZombies()
  CheckInput(dt)
end
end

function CheckInput(dt)

  if love.keyboard.isDown("s") then
    player.y = player.y + player.speed * dt
  end
  if love.keyboard.isDown("w") then
    player.y = player.y - player.speed * dt
  end
  if love.keyboard.isDown("d") then
    player.x = player.x + player.speed * dt
  end
  if love.keyboard.isDown("a") then
    player.x = player.x - player.speed * dt
  end

  if love.keyboard.isDown("z") then
    if player.skillPoints > 0 then
      if(doneOnce == false) then
        player.damage = player.damage + 5
        player.skillPoints = player.skillPoints - 1
        doneOnce = true
      end
    end
  end
    if love.keyboard.isDown("x") then
      if(doneOnce == false) then
        player.health = player.health + 25
        player.skillPoints = player.skillPoints - 1
        doneOnce = true
      end
    end

    if love.keyboard.isDown("c") then
      if doneOnce == false then
        player.speed = player.speed + 25
        player.skillPoints = player.skillPoints - 1
        doneOnce = true
      end
    end

-- zrezygnowalem z pociskow przebijajacych bo przy takiej czestotliwosci klatek na sekunde zawsze zabijaly przecinko

  --  if love.keyboard.isDown("c") then
    --  if(doneOnce == false) then
      --  player.ammoType = 1
      --  player.skillPoints = player.skillPoints - 1
      --  if player.ammoType == 1 then
      --    player.ammoLevel = player.ammoLevel + 1
      --    doneOnce = true
      --  end
      --  doneOnce = true
      --end
    --end
end


function ZombieHealthLogic()
  for i=#zombiesArray,1,-1 do
    local z = zombiesArray[i]
    if z.bIsDead == true then
      player.kills = player.kills + 1
      if player.kills % 10 == 0 then
        player.skillPoints = player.skillPoints + 1
        doneOnce = false
      end
      table.remove(zombiesArray, i)
    end
  end
end

function BulletsLogic(dt)
  for i,b in ipairs(bulletsArray) do
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
  end

  for i=#bulletsArray,1,-1 do
    local b = bulletsArray[i]
    if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight()  or b.destroyed == true then
      table.remove(bulletsArray, i)
    end
  end
end

function CheckBulletCollisionWithZombies()
  for i,z in ipairs(zombiesArray) do
    for j,b in ipairs(bulletsArray) do
      if distanceFrom(b.x, b.y, z.x, z.y) <= 20 then
          z.health = z.health - b.damage
          b.hits = b.hits + 1
      --  if bullet.type == 0 then
          b.destroyed = true
    --    else if bullet.type == 1 then
      --    if hits == bullet.level then
        --    b.destroyed = true
          --end
      --  end

      end
    end
  end
end

function ZombiesLogic(dt)
  for i,z in ipairs(zombiesArray) do
    UpdateZombieRotation(z)
    if z.health <= 0 then
      z.bIsDead = true
    end

    if z.bShouldMove == true then
      z.x=z.x + math.cos(z.rotation) * z.speed * dt
      z.y=z.y + math.sin(z.rotation) * z.speed * dt
    end
    if distanceFrom(z.x, z.y, player.x, player.y) <= 20 then
      if player.health > 0 then
        player.health = player.health - z.damage * dt
      end
      z.bShouldMove = false
    else
      z.bShouldMove = true
    end
  end
end

function UpdatePlayerRotation()
  player.rotation = math.atan2( love.mouse.getY() - player.y , love.mouse.getX() - player.x)
end

function UpdateZombieRotation(z)
  z.rotation = math.atan2(player.y - z.y, player.x - z.x )
end

function distanceFrom(x1,y1,x2,y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function love.mousepressed(x, y, button, isTouch)
  if gameState == 1 then
    gameState = 2
  end
  if gameState == 2 then
    if button == 1 then
      SpawnBullet()
    end
  end
end


function SpawnBullet()
  bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 500
  bullet.direction = player.rotation
  bullet.damage = 17 + player.damage
  bullet.type = player.ammo
  bullet.width = sprites.bullet:getWidth()/2
  bullet.height = sprites.bullet:getHeight()/2
  bullet.destroyed = false
  bullet.level = player.ammoLevel
  bullet.hits = 0

  table.insert(bulletsArray, bullet)
end

function SpawnZombie()
  zombie = {}
--  zombie.x = math.random(0, love.graphics.getWidth())
  zombie.x = 0
--  zombie.y = math.random(0, love.graphics.getHeight())
  zombie.y = 0
  zombie.speed = math.random(0,150)
  zombie.width = sprites.zombie:getWidth()/2
  zombie.height = sprites.zombie:getHeight()/2
  zombie.rotation = 0
  zombie.health = math.random(60,200)
  zombie.damage = math.random(10,40)
  zombie.bShouldMove = true
  zombie.bIsDead = false
  local side = math.random(1,4)

  if side == 1 then
    zombie.x = -30
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = - 30
  elseif side == 3 then
    zombie.x = love.graphics.getWidth() + 30
    zombie.y =  math.random(0, love.graphics.getHeight())
  else
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + 30
  end

  table.insert(zombiesArray, zombie)
end
