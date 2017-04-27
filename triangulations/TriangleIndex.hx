package triangulations;
    // Created abstraction to make 't' cleaner to use.
    // Quote from 'findingEnclosedTriangle'
    // Indexing triangles here involves some evil hacking. 
    // A triangle is represented by an edge and a vertex of its co-edge.
    // Suppose the edge in question has number j, and k is 0 or 1 depending on which
    // co-edge vertex is chosen. Then the triangle index is t = 2 * j + k.
    
    // Introduced some abstracts to reduce the hack - t now uses TriangleIndex and j, k is EdgeVertexTriangle 
    
import triangulations.EdgeVertexTriangle;

abstract TriangleIndex( Int ) to Int from Int {
    inline public function new( t : Int) {
        this = t;
    }
    inline public function edgeVertexTriangle(){
        var vertexId = Std.int( this % 2 );
        var edgeId = Std.int( ( this - vertexId ) / 2 );
        return new EdgeVertexTriangle( edgeId, vertexId );
    }
    @:from
    static public function fromEdgeVertex( ev: EdgeVertexTriangle ) {
        return new TriangleIndex( 2 * ev.edgeId + ev.vertexId );
    }
}
