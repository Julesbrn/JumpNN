/* @pjs preload="oldman_3.png"; */
// Devon Scott-Tunkin
// Playgramming 2013




/*
todo
detect collision between obstacles and player, // redo collison detection
destroy obstacle when off screen
*/




  
  
  
 
  

class SideJumper
{
  PImage image;
  PVector position;
  float direction;
  PVector velocity;
  float jumpSpeed;
  float walkSpeed;
}

class obstacle
{
  float x, y, speed;
  float sizex = 10;
  float sizey = 10;
  
  
  obstacle(float x, float y, float speed, float h)
  {
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.sizey = h;
  }
  void debug()
  {
   println(x + ":" + y + ":"); 
  }
  void doDraw()
  {
    x -= speed;
    //ellipse(x, y, 10, 10);
    fill(255);
    rect(x, y - sizey + 10, sizex, sizey);
    
  }
}

class player
{
  int inputNodes = 1;
  int outputNodes = 1;
  
  int numNodes = 8;
  int numLayers = 8;
  
  int xPadding = 50;
  int yPadding = 50;


  Brain br = new Brain(numLayers, numNodes, inputNodes, outputNodes, width, height/2, xPadding, yPadding, 1);
  Node[] inputLayer;
  Node[] outputLayer;
  
  
  player(String name, float posx, float posy, float velx, float vely, float r, float g, float b)
  {
    this.name = name;
    this.posx = posx;
    this.posy = posy;
    this.velx = velx;
    this.vely = vely;
    this.r = r;
    this.g = g;
    this.b = b;
    inputLayer = br.getInput();
    outputLayer = br.getOutput();
  }
  
  
  float posy, posx, velx, vely, jumpSpeed, walkSpeed, up;
  float jumpspeed = 100;
  float sizex = 10;
  float sizey = 20;
  float r;
  float g;
  float b;
  String name;
  
  
  void setNNInput(float[] inputs)
  {
    if (inputs.length == 0 ) return;
    Node[] inputLayer = br.getInput();
    for (int i = 0; i < inputLayer.length; i ++)
    {
      inputLayer[i].val = inputs[i];
    }
  }
  
  boolean shouldJump()
  {
    println("output: " + br.getOutput()[0].val);
    if (br.getOutput()[0].val >= 0.5) return true;
    else return false;
   //return br.getOutput()[0].val >= 0.5;
  }
  
  
  
  void die()
  {
   println(name + " has died"); 
  }
  void doWork()
  {
     // Only apply gravity if above ground (since y positive is down we use < ground)
    if (posy < ground)
    {
      vely += gravity;
    }
    else
    {
      vely = 0; 
    }
    
    // If on the ground and "jump" key is pressed set my upward velocity to the jump speed!
    if (posy >= ground && up != 0)
    {
      //println("pjump");
      vely = -10;
    }
    
    
    // Walk left and right. See Car example for more detail.
    velx = walkSpeed * (left + right);
    
    // We check the nextPosition before actually setting the position so we can
    // not move the oldguy if he's colliding.
    
    
    // Check collision with edge of screen and don't move if at the edge
    float offset = 0;
    if (posx + velx > offset && posx + velx < (width - offset))
    {
      posx += velx;
    } 
    if (posy + vely > offset && posy + vely < (height - offset))
    {
      posy += vely;
    }  
    fill(r,g,b);
    rect(posx, posy, 10,10);
  }
}

boolean checkCollision(player p, obstacle o)
{
  if (p.posx <= o.x && o.x <= p.posx + p.sizex &&
      p.posy <= o.y && o.y <= p.posy + p.sizey)
      {
       return true; 
      }
  if (p.posx <= o.x + o.sizex && o.x + o.sizex <= p.posx + p.sizex &&
      p.posy <= o.y && o.y <= p.posy + p.sizey)
      {
       return true; 
      }
  if (p.posx <= o.x && o.x <= p.posx + p.sizex &&
      p.posy <= o.y + o.sizey && o.y + o.sizey <= p.posy + p.sizey)
      {
       return true; 
      }
  if (p.posx <= o.x + o.sizex && o.x + o.sizex <= p.posx + p.sizex &&
      p.posy <= o.y + o.sizey && o.y + o.sizey <= p.posy + p.sizey)
      {
       return true; 
      }
  
  return false;
}


// GLOBAL VARIABLES

SideJumper oldGuy;
float left;
float right;
float up;
float down;

// half a pixel per frame gravity.
float gravity = .5;

// Y coordinate of ground for collision
float ground = 775;

obstacle ob;
player p;
ArrayList<player> population = new ArrayList<player>();
ArrayList<obstacle> obstacles = new ArrayList<obstacle>();

int counter = 0;
int numPlayers = 1;

int fr = 60;

void setup()
{
  size(800, 800);
  frameRate(fr);
  
  /*oldGuy = new SideJumper();
  oldGuy.image = loadImage("player.png");
  oldGuy.position = new PVector(400, ground);
  oldGuy.direction = 1;
  oldGuy.velocity = new PVector(0, 0);
  oldGuy.jumpSpeed = 10;
  oldGuy.walkSpeed = 4;*/
  
  ob = new obstacle(width,height -20, 2.5, 20);
  obstacles.add(ob);
  p = new player("Player", 100,700, -1, 0, 255,255,255);
  for (int i = 0; i < numPlayers; i++)
  {
   player tmp =  new player("" + i, 10,700, -1, 0, random(0,255), random(0,255), random(0,255));
   population.add(tmp);
  }
}

float calcDist(player p, obstacle o)
{
  /*
  float x = p.posx - o.x;
  float y = p.posy - o.y;
  
  float ret = sqrt(x*x + y*y);
  if (p.posx > o.x) ret *= -1;
  */
  
  return  o.x - p.posx;
}

int generation = 1;
int next = 0;

float mill = millis();
boolean show = false;
boolean turbo = false;


void draw()
{
  mill = millis();
  
  println("framrate: " + frameRate);
  
  counter++;
  if (counter >= next)
  {
    println(counter + ":" + next + " triggered");
   counter = 0;
   next = int(random(90,190));
   obstacles.add(new obstacle(width,height -20, 2.5, 50));
   //obstacles.add(new obstacle(width,height -20, 2.5, random(10,50)));
  }
  
  
  
  background(0);
  drawText(generation +"", 50, 50);
  drawText(fr +"", 100, 50);
  drawText(frameRate +"", 200, 50);
  drawText(turbo +"", 10, 50);
  fill(0,0,255);
  rect(0, 790, 800,10);
  fill(255);
  //ob.doDraw();
  if (checkCollision(p, ob))
  {
   //println("COLLISION"); 
  }
  
  for (player pl: population)
  {
    //if (pl.up == -1) pl.up = 0;
    //if (random(-10, 100) > 90) pl.up = -1;
    pl.doWork();
    
    //ArrayList<Float> dists = new ArrayList<Float>();
    float[] dists = new float[obstacles.size()];
    
    for (int i = 0; i < obstacles.size(); i ++)
    {
      dists[i] = calcDist(pl, obstacles.get(i));
    }
    
    pl.setNNInput(dists);
    
    
    
    
    
    pl.br.doCalc();
    if (show) pl.br.doDraw();
    
    
    println("shouldjump: " + pl.shouldJump());
    if (pl.shouldJump()) pl.up = -1;
    else pl.up = 0;
    
    

  }
  
  for (int i = population.size()-1; i >= 0; i--)
  {
    player tmp = population.get(i);
    for (obstacle o: obstacles)
    {
      if (checkCollision(tmp, o))
      {
        //population.remove(i);
        //tmp.die();
        tmp.br.evolve();
        generation++;
        //println("evolved" + generation);
        
        break;
      }
    }
  }
  
  for (int i = obstacles.size()-1; i >= 0; i--)
  {
    obstacle tmp = obstacles.get(i);
    tmp.doDraw();
    //tmp.debug();
    if (tmp.x <= 0) obstacles.remove(i);
  }
  println(obstacles.size() + " obstacles present");
  
  /*if (up != -1)
  {
    
    if (random(-100, 100) > 99)
    {
      up = -1;
      p.up = -1;
      println("jumping");
    }
    else
    {
     //println("not jumping"); 
    }
  }
  else
  {
    up = 0;
    p.up = 0;
  }*/
  //p.doWork();
  println("took: " +( millis() - mill));
}

void updateOldGuy()
{
  // Only apply gravity if above ground (since y positive is down we use < ground)
  if (oldGuy.position.y < ground)
  {
    oldGuy.velocity.y += gravity;
  }
  else
  {
    oldGuy.velocity.y = 0; 
  }
  
  // If on the ground and "jump" keyy is pressed set my upward velocity to the jump speed!
  if (oldGuy.position.y >= ground && up != 0)
  {
    oldGuy.velocity.y = -oldGuy.jumpSpeed;
  }
  
  // Wlak left and right. See Car example for more detail.
  oldGuy.velocity.x = oldGuy.walkSpeed * (left + right);
  
  // We check the nextPosition before actually setting the position so we can
  // not move the oldguy if he's colliding.
  PVector nextPosition = new PVector(oldGuy.position.x, oldGuy.position.y);
  nextPosition.add(oldGuy.velocity);
  
  // Check collision with edge of screen and don't move if at the edge
  float offset = 0;
  if (nextPosition.x > offset && nextPosition.x < (width - offset))
  {
    oldGuy.position.x = nextPosition.x;
  } 
  if (nextPosition.y > offset && nextPosition.y < (height - offset))
  {
    oldGuy.position.y = nextPosition.y;
  } 
  
  // See car example for more detail here.
  pushMatrix();
  
  translate(oldGuy.position.x, oldGuy.position.y);
  
  // Always scale after translate and rotate.
  // We're using oldGuy.direction because a -1 scale flips the image in that direction.
  scale(oldGuy.direction, 1);
  
  imageMode(CENTER);
  image(oldGuy.image, 0, 0);
  
  popMatrix();
}

void keyPressed()
{
  /*if (key == 'd')
  {
    right = 1;
    oldGuy.direction = -1;
  }
  if (key == 'a')
  {
    left = -1;
    oldGuy.direction = 1;
  }
  if (key == ' ')
  {
    up = -1;
    p.up = -1;
  }
  if (key == 's')
  {
    down = 1;
  }*/
  if (key == 'p')
  {
   show = !show; 
  }
  if (key == 'q')
  {
    if (fr >= 300) fr += 100;
    else fr += 10;
    if (!turbo) frameRate(fr);
  }
  if (key == 'a')
  {
    if (fr -10 <= 0) return;
    if (fr >= 300) fr -= 100;
    else fr -= 10;
    if (!turbo) frameRate(fr);
  }
  if (key == 'e')
  {
    turbo = !turbo;
    if (turbo) frameRate(999999); 
    else frameRate(fr);
  }
  
}

void keyReleased()
{

  
  
}
