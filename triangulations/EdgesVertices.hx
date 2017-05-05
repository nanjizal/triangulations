package triangulations;
import triangulations.Edges;
import triangulations.Vertices;
import triangulations.Edge;
import khaMath.Vector2;
// just used for hitTest edges and vertices
class EdgesVertices {
    public var edges: Edges;
    public var vertices: Vertices;
    public static function fromShape( f: FillShape ): EdgesVertices {
        return new EdgesVertices( f.edges, f.vertices );
    }
    public function new( edges_: Edges, vertices_: Vertices ){
        edges = edges_;
        vertices = vertices_;
    }
    inline public 
    function hitTestEdgeId( v: Vector2, dist: Float ): Int {
        var l = edges.length;
        var e: Edge;
        var v0: Vector2;
        var v1: Vector2;
        var distance: Float;
        var near = 10000000000;
        var out: Null<Int> = null;
        // find closest edge
        for( i in 0...l ){
            e = edges[i];
            v0 = vertices[e.p];
            v1 = vertices[e.q];
            distance = (v0.mid(v1)).distSq( v );
            if( near > distance ){
                near = distance;
                out = i;
            }
        }
        // check if it's near
        if( near > Math.pow( dist,2 ) ) out = null;
        return out;
    }
    inline public 
    function hitTestVertexId( v: Vector2, dist: Float ): Int {
        var l = vertices.length;
        var v0: Vector2;
        var distance: Float;
        var near = 10000000000;
        var out: Null<Int> = null;
        // find closest edge
        for( i in 0...l ){
            v0 = vertices[i];
            distance = v0.distSq( v );
            if( near > distance ){
                near = distance;
                out = i;
            }
        }
        // check if it's near
        if( near > Math.pow( dist,2 ) ) out = null;
        return out;
    }
    // negative for edge -1, positive for vertex 
    //
    /* example use
        var i = edgesVertices.hitTestId( hitVector2, distance );
        if( i == null ) return;
        if( i < 0 ) {
            i = -i - 1; 
            trace( 'edge found ' + i );
        } else {
            trace( 'vertex found ' + i );
        }
    */
    inline public 
    function hitTestId( v: Vector2, dist: Float ): Int {
        var l: Int;
        var e: Edge;
        var distance: Float;
        var v0: Vector2;
        var v1: Vector2;
        // check edges
        l = edges.length;
        var nearEdge = 10000000000.;
        var edgeId: Null<Int> = null;
        // find closest edge
        for( i in 0...l ){
            e = edges[i];
            if( e == null ) continue;
            v0 = vertices[e.p];
            if( v0 == null ) continue;
            v1 = vertices[e.q];
            if( v1 == null ) continue;
            distance = (v0.mid(v1)).distSq( v );
            if( nearEdge > distance ){
                nearEdge = distance;
                edgeId = i;
            }
        }
        // check vertices
        var l = vertices.length;
        var nearVertex = 10000000000.;
        var vertexId: Null<Int> = null;
        // find closest edge
        for( i in 0...l ){
            v0 = vertices[i];
            if( v0 == null ) continue;
            distance = v0.distSq( v );
            if( nearVertex > distance ){
                nearVertex = distance;
                vertexId = i;
            }
        }
        // trace( 'vertexId ' + vertexId + ' edgeId ' + edgeId );
        // check if it's near
        var out: Null<Int> = null;
        if( nearVertex <= nearEdge ){
            if( nearVertex > Math.pow( dist,2 ) ) {
                out = null;
            } else {
                out = vertexId;
            }
        } else {
            if( nearEdge > Math.pow( dist,2 ) ) {
                out = null;
            } else {
                // edges negated and -1 so they are different from vertex output.
                out = -edgeId - 1;
            }
        }
        return out;
    }
}
