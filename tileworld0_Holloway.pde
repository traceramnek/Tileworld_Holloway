/**
 * tileworld0.pde
 *
 * This program simulates a simplified version of the class TileWorld.
 * Updated and modified by Kwan Holloway, Spring 2016
 *
 */

/*Global Variables*/
int min_x = 0;
int min_y = 0;
int max_x = 400;
int max_y = 600;
int grid_size = 10;
int numObjs = 150;
int totalObjs = numObjs * 3 + 1;
int direction;
int dollars = 0;

PVector agent;
PVector holes [] = new PVector[numObjs]; 
PVector tiles [] = new PVector[numObjs];
PVector obstacles [] = new PVector[numObjs];
PVector locArray [] = new PVector[totalObjs];
int obstLocs[][] = new int[max_x+1/grid_size][max_y+1/grid_size];

//consts for the 4 directions
final int NORTH = 0, EAST = 1, SOUTH = 2, WEST = 3;

// agent state variables
final int STOPPED = 0;
final int RUNNING = 1;
int agentState = STOPPED;
boolean agentLiving = true;

//Agent's sensor ranges 1.2
int hSensorRange = 2; //hole sensor
int tSensorRange = 1; // tile sensor
int oSensorRange = 2; // obstacle sensor
  
 //Agent's Sensor Arrays
 // # 1.2
 int sensorsLength = 4;
 int holeSensors[] = new int [sensorsLength];
 int tileSensors[] = new int [sensorsLength];
 int obstSensors[] = new int [sensorsLength];

void settings(){
size( max_x, max_y );

}

/**
 * setup()
 * this function is called once, when the sketch starts up.
 *
 */
void setup() {
  settings();
  ellipseMode( CORNER );
  agentState = RUNNING;
  populate();
} // end of setup()

/** Populates the various collections with locations 
* Also gives the agent a location
* Populates the obstLocs Array
* # 1.1
*/
void populate(){ ///1.1
  //give agent random location
  agent = getNewLoc(holes,holes.length);
  
  //populate holes array
  for(int i = 0; i < numObjs; i++){
    holes[i] = getNewLoc(holes, holes.length); 
  }
  //populate tiles array
  for(int i = 0; i < numObjs; i++){
    tiles[i] = getNewLoc(tiles, tiles.length);
  }
  // populate obstacles array
  for(int i = 0; i < numObjs; i++){
    obstacles[i] = getNewLoc(obstacles, obstacles.length);
  }   
  
  // populate sensor arrays
  for(int i = 0; i < sensorsLength; i++){
    holeSensors[i] = 0;
    tileSensors[i] = 0;
    obstSensors[i] = 0;
  } 

}

/**Returns a new location that is unique 
* # 1.1
*/
PVector getNewLoc(PVector [] arr, int arrSize){
  PVector temp = getRandomLoc();
  //while it's not unique, try a new loc
  while(isLocUsed(temp,arr,arrSize)){
    temp = getRandomLoc();
  }
  //otheriwse return the unique location
  return temp;
}

/** Checks to see if a location exists in the given collection
* # 1.1
*/
boolean isLocUsed(PVector randLoc, PVector [] tempArr, int tempSize){
  //check for randLoc
  for(int i = 0; i < tempSize; i++){
    if(tempArr[i] == randLoc){
      //retun true if location is used
      return true;
    }
  }
  //if location is unique
  return false;
}

// Determines if a pvector is in a pvector array
//# 1.2
boolean isInPVector(PVector [] arr, PVector vec, int size){
  for(int i = 0; i < size; i++){
    if(arr[i].equals(vec)){
     return true; 
    }
  }
  return false;
}

// returns a PVector corresponding that is in the direction specified by
// direc's value and mpy's value
//# 1.2
PVector getCardinalCoor(int agentX, int agentY, int direc, int mpy){
  PVector tempCoor;
  if(direc == NORTH){//north
    if(agentY-(mpy*grid_size) < min_y) {
       agentY = max_y - grid_size;
    }
    return new PVector(agentX,agentY-(mpy*grid_size));
  }
   if(direc == EAST){//east
   if(agentX+(mpy*grid_size) >= max_x) {
      agentX = min_x;
    }
    return new PVector(agentX+(mpy*grid_size),agentY);
  }
   if(direc == SOUTH){//south
   if(agentY+(mpy*grid_size) >= max_y) {
      agentY = min_y;
    }
    return new PVector(agentX,agentY+(mpy*grid_size));
  }
   if(direc == WEST){//west
   if(agentX-(mpy*grid_size) < min_x) {
      agentX = max_x - grid_size;
    }
    return new PVector(agentX-(mpy*grid_size),agentY);
  }
  return new PVector(agentX,agentY);
}

//Checks to see if there is a hole/tile/obst on all sides of the agent
//uses a nested for to check if there is a hole/tile/obst ina given direction
// # 1.2
void perceiveCollection(PVector [] arr, int [] sensors, int senseRange){
  PVector temp;
  for(int i = 1; i <= senseRange; i++){//range specified by parameter
    for(int j = 0; j < 4; j++){// 4 directions
      temp = getCardinalCoor((int)agent.x,(int)agent.y,j,i); 
      if(isInPVector(arr,temp,numObjs)){
        //use 1 because it treats an object that's far as being right next to the agent 
        //so it doesn't go that way
         sensors[j] = i;
      }
    }
  }
}

//Let's Agent perceive the area around of it
//calls another fucntion that actually does the perceiving
// # 1.2
void perceive(){
  //set all sensors to 0 before checking again
  for(int i = 0; i < sensorsLength; i++){
    holeSensors[i] = 0;
    tileSensors[i] = 0;
    obstSensors[i] = 0;
  }
  
  perceiveCollection(holes,holeSensors,hSensorRange);
  perceiveCollection(tiles,tileSensors,tSensorRange);
  perceiveCollection(obstacles,obstSensors,oSensorRange);
  
}

//Return random int between 0 and 4
//the numbers will correspond to the NORTH, EAST, SOUTH, and WEST defined above
// # 1.3
int getDirection(){
  return (int)random(0,4);
}

/**
* Determines if the agent is alive or not by checking if it shares it's location with a hole
* # 1.4
*/
boolean isAlive(){
  if(isInPVector(holes,agent,holes.length)){
    //agent is dead
    agentLiving = false;
    return false;
  }
  return true;
}

// 4 functions that move the agent in the sorresponding direction
// # 1.5
void moveNorth(){
  
  agent.y -= grid_size;
    if ( agent.y < min_y ) {
      agent.y = max_y - grid_size;
    }
}
void moveEast(){
  
  agent.x += grid_size;
    if ( agent.x > max_x ) {
      agent.x = min_x;
    }
}
void moveSouth(){
  agent.y += grid_size;
    if ( agent.y > max_y ) {
      agent.y = min_y;
    }
}
void moveWest(){
  agent.x -= grid_size;
    if ( agent.x < min_x ) {
      agent.x = max_x - grid_size;
    }
}

// Determines if a pvector is in a pvector array
// if it is in the array, it retuns the index
//# 1.6
int whereInPVector(PVector [] arr, PVector vec, int size){
  for(int i = 0; i < size; i++){
    if(arr[i].equals(vec)){
     return i; 
    }
  }
  return -1;
}
// Deletes an object from the specified collection
// # 1.6
void deleteObj(PVector [] arr, int index, int size){
  for (int i = index; i < size-1; i++){
        arr[i] = arr[i+1];
  }
    size--;
}

// Moves the agent in a specified direction
// # 1.6
void moveInDirection(int direction){
  if(direction == NORTH){
    moveNorth();
  }
  if(direction == EAST){
    moveEast();
  }
  if(direction == SOUTH){
    moveSouth();
  }
  if(direction == WEST){
    moveWest();
  }
}

/**
* Deals with the logic of moving tiles inspecific cases
* # 1.6
*/
void pushTiles(int direction){
  int indexTile;
  int indexHole;
  PVector tempObj;
  PVector tempT;
  //tempObj is the spot 2 away from the agent
  tempObj = getCardinalCoor((int)agent.x,(int)agent.y,direction,2);
  //tempT is spot directly nextagent
  tempT = getCardinalCoor((int)agent.x,(int)agent.y,direction,1);
  
  if(isInPVector(tiles,tempObj,numObjs) || isInPVector(obstacles,tempObj,numObjs)){
    //if tempObj is a tile or obst, don't do anything
    //do nothing, agent can't push tile
     return;
  }
  //if tempObj is a hole, push the tile into the hole
  if(isInPVector(holes,tempObj,numObjs)){
    //determine which hole we're dealing with
    indexHole = whereInPVector(holes,tempObj,numObjs);
    //determine which tile we're dealing with
    indexTile = whereInPVector(tiles,tempT,numObjs);
    //move agent in direction
    moveInDirection(direction);
    //delete that tile
    deleteObj(tiles, indexTile,numObjs);
    //increment dollars
    dollars++;
    println("Agent's Dollars so far: " + dollars);
    return;
  }
  // there's a tile ahead of the agent
  // But there's nothing 2 spots ahead of the agent(tile/hole/obst)
  // Then just move the tile
  else{
    //determine which tile are we dealing with
    indexTile = whereInPVector(tiles,tempT,numObjs);
    //move that tile 1 forward
    tiles[indexTile].set(tempObj.x,tempObj.y);
    //agent moves forward
    moveInDirection(direction);
    return;
  }
}

/**
* Makes a move depending on the direction chosen and by perceiving
*# 1.3, 1.5, 1.6
*/
void makeMove(int direction){
  //int direction = getDirection();
  //perceive();
  switch( direction ) {
  case NORTH: // north 
    
    if(obstSensors[NORTH] >= 1 || holeSensors[NORTH] >= 1){
       //don't move
       break;
    }
    if(tileSensors[NORTH] == 1){
      pushTiles(NORTH);
      break;
    }
    moveNorth();
    break;
  case WEST: // west  
    if(obstSensors[WEST] >= 1 || holeSensors[WEST] >= 1){
       //don't move     
       break;
    }
    if(tileSensors[WEST] == 1){
      pushTiles(WEST);
      break;
    }
    moveWest();
    break;
  case SOUTH: // south
    if(obstSensors[SOUTH] >= 1 || holeSensors[SOUTH] >= 1){
       //don't move    
       break;
    }
    if(tileSensors[SOUTH] == 1){
      pushTiles(SOUTH);
      break;
    }
    moveSouth();
    break;
  case EAST: // east
    if(obstSensors[EAST] >= 1 || holeSensors[EAST] >= 1){
       //don't move    
       break;
    }
    if(tileSensors[EAST] == 1){
      pushTiles(EAST);
      break;
    }
    moveEast();
    break;
  } // end of switch
}// end of makeMove


/**
 * getRandomLoc()
 * this function returns a new PVector set to a random discrete location
 * in the grid.
 */
PVector getRandomLoc() {
  return( new PVector(
  ((int)random(min_x,max_x+1)/grid_size)*grid_size,
  ((int)random(min_y,max_y+1)/grid_size)*grid_size ));
} // end of getRandomLoc()


/**
 * draw()
 * this function is called by the Processing "draw" loop,
 * i.e., every time the display window refreshes.
 */
void draw() { 
  
  
  // draw grid for TileWorld
  background( #ffffff );
  stroke( #cccccc );
  for ( int x=min_x; x<=max_x; x+=grid_size ) {
    line( x,min_y,x,max_y );
  }
  for ( int y=min_y; y<=max_y; y+=grid_size ) {
    line( min_x,y,max_x,y );
  }
  // draw obstacle
  stroke( #cccccc );
  fill( #cccccc );
  for(int i = 0; i < obstacles.length; i++){
    rect( obstacles[i].x, obstacles[i].y, grid_size, grid_size );
  }
  // draw hole
  stroke( #cccccc );
  fill( #000000 );
  for(int i = 0; i < holes.length; i++){
    rect( holes[i].x, holes[i].y, grid_size, grid_size );
  }
  // draw tile
  stroke( #cccccc );
  fill( #cc00cc );
  for(int i = 0; i < tiles.length; i++){
    rect( tiles[i].x, tiles[i].y, grid_size, grid_size );
  }
  noFill();
  // draw agent
  if ( agentState == RUNNING ) {
    //makeRandomMove();
    direction = getDirection();
    makeMove(direction);
    delay(100); //slows down movement of agent so you can see where it's going
  }
  stroke( #0000ff );
  fill( #0000ff );
  ellipse( agent.x, agent.y, grid_size, grid_size );
  
  //let the agent perceive it's environment
  perceive();
  
  //Ends game is agent is dead
  if(isAlive() == false){
   println("The Agent has died! Click the mouse to begin a new game!");
   background(0);
   noLoop();
  }
} // end of draw()

/**
 * mouseClicked()
 * this function responds to "mouse click" events.
 */
void mouseClicked() {
  if ( agentState == STOPPED ) {
    agentState = RUNNING;
  }
  else {
    agentState = STOPPED;
  }
  
  if(agentLiving == false){
    dollars = 0;
    agentState = RUNNING;
    agentLiving = true;
    agent = getNewLoc(holes,holes.length);
    //continue drawing
    loop();
  }
} // end of mouseClicked()

/**
 * makeRandomMove()
 * this function causes the agent to move randomly (north, south, east or west).
 * if the agent reaches the edge of its world, it wraps around.
 */
void makeRandomMove() {
  int direction = (int)random( 0,4 );
  switch( direction ) {
  case 0: // north
    
    agent.y -= grid_size;
    if ( agent.y < min_y ) {
      agent.y = max_y - grid_size;
    }
    break;
  case 1: // west
    agent.x -= grid_size;
    if ( agent.x < min_x ) {
      agent.x = max_x - grid_size;
    }
    break;
  case 2: // south
    agent.y += grid_size;
    if ( agent.y > max_y ) {
      agent.y = min_y;
    }
    break;
  case 3: // east
    agent.x += grid_size;
    if ( agent.x > max_x ) {
      agent.x = min_x;
    }
    break;
  } // end of switch
} // end of makeRandomMove()