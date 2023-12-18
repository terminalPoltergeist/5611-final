// we call one entity in the boid system a "member"
// the entire group of memebers makes up the boid

public class Boid {
    public Member[] members;
    public int n; // number of members in the boid
    public Vec2 com; // percieved center of mass of the boid
    public float maxSpeed;
    public float maxForce;

    public Boid(Member[] mems) {
        this.members = mems;
        this.n = this.members.length;
        maxSpeed = 2;
        maxForce = 0.05;
    }

    public void update_members() {
        // for each member, calculate the percieved com in relation to that member, then update it's position
        Vec2 v1, v2, v3;
        for (int i = 0; i < this.n; i++) {
            Member current_member = this.members[i];
            // this.find_com(current_member);
            v1 = find_cohesion(current_member);
            v2 = avoid_others(current_member);
            v3 = go_with_the_flow(current_member);
            current_member.vel = current_member.vel.plus(v1.plus(v2.plus(v3)));
            current_member.vel.clampToLength(maxSpeed);
            current_member.pos.add(current_member.vel);

            // Deal with the mouse coming in and run away from it
            Vec2 mouse = new Vec2(mouseX, mouseY);
            Vec2 delta = current_member.pos.minus(mouse);
            float dist = delta.length();

            // Loop around the screen
            if (dist < 100) {
                current_member.pos.add(delta.normalized().times(dist/50));
            }
            if (current_member.pos.x > width * 1.25) {
                current_member.pos.x = 0;
            }
            if (current_member.pos.y > height * 1.25) {
                current_member.pos.y = 0;
            }
            if (current_member.pos.x < width - (width * 1.25)) {
                current_member.pos.x = width;
            }
            if (current_member.pos.y <  height - (height * 1.25)) {
                current_member.pos.y = height;
            }
        }
    }

    public Vec2 find_com(Member m) {
        // find the percieved center of mass
        // the com of the boid without including member m
        // per: http://www.kfish.org/boids/pseudocode.html
        Vec2 total = new Vec2(0,0);
        for (int i = 0; i < this.n; i++) {
            if (this.members[i] != m) total.add(this.members[i].pos); // don't include the position of member m
        }
        // total.times(0.5);
        total.mul(1 /float(this.n - 1));
        total.subtract(m.pos);
        total.mul(1/float(100));
        println(total);
        return total;
    }

    public Vec2 find_cohesion(Member m) {
        float neighbordist = 50;
        Vec2 sum = new Vec2(0,0);
        int count = 0;
        for (int i = 0; i < this.n; i++){
            if (this.members[i] != m){
                float d = m.pos.distanceTo(this.members[i].pos);
                if (d < neighbordist){
                    sum.add(this.members[i].pos);
                    count++;
                }
            }
        }
        if (count > 0) {
            sum.mul(1/count);
            return move_to_pos(m,sum);
        } else {
            return new Vec2(0,0);
        }
    }

    public Vec2 avoid_others(Member m) {
        Vec2 delta = new Vec2(0,0);

        for (int i = 0; i < this.n; i++) {
            if (this.members[i] != m) {
                if (m.pos.distanceTo(this.members[i].pos) < 20) {
                    // if the given member is within a radius of 20, count it towards the delta
                    delta = delta.minus(this.members[i].pos.minus(m.pos));
                }
            }
        }
        
        return delta;
    }

    public Vec2 go_with_the_flow(Member m) {
        // for a given member, update it's velocity to go with the rest of the members
        Vec2 pv = new Vec2(0.0,0.0); // the percieved velocity of the member

        for (int i = 0; i < this.n; i++) {
            if (this.members[i] != m) {
                pv = pv.plus(this.members[i].vel);
            }
        }
        pv = pv.times(1/float(this.n-1));
        pv = pv.minus(m.vel).times(1/8);
        return pv;
    }

    public Vec2 move_to_pos(Member m, Vec2 target){
        Vec2 goal = target.minus(m.pos);
        goal.normalize();
        goal.mul(maxSpeed);

        Vec2 change = goal.minus(m.vel);
        change.clampToLength(maxForce);
        return change;
    }

    // public Vec2 separate(Member m){
    //     float seperation_factor = 25.0;
    //     Vec2 change = new Vec2(0,0);
    //     int count = 0;

    //     for (int i = 0; i < this.n; i++){
    //         float d = m.pos.distanceTo(this.members[i].pos);
    //         if((d > 0) && (d < seperation_factor)){
    //             Vec2 dif = m.pos.minus(this.members[i].pos);
    //             diff.normalize();
    //             diff.mul(1/d);
    //             change.add(diff);
    //             count++;
    //         }
    //     }
    //     if (count > 0) change.mul(1/count);
    // }
}
