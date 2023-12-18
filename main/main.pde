int numBoids = 100;
Member[] members = new Member[numBoids];
Boid b;
PShape boid;
ArrayList<Member> falling_members = new ArrayList<Member>();
int swap = 0; // Used to make all the boids fall in the same way
ArrayList<Member>  dead_members = new ArrayList<Member>();

void setup() {
    size(500,500,P2D);
    for (int i = 0; i < numBoids; i++) {
        members[i] = new Member(new Vec2(random(0, 500), random(0,500)), new Vec2(random(1,2), random(-0.5,0.5)));
    }
    // Is the shape that all the boids will be, defined here to assist with speed up as drawing them each slowed it down without PShape
    b = new Boid(members);
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

void mouseClicked() {
    IntList knocked_out = new IntList();
    for (int i = 0; i < b.n; i++) {
        Member current_member = b.members[i];
        Vec2 mouse = new Vec2(mouseX, mouseY);
        float dist = current_member.pos.distanceTo(mouse);
        
        if (dist < 50) {
            // Add the member to falling list
            falling_members.add(b.members[i]);
            knocked_out.append(i);
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

void draw() {
    background(255,255,255);
    fill(255,0,0);
    stroke(0,0,0);

    b.update_members();
    for (int i = 0; i < b.n; i++) { // Move all the living boids
        Vec2 pos = b.members[i].pos;
        Vec2 vel = b.members[i].vel;
        pushMatrix();
        translate(pos.x, pos.y);
        rotate(atan2(vel.x, vel.y) + PI); // The PI modifier was added to help but it still doesn't seem to get it 100%
        shape(boid);
        popMatrix();
        
    }
    for (int i = 0; i < falling_members.size(); i++){
        Vec2 pos = falling_members.get(i).pos;
        pushMatrix();
        translate(pos.x, pos.y);
        shape(boid);
        popMatrix();
        if (swap < 10){
            falling_members.get(i).pos = pos.minus(new Vec2(1,-1));
            
        } else if (swap < 20){
            falling_members.get(i).pos = pos.minus(new Vec2(-1,-1)); 
        }
        
    }
    if (swap < 20){
        swap++;
    } else {
        swap = 0;
    } 

    noFill();
    stroke(200,200,200);
    circle(mouseX, mouseY, 100);
    stroke(0,0,0);
    //delay(100);
}
