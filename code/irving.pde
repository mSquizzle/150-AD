//should pass
//expected output: M = {0,5}, {1,3},{2,4} 

int selectedExample = 0;

int[][] firstExample = {
                        {2, 3, 1, 5, 4},
                        {5, 4, 3, 0, 2},
                        {1, 3, 4, 0, 5},
                        {4, 1, 2, 5, 0},
                        {2, 0, 1, 3, 5},
                        {4, 0, 2, 3, 1}
                        };
                        
                      
//expected output: no stable matching
int[][] secondExample = {
                        {2,1,3},
                        {0,2,3},
                        {1,0,3},
                        {0,2,1}
                      };

//expected output: M = {0,1}, {2,3}
int[][] thirdExample = {
  {1,2,3},
  {0,2,3},
  {1,0,3},
  {0,1,2}
};


ArrayList<int[][]> examples = new ArrayList<int[][]>();

int[][] preferences;

int numParticipants;

int[] acceptedProposal;

int[][] listPoints;

boolean[] seen;

boolean[][] rejected;

int[][] rotation;

void execute(){
  initialize(); 
  boolean phaseOneSuccess = doPhaseOne();
  if(phaseOneSuccess){
    println("Made it through Phase 1 successfully!");
    boolean phaseTwoSuccess = doPhaseTwo();
    if(phaseTwoSuccess){
      printMatching();  
    }else{
      State finalState = new State();
      finalState.currentGrid = rejected;
      finalState.description = "Process failed in Phase 2";
      finalState.phase = 3;
      copyRotationsToState(rotation, finalState);
      finalState.acceptedProposals = acceptedProposal;
      states.add(finalState);
      println("No matching found after Phase 2!");
    }    
  }else{
    
      State finalState = new State();
      finalState.currentGrid = rejected;
      finalState.description = "Process failed in Phase 1";
      finalState.phase = 3;
      copyRotationsToState(rotation, finalState);
      finalState.acceptedProposals = acceptedProposal;
      states.add(finalState);
    println("No matching found after Phase 1!");
  }
}

void printMatching(){
  println("Here's the matching!");
  String description = "Matching = ";
  for(int i = 0; i < numParticipants; i++){
    int matchIndex = listPoints[i][0];
    int matchValue = preferences[i][matchIndex];
    println("Pair: "+i+" with "+matchValue);
    if(i < matchValue){
      description += "{"+i+", "+matchValue+"} ";  
    }
  }
  State finalState = new State();
  finalState.currentGrid = rejected;
  finalState.description = description;
  finalState.phase = 3;
  copyRotationsToState(rotation, finalState);
  finalState.acceptedProposals = acceptedProposal;
  states.add(finalState);
}


void initialize(){
 examples.add(firstExample);
 examples.add(secondExample);
 examples.add(thirdExample);
 if(selectedExample < 0){
   selectedExample = -1 * selectedExample;
 }
 if(selectedExample >= examples.size()){
   selectedExample = selectedExample % examples.size();
 }
 preferences = examples.get(selectedExample);
 numParticipants = preferences.length;
 acceptedProposal = new int[numParticipants];
 listPoints = new int [numParticipants][3];
 seen = new boolean[numParticipants];
 rejected = new boolean[numParticipants][numParticipants-1];
 
  rotation = new int[2][numParticipants+1];
  for(int i = 0 ; i < rotation[0].length; i++){
    rotation[0][i] = -1;
    rotation[1][i] = -1;
  }
  states = new ArrayList<State>();
  previousStates = new ArrayList<State>();
  currentState = new State();
  currentState.phase = 0;
  currentState.currentGrid = new boolean[numParticipants][numParticipants-1];
  for(int i = 0; i < numParticipants; i++){
    acceptedProposal[i] = -1;
    listPoints[i][0] = 0;
    listPoints[i][1] = 1;
    listPoints[i][2] = numParticipants - 2;
    for(int j = 0; j < numParticipants-1; j++){
      rejected[i][j] = false;  
      currentState.currentGrid[i][j] = false;
    }
  } 
  rotation = new int[2][numParticipants+1];
  for(int i = 0; i < rotation[0].length; i++){
     rotation[0][i] = -1;
     rotation[1][i] = -1;
   } 
  copyRotationsToState(rotation, currentState);
  println("Initializing the problem!");
}

boolean doPhaseOne(){
  ArrayList<Integer> proposers = new ArrayList<Integer>(numParticipants);
  for(int i = 0; i < numParticipants; i++){
    proposers.add(i);
  }
  println("Performing Phase 1");
  boolean noEmptyLists = true;
  while(!proposers.isEmpty() && noEmptyLists){
    int nextProposer = proposers.get(0);
    proposers.remove(0);
    int i = listPoints[nextProposer][0]; 
    boolean keepProposing = true;
    println(nextProposer+" - "+ i +" - " + listPoints[nextProposer][2]);
    while(i <= listPoints[nextProposer][2] && keepProposing && noEmptyLists){
      int y = preferences[nextProposer][i];
      boolean accepted = propose(nextProposer,y);
      if(accepted){
        keepProposing = false;
        if(acceptedProposal[y] > -1){
          //we're ousting someone, reject and make them the next proposer
          int rejectee = acceptedProposal[y];
          proposers.add(0, rejectee);
          noEmptyLists = reject(y, rejectee, 1);
        }
        acceptedProposal[y] = nextProposer;
        State newState = saveBaseState();
        
        newState.firstHighlight = nextProposer;
        newState.firstIndex = listPoints[nextProposer][0];
  
        newState.phase = 1;
        newState.description = y + " accepts proposal from "+nextProposer;
        states.add(newState);
      }else{
        keepProposing = true;
        noEmptyLists = reject(y, nextProposer, 1);
      }
      i++;
    }
  }
  println("Completed Phase 1");
  println("No empty lists? "+noEmptyLists);
  if(noEmptyLists){
    noEmptyLists = trimLists(); 
    println("List trim successful? "+noEmptyLists);
  }
  return noEmptyLists;
}

State saveBaseState(){
  State newState = new State();
  newState.currentGrid = new boolean[numParticipants][numParticipants-1];
  newState.acceptedProposals = new int[numParticipants];
  for(int j = 0; j < numParticipants; j++){
    newState.acceptedProposals[j] = acceptedProposal[j];
    for(int k = 0; k < numParticipants -1; k++){
      newState.currentGrid[j][k] = rejected[j][k];    
    }
   }
  copyRotationsToState(rotation, newState);
  return newState;
}

void copyRotationsToState(int[][] rotations, State state){
  int[][] localRot = new int[2][numParticipants+1];
  if(rotation != null){
    for(int i = 0; i < numParticipants+1; i++){
      localRot[0][i] = rotations[0][i];
      localRot[1][i] = rotations[1][i];
    }  
  }else{
    for(int i = 0; i < numParticipants+1; i++){
      localRot[0][i] = -1;
      localRot[1][i] = -1;
    }
  }
  
  state.rotation = localRot; 
}

boolean trimLists(){
  boolean noFailedReject = true;
  State saveState = saveBaseState();
  saveState.phase = 1;
  saveState.highlightAcceptedProposals = true;
  saveState.description = "Reject anyone after accepted proposal";
  states.add(saveState);
  for(int i = 0; i < numParticipants; i++){
    if(!hasSingleElement(i)){
      int proposal = acceptedProposal[i];
      int propRank = findRank(proposal, i);
      for(int j = propRank + 1; j < numParticipants - 1; j++){
        int rejectee = preferences[i][j];
        noFailedReject = noFailedReject && reject(i, rejectee, 1);  
      }  
    }else{
       println(i+" has a single element, so we're skipping!"); 
    }
  } 
  return noFailedReject;
}

//todo - replace with ranking matrix lookup - this is just silly
//returns the ranking of the value in the member's preference list
//if val is not in member's preference list, returns -1
int findRank(int val, int member){
  int rank = -1;
  for(int i = 0; i < numParticipants - 1; i++){
    if( val == preferences[member][i]){
      rank = i;  
    }
  }
  return rank;
}

//returns true if the proposal is accepted and false otherwise
boolean propose(int x, int y){
  int rankX = findRank(x, y);
  State newState = saveBaseState();
  newState.firstHighlight = x;
  newState.firstIndex = listPoints[x][0];
  newState.phase = 1;
  newState.description = x + " proposes to "+y;
  states.add(newState);
  
  if(acceptedProposal[y] < 0){
    //automatically accept the first proposal offered
    println("there is no preference, "+y+" accepts "+x+"'s proposal"); 
    return true;
  }else{
    if(!rejected[rankX][y]){
    //check the rank of the current accepted proposer vs the new proposer
    int acceptedPropY = acceptedProposal[y];
    int rankPropY = findRank(acceptedPropY, y);
    boolean accepted = rankX < rankPropY;
    println(x+"'s rank: "+rankX);
    println(acceptedPropY+"'s rank: "+rankPropY);
    println(y+" accepts "+x+"'s proposal? "+accepted);
    return accepted;
    }else{
      //x and y have rejected each other at some earlier point and we should skip
      println(x+" and "+y+" have already rejected eachother.");
    }
    return false;
  }
}

//returns true if there are no empty lists as a result of this rejection 
boolean reject(int x, int y, int phase){
  int rankX = findRank(x,y);
  int rankY = findRank(y,x);
  
  rejected[x][rankY] = true;
  rejected[y][rankX] = true;
  
  //adjust the pointers for x
  boolean xEmpty = isEmpty(x);
  boolean yEmpty = isEmpty(y);
  
  println(x+" becomes empty "+xEmpty);
  println(y+" becomes empty "+yEmpty); 
  
  boolean emptyList = xEmpty || yEmpty;
  
  //adjust the pointers only if we didn't reject the last element in either list
  if(!emptyList){
    adjustListPointers(rankY, x);
    adjustListPointers(rankX, y);  
  }
  State newState = saveBaseState();
  newState.firstHighlight = x;
  newState.firstReject = rankY;
  newState.secondHighlight= y;
  newState.secondReject = rankX;
  newState.phase = phase;
  newState.description = x +" rejects "+y;
  states.add(newState);
  return !emptyList;
}

void adjustListPointers(int rank, int member){ 
  println("Checking to see if we need to adjust "+member+"'s pointers as we just rejected the element at "+rank);
  boolean firstChanges = rank == listPoints[member][0];
  boolean secondChanges = (firstChanges && listPoints[member][0] == listPoints[member][1] - 1)|| rank == listPoints[member][1];
  boolean lastChanges = rank == listPoints[member][2]; 
  if(firstChanges){
    listPoints[member][0] = listPoints[member][1];  
    println("adjusted "+member+"'s first pointer to "+listPoints[member][1]);
  }
  int second = listPoints[member][1];
  int last = listPoints[member][2];
  if(secondChanges){
    if(second != last){
        int i = second+1;
        boolean reject = true;
        while(i < last && reject){
          reject = rejected[member][i];
          if(reject){
            i++;  
          }
        }
        println("adjusted "+member+"'s second pointer to "+i);
        listPoints[member][1] = i;
    }
  }
  if(lastChanges){
    if(last != listPoints[member][0]){
      int i = last;
      boolean reject = true;
      while(last > second && reject){
        i--;
        reject = rejected[member][i];  
      }
      println("adjusted "+member+"'s last pointer to "+i);
      listPoints[member][2] = i;
    }  
  }
}

//also not performant
boolean isEmpty(int i){
  for(int j = 0; j< numParticipants -1; j++){
    if(!rejected[i][j]){
      return false;  
    }
  }
  return true;  
}

boolean hasSingleElement(int i){
  int count = 0;
  for(int j = 0; j < numParticipants-1; j++){
    if(!rejected[i][j]){
      count++;
    }
  }
  return count == 1;
//  return listPoints[i][0] == listPoints[i][1];
}

boolean doPhaseTwo(){  
 println("Performing Phase 2");
 boolean phaseTwoSuccess = true;
 boolean keepGoing = true;
 int index = 0;
 
   State state = saveBaseState();
   state.phase = 2;
   state.description = "Start Phase 2";
   states.add(state);
 while(keepGoing && index <= numParticipants){
   if(index == numParticipants){
     keepGoing = false;
     continue;
   }
   if(hasSingleElement(index)){
     println(index+" has only a single element, finding a different rotation candidate");
     index++;
     continue;  
   }
   
   //detect the cycle
   int[] alreadySeen = new int[numParticipants];
   int start = 0;
   int end = 0;
   rotation = new int[2][numParticipants+1];
   for(int i = 0; i < rotation[0].length; i++){
     rotation[0][i] = -1;
     rotation[1][i] = -1;
   }
  
   int p = index;
   rotation[0][0] = p;
   state = saveBaseState();
   state.phase = 2;
   state.firstHighlight = p;
   state.description = "Detecting rotation";
   
   int secondPointer = listPoints[p][1];
   int q = preferences[p][secondPointer];
   state.firstIndex = secondPointer;
   states.add(state);
   rotation[1][0] = q;
   state = saveBaseState();
   state.firstHighlight = q;
   copyRotationsToState(rotation,state);
   state.phase = 2;
   state.description = "Detecting rotation";
   int lastIndex = listPoints[q][2];
   state.firstIndex = lastIndex;
   states.add(state);
   p = preferences[q][lastIndex];
   boolean noRepeatElement = true;
   int i = 1;
   while(noRepeatElement){
     if(alreadySeen[p] == 0 && rotation[0][0] != p){
       alreadySeen[p] = i;
       rotation[0][i] = p;
       state = saveBaseState();
       state.firstHighlight = p;
       state.phase = 2;
       state.description = "Detecting rotation";
       secondPointer = listPoints[p][1];
       state.firstIndex = secondPointer;
       states.add(state);
       q = preferences[p][secondPointer];
       rotation[1][i] = q;
       state = saveBaseState();
       copyRotationsToState(rotation,state);
       state.phase = 2;
       state.firstHighlight = q;
       state.description = "Detecting rotation";
       lastIndex = listPoints[q][2];
       state.firstIndex = lastIndex;
       states.add(state);
       println("p "+p);
       println ("q "+q);
       p = preferences[q][lastIndex];
       i++;
     }else{
       noRepeatElement = false;
     end = i;
     start = alreadySeen[p];
   }
   } 
   rotation[0][i] = p;
   secondPointer = listPoints[p][1];
   state = saveBaseState();
   state.firstHighlight=p;
   copyRotationsToState(rotation,state);
   state.phase = 2;
   state.description = "Detecting rotation";
   states.add(state);
   q = preferences[p][secondPointer];
   //rotation[1][i] = q;
   state = saveBaseState();
   copyRotationsToState(rotation,state);
   state.phase = 2;
   state.description = "Rotation detected";
   state.rotationStart = start;
   state.rotationEnd = end;
   states.add(state);
   println("Finished computing the cycle");
   
   for(int j = 0; j <=end; j++){
     print(rotation[0][j]+" "); 
   }
   println("");
   for(int j = 0; j <=end; j++){
     print(rotation[1][j]+" ");
   }
 
   boolean noEmptyList = true;
   //reduce the cycle the cycle
   State lastState = null;
   for(i = start; i < end; i++){
     p = rotation[0][i+1];
     q = rotation[1][i];
     noEmptyList = noEmptyList && reject(q, p, 2);
     lastState = states.get(states.size()-1);
     lastState.rotationEnd = end;
     lastState.rotationStart = start;
     lastState.rotationHighlight = i;
   }
   if(lastState != null){
     State finalState = saveBaseState();
     finalState.description = "Rotation elimination complete";
     finalState.phase = 2; 
     finalState.rotationEnd = end;
     finalState.rotationStart = start;
     finalState.rotationHighlight = end+1;
     states.add(finalState);
   }
   if(!noEmptyList){
     println("Empty list detected - stopping phase 2!");
     keepGoing = false;  
   }
   //keepGoing = false;
 }
 //if the index is more than the number of participants 
 //that means they've all been reduced to single lists
 phaseTwoSuccess = index == numParticipants;
 println("Completed Phase 2"); 
 return phaseTwoSuccess;
}


PFont f;   

ArrayList<State> states = new ArrayList<State>();
ArrayList<State> previousStates = new ArrayList<State>();
State currentState;

class State{
  boolean[][] currentGrid;
  int phase;
  int firstHighlight = -1;
  int firstIndex = -1;
  int secondHighlight = -1;
  int secondIndex = -1;
  int firstReject = -1;
  int secondReject = -1;
  String description;
  
  int[][] rotation;
  int rotationEnd = -1;
  int rotationStart = -1;
  int rotationHighlight = -1;
  
  int[] acceptedProposals;
  boolean highlightAcceptedProposals = false;
}

void setup(){
  size(350, 375);
  noLoop();
  execute();
  f = createFont("Arial",16,true);
}

void keyPressed(){
    if(keyCode == LEFT){
      if(!previousStates.isEmpty()){
        states.add(0, currentState);
        currentState = previousStates.remove(previousStates.size()-1);
      }
    }else if (keyCode == RIGHT){
      if(!states.isEmpty()){
        previousStates.add(currentState);
        currentState = states.remove(0);
      }
    }else if (keyCode >= 0){
      selectedExample = keyCode;
      setup();
    }else{
      println("unsupported keycode entered, try better next time!");
    }
  redraw();  
}

void draw(){
  background(255);
  textFont(f,16);                  
  fill(0);
  if(currentState != null){
    drawState(); 
  }
}

void drawState(){
  textAlign(CENTER);
  text("Preference Lists", numParticipants*15 + 15, numParticipants * 30 + 25);
  for(int i = 0; i < numParticipants; i++){
    fill(255);  
    rect(15,i*30 + 15, 20, 20);
    fill(0);
    text(i, 25, i*30 + 30);
    for(int j = 0; j < numParticipants-1; j++){
     if(currentState.currentGrid[i][j]){
       fill(20);
     }else{
       fill(150);
     }
     rect(45+j*30, 15+i*30, 20, 20);
     if(currentState.currentGrid[i][j]){
       fill(70);
     }else{
       fill(0);
     }
     text(preferences[i][j], 55+j*30, i*30+30);    
   }
 }
 int i = currentState.firstHighlight;
 if(i >= 0){
    fill(99,195,255);
    rect(15,i*30 + 15, 20, 20);
    fill(0);
    text(i, 25, i*30 + 30);
    if(currentState.firstIndex >= 0){
      fill(204,102,255);
      rect(45+currentState.firstIndex*30,i*30 + 15, 20, 20);
      fill(0);
     text(preferences[i][currentState.firstIndex], 55+currentState.firstIndex*30, i*30+30);      
    }
    
    if(currentState.firstReject >= 0){
      fill(255,0,0);
      rect(45+currentState.firstReject*30,i*30 + 15, 20, 20);
      fill(0);
      text(preferences[i][currentState.firstReject], 55+currentState.firstReject*30, i*30+30);      
    }
 }
 i = currentState.secondHighlight;
 if(i >= 0){
    fill(201, 234, 255);
    rect(15,i*30 + 15, 20, 20);
    fill(0);
    text(i, 25, i*30 + 30);
    if(currentState.secondIndex >= 0){
      fill(204,102,255);
      rect(45+currentState.secondIndex*30,i*30 + 15, 20, 20);
      fill(0);
      text(preferences[i][currentState.secondIndex], 55+currentState.secondIndex*30, i*30+30);  
    }
    if(currentState.secondReject >= 0){
      fill(255,166,166);
      rect(45+currentState.secondReject*30,i*30 + 15, 20, 20);
      fill(0);
      text(preferences[i][currentState.secondReject], 55+currentState.secondReject*30, i*30+30);      
    }
 }
 
 //draw in the accepted proposals
 for(int j = 0; j < numParticipants; j++){
   if(currentState.phase > 1){
    fill(100);
  }else{
    fill(255);
  }
  rect(45 + (numParticipants+3)*30,j*30 + 15, 20, 20);  
  fill(0);
  if(currentState.acceptedProposals != null && currentState.acceptedProposals[j] >= 0){
    text(currentState.acceptedProposals[j], 55 + (numParticipants+3)*30, j*30+30);    
  }
 }
  pushMatrix();
  translate(30 + (numParticipants+3)*30, numParticipants*15 + 15);
  rotate(-HALF_PI);
  text("Acccepted Proposals", 0,0);
  popMatrix();
 //text("Acccepted Proposals", 55 + (numParticipants+3)*30, numParticipants*15 + 30);
 
 //draw in the rotation table
  if(currentState.rotation != null){
    for(int j = 0; j < numParticipants + 1; j++){
      fill(255);
      if(currentState.phase > 2){
       fill(100); 
      }
      rect(15 + j*30, 260, 20, 20);
      rect(15 + j*30, 290, 20, 20);
      if(currentState.rotation[0][j] >= 0){
        fill(0);
        text(currentState.rotation[0][j], 25 + j*30, 275); 
      }
      if(currentState.rotation[1][j] >= 0){
        fill(0);
        text(currentState.rotation[1][j], 25 + j*30, 305);
       }
    }
    
     
     if(currentState.rotationStart >= 0 && currentState.rotationEnd >= 0){
       for(int j = currentState.rotationStart; j < currentState.rotationEnd; j++){
           fill(0,255,0);
           rect(15 + (j+1)*30, 260, 20, 20);
           rect(15 + j*30, 290, 20, 20);
           fill(0);
           text(currentState.rotation[0][j+1], 25 + (j+1)*30, 275);
           text(currentState.rotation[1][j], 25 + j*30, 305);
       }
       if(currentState.rotationHighlight >= 0){
           for(int j = currentState.rotationStart; j < min(currentState.rotationHighlight, currentState.rotationEnd); j++){
             fill(0,100,0);
             rect(15 + (j+1)*30, 260, 20, 20);
             rect(15 + j*30, 290, 20, 20);
             fill(0);
             text(currentState.rotation[0][j+1], 25 + (j+1)*30, 275);
             text(currentState.rotation[1][j], 25 + j*30, 305);
           }
           
           int j = currentState.rotationHighlight;
           
           if(j < currentState.rotationEnd){
             fill(255,255,0);
             rect(15 + (j+1)*30, 260, 20, 20);
             rect(15 + j*30, 290, 20, 20);
             fill(0);
             text(currentState.rotation[0][j+1], 25 + (j+1)*30, 275);
             text(currentState.rotation[1][j], 25 + j*30, 305);
           }
       }else{
         for(int j = currentState.rotationStart; j < currentState.rotationEnd; j++){
           fill(0,255,0);
           rect(15 + (j+1)*30, 260, 20, 20);
           rect(15 + j*30, 290, 20, 20);
           fill(0);
           text(currentState.rotation[0][j+1], 25 + (j+1)*30, 275);
           text(currentState.rotation[1][j], 25 + j*30, 305);
         }  
       }
     }
  }
  fill(0);
  text("Rotations", 15 + (numParticipants + 1)*15, 250);
 
 String phaseDesc = "Phase: ";
 if(currentState.phase == 0){
   phaseDesc+= "Unstarted";
 }else if(currentState.phase == 1){
   phaseDesc += 1;
   //draw out the proposal tables
 }else if(currentState.phase == 2){
   phaseDesc += 2;
   //fade the proposal table
   //draw the cycle search and highlight! 
 }else{
   phaseDesc += "Complete";
 }
  
 text(phaseDesc, width/2, height-26);
 if(currentState.description!=null){
   text(currentState.description, width/2, height-10);  
 }
}