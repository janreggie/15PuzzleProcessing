import java.util.Random;
//import javax.swing.JOptionPane.*;

/*
15 Puzzle
Released under CC0 1.0 Universal

Coordinates:
01 02 03 04
05 06 07 08
09 10 11 12
13 14 15 00

Game of 15 puzzle.
[x] IS Functional
[X] Can choose to open image to create 15 tile game of.
[ ] Has animation (will be done in 1.1 patch)
[X] Views data about game
[x] Makes sure that game is solvable (https://www.cs.bham.ac.uk/~mdr/teaching/modules04/java2/TilesSolvability.html)
*/


PImage mainImage; // Image opened
PFont font; // font of entire game
String customImage; // directory of custom image
boolean isCustomLoaded = false; // if custom image is loaded
int[] tilePerm = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}; // tile permutation
int[] perfectPerm = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
Tile[] tileArr = new Tile[16];
int moveCount = 0;
int[] currentPerm = new int[16];

class Tile {
  PImage tileImg;
  int tileInt; // 1 to 16 (16 is blank) according to image
  int x1, y1; // tile image coordinates (translated to 400x400 play area) (from the PImage image)
  int realPos; // real position of tile during gameplay (1 to 16)
  int x2, y2; // tile image coordinates, depending on realPos i.e. position during gameplay
  Tile (int pos) {
    tileInt = pos;
    x1 = 100*((pos-1)%4);
    y1 = 100*((pos-1)/4);
    tileImg = mainImage.get(x1,y1,100,100);
  }
  void displayImage() {
    // display the image cropped to 100x100 (according to 400x400 board)
    // depending on realPos
    x2 = 100*((realPos-1)%4);
    y2 = 100*((realPos-1)/4);
    image(tileImg,x2,y2);
  }
}

void setup() {
  font = createFont("Font.otf", 10); // Font of the app
  currentPerm = new int[16];
  size(680, 610);
  moveCount = 0;
  // initialise tilePerm
  randomisePermutation();
  println(tilePerm);
  background(#FC75D6);
  loadButtons();
  if (isCustomLoaded) {
    try {
      mainImage = loadImage(customImage);
      image(mainImage,-100,-100,100,100); // test
    } catch (NullPointerException e) {
      e.printStackTrace(); // view what happened
      mainImage = loadImage("Default.png");
      println("Loaded default image");
    }
    println("Image loaded");
  }
  else {
    mainImage = loadImage("Default.png");
    println("Loaded default image");
  }
  mainImage.resize(400,400);
  // initialise tiles
  for (int i = 0; i<16; i++) {
    tileArr[i] = new Tile(tilePerm[i]);
    tileArr[i].realPos = i+1;
  }
}

void draw() {
  // initialise background and buttons
  background(#FC75D6);
  // add background to the damned tiles
  fill(#b61a8a);
  noStroke();
  rect(15,125,410,410);
  stroke(1);
  loadButtons();
  try {
    image(mainImage, 440,180,200,200);
  } catch (NullPointerException e) {
    e.printStackTrace(); // view what happened
    mainImage = loadImage("Default.png");
    println("Loaded default image");
  }

  // display number of moves
  fill(#5dff49);
  textFont(font, 24);
  textAlign(LEFT, CENTER);
  rect(440,400,200,50);
  fill(0);
  text("Moves:",460,400,160,50);
  textAlign(RIGHT, CENTER);
  text(str(moveCount),460,400,160,50);
  // display images according to their realPos
  pushMatrix();
  translate(20, 130);
  for (int i = 0; i < 16; i++) {
    if (tileArr[i].tileInt != 16) {
      tileArr[i].displayImage();
    }
    // determine current permutation
    currentPerm[tileArr[i].realPos-1] = tileArr[i].tileInt;
  }
  popMatrix();

  // if, in the case that thing is solved:
  if (isSolved()) {
    makeText("Congratulations! You did it in " + str(moveCount) + " moves!", 32,
      color(250, 225, 0, 153), 20, 130, 400,400);
  }
}

void mouseClicked() {
  /*
  What happens when mouse is clicked
  on buttons and on tiles
  */
  println(mouseX, ' ', mouseY);

  if (isOnButton(150,540,150+140,540+50)) {
    // if on New Game
    println("is on NewGame");
    setup();
  } else if (isOnButton(20,540,20+120,540+50)) {
    // if on Default
    isCustomLoaded=false;
    println("is on Default");
    setup();
  } else if (isOnButton(300,540,300+120,540+50)) {
    // if on Select Image
    println("is on Select Image");
    selectInput("Select a custom image:", "ifCustomImg");
  }
}

void ifCustomImg(File selection) {
  if (selection == null) {
    println("selection is null");
  } else {
    println("User selected " + selection.getAbsolutePath());
    customImage = selection.getAbsolutePath();
    isCustomLoaded = true;
    setup();
  }
}

void randomisePermutation() {
  /*
  Randomise tilePerm, until it satisfies isSolvable
  */
  shuffleArray(tilePerm);
  while (isSolvable() == false) {
    shuffleArray(tilePerm);
  }
}

void loadButtons() {
  /*
  Load the buttons for the game
  */
  makeText("15 Puzzle", 72, #A65DFA, 20,20,640,90);
  makeText("Default", 32, #48EDBA, 20,540,120,50);
  makeText("New Game", 32, #5DA5FA, 150,540,140,50);
  makeText("Select image", 28, #48EDBA, 300,540,120,50);
  makeText("Solved image:", 28, #5e6bdf, 440,130,200,50);
}

void makeText(String string, int size, color background, int x1, int y1, int l, int h) {
  /*
  Create a textbox with attributes
  */
  rectMode(CORNER);
  fill(background);
  textFont(font, size);
  textAlign(CENTER, CENTER);
  rect(x1,y1,l,h);
  fill(0);
  text(string, x1,y1,l,h);
}

boolean isOnButton(int x1, int y1, int x2, int y2) {
  /*
  Determines whether mouse cursor
  is on the four corners of the button
  */
  return ((x1 <= mouseX && mouseX <= x2) && (y1 <= mouseY && mouseY <= y2));
}

boolean isSolvable() {
  /*
  Checks whether tilePerm is solvable, accg. to *that* webpage
  */
  int inversionCount = 0;
  int positionOfNull = 0; // determines where "16" is (in tilePerm)
  for (int i = 0; i < 16; i++) {
    for (int j = i+1; j < 16; j++) {
      if (tilePerm[i] != 16) {
        inversionCount += int(tilePerm[i] > tilePerm[j]);
      }
    }
    if (tilePerm[i] == 16) {
      positionOfNull = i;
    }
  }
  // determines whether null (16) is on even or odd row
  boolean isNullOnOdd = ((positionOfNull/4) % 2 == 1);
  return (isNullOnOdd == (inversionCount % 2 == 0));
}

void shuffleArray(int[] array) {
  // ~~copy-pasted~~ based from https://forum.processing.org/two/discussion/3546/how-to-randomize-order-of-array 
  // with code from WikiPedia; Fisher–Yates shuffle
  
  Random rng = new Random();
 
  // i is the number of items remaining to be shuffled.
  for (int i = array.length; i > 1; i--) {
 
    // Pick a random element to swap with the i-th element.
    int j = rng.nextInt(i);  // 0 <= j <= i-1 (0-based array)
 
    // Swap array elements.
    int tmp = array[j];
    array[j] = array[i-1];
    array[i-1] = tmp;
  }
}

void keyPressed() {
  // determine position of Null
  int nullPos = 0; // position of Null
  int tempNum = 0; // for later
  for (int i = 0; i < 16; i++) {
    if (tileArr[i].tileInt == 16) {
      nullPos = i;
      break;
    }
  }
  // determine which tiles are north, south, west, and east
  // depending on key pressed, process differently
  int move = 0; // depending on key pressed
  switch (keyCode) {
    case UP: {
      move += 4;
      break;
    }
    case DOWN: {
      move -= 4;
      break;
    }
    case LEFT: {
      move += 1;
      break;
    }
    case RIGHT: {
      move -= 1;
      break;
    }
    case 'r':
    case 'R': {
      // r for Reset
      setup();
      break;
    }
  }
  println(move);

  // if isSolved, do nothing
  if (isSolved() == false) {
    for (int i = 0; i < 16; i++) {
      // determine whether it exceeds the bounds; if it does, move to next i
      if (tileArr[i].realPos - move < 1 || tileArr[i].realPos - move > 16) {
        continue;
      }
      // determine if move is left/right AND make sure that they are in same row
      if (abs(move) == 1 && ((tileArr[i].realPos - 1) / 4 == (tileArr[nullPos].realPos-1)/4)) {
        // determine whether they are in left/right of each other
        if (tileArr[i].realPos - move == tileArr[nullPos].realPos) {
          // then SWITCH!
          tempNum = tileArr[i].realPos;
          tileArr[i].realPos = tileArr[nullPos].realPos;
          tileArr[nullPos].realPos = tempNum;
          moveCount += 1;
          break;
        }
      }
      // determine if move is up/down
      else if (abs(move)==4) {
        // same code as above
        if (tileArr[i].realPos - move == tileArr[nullPos].realPos) {
          tempNum = tileArr[i].realPos;
          tileArr[i].realPos = tileArr[nullPos].realPos;
          tileArr[nullPos].realPos = tempNum;
          moveCount += 1;
          break;
        }
      }
    }
    for (int i = 0; i < 16; i++) {
      print(currentPerm[i], ", ");
    }
    println();
  }
}

boolean isSolved() {
  /*
  Determines whether thing is solved
  */
  for (int i = 0; i < 16; i++) {
    if (currentPerm[i] != perfectPerm[i]) {
      return false;
    }
  }
  return true;
}
