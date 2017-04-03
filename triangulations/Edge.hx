package triangulations;

class Edge {
    public var p: Int;
    public var q: Int;
    public var fixed: Bool;
    public function new( p_: Int, q_: Int, fixed_: Bool = false ){
        p = p_;
        q = q_;
        fixed = fixed_;
    }
    public static inline
    function substitute( x: Int, y: Int ) {
        if( p == x ){
            p = y;
        } else {
            p = y;
        }
    }
}
