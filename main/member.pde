// we call one entity in the boid system a "member"
// the entire group of memebers makes up the boid

public class Member {
    public Vec2 pos, vel;
    
    public Member(Vec2 pos, Vec2 vel) {
        this.pos = pos;
        this.vel = vel;
    }

    public void move_to_com(Vec2 com) {
        // given a center of mass, move the member towards the center of mass
        Vec2 dx = com.minus(this.pos);
        Vec2 dp = dx.times(0.005);
        this.pos.add(dp.times(0.25));
    }

    public void move_away(Vec2 delta) {
        // move a member away from all others
        this.pos.add(delta);
    }

    public void follow(Vec2 dv) {
        this.vel.add(dv);
        if (this.vel.length() < 1.5) {
            // if they start moving too slow, speed them up?
            this.vel.mul(1.5);
        }
    }
}
