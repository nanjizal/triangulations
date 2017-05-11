package triangulations;
/**
 * Uses Delaunay to re-triangulate the edges.
 **/
class Delaunay {
    var unsure = new Array<Bool>();
    var tried = new Array<Int>();
    var cookie: Int = 0;
    public function new(){}
    /**
     * Refines the given triangulation graph to be a Conforming Delaunay
     * Triangulation (abr. CDT). Edges with property fixed = true are not altered.
     * 
     * The edges are modified in place and returned is an array of indices tried to
     *  flip. The flip was performed unless the edge was fixed. If a trace array is
     *  provided, the algorithm will log key actions into it.
     * 
     * @param   vertices
     * @param   edges
     * @param   coEdges
     * @param   sideEdges
     * @return                  tried edges
     */
    public inline
    function refineToDelaunay(  vertices:   Vertices
                            ,   edges:      Edges
                            ,   coEdges:    Edges
                            ,   sideEdges:  Array<SideEdge> )
                            :   Array<Int>
    {
        // We mark all edges as unsure, i.e., we don't know whether the enclosing
        // quads of those edges are properly triangulated.
        var unsureEdges = edges.getUnsure();
        return calculate( vertices, edges, coEdges, sideEdges, unsureEdges );
    }
    /**
     * 
     * @param   vertices
     * @param   edges
     * @param   coEdges
     * @param   sideEdges
     * @param   unsureEdges
     * @return                  tried edges
     */
    public inline
    function calculate(    vertices:   Vertices
                ,   edges:      Edges
                ,   coEdges:    Edges
                ,   sideEdges:  Array<SideEdge>
                ,   unsureEdges: Array<Int>
                ): Array<Int> {
        ++cookie;
        var triedEdges = unsureEdges.slice(0);// not sure if ideal replace with loop?
        for( l in 0...unsureEdges.length ) {
            unsure[ unsureEdges[ l ] ] = true;
            tried[ unsureEdges[ l ] ] = cookie;
        }
        // The procedure used is the incremental Flip Algorithm. As long as there are
        // any, we fix the triangulation around an unsure edge and mark the
        // surrounding ones as unsure.
        while( unsureEdges.length > 0 ){
            var j = unsureEdges.pop();
            unsure[j] = false;
            ensureDelaunayEdge( vertices, edges, coEdges, sideEdges, j );
            if ( !edges[j].fixed && !ensureDelaunayEdge( vertices, edges, coEdges, sideEdges, j ) ) {
                var newUnsureCnt = 0;
                for( jk in sideEdges[j] ){ 
                    if( !unsure[ jk ] ){
                        if (tried[ jk ] != cookie) {
                            triedEdges.push( jk );
                            tried[ jk ] = cookie;
                        }
                        if (!edges[ jk ].fixed) {
                            unsureEdges.push( jk );
                            unsure[ jk ] = true;
                            ++newUnsureCnt;
                        }
                    }
                }
                //if( newUnsureCnt > 0 ) trace( unsureEdges.slice(-newUnsureCnt) );
            }
        }
        return triedEdges;
    }
    /**
     * Given edges along with their quad-edge datastructure, flips the chosen edge
     * j if it doesn't form a Delaunay triangulation with its enclosing quad.
     * Returns true if a flip was performed.
     *
     * @param   vertices
     * @param   edges
     * @param   coEdges
     * @param   sideEdges
     * @param   j
     * @return          true if flipped
     */
    public static inline
    function ensureDelaunayEdge(  vertices:     Vertices
                                , edges:        Edges
                                , coEdges:      Edges
                                , sideEdges:    Array<SideEdge>
                                , j:            Int ): Bool {
      var out: Bool;
      if( isDelaunayEdge( vertices, edges[ j ], coEdges[ j ] ) ) {
          out = false;
      } else { 
          edges.flipEdge( coEdges, sideEdges, j );
          out = true;
      }
      return out;
    }
    
    public static inline
    function isDelaunayEdge(    vertices:   Vertices
                            ,   edge:       Edge
                            ,   coEdge:     Edge ): Bool{
        var a = vertices[ edge.p ];
        var c = vertices[ edge.q ];
        var b = vertices[ coEdge.p ];
        var d = vertices[ coEdge.q ];
        var in0 = !Geom2.pointInCircumcircle( a, c, b, d );
        var in1 = !Geom2.pointInCircumcircle( a, c, d, b );
        return in0 && in1;
    }
}
