package triangulations;
import triangulations.Vertices;
import triangulations.Edges;
import triangulations.SideEdge;
import triangulations.Queue;
import triangulations.Face;
import khaMath.Vector2;
  
// This is not really nice to understand :(
    
    // Finds the triangle enclosing the given point p. The quad-edge datastructure
    // has to be provided. The search is started from the triangles adjecent to
    // edge j0 and proceeds to to neighboring triangles. Falling through fixed
    // edges, i.e., with property fixed = true, is not permitted, so providing a j0
    // which is in another connected component won't yield any result.
    //
    // The result is a triangle index. Indexing triangles here involves some evil
    // hacking. A triangle is represented by an edge and a vertex of its co-edge.
    // Suppose the edge in question has number j, and k is 0 or 1 depending on which
    // co-edge vertex is chosen. Then the triangle index is t = 2 * j + k.
    
    // UNTESTED but can compile as import
class FindEnclosingTriangle {
    var enqueued    = new Array<Int>();
    var cookie:     Int = 0;
    var queue:      Queue<Int>;
    var edges:      Edges;
    var coEdges:    Edges;
    var sideEdges:  Array<SideEdge>;
    
    public function new(){}
    // We use a helper function to enqueue triangles since our indexing is
    // ambiguous -- each triangle has three indices. To prevent multiple visits,
    // all three are marked as already enqueued. Trianglea already enqueued and
    // Invalid triangles supported by external edges are rejected.
    inline
    function tryEnqueue( j: Int, k: Int ): Bool {
        var t = 2 * j + k;
        var out: Bool;
        var pq: Int;
        if( k == 0 ) {
            pq = coEdges[ j ].p;
        } else {
            pq = coEdges[ j ].q;
        }
        
        if( enqueued[ t ] == cookie || pq == null ) {
            out = false;
        } else {
            queue.enqueue( t );
            var j0 = sideEdges[ j ].getByIndex( k );
            var j1 = sideEdges[ j ].getByIndex( 3 - k );
            var jp = edges[j].p;
            enqueued[ t ] = enqueued[ 2 * j0 + ( coEdges[j0].p == jp ? 0 : 1 ) ]
                        = enqueued[ 2 * j1 + ( coEdges[j1].p == jp ? 0 : 1 ) ]
                        = cookie;
            out = true;
        }
        return out;
    }
    public
    function getFace(     vertices:   Vertices
                    ,     edges_:      Edges
                    ,     coEdges_:    Edges
                    ,     sideEdges_:  Array<SideEdge>
                    ,     p:          Vector2
                    ,     j0:         Int 
                    ):    Void->Face {
        return function() {
            edges = edges_;
            coEdges = coEdges_;
            sideEdges = sideEdges_;
            queue = new Queue<Int>();
            ++cookie;
            // We start at two triangles adjacent to edge j.
            tryEnqueue( j0, 0 ); 
            tryEnqueue( j0, 1 ); 
            var t_ = null;
            while( !queue.isEmpty() ){
                var t = queue.dequeue();
                var k = t % 2;
                var j = Std.int( (t - k) / 2 );
                var ai = edges[j].p;  
                var a = vertices[ai];
                var bi: Int;
                if( k == 0 ){
                    bi = coEdges[j].p; // :(
                } else {
                    bi = coEdges[j].q;
                }
                var b = vertices[bi];
                var ci = edges[j].q;  
                var c = vertices[ci];
                if( Geom2.pointInTriangle(a, b, c)( p ) ) {
                    t_ = t;
                    break;
                } 
                // Continue search to triangles adjacent to edges opposite to vertices a and
                // c. The other triangle, adjacent to edge j, i.e., opposite to b, is not
                // further examined as this is the direction we are coming from.
                var ja = sideEdges[j].getByIndex( k ); // :(
                var jc = sideEdges[j].getByIndex( 3 - k );
                // Falling through a fixed edge is not allowed.
                if( edges[ja] != null ) if( !edges[ja].fixed ) tryEnqueue( ja, coEdges[ja].p == ai ? 1 : 0 );
                if( edges[jc] != null ) if( !edges[jc].fixed ) tryEnqueue( jc, coEdges[jc].p == ci ? 1 : 0 );
            }
            var face: Face = null;
            if ( t_ != null ) {
                var k = Std.int( t_ % 2 );
                var j = Std.int( (t_ - k) / 2 );
                var c: Int;
                if( k == 0 ){
                    c = coEdges[j].p;
                } else {
                    c = coEdges[j].q;
                }
                face = [ edges[j].p, edges[j].q, c ];
            }
            return face;
        };
    }
}
