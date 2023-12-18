int numBoids = 100;
Member[] members = new Member[numBoids];
Boid b;
PShape boid;
ArrayList<Member> falling_members = new ArrayList<Member>();
int swap = 0; // Used to make all the boids fall in the same way
ArrayList<Member>  dead_members = new ArrayList<Member>();
int score = 0;
boolean mainScreen = true;

void setup() {
    size(500,500,P2D);

    // Is the shape that all the boids will be, defined here to assist with speed up as drawing them each slowed it down without PShape    
    boid = createShape();
    boid.beginShape();
    boid.fill(255,0,0);
    boid.stroke(0,0,0);
    boid.strokeWeight(1);
    boid.vertex(0, 5);
    boid.vertex(-3, -5);
    boid.vertex(0, -3);
    boid.vertex(3, -5);
    boid.endShape(CLOSE);
}

void startGame(){
    mainScreen = false;
    for (int i = 0; i < numBoids; i++) {
        members[i] = new Member(new Vec2(random(0, 500), random(0,500)), new Vec2(random(1,2), random(-0.5,0.5)));
    }
    b = new Boid(members);
    score = 0;
}

void mouseClicked() {
    if (mainScreen){
        if (mouseX > width /2 - 75 && mouseX < width / 2 + 75 && mouseY > height / 2 + 155 && mouseY < height / 2 + 205){
            startGame();
        }
    } else {
        IntList knocked_out = new IntList();
        for (int i = 0; i < b.n; i++) {
            Member current_member = b.members[i];
            Vec2 mouse = new Vec2(mouseX, mouseY);
            float dist = current_member.pos.distanceTo(mouse);
            
            if (dist < 50) {
                // Add the member to falling list
                falling_members.add(b.members[i]);
                knocked_out.append(i);
                score += 10;
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
    }   
}

void draw() {
    if (mainScreen){
        background(30, 30, 60);
         fill(255);
        textSize(48);
        textAlign(CENTER, CENTER);
        text("Boid Hunt", width / 2, height / 2 - 50);

        textSize(20);
        text("Instructions:", width / 2, height / 2 + 20);
        text("- Hunt down the boids!", width / 2, height / 2 + 50);
        text("- Click with your shotgun mouse to get em!", width / 2, height / 2 + 80);

        drawStartButton(width / 2, height / 2 + 180, 150, 50);
    } else { // Play the level section
        background(255,255,255);
        fill(255,0,0);
        stroke(0,0,0);

        b.update_members();
        // Move all the living boids
        for (int i = 0; i < b.n; i++) { 
            Vec2 pos = b.members[i].pos;
            Vec2 vel = b.members[i].vel;
            pushMatrix();
            translate(pos.x, pos.y);
            rotate(atan2(vel.x, vel.y) + PI); // The PI modifier was added to help but it still doesn't seem to get it 100%
            shape(boid);
            popMatrix();
            
        }
        // Move all the falling boids
        for (int i = 0; i < falling_members.size(); i++){
            Vec2 pos = falling_members.get(i).pos;
            pushMatrix();
            translate(pos.x, pos.y);
            shape(boid);
            popMatrix();
            if (swap < 10){
                falling_members.get(i).pos = pos.minus(new Vec2(1,-2)); // The difference in y is intentional as it makes the motion more "realistic" to me
                
            } else if (swap < 20){
                falling_members.get(i).pos = pos.minus(new Vec2(-1,-1)); 
            }
            
        }
        // Setup for the swaying of the falling boids
        if (swap < 20){
            swap++;
        } else {
            swap = 0;
        }

        // Score display
        textSize(32);
        textAlign(LEFT);
        text("SCORE:", 0, 32);
        text(str(score), 40, 64);

        noFill();
        stroke(200,200,200);
        circle(mouseX, mouseY, 100);
        stroke(0,0,0);
    }
    
    //delay(100);
}


void drawStartButton(float x, float y, float w, float h) {
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
  text("Start", x, y);
}

