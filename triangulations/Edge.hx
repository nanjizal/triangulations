package triangulations;

class Edge {
    public var p: Int;
    public var q: Int;
    // Defaults false?
    public var fixed: Bool = false;
    public var external: Bool = false;
    public function new( p_: Int, q_: Int ){
        p = p_;
        q = q_;
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
