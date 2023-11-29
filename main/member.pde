// we call one entity in the boid system a "member"
// the entire group of memebers makes up the boid

public class Member {
    public Vec2 pos;
    
    public Member(Vec2 pos) {
        this.pos = pos;
    }

    public void move_to_com(Vec2 com) {
        Vec2 dx = com.minus(this.pos);
        Vec2 dp = dx.times(0.001);
        this.pos.add(dp);
    }

    public void move_away(Vec2 delta) {
        this.pos.add(delta);
    }
}
