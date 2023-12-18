// we call one entity in the boid system a "member"
// the entire group of memebers makes up the boid

public class Boid {
    public Member[] members;
    public int n; // number of members in the boid
    public Vec2 com; // percieved center of mass of the boid
    float maxSpeed;

    public Boid(Member[] mems) {
        this.members = mems;
        this.n = this.members.length;
        maxSpeed = 3.0;
    }

    public void update_members() {
        // for each member, calculate the percieved com in relation to that member, then update it's position
        Vec2 chaos = new Vec2(random(-0.05, 0.05), random(-0.05, 0.05)); // a modifyer to add to all boid members percieved velocities, makes the entire mass shift direction slightly
        for (int i = 0; i < this.n; i++) {
            Member current_member = this.members[i];
            this.find_com(current_member);
            Vec2 d = this.avoid_others(current_member);
            if (this.com.length() > 0) current_member.move_to_com(this.com); // Changed so that they don't gravitate towards 0,0 when there is no one else near them
            current_member.move_away(d);
            Vec2 dv = this.go_with_the_flow(current_member);  // percieved directional velocity of the mass of boids
            // dv.add(chaos);
            current_member.follow(dv); // update members velocity with dv

            // check if members are in radius of the mouse
            Vec2 mouse = new Vec2(mouseX, mouseY);
            Vec2 delta = current_member.pos.minus(mouse);
            float dist = delta.length(); // distance between the mouse and the given boid member
            
            
            if (dist < 100) {
                current_member.vel.add(delta.times(dist/75));
            }
            if (current_member.vel.length() > maxSpeed) current_member.vel.clampToLength(maxSpeed); //Sets a max speed
            // check if members are outside of the screen
            current_member.pos.add(current_member.vel);
            if (current_member.pos.x > width + 5) {
                current_member.pos.x = 0;
            }
            if (current_member.pos.y > height + 5) {
                current_member.pos.y = 0;
            }
            if (current_member.pos.x < -5) {
                current_member.pos.x = width;
            }
            if (current_member.pos.y <  -5) {
                current_member.pos.y = height;
            }
        }
    }

    public Vec2 find_com(Member m) {
        // find the percieved center of mass
        // the com of the boid without including member m
        // per: http://www.kfish.org/boids/pseudocode.html
        Vec2 total = new Vec2(0,0);
        int count = 0; // This is to account for the 1/(N-1)
        for (int i = 0; i < this.n; i++) {
            if (this.members[i] != m && m.pos.distanceTo(this.members[i].pos) < 50){
                total.add(this.members[i].pos); // don't include the position of member m
                count++;
            } 
        }
        if (count > 0){
            total.mul(1/count);
        }
        total.mul(0.5);
        this.com = total;
        return this.com;
    }

    public Vec2 avoid_others(Member m) {
        Vec2 delta = new Vec2(0,0);

        for (int i = 0; i < this.n; i++) {
            if (this.members[i] != m) {
                if (m.pos.distanceTo(this.members[i].pos) < 20) {
                    // if the given member is within a radius of 20, count it towards the delta
                    delta = delta.minus(this.members[i].pos.minus(m.pos)).times(0.2);
                }
            }
        }

        return delta.times(0.5);
    }

    public Vec2 go_with_the_flow(Member m) {
        // for a given member, update it's velocity to go with the rest of the members
        Vec2 pv = new Vec2(0.0,0.0); // the percieved velocity of the member
        int count = 0;
        for (int i = 0; i < this.n; i++) {
            if (this.members[i] != m && m.pos.distanceTo(this.members[i].pos) < 50) {
                pv = pv.plus(this.members[i].vel);
                count++;
            }
        }
        if (count > 0){
            pv = pv.times(1/float(count));
            return pv.minus(m.vel);
        } 
        
        return new Vec2(0,0);
    }
}
