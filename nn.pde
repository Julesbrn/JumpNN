
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
   if (input < 0) return 0;
   else return input;
  }
  else
  {
   println("Something is wrong. input: " + input + " override: " + override);
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
    println("Something is wrong. makeWeight");
   return 0; 
  } 
}

void drawType(float x) 
{
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
        tmp.add(prev.get(j).clone(hm));
      }
      ret.brain.add(tmp);
    }
    
    for (int i = 0; i < brain.size(); i++)
    {
      ArrayList<Node> tmp = ret.brain.get(i);
      for (int j = 0; j < tmp.size(); j++)
      {
        tmp.get(j).finishClone(hm);
      }
    }
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
  
  void destroyBrain()
  {
    for (ArrayList<Node> b: brain)
    {
      for (Node n: b)
      {
        n.destroyNode();
        n = null;
      }
      b = null;
    }
    brain = null;
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
      Node abc = new Node((numLayers+1) * wdth + xpos, (i) * outputHeight + outputHeight/2);
      abc.setVal(random(-1.0,1.0));
      abc.override = 0;
      outputLayer.add(abc);
    }
    brain.add(outputLayer);
    
    //add all of the lines
    for (int i = 1; i < brain.size(); i ++)//for each layer in brain
    {
      
      ArrayList<Node> thisLayer = brain.get(i);
      ArrayList<Node> prevLayer = brain.get(i-1);
      for (int a = 0; a < thisLayer.size(); a++) //for each node in this layer
      {
        ArrayList<Line> lines = new ArrayList<Line>();
        for (int b = 0; b < prevLayer.size(); b++) //for nodes in previous layer
        {
          //create a link between these two
          lines.add(new Line(thisLayer.get(a), prevLayer.get(b)));
        }
        thisLayer.get(a).addLines(lines);
      }
    }
  }
  
  void evolve() //to evolve a brain we either evolve a node or a line. Nodes mutate their bias. Lines mutate their weight
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
  float size = 25;
  
  Node(float x, float y, float val)
  {
    this.x = x;
    this.y = y;
    this.val = val;
  }
  
  Node(float x, float y)
  {
    this.x = x;
    this.y = y;
    bias = makeBias();
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
  
  void evolveNode()
  {
    bias = makeBias();
  }
  
  float makeBias()
  {
    return random(-0.1f, 0.1);
  }
  
  void addLines(ArrayList<Line> lines)
  {
    this.lines = lines;
  }
  
  void setVal(float v)
  {
   val = v; 
   size = ((val + 1)/2) * 15 + 10;
   if (size > 50) size = 50;
   if (size < 0) size = 10;
  }
  
  void changeVal(float v)
  {
    val += v;
    
    float act = activation(val, override);
    size = 10 + ((act+1)/2)*15;
  }
  
  void doCalc()
  {
    val = bias;
    for (Line line: lines)
    {
       val += line.calc();
    }
    rawVal = val;
    
    val = activation(val, 0);
    
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
  
  void destroyNode()
  {
   for (Line l: lines)
   {
     l.destroyLine();
   }
   lines = null;
  }
}

class Line
{
  Node A; //the node the calling node wants information from
  Node B; //The node calling this line
  
  float weight; //the weight of this line
  
  
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
  
  float calc()
  {
   return B.val * weight; 
  }
  
  void doDraw()
  {
    stroke(255 - (weight+1) * 128,   (weight+1) * 128, 0);
    line(A.x, A.y, B.x, B.y);
  }
  
  void fixLines(HashMap<Node,Node> hm)
  {
    this.A = hm.get(A);
    this.B = hm.get(B);
  }
  
  void evolveLine()
  {
    weight = makeWeight();
  }
  
  void destroyLine()
  {
   A = null;
   B = null;
  }
}
