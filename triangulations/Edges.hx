package triangulations;
import triangulations.Geom2;

abstract Edges( Array<Edge> ) from Array<Edge> to Array<Edge> {
    
    inline public function new( v: Array<Edge> ) {
      this = v;
    }
    public inline static 
    function getEmpty(){
        return new Edges( new Array<Edge>() );
    }
    public /*inline*/ function set_fixedExternal( val: Bool ){
        for( e in this ) {
            e.fixed = val;
            e.external = val;
        }
        return val;
    }
    public var fixedExternal( never, set ):Bool;
    
    public inline
    function clone(): Edges {
        var e = new Edges();
        var l = this.length;
        for( i in 0...l ){
            e[ i ].p = this[ i ].p;
            e[ i ].q = this[ i ].q;
        }
        return v;
    }
    
    public inline
    function getUnsure(): Array<Int> {
        var unsureEdges = new Array<Int>();
        var l = this.length;
        var lu = 0;
        for( j in 0...l ){
            if( !edges[j].fixed ){
                unsureEdges[ lu ] = j;
                lu++;
            }
        }
        return unsureEdges;
    }
    
    public inline
    function add( e: Edges ){
        var l = this.length;
        var el = e.length;
        for( i in 0...el ) this[ l + i ] = e[ i ];
    }
    @:from
    static public function fromArrayArray( arr:Array<Array<Null<Int>>> ) {
        var edges: Edges = getEmpty();
        var l = arr.length;
        for( i in 0...l ) edges[ i ] = Edge.fromArray( arr[ i ] );
        return edges;
    }
}
