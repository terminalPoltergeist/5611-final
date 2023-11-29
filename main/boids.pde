// we call one entity in the boid system a "member"
// the entire group of memebers makes up the boid

public class Boid {
    public Member[] members;
    public int n; // number of members in the boid
    public Vec2 com; // percieved center of mass of the boid

    public Boid(Member[] mems) {
        this.members = mems;
        this.n = this.members.length;
    }

    public void update_members() {
        // for each member, calculate the percieved com in relation to that member, then update it's position
        for (int i = 0; i < this.n; i++) {
            Member current_member = this.members[i];
            this.find_com(current_member);
            current_member.move_to_com(this.com);
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
        this.com = total.times(1 /float(this.n - 1));
        return this.com;
    }
}
