package triangulations;
import mathKha.Vector2;
import triangulations.Vectices;
import triangulations.Edges;

class Graph {
    public var vertices:    Vertices;
    public var edges:       Edges;
    public var faces:       Array<Array<Int>>;
    public function new(    vertices_: Vectices   = new Vectices()
                        ,   edges_: Edges         = new Edges()
                        ,   faces_: Array<Array<Int>>    = new Array<Array<Int>> ){
        if( faces_[0] == null ) faces_[0] = new Array<Int>();
        vertices   = vertices_;
        edges       = edges_;
        faces       = faces_;
    }
    
    // return 1, +1, 0
    public inline
    function faceOrientation( k: int): Int {
        var face = faces[ k ];
        // The outermost polygon is the one with the leftmost vertex. This may not
        // be true if there are tangent polygons, but we don't bother.
        var outerPoly = face[ 0 ];
        var xMin = vertices[ outerPoly[ 0 ] ].x;
        for( l in 0...face.length ) {
            var poly = face[l];
            for( var m in 0...poly.length ){
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

}
