package triangulations;
import triangulations.Geom2;
import triangulations.Triangulate;
import triangulations.FindEnclosingTriangle;
class Rupert {
    
    // "ok"
    private static inline 
    function arrToBack( a:Array<Int>, i: Int ){
        var tmp = a[ i ];
        a[ i ] = a[ a.length - 1 ];
        a[ a.length - 1 ] = tmp;
    } 
    
    // "NOT OK!"
    public static inline 
    function refineTo( vertices:     Vertices
                            , edges:        Edges
                            , coEdges:      Edges
                            , sideEdges:    Array<SideEdge>
                            , settings:     Settings ) {
        var encroached = [];
        var bad = [];
        if( settings == null ) settings = new Settings();
        if( settings.maxSteinerPoints == null ) settings.maxSteinerPoints = 50;
        var steinerLeft = settings.maxSteinerPoints;
        var minAngle = settings.minAngle;
        var maxArea = settings.maxArea;
        var isBad = Geom2.triangleIsBad( minAngle, maxArea );
        var encroachedEdges = [];
        var badTriangles = [];

        for( j in 0...edges.length ){
            if (edges[j].fixed) {
                encroachedEdges.push(j);
                encroached[j] = true;
            }
            badTriangles.push(j);
            bad[j] = true;
        }

        while (
            steinerLeft > 0 && (encroachedEdges.length > 0 || badTriangles.length > 0)
        ){
            var affectedEdges = [];
            var forceSplit = [];
            var traceEntry = {};
            if (encroachedEdges.length > 0) {
                var s = Math.floor(Math.random() * encroachedEdges.length);
                arrToBack(encroachedEdges, s);
                var j = encroachedEdges.pop();
                encroached[j] = false;
                if( edgeIsEncroached( vertices, edges, coEdges, j ) ) {
                    affectedEdges = Triangulate.splitEdge( vertices, edges, coEdges, sideEdges, j );
                    --steinerLeft;
                    //traceEntry.split = [j];
                }
            } else if (badTriangles.length > 0) {
                var s = Math.floor(Math.random() * badTriangles.length);
                arrToBack( badTriangles, s );
                var j = badTriangles[badTriangles.length - 1];
                var edge = edges[j];
                var coEdge = coEdges[j];
                var a = vertices[ edge.p ];
                var c = vertices[ edge.q ];
                var okCnt = 0;
                var coEdgeK: Int;
                for( k in 0...2 ){ // NOT Ideal!!
                    coEdgeK = if( k == 0 ){
                        coEdge.p;
                    } else {
                        coEdge.q;
                    }
                    
                    if( coEdgeK == null ) {
                        ++okCnt;
                        continue;
                    }
                    var b = vertices[ coEdgeK ];
                    if (!isBad(a, b, c)) {
                        ++okCnt;
                        continue;
                    }
                    var p = Geom2.circumcenter(a, b, c);
                    var insert = tryInsertPoint( vertices, edges, coEdges, sideEdges, p, j );
                    if( insert.success ){
                        affectedEdges = insert.affectedEdges;
                        --steinerLeft;
                        traceEntry.insert = 2 * j + k;
                    } else {
                        forceSplit = insert.encroachedEdges;
                    }
                    break;
                  }
                  if (okCnt == 2) {
                        badTriangles.pop();
                        bad[j] = false;
                  }
                }
                
                if (forceSplit.length > 0) traceEntry.split = [];
                while (forceSplit.length > 0 && steinerLeft > 0) {
                      var j = forceSplit.pop();
                      var affectedEdgesPart = Triangulate.splitEdge( vertices, edges, coEdges, sideEdges, j );
                      Array.prototype.push.apply(affectedEdges, affectedEdgesPart);
                      var l = affectedEdgesPart.length;
                      for( i in 0...l ) affectedEdges[ l + i ] = affectedEdgesPart[ i ];
                      --steinerLeft;
                      traceEntry.split.push(j);
                }

        while (affectedEdges.length > 0) {
            var j = affectedEdges.pop();
            if (edges[j].fixed && !encroached[j]) {
                encroachedEdges.push(j);
                encroached[j] = true;
            }
            if (!bad[j]) {
                badTriangles.push(j);
                bad[j] = true;
            }
        }
      }
    }
    
    private static
    function tryInsertPoint ( vertices: Vertices
                            , edges: Edges
                            , coEdges: Edges
                            , sideEdges:Array<SideEdge>
                            , p
                            , j0 ) {
      var findTri = new FindEnclosingTriangle();
      var t = findTri.getFace( vertices, edges, coEdges, sideEdges, p, j0 )();
      if (t == null)
        throw "impossibru";//return { success: true, affectedEdges: [] };

      var k = t % 2, j = (t - k) / 2;
      var edge = edges[ j ];
      var coEdge = coEdges[ j ];
      var ai = edge.p;
      var a = vertices[ ai ];
      var bcj = sideEdges[ j ].getByIndex( k );
      var bi = coEdge[ k ];
      var b = vertices[ bi ];
      var caj = j;
      var ci = edge.q;
      var c = vertices[ ci ]; 
      var abj = sideEdges[ j ].getByIndex( 3 - k );

      var encroachedEdges = [];
      if( edges[bcj].fixed && pointEncroachesEdge( b, c, p ) ) encroachedEdges.push( bcj );
      if( edges[caj].fixed && pointEncroachesEdge( c, a, p ) ) encroachedEdges.push( caj );
      if( edges[abj].fixed && pointEncroachesEdge( a, b, p ) ) encroachedEdges.push( abj );
      if (encroachedEdges.length > 0)
        return { success: false, encroachedEdges: encroachedEdges };

      var pi = vertices.push(p) - 1;
      edges.push( new Edge( pi, ai ) );
      var paj = edges.length - 1;
      edges.push( new Edge( pi, bi ) );
      var pbj = edges.length - 1;
      edges.push( new Edge( pi, ci ));
      var pcj = edges.length - 1;

      coEdges[ paj ] = new Edge( bi, ci );
      sideEdges[ paj ] = new SideEdge( abj, caj, pcj, pbj );

      coEdges[ pbj ] = new Edge( ci, ai );
      sideEdges[ pbj ] = new SideEdge( bcj, abj, paj, pcj );

      coEdges[ pcj ] = new Edge( ai, bi );
      sideEdges[ pcj ] = new SideEdge( caj, bcj, pbj, paj );

      coEdges[bcj].substitute( ai, pi );
      sideEdges[bcj].substitute( caj, pcj );
      sideEdges[bcj].substitute( abj, pbj );

      coEdges[caj].substitute( bi, pi );
      sideEdges[caj].substitute( abj, paj );
      sideEdges[caj].substitute( bcj, pcj );

      coEdges[abj].substitute( ci, pi );
      sideEdges[abj].substitute( bcj, pbj );
      sideEdges[abj].substitute( caj, paj );

      var unsureEdges = [];
      if( !edges[bcj].fixed ) unsureEdges.push(bcj);
      if( !edges[caj].fixed ) unsureEdges.push(caj);
      if( !edges[abj].fixed ) unsureEdges.push(abj);

      return {
        success: true,
        affectedEdges: Triangulate.maintainDelaunay(    vertices
                                        ,   edges
                                        ,   coEdges
                                        ,   sideEdges
                                        ,   unsureEdges )
      };
    }
    
    public static inline 
    function edgeIsEncroached(  vertices: Vertices
                            ,   edges:    Edges
                            ,   coEdges:  Edges
                            ,   j: Int    ): Bool
    {
      var edge = edges[j];
      var coEdge = coEdges[j];
      var a = vertices[ edge.p ];
      var c = vertices[ edge.q ];
      var p = a.mid(c);
      var rSq = p.distSq(a);
      return ( coEdge.p != null && p.distSq( vertices[ coEdge.p ] ) <= rSq ) ||
             ( coEdge.q != null && p.distSq( vertices[ coEdge.q ] ) <= rSq );
    }
    
    
}
