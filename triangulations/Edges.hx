package triangulations;
import triangulations.Geom2;

abstract Edges( Array<Edge> ) from Array<Edge> to Array<Edge> {
    inline public function new( v: Array<Edge> ) {
      this = v;
    }
    public /*inline*/ function set_fixedExternal( val: Bool ){
        for( e in this ) {
            e.fixed = val;
            e.external = val;
        }
        return val;
    }
    public var fixedExternal( default, set ):Bool;
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
}
