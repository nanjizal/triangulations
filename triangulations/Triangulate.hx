package triangulations;

import khaMath.Vector2;
import triangulations.DllNode;
import triangulations.SideEdge;
import triangulations.Edge;
import triangulations.Edges;
import triangulations.Vertices;
import triangulations.Queue;
import triangulations.Face;

class Triangulate {
    
    public static inline
    function triangulateSimple( vertices: Vertices, edges: Edges, face: Array<Array<Face>> ) {
        for ( k in 0...face.length ) {
            var diags = triangulateFace( vertices, face[ k ] );
            edges.add( diags );
        }
    }
    
    public static inline
    function triangulateFace(  vertices:   Vertices
                            ,  face:      Array<Face> ){
        // Convert the polygon components into linked lists. We assume the first
        // polygon is the outermost, and the rest, if present, are holes.
        var polies = [ makeLinkedPoly( face[ 0 ] ) ];
        var holes = [];
        var l = face.length;
        for ( k in 1...l ){
          holes.push( makeLinkedPoly( face[ k ] ) );
        }
        
        // We handle only the outer polygons. We start with only one, but more are
        // to come because of splitting. The holes are eventually merged in.
        // In each iteration a diagonal is added.
        var diagonals = new Edges();
        while( polies.length > 0 ){
            var poly = polies.pop();
            // First we find a locally convex vertex.
            var node = poly;
            var a: Vector2;
            var b: Vector2;
            var c: Vector2;
            var convex = false;
            do {
                a = vertices[ node.prev.value ];
                b = vertices[ node.value ];
                c = vertices[ node.next.value ];
                convex = (a.span(b)).cross(b.span(c)) < 0;
                node = node.next;
            } while( !convex && node != poly);

            if(!convex) continue;
            var aDllNode = node.prev.prev;
            var bDllNode = node.prev;
            var cDllNode = node;

            // We try to make a diagonal out of ac. This is possible only if it lies
            // completely inside the polygon.
            var acOK = true;

            // Ensuring there are no intersections of ac with other edges doesn't
            // guarantee that ac lies within the poly. It is also possible that the
            // whole polygon is inside the triangle abc. Therefore we early reject the
            // case when the immediate neighbors of vertices a and c are inside abc.
            // Note that if ac is already an edge, it will also be rejected.
            var inabc = Geom2.pointInTriangle( a, b, c );
            acOK = !inabc( vertices[ aDllNode.prev.value ] ) && !inabc( vertices[ cDllNode.next.value ] );
            
            // Now we proceed with checking the intersections with ac.
            if( acOK ) acOK = !intersects( a, c, vertices, cDllNode.next, aDllNode.prev );
            var holesLen = holes.length;
            for( l in 0...holesLen ){
                acOK = !intersects( a, c, vertices, holes[ l ] );
                if( !acOK ) break; // moved this to get same out as example but unsure if correct.
            }
            
            var split;
            var fromDllNode;
            var toDllNode;
            if( acOK ){
              // No intersections. We can easily connect a and c.
              fromDllNode = cDllNode;
              toDllNode = aDllNode;
              split = true;
            } else {
              // If there are intersections, we have to find the closes vertex to b in
              // the direction perpendicular to ac, i.e., furthest from ac. It is
              // guaranteed that such a vertex forms a legal diagonal with b.
              var findBest = findDeepestInside(a, b, c);
              var best = 
                  if( cDllNode.next != aDllNode ){
                      findBest( vertices, cDllNode.next, aDllNode );
                  } else {
                      null; 
                  }
              var lHole = -1;
              var holesLen = holes.length;// TODO: check if need to redefine does findBest effect?
              for( l in 0...holesLen ) {
                  var newBest = findBest( vertices, holes[l], holes[l], best );
                  if( newBest != best ) lHole = l;
                  best = newBest;
              }
              
              fromDllNode = bDllNode;
              toDllNode = best;
              if( lHole < 0 ){
                // The nearest vertex does not come from a hole. It is lies on the outer
                // polygon itself (or is undefined).
                split = true;
              } else {
                // The nearest vertex is found on a hole. The hole will be merged into
                // the currently processed poly, so we remove it from the hole list.
                holes.splice( lHole, 1 );
                split = false;
              }
          }

          if( toDllNode == null ) {
            // It was a triangle all along!
            continue;
          }

          diagonals.push( new Edge( fromDllNode.value, toDllNode.value ) );
          //if (trace !== undefined) {
            //trace.push({
              //selectFace: makeArrayPoly( poly ),
              //addDiag: [fromDllNode.value, toDllNode.value ]
            //});
          //}

          // TODO: Elaborate
          var poly1 = new DllNode( fromDllNode.value );
          poly1.next = fromDllNode.next; 
          var tempDllNode = new DllNode( toDllNode.value );
          tempDllNode.prev = toDllNode.prev;
          tempDllNode.next = poly1;
          poly1.prev = tempDllNode;
          fromDllNode.next.prev = poly1;
          toDllNode.prev.next = poly1.prev;

          fromDllNode.next = toDllNode;
          toDllNode.prev = fromDllNode;
          var poly2 = fromDllNode;
          if( split ){
              polies.push( poly1 );
              polies.push( poly2 );
          } else {
              polies.push( poly2 );
          }
        }
        return diagonals;
    }
    
    // Given a polygon as a list of vertex indices, returns it in a form of
    // a doubly linked list.
    public static inline
    function makeLinkedPoly( face: Array<Int> ): DllNodeInt {
        var linkedPoly = new DllNodeInt( face[ 0 ] );
        var node = linkedPoly;
        var l = face.length;
        for( i in 1...l ) {
            var prevDllNode = node;
            node = new DllNodeInt( face[ i ] );
            prevDllNode.next = node;
            node.prev = prevDllNode;
        }
        node.next = linkedPoly;
        linkedPoly.prev = node;
        return linkedPoly;
    }
    
    public static inline
    function isDelaunayEdge(    vertices:   Vertices
                            ,   edge:       Edge
                            ,   coEdge:     Edge ): Bool{
      var a = vertices[ edge.p ];
      var c = vertices[ edge.q ];
      var b = vertices[ coEdge.p ];
      var d = vertices[ coEdge.q ];
      return !Geom2.pointInCircumcircle( a, c, b, d ) &&
             !Geom2.pointInCircumcircle( a, c, d, b );
    }
    
    // Checks wether any edge on path [nodeBeg, nodeEnd] intersects the segment ab.
    // If nodeEnd is not provided, nodeBeg is interpreted as lying on a cycle and
    // the whole cycle is tested. Edges spanned on equal (===) vertices are not
    // considered intersecting.
    public static inline
    function intersects(    a:          Vector2
                        ,   b:          Vector2
                        ,   vertices:   Vertices
                        ,   nodeBeg:    DllNodeInt
                        ,   ?nodeEnd:    DllNodeInt = null ): Bool {
       var out = false;
       if( nodeEnd == null ) {
         if( aux( vertices, a, b, nodeBeg ) ){
             out = true;
         } else {
             nodeEnd = nodeBeg;
             nodeBeg = nodeBeg.next;
         }
      }
      if( out!= true ){
          var node = nodeBeg;
          while( node!= nodeEnd ){
              if( aux( vertices, a, b, node ) ){ 
                  out = true;
                  break;
              } else {
                  node = node.next;
              }
          }
      }
      return out;
    }
    
    public static inline
    function aux( vertices: Vertices, a: Vector2, b: Vector2, node: DllNodeInt ): Bool {
        var c = vertices[ node.value ];
        var d = vertices[ node.next.value ];
        return c != a && c != b && d != a && d != b && Geom2.edgesIntersect( a, b, c, d );
    }
    
    public static inline
    function findDeepestInside( a: Vector2, b: Vector2, c: Vector2 )
                            : Vertices -> DllNodeInt -> DllNodeInt -> ?DllNodeInt -> DllNodeInt {
      
      var inabc     = Geom2.pointInTriangle( a, b, c );
      var acDistSq  = Geom2.pointToEdgeDistSq( a, c );
      
      return 
          function( vertices: Vertices
                  , nodeBeg: DllNodeInt
                  , nodeEnd: DllNodeInt
                  , ?bestDllNode: DllNodeInt = null ): DllNodeInt {
                      
              var v: Int; 
              var maxDepthSq = 
                  if( bestDllNode != null ){
                      v = bestDllNode.value;
                      acDistSq( vertices[ v ] );
                  } else {
                    -1;
                  }
              
              var node = nodeBeg;
              do {
                  var v = vertices[ node.value ];
                  if(v != a && v != b && v != c && inabc( v )) {
                      var depthSq = acDistSq( v );
                      if( depthSq > maxDepthSq ) {
                          maxDepthSq = depthSq;
                          bestDllNode = node;
                      }
                  }
                  node = node.next;
               } while (node != nodeEnd);
               
               return bestDllNode;
           };
    }
    
    // Given a triangulation graph, produces the quad-edge datastructure for fast
    // local traversal. The result consists of two arrays: coEdges and sideEdges
    // with one entry per edge each. The coEdges array is returned as list of vertex
    // index pairs, whereas sideEdges are represented by edge index quadruples.
    //
    // Consider edge ac enclosed by the quad abcd. Then its co-edge is bd and the
    // side edges are: bc, cd, da, ab, in that order. Although the graph is not
    // directed, the edges have direction implied by the implementation. The order
    // of side edges is determined by the de facto orientation of the primary edge
    // ac and its co-edge bd, but the directions of the side edges are arbitrary.
    //
    // External edges are handled by setting indices describing one supported
    // triangle to undefined. Which triangle it will be is not determined.
    //
    // WARNING: The procedure will change the orientation of edges.
    // 
    public static 
    function makeQuadEdge( vertices: Vertices
                        ,  edges: Edges
                        , coEdges: Edges
                        , sideEdges: Array<SideEdge> ) {
      // Prepare datas tructures for fast graph traversal.  
      // !!!! pass coEdges and SideEdges in rather than return object of them.  !!!
      //var coEdges = [];
      //var sideEdges = [];
      for( j in 0...edges.length ){
        coEdges[ j ] = new Edge( null, null );
        sideEdges[ j ] = SideEdge.getEmpty();
      }

      // Find the outgoing edges for each vertex
      var outEdges = new Array<Array<Int>>();
      for( i in 0...vertices.length )
        outEdges[ i ] = new Array<Int>();
      for( j in 0...edges.length ){
        var e = edges[ j ];
        outEdges[ e.p ].push( j );
        outEdges[ e.q ].push( j );
      }
      var l = vertices.length;
      // Process edges around each vertex.
      for( i in 0...l ){
        var v = vertices[i];
        var js = outEdges[i];

        // Reverse edges, so that they point outward and sort them angularily.
        for( k in 0...js.length ) {
          var e = edges[js[k]];
          if( e.p != i ) {
            e.q = e.p;
            e.p = i;
          }
        }
        
        var angleCmp = Geom2.angleCompare( v, vertices[ edges[ js[ 0 ] ].q ] );
        js.sort(function (j1: Int, j2: Int) {
          return Std.int( angleCmp( vertices[ edges[j1].q ], vertices[ edges[j2].q ]) );
        });

        // Associate each edge with neighbouring edges appropriately.
        for( k in 0...js.length ) {
          var jPrev = js[(js.length + k - 1) % js.length];
          var j     = js[k];
          var jNext = js[(k + 1) % js.length];
          // DllNode that although we could determine the whole co-edge just now, we
          // we choose to push only the endpoint edges[jPrev][1]. The other end,
          // i.e., edges[jNext][1] will be, or already was, put while processing the
          // edges of the opporite vertex, i.e., edges[j][1].
          coEdges[j].push( edges[ jPrev ].q );
          sideEdges[j].push( jPrev );
          sideEdges[j].push( jNext );  
        }
        
      }

      // Amend external edges
      // THIS DOES NOT SEEM TO BE USED???
      function disjoint( i: Int, j: Int ) { 
          return edges[j].p != i && edges[j].q != i;
      }
      
      for( j in 0...edges.length ){
        if( !edges[j].external ) continue;
        var ce = coEdges[ j ]; 
        var ses = sideEdges[ j ];

        // NOT Working?? Comment out ...

        // If the whole mesh is a triangle, just remove one of the duplicate entries
        if( ce.p == ce.q ) {
          ce.q = ses.b = ses.c = null;
          continue;
        }
        
        // TODO: Fix / Rework
        // This seems to partially destroy half an Edge and sideEdge from coEdges/sideEdges,
        // surely they need to be removed for safety once that is done otherwise easily break rendering?
        // 
        // NOT Working!! Comment out ...
        /*
        // If the arms of a supported triangle are also external, remove.
        if( edges[ ses.a ].external && edges[ ses.d ].external)
          ce.p = ses.a = ses.d = null;
        if( edges[ ses.b ].external && edges[ ses.c ].external)
          ce.q = ses.b = ses.c = null;  
        */
      }
      
    }
    
    // Given edges along with their quad-edge datastructure, flips the chosen edge
    // j if it doesn't form a Delaunay triangulation with its enclosing quad.
    // Returns true if a flip was performed.
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
    
    // makeArrayPoly
    public static inline
    function faceFromDllNode( linkedPoly: DllNodeInt ): Face {
        var face = new Face();
        var node = linkedPoly;
        var l = 0;
        do {
            face[ l ] = node.value;
            ++l;
            node = node.next;
        } while (node != linkedPoly);
        return face;
    }
    
    // Refines the given triangulation graph to be a Conforming Delaunay
    // Triangulation (abr. CDT). Edges with property fixed = true are not altered.
    //
    // The edges are modified in place and returned is an array of indeces tried to
    // flip. The flip was performed unless the edge was fixed. If a trace array is
    // provided, the algorithm will log key actions into it.
    public static inline
    function refineToDelaunay(  vertices:   Vertices
                            ,   edges:      Edges
                            ,   coEdges:    Edges
                            ,   sideEdges:  Array<SideEdge> )
                            :   Vertices->Edges->Edges->Array<SideEdge>->Array<Int>->Array<Int>
    {
      // We mark all edges as unsure, i.e., we don't know whether the enclosing
      // quads of those edges are properly triangulated.
      var unsureEdges = edges.getUnsure();
      return maintainDelaunay( vertices, edges, coEdges, sideEdges, unsureEdges );
    }
    
    public static inline
    function maintainDelaunay(  vertices:   Vertices
                            ,   edges:      Edges
                            ,   coEdges:    Edges
                            ,   sideEdges:  Array<SideEdge>
                            ,   unsureEdges: Array<Int> )
                            :   Vertices->Edges->Edges->Array<SideEdge>->Array<Int>->Array<Int> 
    {
        var unsure = new Array<Bool>();
        var tried = new Array<Int>();
        var cookie: Int = 0;
        return function(    vertices:   Vertices
                    ,   edges:      Edges
                    ,   coEdges:    Edges
                    ,   sideEdges:  Array<SideEdge>
                    ,   unsureEdges: Array<Int>
                    ): Array<Int> {
          ++cookie;
          var triedEdges = unsureEdges.slice(0);// not sure if ideal replace with loop?
          for( l in 0...unsureEdges.length ) {
              unsure[ unsureEdges[l] ] = true;
              tried[ unsureEdges[l] ] = cookie;
          }
          // The procedure used is the incremental Flip Algorithm. As long as there are
          // any, we fix the triangulation around an unsure edge and mark the
          // surrounding ones as unsure.
          while( unsureEdges.length > 0 ){
              var j = unsureEdges.pop();
              unsure[j] = false;
              if ( !edges[j].fixed && ensureDelaunayEdge( vertices, edges, coEdges, sideEdges, j ) ) {
                  var newUnsureCnt = 0;
                  for( jk in sideEdges[j] ){ 
                      if( !unsure[jk] ){
                          if (tried[jk] != cookie) {
                              triedEdges.push(jk);
                              tried[ jk ] = cookie;
                          }
                          if (!edges[jk].fixed) {
                              unsureEdges.push(jk);
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
    }
    
    /*
    // "ok"  - unsure of fixed
    
    
    // "NOT OK - requires more work and thought"
    
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
    public static inline 
    function findEnclosingTriangle( vertices:   Vertices
                                  , edges:      Edges
                                  , coEdges:    Edges
                                  , sideEdges:  Array<SideEdge>
                                  , p:          DllNodeInt
                                  , j0:         Int ) {
        var enqueued = [];
        var cookie = 0;
        return function() {
            var queue = new Queue();
            ++cookie;
            // We use a helper function to enqueue triangles since our indexing is
            // ambiguous -- each triangle has three indices. To prevent multiple visits,
            // all three are marked as already enqueued. Trianglea already enqueued and
            // Invalid triangles supported by external edges are rejected.
            function tryEnqueue( j: Int, k: Int ) {
                var t = 2 * j + k;
                if( enqueued[ t ] == cookie || coEdges[ j ][ k ] == null ) return;
                queue.enqueue(t);
                var j0 = sideEdges[j].getByIndex( k );
                var j1 = sideEdges[j].getByIndex( 3 - k );
                enqueued[t] = enqueued[2 * j0 + ( coEdges[j0].p == edges[j].p ? 0 : 1)]
                    = enqueued[2 * j1 + ( coEdges[j1].p == edges[j].q ? 0 : 1)]
                    = cookie;
        }
      // We start at two triangles adjecent to edge j.
      tryEnqueue( j0, 0); 
      tryEnqueue( j0, 1);
      while( !queue.isEmpty() ){
        var t = queue.dequeue();
        var k = t % 2, j = (t - k) / 2;
        var ai = edges[j].p;  
        var a = vertices[ai];
        var bi = coEdges[j][k]; // :(
        var b = vertices[bi];
        var ci = edges[j].q;  
        var c = vertices[ci];
        if( Geom2.pointInTriangle(a, b, c)(p) ) return t;
        // Continue search to triangles adjecent to edges opposite to vertices a and
        // c. The other triangle, adjecent to edge j, i.e., oppisite to b, is not
        // further examined as this is the direction we are coming from.
        var ja = sideEdges[j].getByIndex( k );
        var jc = sideEdges[j].getByIndex( 3 - k );
        // Falling through a fixed edge is not allowed.
        if (!edges[ja].fixed)
          tryEnqueue(ja, coEdges[ja].p == ai ? 1 : 0);
        if (!edges[jc].fixed)
          tryEnqueue(jc, coEdges[jc].p == ci ? 1 : 0);
      }
    }
}
    
    
    // "Maybe OK"
    public static inline
    function splitEdge(     vertices:   Vertices
                        ,   edges:      Edge
                        ,   coEdges:    Edge
                        ,   sideEdges:  SideEdge
                        ,   j ) {
      var edge   = edges[j];
      var coEdge = coEdges[j];
      var ia = edge.p;
      var ic = edge.q;
      var ib = coEdge.p;
      var id = coEdge.q;
      var p = (vertices[ia]).mid( vertices[ic] ) ;
      var unsureEdges = [];
      verticies.push( p );
      var ip = verticies.length - 1;
      edges[ j ] = new Edge( ia, ip ); 
      var ja = j; // Reuse the index
      edges.push( new Edge( ip, ic ) );
      var jc = edges.length - 1;
      // One of the supported triangles is is not present if the edge is external,
      // which is typical for fixed edges.
      var jb;
      var j0;
      var j3;
      if( ib != null ){
        edges.push( new Edge( ib, ip ) );
        jb =  edges.length - 1;
        j0 = sideEdges[j].a; 
        j3 = sideEdges[j].d;
        coEdges[j0].substitute( ia, ip );
        sideEdges[j0].substitute( j, jc );
        sideEdges[j0].substitute( j3, jb );
        coEdges[j3].substitute( ic, ip );
      //arraySubst4(sideEdges[j3],  j, ja); // Not needed, ja == j
        sideEdges[j3].substitute( j0, jb );
        coEdges[jb] = new Edge( ia, ic );
        sideEdges[jb] = new SideEdge( ja, jc, j0, j3 );
        if( !edges[j0].fixed ) unsureEdges.push( j0 );
        if (!edges[j3].fixed)  unsureEdges.push( j3 );
      }
      var jd = null;
      var j1 = null;
      var j2 = null;
      
      if (id != null ) {
        edges.push( new Edge( ip, id) );
        jd = edges.length - 1;
        j1 = sideEdges[j].b; 
        j2 = sideEdges[j].c;
        coEdges[j1].substitute( ia, ip );
        sideEdges[j1].substitute( j, jc );
        sideEdges[j1].substitute( j2, jd );
        coEdges[j2].substitute( ic, ip );
      //arraySubst4(sideEdges[j2],  j, ja); // Not needed, ja == j
        sideEdges[j2].substitute( j1, jd );
        coEdges[ jd ] = new Edge( ia, ic );
        sideEdges[ jd ] = new SideEdge( j2, j1, jc, ja );
        if( !edges[j1].fixed ) unsureEdges.push( j1 );
        if( !edges[j2].fixed ) unsureEdges.push( j2 );
      }
    //coEdges[ja] = [ib, id]; // Not needed, already there.
      sideEdges[ ja ] = new SideEdge( jb, jd, j2, j3 );
      coEdges[ jc ]   = new Edge( ib, id );
      sideEdges[ jc ] = new SideEdges( j0, j1, jd, jb );
      // Splitting a fixed edge yields fixed edges. Same with external.
      if( edge.fixed ) {
          edges[ ja ].fixed = true;
          edges[ jc ].fixed = true;
      }
      if( edge.external ){
        edges[ ja ].external = true;
        edges[ jc ].external = true;
     }
      var affectedEdges = maintainDelaunay( vertices
                                          , edges
                                          , coEdges
                                          , sideEdges
                                          , unsureEdges );
      affectedEdges.push( ja );
      affectedEdges.push( jc );
      if (jb != null ) affectedEdges.push( jb );
      if (jd != null ) affectedEdges.push( jd );
      return affectedEdges;
    }

    
    // "NOT OK - needs a lot more thought and work."
    public static 
    function maintainDelaunay() {
    var unsure = new Array<Bool>();
    var tried = new Array<Bool>();
    var cookie: Int = 0;
    return function(    vertices:   Vertices
                    ,   edges:      Edges
                    ,   coEdges:    Edges
                    ,   sideEdges:  Array<SideEdge>
                    ,   unsureEdges: Array<Int>
                    ) {
      ++cookie;
      var triedEdges = unsureEdges.slice();
      for( l in 0...unsureEdges.length ) {
        unsure[ unsureEdges[l] ] = true;
        tried[ unsureEdges[l] ] = cookie;
      }
      // The procedure used is the incremental Flip Algorithm. As long as there are
      // any, we fix the triangulation around an unsure edge and mark the
      // surrounding ones as unsure.
      while (unsureEdges.length > 0) {
        var j = unsureEdges.pop();
        unsure[j] = false;
        //var traceEntry = { ensured: j };
        if ( !edges[j].fixed && ensureDelaunayEdge( vertices, edges, coEdges, sideEdges, j ) ) {
          traceEntry.flippedTo = edges[j].slice();
          var newUnsureCnt = 0;
          for( k in 0...4 ) {// TODO: refactor
            var jk = sideEdges[j].getIndexBy( k );
            if (!unsure[jk]) {
              if (tried[jk] != cookie) {
                triedEdges.push(jk);
                tried[ jk ] = cookie;
              }
              if (!edges[jk].fixed) {
                unsureEdges.push(jk);
                unsure[ jk ] = true;
                ++newUnsureCnt;
              }
            }
          }
          //if (newUnsureCnt > 0) traceEntry.markedUnsure = unsureEdges.slice(-newUnsureCnt);
        }
      }
      return triedEdges;
    }}
    
*/

}
