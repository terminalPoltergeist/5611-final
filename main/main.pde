Member[] members = new Member[100];
Boid b;

void setup() {
    size(500,500);
    for (int i = 0; i < 100; i++) {
        members[i] = new Member(new Vec2(random(0, 500), random(0,500)));
    }
    b = new Boid(members);
}


void draw() {
    background(255,255,255);
    fill(255,0,0);
    stroke(0,0,0);

    b.update_members();
    for (int i = 0; i < b.n; i++) {
        circle(b.members[i].pos.x, b.members[i].pos.y, 10);
    }
    //delay(100);
}
