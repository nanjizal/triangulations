package triangulations;
import triangulations.Geom2;
@:forward
abstract Edges( Array<Edge> ) from Array<Edge> to Array<Edge> {
    
    inline public function new( ?v: Array<Edge> ) {
        if( v == null ) v = getEmpty();
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
            e[ i ] = new Edge( this[ i ].p, this[ i ].q );
        }
        return e;
    }
    
    public inline
    function getUnsure(): Array<Int> {
        var unsureEdges = new Array<Int>();
        var l = this.length;
        var lu = 0;
        for( j in 0...l ){
            if( !this[j].fixed ){
                unsureEdges[ lu ] = j;
                lu++;
            }
        }
        return unsureEdges;
    }
    
    public inline
    function add( e: Edges ): Edges {
        var l = this.length;
        var el = e.length;
        for( i in 0...el ) this[ l + i ] = e[ i ];
        return e;
    }
    @:from
    static public function fromArrayArray( arr: Array<Array<Null<Int>>> ) {
        var edges: Edges = getEmpty();
        var l = arr.length;
        for( i in 0...l ) {
            edges[ i ] = Edge.fromArray( arr[ i ] );
        }
        return edges;
    }
    
    // "ok"
    // Given edges along with their quad-edge datastructure, flips the chosen edge
    // j, maintaining the quad-edge structure integrity.
    public inline
    function flipEdge( coEdges: Edges, sideEdges: Array<SideEdge>, j: Int ) {
      var edge = this[j];
      var coEdge = coEdges[j];
      var se = sideEdges[j];
      var j0 = se.a;
      var j1 = se.b;
      var j2 = se.c;
      var j3 = se.d;

      // Amend side edges 
      coEdges[j0].substitute( edge.p, coEdge.q);
      se = sideEdges[j0];
      se.substitute( j, j1 );
      se.substitute( j3, j );

      coEdges[j1].substitute( edge.p, coEdge.p);
      se = sideEdges[j1];
      se.substitute( j , j0);
      se.substitute( j2, j );

      coEdges[j2].substitute( edge.q, coEdge.p);
      se = sideEdges[j2];
      se.substitute( j , j3);
      se.substitute( j1, j );

      coEdges[j3].substitute( edge.q, coEdge.q);
      se = sideEdges[j3];
      se.substitute( j , j2);
      se.substitute( j0, j );

      // Flip
      this[j] = coEdges[j];
      coEdges[j] = edge.clone(); // in order to not effect the input

      // Amend primary edge
      var tmp = sideEdges[j].a;
      sideEdges[j].a = sideEdges[j].c;
      sideEdges[j].c = tmp;
    }
    public function toString() {
        var out = 'Edges( ';
        var e: Edge;
        for( i in 0...this.length ){
            e = this[i];
            out += e.toString() + ',';
        }
        out = out.substr( 0, out.length - 1 );
        out += ' )';
        return out;
    }
}
