import processing.sound.*;
Sound s;
SoundFile reload, blast, quack;

int numBoidsGlobal = 100;
int numBoids = numBoidsGlobal;
Member[] members = new Member[numBoids];
Boid b;
PShape boid;
ArrayList<Member> falling_members = new ArrayList<Member>();
int swap = 0; // Used to make all the boids fall in the same way
ArrayList<Member>  dead_members = new ArrayList<Member>();
int score = 0;
int currentLevel = 0; // The level is based on the number: 0 - Start Screen, 1 - Game Screen, 2 - End Screen, 3 - Score Screen, 4 - ????
int startTime;
String[] scoreData;
String fileName = "scoreData.txt";
String userInput = "";
Vec2[] clouds = new Vec2[6];
int shells = 2;
boolean fired = false;
boolean hit = false;
int flashSize = 0;

void setup() {
    size(1000,1000,P2D);

    // Is the shape that all the boids will be, defined here to assist with speed up as drawing them each slowed it down without PShape    
    boid = createShape();
    boid.beginShape();
    boid.stroke(0,0,0);
    boid.strokeWeight(0);
    boid.vertex(0, 7);
    boid.vertex(-4, -7);
    boid.vertex(0, -4);
    boid.vertex(4, -7);
    boid.endShape(CLOSE);

    // Load the score
    scoreData = loadStrings(fileName);

    // Load the sounds
    s = new Sound(this);
    s.volume(0.1);
    reload = new SoundFile(this, "Audio/reload.mp3");
    blast = new SoundFile(this, "Audio/blast.mp3");
    quack = new SoundFile(this, "Audio/quack.mp3");

}

void startGame(){
    currentLevel = 1;
    startTime = millis();
    falling_members = new ArrayList<Member>();
    scoreData = loadStrings(fileName);
    userInput = "";
    numBoids = numBoidsGlobal;
    Member[] members = new Member[numBoids];
    for (int i = 0; i < numBoids; i++) {
        members[i] = new Member(new Vec2(random(width), random(height)), new Vec2(random(1,2), random(-0.5,0.5)));
    }
    b = new Boid(members);
    score = 0;
    for (int i = 0; i < 6; i++){
        clouds[i] = new Vec2(random(width),random(height));
    }
}

void mouseClicked() {
    switch (currentLevel){
        case 0: // Start Screen
            if (mouseX > width /2 - 75 && mouseX < width / 2 + 75 && mouseY > height / 2 + 135 && mouseY < height / 2 + 185){
                startGame();
            } else if (mouseX > width /2 - 75 && mouseX < width / 2 + 75 && mouseY > height / 2 + 190 && mouseY < height / 2 + 240){
                currentLevel = 4;
            }
            break;
        case 1: // Game Screen
            IntList knocked_out = new IntList();
            for (int i = 0; i < b.n; i++) {
                Member current_member = b.members[i];
                Vec2 mouse = new Vec2(mouseX, mouseY);
                float dist = current_member.pos.distanceTo(mouse);
                fired = true;
                if (dist < 50 && shells > 0) {
                    // Add the member to falling list
                    falling_members.add(b.members[i]);
                    knocked_out.append(i);
                    score += 10;
                    hit = true;
                } 
            }
            // Resize the members
            members = new Member[numBoids - knocked_out.size()];
            int newIndex = 0;
            for (int i = 0; i < numBoids; i++){
                if (!knocked_out.hasValue(i)){
                    members[newIndex] = b.members[i];
                    newIndex++;
                }
            }
            b = new Boid(members);
            numBoids = numBoids - knocked_out.size();
            break;
        case 2: // End Screen
            if (millis() - startTime > 1000){
                currentLevel = 0;
                if (mouseX > width /2 - 60 && mouseX < width / 2 + 60 && mouseY > height / 2 + 100 && mouseY < height / 2 + 140){
                    currentLevel = 3;
                }
            }
            break;
        case 3: // Score Screen
            if (mouseX > width / 2 - 40 && mouseX < width / 2 + 40 && mouseY > height / 2 + 25 && mouseY < height / 2 + 55 && userInput.length() == 3){
                saveScore();
                currentLevel = 0;
            }
            break;
        case 4: // Score Screen Display
            currentLevel = 0;
            break;

    }
        
}

void draw() {
    switch (currentLevel) {
        case 0: // Start Screen
            background(30, 30, 60);
            fill(255);
            textSize(48);
            textAlign(CENTER, CENTER);
            text("Boid Hunt", width / 2, height / 2 - 50);

            textSize(20);
            text("Instructions:", width / 2, height / 2 + 20);
            text("- Hunt down the boids!", width / 2, height / 2 + 50);
            text("- Click with your shotgun mouse to get em!", width / 2, height / 2 + 80);

            drawButton("Start", width / 2, height / 2 + 160, 150, 50);
            drawButton("Scores", width / 2, height / 2 + 215, 150, 50);
            break;
        case 1: // Game Screen
            background(135, 206, 235);
            fill(255,0,0);
            stroke(0,0,0);

            for (int i = 0; i < 6; i++){
                drawCloud(clouds[i].x,clouds[i].y);
            }

            b.update_members();
            // Move all the living boids
            drawFlyingBoids();
            // Move all the falling boids
            drawFallingBoids();

            // Score display
            drawScore();

            if (fired && shells < 1) {
                shells = 2;
                fired = false;
                reload.play();
            }
            if (fired) {
                shells--;
                fired = false;
                blast.play();
            }
            if (hit){
                quack.play();
                hit = false;
                startFlash();
            }
            drawShells();

            if (millis() - startTime > 30000) {
                currentLevel = 2; //Is set for 30 seconds right now 
                startTime = millis(); // Set a new start time so that there is a buffer on going back to the start screen
            }
            break;
        case 2: // End Screen
            background(30,30,60);
            fill(255, 0, 0);
            textSize(32);
            text("Game Over", width / 2, height / 2 - 30);
            
            // Display score
            textSize(24);
            text("Score: " + score, width / 2, height / 2 + 20);
            
            // Display message prompt
            drawButton("Enter Score", width / 2, height / 2 + 120, 120, 40);
            break;
        case 3: // Score Screen
            background(30,30,60);
            textSize(18);
            fill(0);
            text("Score Data", width / 2, 30);
            for (int i = 0; i < scoreData.length; i++) {
                text(scoreData[i], width / 2, 60 + i * 20);
            }

            // Display user input prompt
            fill(0);
            textSize(32);
            text("Enter your 3-letter identifier:", width / 2, height / 2 - 30);
            text(userInput, width / 2, height / 2);
            // Draw a button to submit the user input
            drawButton("Submit", width / 2, height / 2 + 40, 80, 30);
            break;
        case 4: // Score Screen Display
            int fromColor = color(30, 30, 60); // Dark blue
            int toColor = color(70, 70, 120);   // Light blue

            
            for (int i = 0; i < height; i++) {
                float inter = map(i, 0, height, 0, 1);
                int c = lerpColor(fromColor, toColor, inter);
                stroke(c);
                line(0, i, width, i);
            }
            fill(255);
            textSize(64);
            textAlign(CENTER, TOP);
            text("High Scores", width / 2, 20);

            // Display score data
            fill(255);
            textSize(32);
            bubbleSort(scoreData); // Display the data in order of highest to lowest
            for (int i = 0; i < scoreData.length; i++) {
                text(scoreData[i], width / 2, 100 + i * 30);
            }
            break;

    }
    //delay(100);
}

void drawFlyingBoids(){
    for (int i = 0; i < b.n; i++) { 
        Vec2 pos = b.members[i].pos;
        Vec2 vel = b.members[i].vel;
        pushMatrix();
        translate(pos.x, pos.y);
        rotate(atan2(-1 * vel.x, vel.y));
        boid.setFill(color(255,216,1));
        shape(boid);
        popMatrix();
        
    }
}

void drawFallingBoids(){
    for (int i = 0; i < falling_members.size(); i++){
        Vec2 pos = falling_members.get(i).pos;
        pushMatrix();
        translate(pos.x, pos.y);
        boid.setFill(color(120,120,120));
        shape(boid);
        popMatrix();
        if (swap < 10){
            falling_members.get(i).pos = pos.minus(new Vec2(1,-4)); // The difference in y is intentional as it makes the motion more "realistic" to me
            
        } else if (swap < 20){
            falling_members.get(i).pos = pos.minus(new Vec2(-1,-2)); 
        }
        
    }
    // Setup for the swaying of the falling boids
    if (swap < 20){
        swap++;
    } else {
        swap = 0;
    }
}

void startFlash(){
    flashSize = 135;
}

void drawScore(){
    textSize(32);
    textAlign(LEFT);
    text("SCORE:", 12, 32);
    text(str(score), 40, 64);
    text("TIME", width - 100, 32);
    text(str(30-(millis()-startTime)/1000), width - 70, 64);

    // Draws the flash
    fill(255,255,0, 150);
    noStroke();
    circle(mouseX, mouseY, flashSize);
    if (flashSize > 0) flashSize -= 5; //Decrease the size of the flash per time step

    // Draws the reticle
    noFill();
    stroke(255,0,0);
    circle(mouseX, mouseY, 100);
    line(mouseX-50,mouseY,mouseX+50,mouseY);
    line(mouseX,mouseY-50,mouseX,mouseY+50);
    stroke(0,0,0);
}

void drawShells(){
    rectMode(CENTER);
    for (int i = 0; i < shells; i++){
        fill(255,215,0);
        rect(55, height - 17.5 -(i * 20), 10, 15);
        fill(255, 0, 0);
        rect(30, height - 17.5 -(i*20), 40, 15);
    }
    
}

void saveScore(){
    String newScore = userInput + " - " + str(score);
    String[] newData = append(scoreData, newScore);
    bubbleSort(newData);
    saveStrings(fileName, newData);
    scoreData = loadStrings(fileName);
}

void drawButton(String label, float x, float y, float w, float h) {
  // Check if the mouse is over the button
  boolean isOverButton =
    mouseX > x - w / 2 &&
    mouseX < x + w / 2 &&
    mouseY > y - h / 2 &&
    mouseY < y + h / 2;

  // Draw button background
  fill(isOverButton ? color(50, 200, 50) : color(0, 150, 0));
  rectMode(CENTER);
  rect(x, y, w, h, 10);

  // Draw button text
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text(label, x, y);
}

void drawCloud(float x, float y) {
  noStroke();
  fill(255,255,242); // Cloud color
  
  // Draw cloud body
  float cloudWidth = 90;
  float cloudHeight = 55;
  ellipse(x, y, cloudWidth + x % 17, cloudHeight + y % 13);
  ellipse(x - cloudWidth * 0.4, y, cloudWidth * 1.2 - x % 23, cloudHeight * 0.8 + y % 23);
  ellipse(x + cloudWidth * 0.4, y, cloudWidth * 0.8 + x % 23, cloudHeight + y % 23);
}

void keyPressed(){
    switch (currentLevel){
        case 3: // Score Screen
            if (keyCode >= 'A' && keyCode <= 'Z' && userInput.length() < 3) {
                userInput += key;
                userInput = userInput.toUpperCase();
            } else if (keyCode == BACKSPACE && userInput.length() > 0) {
                userInput = userInput.substring(0, userInput.length() - 1);
            }
            break;
    }
}

void bubbleSort(String[] arr) {
  int n = arr.length;
  
  for (int i = 0; i < n-1; i++) {
    for (int j = 0; j < n-i-1; j++) {
      // Extract numeric part from the strings
      int num1 = Integer.parseInt(arr[j].split("-")[1].trim());
      int num2 = Integer.parseInt(arr[j+1].split("-")[1].trim());
      
      // Swap if the numeric part of the current element is greater than the next element
      if (num1 < num2) {
        String temp = arr[j];
        arr[j] = arr[j+1];
        arr[j+1] = temp;
      }
    }
  }
}
