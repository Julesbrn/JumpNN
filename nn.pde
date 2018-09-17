
PFont f;

int width2 = 3*width/4;

Brain b;
/*
void setup() 
{
  size(1280, 720);
  //printArray(PFont.list());
  f = createFont("SourceCodePro-Regular.ttf", 24);
  textFont(f);
  
  
  int inputNodes = 2;
  int outputNodes = 1;
  
  int numNodes = 2;
  int numLayers = 1;
  
  int xPadding = 50;
  int yPadding = 50;
  
  
  
  
  b = new Brain(numLayers, numNodes, inputNodes, outputNodes, width, height, xPadding, yPadding, 1);
  
  
  
  //numLayers, numnodes, inputlayer, width, height, xpos, ypox
  
  //Brain(int numLayers, int nodesPerLayer, float wdth, float hght, float xpos, float ypos)
  
  
}
*/

/*
void keyPressed() {
  int keyIndex = -1;
  if (key >= 'A' && key <= 'Z') 
  {
    keyIndex = key - 'A';
  } 
  else if (key >= 'a' && key <= 'z') 
  {
    keyIndex = key - 'a';
  }
  if (keyIndex == -1) 
  {
    // If it's not a letter key, clear the screen
    background(0);
  } 
  else 
  { 
    String[] keys = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
    String pressed = keys[keyIndex]; 
    
    println("keypressed: " + pressed);
    ArrayList<Node> inputLayer = b.brain.get(0);
    if (pressed == "I") inputLayer.get(0).changeVal(1f);
    if (pressed == "K") inputLayer.get(0).changeVal(-1f);
    
    if (pressed == "U") inputLayer.get(1).changeVal(1f);
    if (pressed == "J") inputLayer.get(1).changeVal(-1f);
    
    if (pressed == "R") 
    {
      inputLayer.get(0).val = 0;
      inputLayer.get(1).val = 0;
    }
    
    if (pressed == "E") b.evolve();
    
  }
}
*/

float activation(float input, int override)
{
  int type = 0;
  if (override >= 0) type = override;
  if (type == 0) //sigmoid
  {
    return 1/(1+exp(-1*input));
  }
  if (type == 1)
  {
    println("THIS SHOULDNT HAPPEN!");
   if (input < 0) return 0;
   else return input;
  }
  else
  {
    println("Something is wrong");
   return 0; 
  }  
}

float makeWeight()
{
  int type = 0;
  if (type == 0) 
  {
    return random(-1f,1f);
  }
  if (type == 1)
  {
   return random(0f,1f);
  }
  else
  {
    println("Something is wrong");
   return 0; 
  } 
}




float mil = millis();
/*
void draw() {
  background(0);
  
    //drawText(str(handles[i].stretch), handles[i].x, handles[i].y);

  b.doCalc();
  b.doDraw();
  
  //println(millis() - mil);
  //mil = millis();
  //exit();
  
}
*/
void drawType(float x) {
  fill(255);
  text("shi", x, 210);
}

void drawText(String text, float x, float y)
{
  fill(255);
  text(text, x, y);
}

class Brain
{
  ArrayList<ArrayList<Node>> brain = new ArrayList<ArrayList<Node>>(); // 2d array of nodes, each layer followed by the nodes in that layer
  
  Brain()
  {
   brain = new ArrayList<ArrayList<Node>>(); 
  }
  
  Brain deepCopy()
  {
    Brain ret = new Brain();
    HashMap<Node,Node> hm = new HashMap<Node,Node>(); // prev -> new for lines
    for (int i = 0; i < brain.size(); i++)
    {
      
      ArrayList<Node> tmp = new ArrayList<Node>();
      ArrayList<Node> prev = brain.get(i);
      for (int j = 0; j < prev.size(); j++)
      {
        //println(i + "," + j);  
        tmp.add(prev.get(j).clone(hm));
      }
      ret.brain.add(tmp);
      
    }
    //println("size of hashmap = " + hm.entrySet().size());
    
    for (int i = 0; i < brain.size(); i++)
    {
      ArrayList<Node> tmp = ret.brain.get(i);
      for (int j = 0; j < tmp.size(); j++)
      {
        tmp.get(j).finishClone(hm);
      }
    }
    
    
    
    
    
    //Then copy lines with hashmap
    
    return ret;    
  }
  
  Node[] getInput()
  {
    ArrayList<Node> L = brain.get(0);
    Node[] tmp = new Node[L.size()];
    for (int i = 0; i < L.size(); i ++)
    {
      tmp[i] = L.get(i);
    }
   return tmp;
  }
  
  Node[] getOutput()
  {
    ArrayList<Node> L = brain.get(brain.size()-1);
    Node[] tmp = new Node[L.size()];
    for (int i = 0; i < L.size(); i ++)
    {
      tmp[i] = L.get(i);
    }
   return tmp;
  }
  
  
  Brain(int numLayers, int nodesPerLayer, int inputLayerNum, int outputNodesNum, float wdth, float hght, float xpos, float ypos, int x)
  {
    float inputHeight = hght / (inputLayerNum);
    float outputHeight = hght / (outputNodesNum);
    
    wdth /= (numLayers+2);
    hght /= nodesPerLayer;
    
    
    
    //make the first layer
    ArrayList<Node> firstLayer = new ArrayList<Node>();
    for (int i = 0; i < inputLayerNum; i ++)
    {
      Node abc = new Node(0 * wdth + xpos, (i) * inputHeight + inputHeight/2);
      abc.setVal(0f);
      firstLayer.add(abc);
    }
    brain.add(firstLayer);
    
    //make the hidden layers
    for (int layer = 0; layer < numLayers; layer ++ )
    {
      ArrayList<Node> thisLayer = new ArrayList<Node>();
      for (int nNode = 0; nNode < nodesPerLayer; nNode++)
      {
        Node abc = new Node((layer+1) * wdth + xpos, nNode * hght + ypos + hght/2);
        float val = random(-1.0,1.0);
        //println("val:" + val);
        abc.setVal(val);
        thisLayer.add(abc);
      }
      brain.add(thisLayer);
      
    }
    
    //Make the output Layer
    
     ArrayList<Node> outputLayer = new ArrayList<Node>();
    for (int i = 0; i < outputNodesNum; i ++)
    {
      //Node abc = new Node(i * wdth + 0, numLayers * hght + 0);
      Node abc = new Node((numLayers+1) * wdth + xpos, (i) * outputHeight + outputHeight/2);
      abc.setVal(random(-1.0,1.0));
      abc.override = 0;
      outputLayer.add(abc);
    }
    brain.add(outputLayer);
    
    //add all of the lines

    
    //for each layer in brain
    for (int i = 1; i < brain.size(); i ++)
    {
      
      ArrayList<Node> thisLayer = brain.get(i);
      ArrayList<Node> prevLayer = brain.get(i-1);
      //for each node in this layer
      for (int a = 0; a < thisLayer.size(); a++)
      {
        ArrayList<Line> lines = new ArrayList<Line>();
        //for nodes in previous layer
        for (int b = 0; b < prevLayer.size(); b++)
        {
          //create a link between these two
          lines.add(new Line(thisLayer.get(a), prevLayer.get(b)));
        }
        thisLayer.get(a).addLines(lines);
      }
    }
  }
  
  void evolve()
  {
   ArrayList<Node> tmp = brain.get(int(random(0f,1f)*(brain.size()-1))+1);
   Node n = tmp.get(int(random(0f,1f)*tmp.size()));
   
   if (random(0f,1f) > 0.5) 
   {
     n.evolveNode();
     return;
   }
   
   
   Line l = n.lines.get(int(random(0f,1f)*n.lines.size()));
   l.evolveLine();
   
  }
  
  
  
  
  
  /*Brain(int numLayers, int nodesPerLayer, int inputLayerNum, int outputNodesNum, float wdth, float hght, float xpos, float ypos)
  {
    
    //(width - xPadding) / numLayers, (height - yPadding) / numNodes, xPadding, yPadding
    //float wdth, float hght, float xpos, float ypos
    
    //numLayers, numnodes, inputlayer, width, height, xpos, ypox
    
    float inputHeight = hght / (inputLayerNum);
    
    wdth /= numLayers;
    hght /= nodesPerLayer;
    
    
    
    
    
    ArrayList<Node> tmp1 = new ArrayList<Node>();
    for(int j = 0; j < inputLayerNum; j++)
    {
      Node abc = new Node(0 * wdth + xpos, (j) * inputHeight + inputHeight/2);
      abc.setVal(random(-1.0,1.0));
      tmp1.add(abc);
      
    }
    brain.add(tmp1);
      
    for (int i = 1; i < numLayers; i ++)
    {
      int num = nodesPerLayer;
      //if (i == 1) num = inputLayerNum; 
      if (i == 1) num = inputLayerNum; 
      if (i == numLayers-1) num = outputNodesNum;
      ArrayList<Node> tmp = new ArrayList<Node>();
      for(int j = 0; j < num; j++)
      {
        tmp.add(new Node(i * wdth + xpos, j * hght + ypos));
      }
      
      
      
      println(num);
      for(int a = 0; a < brain.get(i-1).size(); a++)
      {
       ArrayList<Line> lineTmp = new ArrayList<Line>();
       ArrayList<Node> prev = brain.get(i-1);
       for (int b = 0; b < brain.get(i-2).size(); b++)
       {
         //if (a != b) 
         //println("=" + a + "," + b);
         lineTmp.add(new Line(tmp.get(a), prev.get(b)));
       }
       tmp.get(a).addLines(lineTmp);
      }
      brain.add(tmp); //######## redo? generate all nodes then link? Solves index oob issues.
      
      
    }
  }*/
  
  void doDraw()
  {
    for(ArrayList<Node> layer: brain)
    {
      for(Node node: layer)
      {
        node.doDraw();
      }
    } 
    for(ArrayList<Node> layer: brain)
    {
      for(Node node: layer)
      {
        node.doDraw2();
      }
    } 
    
    boolean tmp = false;
    if (tmp)
    {
      ArrayList<Node> inLayer = brain.get(0);
      ArrayList<Node> outLayer = brain.get(brain.size()-1);
      
      for(Node node: inLayer)
      {
        node.doDraw3();
      }
      for(Node node: outLayer)
      {
        node.doDraw3();
      }
    }
    
    
    
    
  }
  
  
  void doCalc()
  {
    for (int i = 1; i < brain.size(); i ++)//first layer is the input, therefore should not be calculated.
    {
      for (int j = 0; j < brain.get(i).size(); j++)
      {
       brain.get(i).get(j).doCalc(); 
      }
    }
  }
  
}

class Node
{
  ArrayList<Line> lines = new ArrayList<Line>(); //these are lines which connect to all node connected to this one. In a deep, fully connected neural network, this is the entire previous layer
  float x,y; //the location of this node, calculated by brain
  float val ; // this will be set once the calculation is finished
  float rawVal;
  float bias;
  int override = -1;
  Node(float x, float y, float val)
  {
    this.x = x;
    this.y = y;
    this.val = val;
    
  }
  
  Node clone(HashMap<Node,Node> hm)
  {
    Node ret = new Node(x,y,val);
    for(int i = 0; i < lines.size(); i++)
    {
      Line tmp = new Line(this.lines.get(i));
      ret.lines.add(tmp);
    }
    hm.put(this, ret);
    
    return ret;
  }
  void finishClone(HashMap<Node,Node> hm)
  {
    for (int i = 0; i < lines.size(); i++)
    {
     lines.get(i).fixLines(hm); 
    }
  }
  
  
  float size = 25;
  
  Node(float x, float y)
  {
    this.x = x;
    this.y = y;
    bias = makeBias();
  }
  void evolveNode()
  {
    bias = makeBias();
  }
  float makeBias()
  {
    //return 0;
    return random(-0.1f, 0.1);
  }
  void addLines(ArrayList<Line> lines)
  {
    this.lines = lines;
  }
  void setVal(float v)
  {
    //println("setting:" + v);
   val = v; 
   size = ((val + 1)/2) * 15 + 10;
   if (size > 50) size = 50;
   if (size < 0) size = 10;
  }
  void changeVal(float v)
  {
    val += v;
    
    //size = ((val + 1)/2) * 15 + 10;
    
    float act = activation(val, override);
    size = 10 + ((act+1)/2)*15;
  }
  
  void doCalc()
  {
    val = bias;
    for (Line line: lines)
    {
      //println(val);
       val += line.calc();
       
    }
    rawVal = val;
    
    val = activation(val, 0);
    
    //size = ((val + 1)/2) * 15 + 10;
    size = 10 + val*15;
    if (size > 50) size = 50;
    if (size < 0) size = 10;
    
  }
  void doDraw()
  {
    
   for (Line line: lines)
   {
     line.doDraw(); 
   }
   
  }
  void doDraw2()
  {
    stroke(255);
    float c = ((bias+1)/2) * 255;
    fill(255-c, c, 0);
    ellipse(x,y,size,size);
    doDraw3();
  }
  void doDraw3()
  {
   drawText( str(val), x, y);
   drawText( str(bias), x, y+25);
  }
  
}

class Line
{
  Node A; //the node the calling node wants information from
  Node B; //The node calling this line
  
  float weight; //the weight of this line
  
  float calc()
  {
    //println(A.val * weight);
    //println(B.val + "/\\" + weight + "\\/" + B.val * weight);
   return B.val * weight; 
   
  }
  
  void doDraw()
  {
    //strokeWeight(10);
    stroke(255 - (weight+1) * 128,   (weight+1) * 128, 0);
    line(A.x, A.y, B.x, B.y);
    //drawText(str(weight), (A.x + B.x)/2, (A.y + B.y)/2);
  }
  
  void fixLines(HashMap<Node,Node> hm)
  {
    this.A = hm.get(A);
    this.B = hm.get(B);
  }
  
  Line(Line old)
  {
   this.A = old.A;
   this.B = old.B;
   this.weight = old.weight;
  }
  
  Line(Node a, Node b)
  {
    A = a;
    B = b;
    weight = makeWeight();
  }
  Line(Node a, Node b, float wght)
  {
    A = a;
    B = b;
    weight = wght;
  }
  void evolveLine()
  {
    weight = makeWeight();
    /*boolean tmp = random(-1f, 1f) > 0;
    if (tmp) weight *= random(0f, 0.2f);
    else weight *= random(0f, -0.2f);*/
  }
  
}
