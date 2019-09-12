function love.load()
  sprites = {}
  sprites.player = love.graphics.newImage('assets/player.png')
  sprites.bullet = love.graphics.newImage('assets/bullet.png')
  sprites.zombie = love.graphics.newImage('assets/zombie.png')
  sprites.background = love.graphics.newImage('assets/background.png')

  player = {}
  player.x = 200
  player.y = 200
  player.speed = 120
  player.rotation = 0
  player.width = sprites.player:getWidth()/2
  player.height = sprites.player:getHeight()/2
  player.health = 100
  player.kills = 0

  zombiesArray = {}
  bulletsArray = {}

  spawnerTime = 0
end

function love.draw()
  love.graphics.draw(sprites.background)
  love.graphics.draw(sprites.player, player.x, player.y, player.rotation, nil, nil, player.width, player.height)
  love.graphics.print("HP: ", love.graphics.getWidth()/2 - 20, love.graphics.getHeight() - 600, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(player.health, love.graphics.getWidth()/2, love.graphics.getHeight() - 600, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print("Kill Count: ", love.graphics.getWidth()/2 - 40, love.graphics.getHeight() - 590, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(player.kills, love.graphics.getWidth()/2 + 40, love.graphics.getHeight() - 590, r, sx, sy, ox, oy, kx, ky)


  for i,z in ipairs(zombiesArray) do
    love.graphics.draw(sprites.zombie, z.x, z.y , z.rotation, nil, nil, z.width, z.height)
    love.graphics.print(z.health, z.x, z.y - 30, nil, nil, nil, z.width, z.height)
  end

  for i,b in ipairs(bulletsArray) do
    love.graphics.draw(sprites.bullet, b.x, b.y,nil, 0.3, 0.3, b.width, b.height)
  end

end

function love.update(dt)
  spawnerTime = spawnerTime + dt

  if spawnerTime>=3 then
    SpawnZombie()
    spawnerTime=0
  end
  UpdatePlayerRotation()
  ZombiesLogic(dt)


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

  for i=#zombiesArray,1,-1 do
    local z = zombiesArray[i]
    if z.bIsDead == true then
      table.remove(zombiesArray, i)
    end
  end

  for i,z in ipairs(zombiesArray) do
    for j,b in ipairs(bulletsArray) do
      if distanceFrom(b.x, b.y, z.x, z.y) <= 20 then
        z.health = z.health - b.damage
        b.hits = b.hits + 1
        if bullet.type == 0 then
          b.destroyed = true
        else if bullet.type == 1 then
          if hits == bullet.level then
            b.destroyed = true
          end
        end
      end
    end
  end
end
  CheckInput(dt)
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
  if button == 1 then
    SpawnBullet()
  end
end


function SpawnBullet()
  bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 500
  bullet.direction = player.rotation
  bullet.damage = 10
  bullet.type = 0
  bullet.width = sprites.bullet:getWidth()/2
  bullet.height = sprites.bullet:getHeight()/2
  bullet.destroyed = false
  bullet.level = 1
  bullet.hits = 0

  table.insert(bulletsArray, bullet)
end

function SpawnZombie()
  zombie = {}
  zombie.x = math.random(0, love.graphics.getWidth())
  zombie.y = math.random(0, love.graphics.getHeight())
  zombie.speed = math.random(0,150)
  zombie.width = sprites.zombie:getWidth()/2
  zombie.height = sprites.zombie:getHeight()/2
  zombie.rotation = 0
  zombie.health = math.random(0,150)
  zombie.damage = 4
  zombie.bShouldMove = true
  zombie.bIsDead = false

  table.insert(zombiesArray, zombie)
end
