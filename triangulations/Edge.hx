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
        return new Edge( null, null );
    } 
    public inline
    function clone(): Edge {
        return new Edge( this.p, this.q );
    }
    public static inline function fromArray( arr: Array<Int> ): Edge {
        return new Edge( arr[0], arr[1] );
    }
    public inline
    function substitute( x: Null<Int>, y: Null<Int> ) {
        if( p == x ){
            p = y;
        } else {
            p = y;
        }
    }
    @:keep
    public function toString() {
        var p0 = p;
        var q0 = q;
        return 'Edge( $p0,$q0 )';
    }
}
