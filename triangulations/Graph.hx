package triangulations;
import khaMath.Vector2;
import triangulations.Vertices;
import triangulations.Edges;
import triangulations.Face;

class Graph {
    public var vertices:    Vertices;
    public var edges:       Edges;
    public var faces:       Array<Array<Face>>;
    public function new(    vertices_:  Vertices
                        ,   edges_:     Edges
                        ,   faces_:     Array<Array<Face>> ){
        if( vertices_ == null ) vertices_ = new Vertices();
        if( edges_ == null ) edges_ = new Edges();
        if( faces_ == null ) faces_ = new Array<Array<Face>>();
        if( faces_[0] == null ) faces_[0] = new Array<Face>();
        if( faces_[0][0] == null ) faces_[0][0] = new Array<Int>();
        vertices   = vertices_;
        edges       = edges_;
        faces       = faces_;
    }
    
    // return 1, +1, 0
    public inline
    function faceOrientation( k: Int ): Int {
        var face = faces[ k ]; // Face  // Array<Int>
        // The outermost polygon is the one with the leftmost vertex. This may not
        // be true if there are tangent polygons, but we don't bother.
        var outerPoly = face[ 0 ];
        var xMin = vertices[ outerPoly[0] ].x;
        for( l in 0...face.length ) {
            var poly = face[l];
            for( m in 0...poly.length ){
                var i = poly[m];
                var x = vertices[ i ].x;
                if (x < xMin) {
                    outerPoly = poly;
                    break;
                }
            }
        }
        return vertices.polygonOrientation( outerPoly );
    }
    
    // Assuming the graph is planar, computes its faces.
    public inline
    function computeFaces(){
        var vertices = this.vertices;
        var edges = this.edges.clone(); // We don't wanna modify the original edges
        var n = vertices.length;
        var m = edges.length;
        
        // Direct the edges
        for( j in 0...m ){
            var e = edges[j];
            edges.push( new Edge( e.p, e.q ) );
        }
        m *= 2;
        
        // For each vertex, find outgoing edges.
        var outEdges = [];
        for( i in 0...n ) outEdges[ i ] = [];
        
        for( j in 0...m ) {
            var e = edges[ j ];
            outEdges[ e.p ].push( j );
        }
        
        // Add looping edges for isolated vertices.
        for( i in 0...n ) {
            if (outEdges[i].length == 0) {
                edges.push( new Edge( i, i ) );
                outEdges[i].push(m);
                ++m;
            }
        }
        
        // Initialize the edge-taken array.
        var taken = new Array<Bool>();
        for( j in 0...m ) taken[ j ] = false;

        // For every edge, find the polygon it belongs to.
        var polies = [];
        for( j0 in 0...m ){
            if( taken[j0] ) continue;
            var iPrev = edges[ j0 ].p;
            var i = edges[ j0 ].q;
            var iFirst = iPrev;
            var poly = [ iPrev ];
            while( i != iFirst){
                // Find the edge with the smallest angle with respect to the incoming
                // direction.
                var cmp = Geom2.angleCompare( vertices[i], vertices[iPrev] );
                var kBest = -1;
                var vBest = null;
                for( k in 0...outEdges[i].length ){
                    var j = outEdges[i][k];
                    if( edges[j].q == iPrev ) continue;
                    var v = vertices[ edges[j].q ];
                    if( kBest < 0 || cmp( v, vBest ) < 0 ) {
                        kBest = k;
                        vBest = v;
                    }
                 }
                 // Turn back in case of a dead-end. It is guaranteed that the returning
                 // edge is the only outgoing left.
                 if (kBest < 0) kBest = 0;
                 
                 // Mark the next edge as taken.
                 jBest = outEdges[i][kBest];
                 taken[jBest] = true;
                 outEdges[i][kBest] = outEdges[i].pop(); // Tricky array remove.
                 
                 // Proceed
                 poly.push(i);
                 iPrev = i;
                 i = edges[jBest][1];
            }
            polies.push(poly);
        }

        // Some faces, namely those with holes, consist of multiple polygons. Here,
        // we assemble them.

        // Find the full polygons and the holes.
        var faces = [];
        var holes = [];
        for( k in 0...polies.length ){
            if( Geom2.polygonOrientation( vertices, polies[ k ] ) > 0){
                faces.push([polies[k]]);
            } else {
              holes.push(polies[k]);
            }
        }

        // Distribute holes to their respective faces. Holes not inside any filled
        // poly, belong to the "outer" (infinite) face.
        var outerFace = [];
        for( l in 0...holes.length ){
            var hole = holes[ l ];
            var v = vertices[ hole[ 0 ] ];
            var foundFace = false;
            for( k in 0...faces.length ){
                var poly = faces[k][0];
                if( Geom2.pointInPolygon( vertices, poly, v ) ){
                    faces[ k ].push( hole );
                    foundFace = true;
                    break;
                }
            }
            if( !foundFace ) outerFace.push( hole );
        }
        faces.push( outerFace );
        this.faces = faces;
    }
    
}
