package triangulations;
import triangulations.EdgeVertexTriangle;
/**
 * Created abstraction to make 't' cleaner to use.
 * Quote from 'findingEnclosedTriangle'
 * Indexing triangles here involves some evil hacking. 
 * A triangle is represented by an edge and a vertex of its co-edge.
 * Suppose the edge in question has number j, and k is 0 or 1 depending on which
 * co-edge vertex is chosen. Then the triangle index is t = 2 * j + k.
 * Introduced some abstracts to reduce the hack - t now uses TriangleIndex and j, k is EdgeVertexTriangle 
 **/  
abstract TriangleIndex( Int ) to Int from Int {
    inline public
    function new( t : Int) {
        this = t;
    }
    /**
     * converts to EdgeVectexTriangle
     *
     **/
    inline public 
    function edgeVertexTriangle(){
        var vertexId = Std.int( this % 2 );
        var edgeId = Std.int( ( this - vertexId ) / 2 );
        return new EdgeVertexTriangle( edgeId, vertexId );
    }
    /**
     * converts EdgeVertexTriangle to TriangleIndex
     *
     * @param   ev                  converts from EdgeVertexTriangle data
     * @return  TriangleIndex
     **/
    @:from
    static public
    function fromEdgeVertex( ev: EdgeVertexTriangle ) {
        return new TriangleIndex( 2 * ev.edgeId + ev.vertexId );
    }
    /**
      * converts TriangeIndex into face
      * 
      * @param  edges
      * @param  coEdges
      * @return             returns a face
      **/
    inline public
    function getFace( edges: Edges, coEdges: Edges ): Face {
        var face: Face = null;
        if( this != null ) {
            var ev = edgeVertexTriangle();
            face = [  edges[ ev.edgeId ].p
                    , edges[ ev.edgeId ].q
                    , ( ev.vertexId == 0 )?coEdges[ ev.edgeId ].p: coEdges[ ev.edgeId ].q  ];
        }
        return face;    
    }
}
