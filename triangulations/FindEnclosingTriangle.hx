package triangulations;
import triangulations.Vertices;
import triangulations.Edges;
import triangulations.SideEdge;
import triangulations.Queue;
import triangulations.Face;
import triangulations.TriangleIndex;
import triangulations.EdgeVertexTriangle;
import khaMath.Vector2;

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
    // Introduced some abstracts to reduce the hack - t now uses TriangleIndex and j, k is EdgeVertexTriangle 
class FindEnclosingTriangle {
    var enqueued    = new Array<Int>();
    var cookie:     Int = 0;
    var queue:      Queue<TriangleIndex>;
    var edges:      Edges;
    var coEdges:    Edges;
    var sideEdges:  Array<SideEdge>;
    
    public function new(){}
    // We use a helper function to enqueue triangles since our indexing is
    // ambiguous -- each triangle has three indices. To prevent multiple visits,
    // all three are marked as already enqueued. Trianglea already enqueued and
    // Invalid triangles supported by external edges are rejected.
    inline
    function tryEnqueue( ev: EdgeVertexTriangle ): Bool {
        var t: TriangleIndex = ev;
        var out: Bool;
        var pq: Int;
        if( ev.vertexId == 0 ) {
            pq = coEdges[ ev.edgeId ].p;
        } else {
            pq = coEdges[ ev.edgeId ].q;
        }
        if( enqueued[ t ] == cookie || pq == null ) {
            out = false;
        } else {
            queue.enqueue( t );
            var j0 = sideEdges[ ev.edgeId ].getByIndex( ev.vertexId );
            var j1 = sideEdges[ ev.edgeId ].getByIndex( 3 - ev.vertexId );
            var jp = edges[ ev.edgeId ].p;
            var t0: TriangleIndex = new EdgeVertexTriangle( j0, ( coEdges[j0].p == jp ? 0 : 1 ) );
            var t1: TriangleIndex = new EdgeVertexTriangle( j1, ( coEdges[j1].p == jp ? 0 : 1 ) );
            enqueued[ t ] = enqueued[ t0 ] = enqueued[ t1 ] = cookie;
            out = true;
        }
        return out;
    }
    public inline
    function triangleIndex(     vertices:   Vertices
                    ,     edges_:      Edges
                    ,     coEdges_:    Edges
                    ,     sideEdges_:  Array<SideEdge>
                    ,     p:          Vector2
                    ,     j0:         Int 
                    ):    TriangleIndex {
        edges = edges_;
        coEdges = coEdges_;
        sideEdges = sideEdges_;
        
        queue = new Queue<TriangleIndex>();
        ++cookie;
        // We start at two triangles adjacent to edge j.
        tryEnqueue( new EdgeVertexTriangle( j0, 0 ) ); 
        tryEnqueue( new EdgeVertexTriangle( j0, 1 ) ); 
        var t_: TriangleIndex = null;
        while( !queue.isEmpty() ){
            var t = queue.dequeue();
            var ev = t.edgeVertexTriangle();
            //var k = t % 2;
            //var j = Std.int( (t - k) / 2 );
            var ai = edges[ ev.edgeId ].p;  
            var a = vertices[ai];
            var bi: Int;
            if( ev.vertexId == 0 ){
                bi = coEdges[ ev.edgeId ].p; // :(
            } else {
                bi = coEdges[ ev.edgeId ].q;
            }
            var b = vertices[bi];
            var ci = edges[ ev.edgeId ].q;  
            var c = vertices[ci];
            if( Geom2.pointInTriangle(a, b, c)( p ) ) {
                t_ = t;
                break;
            } 
            // Continue search to triangles adjacent to edges opposite to vertices a and
            // c. The other triangle, adjacent to edge j, i.e., opposite to b, is not
            // further examined as this is the direction we are coming from.
            var ja = sideEdges[ ev.edgeId ].getByIndex( ev.vertexId ); // :(
            var jc = sideEdges[ ev.edgeId ].getByIndex( 3 - ev.vertexId );
            // Falling through a fixed edge is not allowed.
            if( edges[ja] != null ) if( !edges[ja].fixed ) {
                tryEnqueue( new EdgeVertexTriangle( ja, coEdges[ja].p == ai ? 1 : 0 ) );
            }
            if( edges[jc] != null ) if( !edges[jc].fixed ) {
                tryEnqueue( new EdgeVertexTriangle( jc, coEdges[jc].p == ci ? 1 : 0 ) );
            }
        }
        return t_;
    }
    
    
    public inline
    function getFace(     vertices:   Vertices
                    ,     edges_:      Edges
                    ,     coEdges_:    Edges
                    ,     sideEdges_:  Array<SideEdge>
                    ,     p:          Vector2
                    ,     j0:         Int 
                    ):    Face {
        return triangleIndex( vertices, edges_, coEdges_, sideEdges_, p, j0 ).getFace( edges_, coEdges );
    }
}
