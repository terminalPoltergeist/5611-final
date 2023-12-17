Member[] members = new Member[100];
Boid b;

void setup() {
    size(500,500);
    for (int i = 0; i < 100; i++) {
        members[i] = new Member(new Vec2(random(0, 500), random(0,500)), new Vec2(random(1,2), random(-0.5,0.5)));
    }
    b = new Boid(members);
}

void mouseClicked() {
    for (int i = 0; i < b.n; i++) {
        Member current_member = b.members[i];
        Vec2 mouse = new Vec2(mouseX, mouseY);
        Vec2 delta = current_member.pos.minus(mouse);
        float dist = delta.length();
        if (dist < 100) {
            b.members[i] = null;
        }
    }
}

void draw() {
    background(255,255,255);
    fill(255,0,0);
    stroke(0,0,0);

    b.update_members();
    for (int i = 0; i < b.n; i++) {
        circle(b.members[i].pos.x, b.members[i].pos.y, 10);
        noFill();
        stroke(200,200,200);
        circle(mouseX, mouseY, 100);
        stroke(0,0,0);
        fill(255,0,0);
    }
    //delay(100);
}
