// Ruppert's algorithm
// https://en.wikipedia.org/wiki/Ruppert%27s_algorithm
/*  Pseudocode
 1  function Ruppert(points,segments,threshold):
 2      T := DelaunayTriangulation(points);
 3      Q := the set of encroached segments and poor quality triangles;
 4      while Q is not empty:                 // The main loop
 5          if Q contains a segment s:
 6              insert the midpoint of s into T;
 7          else Q contains poor quality triangle t:
 8              if the circumcenter of t encroaches a segment s:
 9                  add s to Q;
10              else:
11                  insert the circumcenter of t into T;
12              end if;
13          end if;
14          update Q;
15      end while;
16      return T;
17  end Ruppert.
*/
package triangulations;
import triangulations.Geom2;
import khaMath.Vector2;
import triangulations.Triangulate;
import triangulations.FindEnclosingTriangle;
class Ruppert {
    
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
                    coEdgeK = coEdge.getByIndex( k );
                    
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
                    var encroachedEdges = new Array<Int>();
                    var insert = tryInsertPoint( vertices, edges, coEdges, sideEdges, encroachedEdges, p, j );
                    if( insert != null ){
                        affectedEdges = insert;
                        --steinerLeft;
                        //traceEntry.insert = 2 * j + k;
                    } else {
                        forceSplit = encroachedEdges;
                    }
                    break;
                  }
                  if (okCnt == 2) {
                        badTriangles.pop();
                        bad[j] = false;
                  }
                }
                
                //if (forceSplit.length > 0) traceEntry.split = [];
                while (forceSplit.length > 0 && steinerLeft > 0) {
                      var j = forceSplit.pop();
                      var affectedEdgesPart = Triangulate.splitEdge( vertices, edges, coEdges, sideEdges, j );
                      addArrayInt( affectedEdges, affectedEdgesPart );
                      --steinerLeft;
                      //traceEntry.split.push(j);
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
    
    public static inline
    function addArrayInt( e0: Array<Int>, e1: Array<Int> ): Array<Int> {
        var l = e0.length;
        var el = e1.length;
        for( i in 0...el ) e0[ l + i ] = e1[ i ];
        return e0;
    }
    
    private static
    function tryInsertPoint ( vertices: Vertices
                            , edges: Edges
                            , coEdges: Edges
                            , sideEdges:Array<SideEdge>
                            , encroachedEdges: Array<Int>
                            , p: Vector2
                            , j0: Int ):Array<Int> {
      var findTri = new FindEnclosingTriangle();
      var t = findTri.triangleIndex( vertices, edges, coEdges, sideEdges, p, j0 );
      if (t == null) return null;
      //var k = t % 2, j = (t - k) / 2;
      var ev = t.edgeVertexTriangle();
      var edgeId = ev.edgeId;
      var vertexId = ev.vertexId;
      
      var edge = edges[ edgeId ];
      var coEdge = coEdges[ edgeId ];
      var ai = edge.p;
      var a = vertices[ ai ];
      var bcj = sideEdges[ edgeId ].getByIndex( vertexId );
      var bi = coEdge.getByIndex( vertexId );
      var b = vertices[ bi ];
      var caj = edgeId;
      var ci = edge.q;
      var c = vertices[ ci ]; 
      var abj = sideEdges[ edgeId ].getByIndex( 3 - vertexId );

      // var encroachedEdges = [];
      if( edges[bcj].fixed && Geom2.pointEncroachesEdge( b, c, p ) ) encroachedEdges.push( bcj );
      if( edges[caj].fixed && Geom2.pointEncroachesEdge( c, a, p ) ) encroachedEdges.push( caj );
      if( edges[abj].fixed && Geom2.pointEncroachesEdge( a, b, p ) ) encroachedEdges.push( abj );
      // TODO pass in encroacedEdges so that can keep return simpler?
      if (encroachedEdges.length > 0) return null;
      vertices.push( p );
      var pi = vertices.length - 1;
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
      var delaunay = new Delaunay();
      return delaunay.calculate(    vertices
                                ,   edges
                                ,   coEdges
                                ,   sideEdges
                                ,   unsureEdges );
    }
    
    public static inline 
    function edgeIsEncroached(  vertices: Vertices
                            ,   edges:    Edges
                            ,   coEdges:  Edges
                            ,   edgeId: Int    ): Bool
    {
      var edge = edges[ edgeId ];
      var coEdge = coEdges[ edgeId ];
      var a = vertices[ edge.p ];
      var c = vertices[ edge.q ];
      var p = a.mid(c);
      var rSq = p.distSq(a);
      return ( coEdge.p != null && p.distSq( vertices[ coEdge.p ] ) <= rSq ) ||
             ( coEdge.q != null && p.distSq( vertices[ coEdge.q ] ) <= rSq );
    }
    
    
}
