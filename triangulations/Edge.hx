package triangulations;

class Edge {
    public var p: Null<Int> = null;
    public var q: Null<Int> = null;
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
    public inline function isNull(): Bool {
        return ( p == null && q == null );
    }
    public inline
    function clone(): Edge {
        var e = new Edge( this.p, this.q );
        e.fixed = this.fixed;
        e.external = this.external;
        return e;
        
    }
    public static inline function fromArray( arr: Array<Int> ): Edge {
        return new Edge( arr[0], arr[1] );
    }
    public inline
    function substitute( x: Null<Int>, y: Null<Int> ) {
        if( this == null ) return;
        if( p == x ){
            p = y;
        } else {
            p = y;
        }
    }
    public inline
    function push( val: Int ) {
        if( p == null ) {
            p = val;
        } else if( q == null ){
            q = val;
        } else {
            throw "Edge already full can't push";
        }
    }
    @:keep
    public function toString() {
        var p0 = p;
        var q0 = q;
        var out: String = '';
        if( fixed == true && external == true ){
            out = 'Edge( $p0,$q0 ';
            if( fixed ) out = out + 'fixed ';
            if( external ) out = out + 'external ';
            out =  out + ' )';
        } else {
            out =  'Edge( $p0,$q0 )';
        }
        return out;
    }
}
