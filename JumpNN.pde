/* @pjs preload="oldman_3.png"; */
// Devon Scott-Tunkin
// Playgramming 2013




/*
todo
detect collision between obstacles and player, // redo collison detection
destroy obstacle when off screen
*/



public class MyRunnable implements Runnable 
{
  //player pl;

   public MyRunnable() 
   {
      //this.pl = pl;
   }
   
   public void run()
   {
     
   }

   /*public void run2() 
   {
     pl.doWork();

    float[] dists = new float[1]; //we only care about the closest obstacle, this is an array to make extension easier
    dists[0] = calcDist(pl, obstacles.get(0));
    
    pl.setNNInput(dists);
    pl.br.doCalc();
    
    if (pl.shouldJump()) pl.up = -1;
    else pl.up = 0;
   }*/
}
  
  
  
 
  

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
  float sizex = 20;
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
  
  int numNodes = 5;
  int numLayers = 5;
  
  int xPadding = 50;
  int yPadding = 50;

  Brain br;
  
  Node[] inputLayer;
  Node[] outputLayer;
  
  player(String name, float posx, float posy, float velx, float vely, float r, float g, float b, int numNodes, int numLayers)
  {
    br = new Brain(numLayers, numNodes, inputNodes, outputNodes, width, height/2, xPadding, yPadding, 1);
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
  
  
  player(String name, float posx, float posy, float velx, float vely, float r, float g, float b)
  {
    br = new Brain(numLayers, numNodes, inputNodes, outputNodes, width, height/2, xPadding, yPadding, 1);
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
  
  
  player(player old)
  {
    this.br = old.br.deepCopy();
    this.br.evolve();
    this.posx = old.posx;
    this.posy = old.posy;
    this.velx = old.velx;
    this.vely = old.vely;
    this.r = old.r;
    this.g = old.g;
    this.b = old.b;
    
    inputLayer = br.getInput();
    outputLayer = br.getOutput();
  }
  
  void doDeepCopy()
  {
    Brain br2 = br.deepCopy();
    br = br2;
    //println("Copied brain!");
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
    //println("output: " + br.getOutput()[0].val);
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
  }
  
  
  void doDraw()
  {
    fill(r,g,b);
    rect(posx, posy, 10,10);
  }
}

boolean checkCollision(player p, obstacle o)
{
  //check for player in obstacle
  if (o.x <= p.posx && p.posx <= o.x + o.sizex) //left side
  {
    if (o.y <= p.posy && p.posy <= o.y + o.sizey) return true; //top
    if (o.y <= p.posy + p.sizey && p.posy + p.sizey <= o.y + o.sizey) return true; //bottom
  }
  
  if (o.x <= p.posx + p.sizex && p.posx + p.sizex <= o.x + o.sizex) //right side
  {
    if (o.y <= p.posy && p.posy <= o.y + o.sizey) return true; //top
    if (o.y <= p.posy + p.sizey && p.posy + p.sizey <= o.y + o.sizey) return true; //bottom
  }
  
  //check for obstacle in player
  
  if (p.posx <= o.x && o.x <= p.posx + p.sizex) //left side
  {
    if (p.posy <= o.y && o.y <= p.posy + p.sizey) return true;
    if (p.posy <= o.y + o.sizey && o.y + o.sizey <= p.posy + p.sizey) return true;
  }
  
  if (p.posx <= o.x + o.sizex && o.x + o.sizex <= p.posx + p.sizex) //right side
  {
    if (p.posy <= o.y && o.y <= p.posy + p.sizey) return true;
    if (p.posy <= o.y + o.sizey && o.y + o.sizey <= p.posy + p.sizey) return true;
  }

  return false;
}

boolean checkCollision_old(player p, obstacle o)
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
ArrayList<player> graveYard = new ArrayList<player>();
ArrayList<obstacle> obstacles = new ArrayList<obstacle>();

int counter = 0;
int numPlayers = 100;

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
   player tmp =  new player("" + i, 10,700, -1, 0, random(0,255), random(0,255), random(0,255), int(random(1,10)), int(random(1,10)));
   population.add(tmp);
  }
  
  
  thread("func1");
  
}

void timingDebug(String info, float mil)
{
  float now = nanoTime();
  println(info + " took " + (nanoTime() - mil));
}

float calcDist(player p, obstacle o)
{
  return  o.x - p.posx;
}

float nanoTime()
{
  return System.nanoTime();
}


int generation = 1;
int next = 0;

float mill = nanoTime();
float nano = System.nanoTime();
boolean show = false;
boolean turbo = false;
boolean showOb = true;
boolean showPl = true;







void draw()
{
  
  
  
  
  println("nano: " + (System.nanoTime() - nano));
  nano = System.nanoTime();
  mill = nanoTime();
  
  println("framrate: " + frameRate);
  
  counter++;
  if (counter >= next)
  {
    println(counter + ":" + next + " triggered");
   counter = 0;
   next = int(random(60,190));
   obstacles.add(new obstacle(width,height -20, 2.5, 50));
   //obstacles.add(new obstacle(width,height -20, 2.5, random(10,50)));
  }
  timingDebug("Spawning obstacles", mill);
  
  
  mill = nanoTime();
  
  background(0);
  drawText(generation +"", 50, 50);
  drawText(fr +"", 100, 50);
  drawText(frameRate +"", 200, 50);
  drawText(turbo +"", 10, 50);
  drawText(population.size() + "", 25, 25);
  
  timingDebug("drawing text", mill);
  
  
  fill(0,0,255);
  rect(0, 790, 800,10);
  fill(255);
  //ob.doDraw();
  if (checkCollision(p, ob))
  {
   //println("COLLISION"); 
  }
  
  //===========================split for loop============================
  
  mill = nanoTime();
  
  /*Thread[] threads = new Thread[100]; //we need to keep track of the threads to join them later
  for (int i = 0; i < 100; i++) //a thread for each player, spread out the calculations
  {
    //Runnable r = new MyRunnable(population.get(i)); //create the runnable and pass in the player reference
    Runnable r = new MyRunnable();
    threads[i] = new Thread(r); //make it a threads
    threads[i].start(); //star the thread
  }
  timingDebug("made threads", mill);
  
  mill = nanoTime();
  for (int i = 0; i < population.size(); i++)
  {
    try 
    {
      threads[i].join(); //wait for all threads to finish
    } 
    catch (InterruptedException e) 
    {
      e.printStackTrace();
    }
  }
  println("threads terminated"); 
  timingDebug("threads terminated", mill);*/
  
  
  
  
  /*
  for (player pl: population)//non draw loop
  {
    pl.doWork();

    float[] dists = new float[1]; //we only care about the closest obstacle, this is an array to make extension easier
    dists[0] = calcDist(pl, obstacles.get(0));
    
    pl.setNNInput(dists);
    pl.br.doCalc();
    
    if (pl.shouldJump()) pl.up = -1;
    else pl.up = 0;
  }
  */
  timingDebug("check if they should jump", mill);
  
  
  
  for (player pl: population)//draw loop
  {
    
    if (showPl) pl.doDraw();
    if (show) pl.br.doDraw();
  }
  
  
  
  //===========================end of split====================
  
  
  
  
  
  
  
  timingDebug("main calculation loop", mill);
  
  
  mill = nanoTime();
  for (int i = population.size()-1; i >= 0; i--)
  {
    player tmp = population.get(i);
    for (obstacle o: obstacles)
    {
      if (checkCollision(tmp, o))
      {
        graveYard.add(tmp);
        population.remove(i);
        break;
      }
    }
  }
  timingDebug("collision check loop", mill);
  
  mill = nanoTime();
  if (population.size() == 0)
  {
    obstacles.remove(0); //Remove the obstacle so the players dont die immediently
    generation++; //we are breeding, so we increment the generation count
    for (int i = graveYard.size()-1; i > graveYard.size() - 11; i--)
    {
      player tmp = graveYard.get(i); 
      population.add(tmp); //we keep the top 10 fittest
      for (int j = 0; j < 9; j++) //Then we create 9 additional players mutated from the original
      {
        population.add(new player(tmp));
      }
    }
  }
  timingDebug("everyone died, finished breeding.", mill);
  
  
  mill = nanoTime();
  for (int i = obstacles.size()-1; i >= 0; i--)
  {
    obstacle tmp = obstacles.get(i);
    if (showOb) tmp.doDraw();
    if (tmp.x <= 0) obstacles.remove(i); //if this obstacle is off the screen, it doesnt matter
  }
  println(obstacles.size() + " obstacles present");
  timingDebug("Drew obstacles", mill);
  
  //println("took: " +( nanoTime() - mill));
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
  if (key == 'o')
  {
   //population.get(0).doDeepCopy();
   player tmp =  new player(population.get(0));
   population.add(tmp);
  }
}

void keyReleased()
{

  
  
}

void baseFunc(int num)
{
  for(int i = 0; (num-1)*10 < num*10; i++)
  {
    if (i => population.size()) return;
    player pl = population.get(i);
    pl.doWork();

    float[] dists = new float[1]; //we only care about the closest obstacle, this is an array to make extension easier
    dists[0] = calcDist(pl, obstacles.get(0));
    
    pl.setNNInput(dists);
    pl.br.doCalc();
    
    if (pl.shouldJump()) pl.up = -1;
    else pl.up = 0;
  }
}



void func1()
{
  while(true)
  {
    println("==========func1=========");
    baseFunc(1);
  }
}
void func2()
{
  while(true)
  {
    baseFunc(2);
  }
}
void func3()
{
  while(true)
  {
    baseFunc(3);
  }
}
void func4()
{
  while(true)
  {
    baseFunc(4);
  }
}
void func5()
{
  while(true)
  {
    baseFunc(5);
  }
}
void func6()
{
  while(true)
  {
    baseFunc(6);
  }
}
void func7()
{
  while(true)
  {
    baseFunc(7);
  }
}
void func8()
{
  while(true)
  {
    baseFunc(8);
  }
}
void func9()
{
  while(true)
  {
    baseFunc(9);
  }
}
void func10()
{
  while(true)
  {
    baseFunc(10);
  }
}
