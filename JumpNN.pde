import java.util.*;
//Hashtable<String,Boolean> tracking = new Hashtable();
/* @pjs preload="oldman_3.png"; */
// Devon Scott-Tunkin
// Playgramming 2013




/*
todo

the toggle by pressing L stops threads from processing
memory leaks, big time. Need to resolve. Objects not being deleted?
*/






public class MyRunnable implements Runnable 
{
   player pl;
   

   public MyRunnable(player pl) 
   {
      this.pl = pl;
   }
   public synchronized void doWaitLoop()
   {
     while(!pl.alive)
       {
         try
         {
           wait();
         }
         catch (InterruptedException ex)
         {
            System.err.println(ex);
         }
       }
       println("Player " + pl.name + "'s thread has terminated.");
   }
   
   public synchronized void run()
   {
    try
     {
       while(pl.alive)
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
        //System.err.println(ex);
        pl = null;
     } 
   }
   
   public synchronized void doWait()
   {
     try
     {
       //println("-----------------locking-------------------");
       wait();
       //println("-----------------unlocked-------------------");
     }
     catch (InterruptedException ex)
     {
        System.err.println(ex);
        pl = null;
     }
   }

   public void run2()
   {
     //println("-------------------------------starting thread for player " + pl.name + " " + pl.alive  + " -----------------");
     while(pl.alive)
     {
       if (pl.test == 0) println("0");
       doWait();
       if (pl == null) break;
       if (!pl.running) 
       {
         //println("thread is running when it should not be " + pl.name);
         break;
       }
       if (!pl.running) 
       {
         
         println("thread is running when it should not be " + pl.name);
       }
       //if (!pl.alive) println("-------------------------------checking thread for player " + pl.name + " " + pl.alive  + " -----------------");
       if (!pl.alive) break;
       if (!pl.running) println("thread is still running after termination");
       //if (!pl.alive) println("still alive? wrongly");
       ////println("-----------------completely unlocked-------------------");

        ////println("running");
        pl.doWork();

        float[] dists = new float[1]; //we only care about the closest obstacle, this is an array to make extension easier
        if (obstacles.size() != 0) dists[0] = calcDist(pl, obstacles.get(0));
        
        pl.setNNInput(dists);
        pl.br.doCalc();
        
        if (pl.shouldJump()) pl.up = -1;
        else pl.up = 0;
        
        //pl.active = false;
     }
     //println("player " + pl.name + "'s thread has terminated");
     
   }
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
   //println(x + ":" + y + ":"); 
  }
  void doWork()
  {
    x -= speed;
  }
  void doDraw()
  {
    
    //ellipse(x, y, 10, 10);
    fill(255);
    rect(x, y - sizey + 10, sizex, sizey);
    
  }
}

class player
{
  Integer test = -1;
  //boolean active = true;
  boolean alive = true;
  int inputNodes = 1;
  int outputNodes = 1;
  
  int numNodes = 5;
  int numLayers = 5;
  
  int xPadding = 50;
  int yPadding = 50;
  Thread thread;
  Runnable run;
  
  boolean running = true;
  

  Brain br;
  
  Node[] inputLayer;
  Node[] outputLayer;
  
  protected void finalize() throws Throwable  
  { 
      // will print name of object 
      //System.out.println(this.name + " successfully garbage collected"); 
      //tracking.put(this.name, true);
  } 
  
  player(String name, float posx, float posy, float velx, float vely, float r, float g, float b, int numNodes, int numLayers)
  {
    //if (tracking == null) println("tracking was null");
    
    
    //tracking.put(name, false);
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
  
  
  player(String name, float posx, float posy, float velx, float vely, float r, float g, float b)
  {
    //tracking.put(this.name, false);
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
    //tracking.put(newName, false);
    //println("player " + newName + " created.");
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
  
  void revive()
  {
    //tracking.put(this.name, false);
   //if (this.alive) //println("==========================Player was alive=========================");
   this.alive = true;
   this.createThread();
  }
  
  void doDeepCopy()
  {
    Brain br2 = br.deepCopy();
    br = br2;
    ////println("Copied brain!");
  }
  
  void createThread()
  {
    run = new MyRunnable(this); //create the runnable and pass in the player reference
    thread = new Thread(run); //make it a threads
    thread.start(); //star the thread 
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
    ////println("output: " + br.getOutput()[0].val);
    if (br.getOutput()[0].val >= 0.5) return true;
    else return false;
   //return br.getOutput()[0].val >= 0.5;
  }
  
  
  
  void die()
  {
   //println(name + " has died"); 
   this.alive = false;
   this.thread.interrupt();
   
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
      ////println("pjump");
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
  if (p == null || o == null) return false;
  //boolean tmp = false;
  //if (!tmp) return false;
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
int topPlayers = 50;

int fr = 60;

int minLayers = 8;
int maxLayers = 9;
int minNodes = 7;
int maxNodes = 8;

void setup()
{
  size(800, 800);
  frameRate(fr);

  for (int i = 0; i < numPlayers; i++)
  {
   player tmp =  new player("" + i, 10,700, -1, 0, random(0,255), random(0,255), random(0,255), int(random(minNodes, maxNodes)), int(random(minLayers,maxLayers)));
   population.add(tmp);
  }
  
  mill = nanoTime();
  
}

void timingDebug(String info, float mil)
{
  float now = nanoTime();
  //println(info + " took " + (nanoTime() - mil));
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
boolean showT = true;

int playerCounter = 0;

 




synchronized void draw()
{
  
  for (player p: population)
  {
    if (!p.thread.isAlive() && p.alive) 
    {
      println("There is a dead thread still alive: " + p.name);
      
      
    }
  }
  
  
  
  
  nano = System.nanoTime();
  mill = nanoTime();
 
  
  counter++;
  if (counter >= next)
  {
    //println(counter + ":" + next + " triggered");
   counter = 0;
   next = int(random(60,190));
   obstacles.add(new obstacle(width,height -20, 2.5, 50));
  }
  timingDebug("Spawning obstacles", mill);
  
  
  mill = nanoTime();
  
  background(0);
  if(showT) drawText(generation +"", 50, 50);
  if(showT) drawText(fr +"", 100, 50);
  drawText(frameRate +"", 200, 50);
  if(showT) drawText(turbo +"", 10, 50);
  if(showT) drawText(population.size() + "", 25, 25);
  
  
  fill(0,0,255);
  rect(0, 790, 800,10);
  fill(255);

   mill = nanoTime();

  for (player pl: population)
  {
    synchronized(pl.run)
    {
      pl.run.notify();
    }
    
  }
  //doUnlock();
  
  for (player pl: population)//draw loop
  {
    //pl.active = true;
    
    if (showPl) pl.doDraw();
    if (show) pl.br.doDraw();
  }
  
  

  for (int i = population.size()-1; i >= 0; i--)
  {
    player tmp = population.get(i);
    for (obstacle o: obstacles)
    {
      if (checkCollision(tmp, o) || !tmp.alive)
      {
        tmp.die();
        //tmp.alive = false;
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
  if (population.size() == 0)
  {
    doGeneration();
  }

  mill = nanoTime();
  for (int i = obstacles.size()-1; i >= 0; i--)
  {
    obstacle tmp = obstacles.get(i);
    tmp.doWork();
    if (showOb) tmp.doDraw();
    if (tmp.x <= 0) obstacles.remove(i); //if this obstacle is off the screen, it doesnt matter
  }
}

boolean isSlow = false;



void keyPressed()
{
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
   player tmp =  new player(population.get(0), str(counter++));
   population.add(tmp);
  }
  if(key == 'l')
  {
    showOb = !showOb;
    showPl = !showPl;
    //showT = !showT;
  }
  if (key == 'm')
  {
   debugThreads(); 
  }
  if (key == 'k')
  {
    if(isSlow) 
    {
      isSlow = false;
      //println("framerate " + frameRate);
      frameRate(fr);
    }
    else 
    {
      isSlow = true;
      //println("framerate " + frameRate);
      frameRate(1);
    }
  }
  if (key == 'n')
  {
   doGeneration_nograveyard(); 
  }
  if (key == 'f')
  {
   doUnlock();
  }
  if (key == 'd')
  {
    for (player p: population)
    {
      println(p.name + (p.thread.isAlive() ? " is running." : "is dead."));
    }
  }
  /*if (key == 'd')
  {
   String tmp = "";
   for (player p: population)
   {
    tmp += p.name + ","; 
   }
   tmp += "\n";

   for(String entry : tracking.keySet()) 
   {
    tmp += entry + ":" + tracking.get(entry) + ",";
    
    Boolean found = false;
    for (player p: population)
    {
      if (p.name == entry) 
      {
       found = true;
       break;
      }
    }
    if (found != tracking.get(entry)) println("both were " + (found? "alive" : "dead"));
    else println(entry + " " + found + "," + tracking.get(entry));
    //if (found) println(entry + " is alive.");
    //else println(entry  + " is dead.");
   }
   println("players alive: " + tmp);
   
  }*/
}


public synchronized void doUnlock()
{
  //println("unlocking");
 notify();
 //println("finished unlocking");
}

void keyReleased()
{

  
  
}

void debugThreads()
{
  //println("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
  for (int i = 0; i < population.size(); i++)
  {
    String t = "Thread " + i + " ";
     t += (population.get(0).thread.isAlive()) ? "Running" : "Not Running";
     //if (!population.get(0).thread.isAlive()) population.get(0).thread.start();
     //println(t);
  }
  
  //println("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
  
}

void baseFunc(int num)
{
  for(int i = 0; (num-1)*10 < num*10; i++)
  {
    if (i >= population.size()) return;
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


void doGeneration_graveyard()
{
    //obstacles.remove(0); //Remove the obstacle so the players dont die immediently
    generation++; //we are breeding, so we increment the generation count
    for (int i = graveYard.size()-1; i > graveYard.size() - 11; i--)
    {
      player tmp = graveYard.get(i); 
      tmp.revive();
      population.add(tmp); //we keep the top 10 fittest
      for (int j = 0; j < 9; j++) //Then we create 9 additional players mutated from the original
      {
        population.add(new player(tmp, str(counter++)));
      }
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
  //println("population size: " + population.size());
  
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
    g.running = false;
    if (g.running) println("BOOLEAN WAS NOT SET!");
    g.alive = false;
    synchronized(g.run)
    {
      g.run.notify();
    }
      
    if (g.thread.isAlive()) 
    {
      //println("player " + g.name + " has a running thread while dead " + g.alive);
      
      try
      {
        g.thread.join();
      }
      catch (InterruptedException ex)
       {
          System.err.println(ex);
       }
      
    }
    if (g.thread.isAlive()) 
    {
      
      println("====player " + g.name + " has a running thread while dead " + g.alive);
    }
    g.thread.interrupt();
    g.test = null;
  }
  graveYard = new ArrayList();
  System.gc();
}

void doGeneration_old()
{
  obstacles.remove(0); //Remove the obstacle so the players dont die immediently
  generation++; //we are breeding, so we increment the generation count
  for (int i = graveYard.size()-1; i > graveYard.size() - 11; i--)
  {
    player tmp = graveYard.get(i); 
    tmp.revive();
    population.add(tmp); //we keep the top 10 fittest
    for (int j = 0; j < 9; j++) //Then we create 9 additional players mutated from the original
    {
      population.add(new player(tmp, str(counter++)));
    }
  } 
}
