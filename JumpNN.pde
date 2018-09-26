import java.util.*;


//begin modifyable values
int numPlayers = 100; //number of players per generation to spawn
int topPlayers = 10; //number of players to resurrect from the grave and breed from

int minLayers = 1;
int maxLayers = 3;
int minNodes = 1;
int maxNodes = 5;
//end modifyable values


//variables below this line should not be changed
ArrayList<player> population = new ArrayList<player>();
ArrayList<player> graveYard = new ArrayList<player>();
ArrayList<obstacle> obstacles = new ArrayList<obstacle>();

int counter = 0;
int fr = 60; //math is frame based. Increasing this from 60 will not create smoother animation, it will only run faster
int generation = 1;
int next = 0;

boolean show = false;
boolean turbo = false;
boolean showOb = true;
boolean showPl = true;
boolean showT = true;
boolean isSlow = false;

float gravity = .5; // half a pixel per frame gravity.
float ground = 775; // Y coordinate of ground for collision


void setup()
{
  size(800, 800);
  frameRate(fr);

  for (int i = 0; i < numPlayers; i++)
  {
   player tmp =  new player("" + i, 10,700, -1, 0, random(0,255), random(0,255), random(0,255), int(random(minNodes, maxNodes)), int(random(minLayers,maxLayers)));
   population.add(tmp);
  }
}
void draw()
{
  counter++;
  if (counter >= next)
  {
   counter = 0;
   next = int(random(60,80));
   obstacles.add(new obstacle(width,height -20, 2.5, 50));
  }
  
  background(0);
  if(showT) drawText(generation +"", 50, 50);
  if(showT) drawText(fr +"", 100, 50);
  drawText(frameRate +"", 200, 50);
  if(showT) drawText(turbo +"", 10, 50);
  if(showT) drawText(population.size() + "", 25, 25);
  
  
  fill(0,0,255);
  rect(0, 790, 800,10); //draw the ground
  fill(255);

  for (player pl: population)
  {
    synchronized(pl.run)
    {
      pl.run.notify(); //wake the blocked threads
    }
  }
  
  for (player pl: population)//draw loop
  {
    if (showPl) pl.doDraw();
    //if (show) pl.br.doDraw(); //comment this out if you want to see all of the brains overlapped
  }
  if (show) population.get(0).br.doDraw(); //only draw a single brain
  
  for (int i = population.size()-1; i >= 0; i--) //check each living player
  {
    player tmp = population.get(i);
    for (obstacle o: obstacles)
    {
      if (checkCollision(tmp, o) || !tmp.alive) //check if the player has died
      {
        tmp.die();
        graveYard.add(tmp);
        population.remove(i);
        synchronized(tmp.run)
        {
         tmp.run.notify(); 
        }
        break;
      }
    }
  }
  
  if (population.size() == 0) //if all players are dead, we need to breed new players
  {
    doGeneration();
  }

  for (int i = obstacles.size()-1; i >= 0; i--) //need to move all obstacles
  {
    obstacle tmp = obstacles.get(i);
    tmp.doWork();
    if (showOb) tmp.doDraw();
    if (tmp.x <= 0) obstacles.remove(i); //if this obstacle is off the screen, it doesnt matter
  }
}



public class PlayerRunnable implements Runnable 
{
   player pl;
   
   public PlayerRunnable(player pl) 
   {
      this.pl = pl;
   }
   
   public synchronized void run()
   {
    try
     {
       while(pl != null && pl.alive)
       {
         if (pl == null) break;
          pl.doWork();

          float[] dists = new float[1]; //we only care about the closest obstacle, this is an array to make extension easier
          if (obstacles.size() != 0) dists[0] = calcDist(pl, obstacles.get(0));
          
          pl.setNNInput(dists);
          pl.br.doCalc();
          
          if (pl.shouldJump()) pl.up = -1;
          else pl.up = 0;
          
          wait();
       }
     }
     catch (InterruptedException ex)
     {
        pl = null; //Thread was told to stop, ensure garbage collection will remove this object
     } 
   }
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
  void doWork()
  {
    x -= speed;
  }
  void doDraw()
  {
    fill(255);
    rect(x, y - sizey + 10, sizex, sizey);
  }
}

class player
{
  boolean alive = true;
  
  int inputNodes = 1;
  int outputNodes = 1;

  int xPadding = 50;
  int yPadding = 50;
  
  Thread thread;
  Runnable run;
  Brain br;
  
  Node[] inputLayer;
  Node[] outputLayer;
  
  float posy, posx, velx, vely, jumpSpeed, walkSpeed, up;
  //float jumpspeed = 100;
  float sizex = 10;
  float sizey = 20;
  float r, g, b;
  
  String name;
  
  
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
    this.createThread();
  }
  
  player(player old, String newName)
  {
    this.name = newName;
    this.alive = true;
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
    this.createThread();
  }
  
  void createThread()
  {
    run = new PlayerRunnable(this); //create the runnable and pass in the player reference
    thread = new Thread(run); //make it a threads
    thread.start(); //star the thread 
  }
  
  void doDeepCopy()
  {
    Brain br2 = br.deepCopy();
    br = br2;
  }

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
    if (br.getOutput()[0].val >= 0.5) return true; //if the output node is >= 0.5 jump
    else return false;
  }
  
  void die()
  {
   this.alive = false;
   this.thread.interrupt();
  }
  
  void revive()
  {
   this.alive = true;
   this.createThread();
  }
  
  void doDraw()
  {
    fill(r,g,b);
    rect(posx, posy, 10,10);
  }
  
  void doWork() //created from example code
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
      vely = -10;
    }   
    
    // Check collision with edge of screen and don't move if at the edge
    float offset = 0;
    if (posy + vely > offset && posy + vely < (height - offset))
    {
      posy += vely;
    }  
  }
  
  protected void finalize() throws Throwable
  {
      destroyPlayer();
  }
  
  void destroyPlayer()
  {
    run = null;
    br.destroyBrain();
    br = null;
  }
}

boolean checkCollision(player p, obstacle o)
{
  if (p == null || o == null) return false; //just in case to prevent any errors. If either one does not exist, it cant collide.
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

float calcDist(player p, obstacle o)
{
  return  o.x - p.posx;
}

void keyPressed()
{
  if (key == 'p') //show/hide drawing the brain
  {
   show = !show; 
  }
  if (key == 'q') //up the framerate
  {
    if (fr >= 300) fr += 100;
    else fr += 10;
    if (!turbo) frameRate(fr);
  }
  if (key == 'a') //lower the framerate
  {
    if (fr -10 <= 0) return;
    if (fr >= 300) fr -= 100;
    else fr -= 10;
    if (!turbo) frameRate(fr);
  }
  if (key == 'e') //toggle turbomode
  {
    turbo = !turbo;
    if (turbo) frameRate(999999); 
    else frameRate(fr);
  }
  if (key == 'o') //breed the top player, only creates 1 more player
  {
   player tmp =  new player(population.get(0), str(counter++));
   population.add(tmp);
  }
  if(key == 'l') //toggles drawing the obstacles
  {
    showOb = !showOb;
    showPl = !showPl;
    //showT = !showT;
  }
  if (key == 'k') //toggle slowmode
  {
    if(isSlow) 
    {
      isSlow = false;
      frameRate(fr);
    }
    else 
    {
      isSlow = true;
      frameRate(1);
    }
  }
  if (key == 'n') //force breeding from remaining players (will only run if num players <= 50)
  {
   doGeneration_nograveyard(); 
  }
}

void doGeneration_nograveyard()
{
  
  if (population.size() == 0) return;
  
  int alive = population.size();
  int tmp = (numPlayers - alive) / population.size();
  
  for (int i = 0; i < alive; i ++)
  {
    player p = population.get(i);
    for (int j = 0; j < tmp; j++)
    {
      population.add(new player(p, str(counter++)));
    }
  }
  graveYard = new ArrayList(); //delete anything in the graveyard.
}

void doGeneration_somegraveyard()
{
  for (int i = population.size(); i < 10; i++) //
  {
    int end = graveYard.size();
    player tmp = graveYard.get(end);
    tmp.revive();
    population.add(tmp);
  }
  
  for (int i = 0; i < population.size(); i++)
  {
    player tmp = population.get(i);
    for (int j = 0; j < 9; j++)
    {
      population.add(new player(tmp, str(counter++)));
    }
  }
}

void doGeneration()
{
  obstacles.remove(0); //Remove the obstacle so the players dont die immediently
  generation++; //we are breeding, so we increment the generation count
  
  for (int i = graveYard.size()-1; i > graveYard.size() - topPlayers - 1; i--)
  {
    player tmp = graveYard.get(i); 
    tmp.revive();
    population.add(tmp); //we keep the top 10 fittest
    
    int remaining = (numPlayers - topPlayers) / topPlayers;
    for (int j = 0; j < remaining; j++) //Then we create 9 additional players mutated from the original
    {
      population.add(new player(tmp, str(counter++)));
    }
  } 
  for (player g: graveYard)
  {
    g.alive = false;
    synchronized(g.run)
    {
      g.run.notify();
    }
      
    if (g.thread.isAlive()) 
    {
      try
      {
        g.thread.join();
      }
      catch (InterruptedException ex)
       {
          System.err.println(ex);
       }
      
    }
    g.thread.interrupt(); //kill the thread
  }
  graveYard = new ArrayList();
  System.gc();
}
