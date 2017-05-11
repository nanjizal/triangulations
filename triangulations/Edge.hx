package triangulations;
/**
 * Edge holds two vertex indices p and q
 * Also can be fixed and/or external
 **/
class Edge {
    /**
     * first vertex index
     **/
    public var p: Null<Int> = null;
    /**
     * second vertex index
     **/
    public var q: Null<Int> = null;
    // Defaults false?
    /**
     * edge that can't be changed ( flipped for instance ).
     **/
    public var fixed: Bool = false;
    /** 
     * edge that is external to the shape
     **/
    public var external: Bool = false;
    /**
     * create edge from to vertices indices
     *
     * @param   p           first index
     * @param   q           second index
     **/
    public function new( p_: Null<Int>, q_: Null<Int> ){
        p = p_;
        q = q_;
    }
    /**
     * creates empty Edge without content, where vertices indices will be pushed later.
     **/
    public static inline
    function Null(): Edge {
        return new Edge( null, null );
    }
    /**
     * check if Edge is not valid, if either p or q are unset.
     **/
    public inline function isNull(): Bool {
        return ( p == null || q == null );
    }
    /**
     * function to clone an Edge used when cloning a FillShape for instance or creating coEdges from Edges.
     *
     * @return      cloned version of the edge
     **/
    public inline
    function clone(): Edge {
        var e = new Edge( this.p, this.q );
        e.fixed = this.fixed;
        e.external = this.external;
        return e;
        
    }
    /**
     * used to get edge index in an array style where 0 is p and 1 is q
     *
     * @param   k       0 is p and 1 is q
     * @return   vertex index
     **/
    public inline function getByIndex( k: Int ){
        return switch( k ){
            case 0:
                return p;
            case 1:
                return q;
            default:
                throw "Error can't get one of the Edges out of range " + k;
                return null;
        }
    }
    /**
     * to allow construction from array of two Integers
     **/
    public static inline function fromArray( arr: Array<Int> ): Edge {
        return new Edge( arr[0], arr[1] );
    }
    /**
     * used in flipping for swapping values
     **/
    public inline
    function substitute( x: Null<Int>, y: Null<Int> ) {
        if( this == null ) return;
        if( p == x ){
            p = y;
        } else {
            q = y;
        }
    }
    /**
     * push to emulate array in code that originally assumed an edge to be array and can't easily be refactored.
     * 
     * @param   val         value to be placed on the next empty edge place.
     **/
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
    /** 
     * toString verbose 
     **/
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
    /**
     * alternate minimal trace useful for viewing lots of edges with less noise
     * but must be called directly when tracing
     **/
    @:keep    @:keep
    public function out() {
        var p0 = p;
        var q0 = q;
        return '($p0,$q0 )';
    }  
}
