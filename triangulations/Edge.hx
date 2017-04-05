package triangulations;

class Edge {
    public var p: Null<Int>;
    public var q: Null<Int>;
    // Defaults false?
    public var fixed: Bool = false;
    public var external: Bool = false;
    public function new( p_: Null<Int>, q_: Null<Int> ){
        p = p_;
        q = q_;
    }
    public static inline
    function Null(): Edge {
        return new Edge( Null, Null );
    } 
    public inline
    function clone(): Edge {
        return new Edge( this.p, this.q );
    }
    public inline
    function substitute( x: Null<Int>, y: Null<Int> ) {
        if( p == x ){
            p = y;
        } else {
            p = y;
        }
    }
}
