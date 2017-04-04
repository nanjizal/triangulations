package triangulations;

import mathKha.Vector2;
import triangulations.Node;
import triangulations.SideEdge;
import triangulations.Edge;
import triangulations.Queue;

class Triangulate {
    
    // "ok"
    public static inline 
    function arrToBack( a:Array<Int>, i: Int ){
        var tmp = a[ i ];
        a[ i ] = a[ a.length - 1 ];
        a[ a.length - 1 ] = tmp;
    } 
    
    // "ok"
    public static inline
    function triangulateSimple( vertices:Array<Vector2>, edges:Array<Edge>, faces /*, trace */ ) {
        for ( k in 0...faces.length ) {
            var diags = triangulateFace( vertices, faces[ k ] /*, trace */ );
            var len = edges.length;
            for( i in 0...diags ) edges[ l + i ] = diags[ i ];// concat Array.prototype.push.apply(edges, diags);
        }
    }
    
    // "ok"
    // Given edges along with their quad-edge datastructure, flips the chosen edge
    // j, maintaining the quad-edge structure integrity.
    public static inline
    function flipEdge( edges: Array<Edge>, coEdges: Array<Edge>, sideEdges: Array<SideEdge>, j) {
      var edge = edges[j];
      var coEdge = coEdges[j];
      var se = sideEdges[j];
      var j0 = se.a;
      var j1 = se.b;
      var j2 = se.c;
      var j3 = se.d;

      // Amend side edges 
      coEdges[j0].substitute( edge.p, coEdge.q);
      se = sideEdge[j0];
      se.substitute( j, j1 );
      se.substitute( j3, j );

      coEdges[j1].substitute( edge.p, coEdge.p);
      se = sideEdges[j1];
      se.substitute( j , j0);
      se.substitute( j2, j );

      coEdges[j2].substitute( edge.q, coEdge.p);
      se = sideEdge[j2];
      se.substitute( j , j3);
      se.substitute( j1, j );

      coEdges[j3].substitute( edge.q, coEdge.q);
      se = sideEdge[j3];
      se.substitute( j , j2);
      se.substitute( j0, j );

      // Flip
      edges[j] = coEdges[j];
      coEdges[j] = edge.slice(); // in order to not effect the input

      // Amend primary edge
      var tmp = sideEdges[j].a;
      sideEdges[j].a = sideEdges[j].c;
      sideEdges[j].c = tmp;
    }
    
    // "ok"
    public static inline
    function isDelaunayEdge(    vertices:   Array<Vector2>
                            ,   edge:       Array<Edge>
                            ,   coEdge:     Array<Edge> ): Bool{
      var a = vertices[ edge.p ];
      var c = vertices[ edge.q ];
      var b = vertices[ coEdge.p ]
      var d = vertices[ coEdge.q ];
      return !Geom.pointInCircumcircle( a, c, b, d ) &&
             !Geom.pointInCircumcircle( a, c, d, b );
    }
    
    // "ok"
    // Given edges along with their quad-edge datastructure, flips the chosen edge
    // j if it doesn't form a Delaunay triangulation with its enclosing quad.
    // Returns true if a flip was performed.
    public static inline
    function ensureDelaunayEdge(  vertices:     Array<Vector2>
                                , edges:        Array<Edge>
                                , coEdges:      Array<Edge>
                                , sideEdges:    Array<SideEdge>
                                , j:            Int ): Bool {
      var out: Bool;
      if( isDelaunayEdge( vertices, edges[ j ], coEdges[ j ] ) ) {
          out = false;
      } else { 
          flipEdge( edges, coEdges, sideEdges, j );
          out = true;
      }
      return out;
    }
    
    
    // "ok"  - unsure of fixed
    // Refines the given triangulation graph to be a Conforming Delaunay
    // Triangulation (abr. CDT). Edges with property fixed = true are not altered.
    //
    // The edges are modified in place and returned is an array of indeces tried to
    // flip. The flip was performed unless the edge was fixed. If a trace array is
    // provided, the algorithm will log key actions into it.
    public static inline
    function refineToDelaunay(  vertices:   Array<Vector2>
                            ,   edges:      Array<Edge>
                            ,   coEdges:    Array<Edge>
                            ,   sideEdges:  Array<SideEdge> ) {
      // We mark all edges as unsure, i.e., we don't know whether the enclosing
      // quads of those edges are properly triangulated.
      var unsureEdges = Array<Int>();
      for( j in 0...edges.length ){
          if( !edges[j].fixed )
              unsureEdges.push( j );
          }
      }
      return maintainDelaunay( vertices, edges, coEdges, sideEdges, unsureEdges );
    }
    
    
    // "ok"
    // Given a polygon as a list of vertex indices, returns it in a form of
    // a doubly linked list.
    public static inline
    function makeLinkedPoly( face: Array<Int> ): NodeInt {
        var linkedPoly = new NodeInt( face[ 0 ] );
        var node = linkedPoly;
        for( i in 1...poly.length ) {
            var prevNode = node;
            node = new NodeInt( face[ i ] );
            prevNode.next = node;
            node.prev = prevNode;
        }
        node.next = linkedPoly;
        linkedPoly.prev = node;
        return linkedPoly;
    }
    
    // "ok"
    public static inline
    function makeArrayPoly( linkedPoly: NodeInt ): NodeInt {
        var poly = [];
        var node = linkedPoly;
        var l = 0;
        do {
            poly[ l ] = node.value;
            ++l;
            node = node.next;
        } while (node !== linkedPoly);
        return poly;
    }
    
    // "ok"
    public static inline
    function aux( a: Vector2, b: Vector2, node: NodeInt ): Bool {
        var c = vertices[ node.value ];
        var d = vertices[ node.next.value ];
        return c !== a && c !== b && d !== a && d !== b && Geom2.edgesIntersect( a, b, c, d );
    }
    
    // "ok"
    // Checks wether any edge on path [nodeBeg, nodeEnd] intersects the segment ab.
    // If nodeEnd is not provided, nodeBeg is interpreted as lying on a cycle and
    // the whole cycle is tested. Edges spanned on equal (===) vertices are not
    // considered intersecting.
    public static inline
    function intersects(    a:          Vector2
                        ,   b:          Vector2
                        ,   vertices:   Array<Vector2>
                        ,   nodeBeg:    NodeInt
                        ,   nodeEnd:    NodeInt ): Bool {
       var out = false;
       if( nodeEnd === null ) {
         if( aux( a, b, nodeBeg ) ){
             out = true;
         } else {
             nodeEnd = nodeBeg;
             nodeBeg = nodeBeg.next;
         }
      }
      if( out!= true ){
          var node = nodeBeg;
          while( node!= nodeEnd ){
              if( aux( a, b, node ) ){ 
                  out = true;
                  break;
              } else {
                  node = node.next;
              }
          }
      }
      return out;
    }
    
    // "ok"
    public static inline
    function findDeepestInside( a: Vector2, b: Vector2, c: Vector2 )
                            : Array<Vector2> -> NodeInt -> NodeInt -> NodeInt -> NodeInt {
      
      var inabc     = Geom2.pointInTriangle( a, b, c );
      var acDistSq  = Geom2.pointToEdgeDistSq( a, c );
      
      return 
          function( vertices: Array<Vector2>
                  , nodeBeg: NodeInt
                  , nodeEnd: NodeInt
                  , bestNode: NodeInt ): NodeInt {
                      
              var v: NodeInt; 
              var maxDepthSq = 
                  if( bestNode != null ){
                      v = bestNode.value;
                      acDistSq( vertices[ v ] )
                  } else {
                    -1;
                  }
              
              var node = nodeBeg;
              do {
                  var v = vertices[ node.value ];
                  if(v !== a && v !== b && v !== c && inabc( v )) {
                      var depthSq = acDistSq( v );
                      if( depthSq > maxDepthSq ) {
                          maxDepthSq = depthSq;
                          bestNode = node;
                      }
                  }
                  node = node.next;
               } while (node !== nodeEnd);
               
               return bestNode;
           };
    }
    
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
    function findEnclosingTriangle( vertices:   Array<Vector2>
                                  , edges:      Array<Edge>
                                  , coEdges:    Array<Edge>
                                  , sideEdges:  Array<SideEdge>
                                  , p:          NodeInt
                                  , j0:         Int ) {
    var enqueued = [];
    var cookie = 0;
    return function  {
      var queue = new Queue();
      ++cookie;
      // We use a helper function to enqueue triangles since our indexing is
      // ambiguous -- each triangle has three indices. To prevent multiple visits,
      // all three are marked as already enqueued. Trianglea already enqueued and
      // Invalid triangles supported by external edges are rejected.
      function tryEnqueue( j: Int, k: Int ) {
        var t = 2 * j + k;
        if( enqueued[ t ] === cookie || coEdges[ j ][ k ] === null ) return;
        queue.enqueue(t);
        var j0 = sideEdges[j].getByIndex( k );
        var j1 = sideEdges[j].getByIndex( 3 - k );
        enqueued[t] = enqueued[2 * j0 + ( coEdges[j0].p === edges[j].p ? 0 : 1)]
                    = enqueued[2 * j1 + ( coEdges[j1].p === edges[j].q ? 0 : 1)]
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
        var ci = edges[j].q,   
        var c = vertices[ci];

        if( geom.pointInTriangle(a, b, c)(p) ) return t;

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
    }})();
    
    
    // "Maybe OK"
    public static inline
    function splitEdge(     vertices: Array<Vector2>
                        ,   edges: NodeInt
                        ,   coEdges: NodeInt
                        ,   sideEdges
                        ,   j ) {
      var edge   = edges[j];
      var coEdge = coEdges[j];
      var ia = edge.p;
      var ic = edge.q;
      var ib = coEdge.p;
      var id = coEdge.q;
      var p = vertices[ia].mid( vertices[ic] ) ;
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
      if (ib != null) {
        edges.push( new Edge( ib, ip ) )
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
      var j1 = null, 
      var j2 = null;
      
      if (id !== null ) {
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
      if (jb !== null ) affectedEdges.push( jb );
      if (jd !== null ) affectedEdges.push( jd );
      return affectedEdges;
    }
    
    function tryInsertPoint (vertices, edges, coEdges, sideEdges, p, j0) {
      var t = findEnclosingTriangle(vertices, edges, coEdges, sideEdges, p, j0);
      if (t === undefined)
        throw "impossibru";//return { success: true, affectedEdges: [] };

      var k = t % 2, j = (t - k) / 2;
      var edge = edges[ j ]
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

      arraySubst2(
      coEdges[abj].substitute( ci, pi );
      sideEdges[abj].substitute( bcj, pbj );
      sideEdges[abj].substitute( caj, paj );

      var unsureEdges = [];
      if( !edges[bcj].fixed ) unsureEdges.push(bcj);
      if( !edges[caj].fixed ) unsureEdges.push(caj);
      if( !edges[abj].fixed ) unsureEdges.push(abj);

      return {
        success: true,
        affectedEdges: maintainDelaunay(    vertices
                                        ,   edges
                                        ,   coEdges
                                        ,   sideEdges
                                        ,   unsureEdges )
      };
    }
    
    // "ok?"
    public static inline 
    function edgeIsEncroached(  vertices: Array<Vertex>
                            ,   edges:    Array<Vector2>
                            ,   coEdges:  Array<Vector2>
                            ,   j: Int    ): Bool
    {
      var edge = edges[j];
      var coEdge = coEdges[j];
      var a = vertices[ edge.p ];
      var c = vertices[ edge.q ];
      var p = a.mid(c);
      var rSq = p.distSq(a);
      return ( coEdge.p !== null && p.distSq( vertices[ coEdge.p ] ) <= rSq ) ||
             ( coEdge.q !== null && p.distSq( vertices[ coEdge.q ] ) <= rSq );
    }
    
    // "NOT OK - needs a lot more thought and work."
    var maintainDelaunay = (function () {
    var unsure = Array<Bool>;
    var tried = Array<Bool>;
    var cookie: Int = 0;
    return function(    vertices:   Array<Vector2>
                    ,   edges:      Array<Edge>
                    ,   coEdges:    Array<Edge>
                    ,   sideEdges:  Array<SideEdge>
                    ,   unsureEdges: Array<Int>
                    ) {
      ++cookie;
      var triedEdges = unsureEdges.slice();
      for (var l = 0; l < unsureEdges.length; ++l) {
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
          for (var k = 0; k < 4; ++k) {
            var jk = sideEdges[j].getIndexBy( k );
            if (!unsure[jk]) {
              if (tried[jk] !== cookie) {
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
    }})();
    
    
    // "Maybe OK?"
    public static inline
    function triangulateFaces(  vertices:   Array<Vertex>
                            ,   faces:      Array<Vector2> ){
        // Convert the polygon components into linked lists. We assume the first
        // polygon is the outermost, and the rest, if present, are holes.
        var polies = [ makeLinkedPoly( faces[ 0 ] ) ];
        var holes = [];
        for (var k = 1; k < face.length; ++k) {
          holes.push( makeLinkedPoly( face[ k ] ) );
        }
        
        // We handle only the outer polygons. We start with only one, but more are
        // to come because of splitting. The holes are eventually merged in.
        // In each iteration a diagonal is added.
        var diagonals = [];
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
            } while(!convex && node !== poly);

            if(!convex) continue;
            var aNode = node.prev.prev;
            var bNode = node.prev;
            var cNode = node;

            // We try to make a diagonal out of ac. This is possible only if it lies
            // completely inside the polygon.
            var acOK = true;

            // Ensuring there are no intersections of ac with other edges doesn't
            // guarantee that ac lies within the poly. It is also possible that the
            // whole polygon is inside the triangle abc. Therefore we early reject the
            // case when the immediate neighbors of vertices a and c are inside abc.
            // Note that if ac is already an edge, it will also be rejected.
            var inabc = Geom2.pointInTriangle( a, b, c );
            acOK = !inabc( vertices[ aNode.prev.value ] ) && !inabc( vertices[ cNode.next.value ] );
            
            // Now we proceed with checking the intersections with ac.
            if( acOK ) acOK = !intersects( a, c, vertices, cNode.next, aNode.prev );
            
            var holesLen = holes.length;
            for( l in 0...holesLen ){
                if( !acOK ) break;
                acOK = !intersects( a, c, vertices, holes[ l ] );
            }
            
            var split;
            var fromNode;
            var toNode;
            
            if (acOK) {
              // No intersections. We can easily connect a and c.
              fromNode = cNode;
              toNode = aNode;
              split = true;
            } else {
              // If there are intersections, we have to find the closes vertex to b in
              // the direction perpendicular to ac, i.e., furthest from ac. It is
              // guaranteed that such a vertex forms a legal diagonal with b.
              var findBest = findDeepestInside(a, b, c);
              var best = 
                  if( cNode.next !== aNode ){
                      findBest( vertices, cNode.next, aNode );
                  } else {
                      undefined; 
                  }
              var lHole = -1;
              var holesLen = holes.length;// TODO: check if need to redefine does findBest effect?
              for( l in 0...holesLen ) {
                  var newBest = findBest( vertices, holes[l], holes[l], best );
                  if( newBest !== best ) lHole = l;
                  best = newBest;
              }
            
              fromNode = bNode;
              toNode = best;

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
              
              if (toNode == undefined) {
                // It was a triangle all along!
                continue;
              }

              diagonals.push( [ fromNode.value, toNode.value ] );
              /*if (trace !== undefined) {
                trace.push({
                  selectFace: makeArrayPoly( poly ),
                  addDiag: [fromNode.value, toNode.value ]
                });
              }*/

              // TODO: Elaborate
              var poly1 = new Node( fromNode.value );
              poly1.next = fromNode.next; 
              var tempNode = new Node( toNode.value );
              tempNode.prev = toNode.prev;
              tempNode.next = poly1;
              poly1.prev = tempNode;
              fromNode.next.prev = poly1;
              toNode.prev.next = poly1.prev;

              fromNode.next = toNode;
              toNode.prev = fromNode;
              var poly2 = fromNode;

              if( split ){
                  polies.push( poly1 );
                  polies.push( poly2 );
              } else {
                  polies.push( poly2 );
              }
            }
            return diagonals;
                 
        }
        
        // "NOT OK!"
        public static inline 
        function refineToRuppert( vertices:     Array<Vector2>
                                , edges:        Array<Edge>
                                , coEdges:      Array<Edge>
                                , sideEdges:    Array<SideEdge>
                                , settings:     Settings ) {
            var encroached = [];
            var bad = [];
            if( settings == null ) settings = new Settings();
            if( settings.maxSteinerPoints = null ) settings.makeSteinerPonts = 50;
            steinerLeft = settings.maxSteinerPoints;
            minAngle = settings.minAngle;
            maxArea = settings.maxArea;
            var isBad = triangleIsBad(minAngle, maxArea);
            var encroachedEdges = [];
            var badTriangles = [];

          for (var j = 0; j < edges.length; ++j) {
            if (edges[j].fixed) {
              encroachedEdges.push(j);
              encroached[j] = true;
            }
            badTriangles.push(j);
            bad[j] = true;
          }

          while (
            steinerLeft > 0 &&
            (encroachedEdges.length > 0 || badTriangles.length > 0)
          ) {
            var affectedEdges = 0;
            var forceSplit = [];
            var traceEntry = {};
            if (encroachedEdges.length > 0) {
              var s = Math.floor(Math.random() * encroachedEdges.length);
              arrToBack(encroachedEdges, s);
              var j = encroachedEdges.pop();
              encroached[j] = false;
              if( edgeIsEncroached( vertices, edges, coEdges, j ) ) {
                affectedEdges = splitEdge( vertices, edges, coEdges, sideEdges, j );
                --steinerLeft;
                traceEntry.split = [j];
              }
            } else if (badTriangles.length > 0) {
              var s = Math.floor(Math.random() * badTriangles.length);
              arrToBack( badTriangles, s );
              var j = badTriangles[badTriangles.length - 1];
              var edge = edges[j], coEdge = coEdges[j];
              var a = vertices[edge[0]], c = vertices[edge[1]];
              var okCnt = 0;
              for( k in 0...2 ) { // NOT Ideal!!
                if (coEdge[k] === undefined) {
                  ++okCnt;
                  continue;
                }
                var b = vertices[coEdge[k]];
                if (!isBad(a, b, c)) {
                  ++okCnt;
                  continue;
                }
                var p = geom.circumcenter(a, b, c);
                var insert = tryInsertPoint(vertices, edges, coEdges, sideEdges, p, j);
                if (insert.success) {
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

            if (forceSplit.length > 0)
              traceEntry.split = [];
            while (forceSplit.length > 0 && steinerLeft > 0) {
              var j = forceSplit.pop();
              var affectedEdgesPart = splitEdge( vertices, edges, coEdges, sideEdges, j );
              Array.prototype.push.apply(affectedEdges, affectedEdgesPart);
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

            if (
              settings.trace !== undefined &&
              (traceEntry.split !== undefined || traceEntry.insert !== undefined)
            ) {
              traceEntry.edgeCnt = edges.length;
              settings.trace.push(traceEntry);
            }
          }
        }})();
            
            
        // "NOT OK ??"
            
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
            function makeQuadEdge (vertices, edges) {
              // Prepare datas tructures for fast graph traversal.
              var coEdges = [];
              var sideEdges = [];
              for( j in 0...edges.length ){
                coEdges[ j ] = [];
                sideEdges[ j ] = [];
              }

              // Find the outgoing edges for each vertex
              var outEdges = [];
              for( i in 0...vertices.length )
                outEdges[ i ] = [];
              for( j in 0...edges.length ){
                var e = edges[ j ];
                outEdges[ e.p ].push(j);
                outEdges[ e.q ].push(j);
              }

              // Process edges around each vertex.
              for( i in 0...vertices.length ){
                var v = vertices[i];
                var js = outEdges[i];

                // Reverse edges, so that they point outward and sort them angularily.
                for( k = 0 in js.length ){
                  var e = edges[ js[k] ];
                  if (e.p != i) {
                    e.q = e.p;
                    e.p = i;
                  }
                }
                var angleCmp = Geom.angleCompare( v, vertices[ edges[ js[0] ].q ] );
                js.sort(function (j1, j2) {
                  return angleCmp( vertices[ edges[j1].q ], vertices[ edges[j2].q ]);
                });

                // Associate each edge with neighbouring edges appropriately.
                for( k = 0 in js.length ) {
                  var jPrev = js[(js.length + k - 1) % js.length];
                  var j     = js[k];
                  var jNext = js[(k + 1) % js.length];
                  // Node that although we could determine the whole co-edge just now, we
                  // we choose to push only the endpoint edges[jPrev][1]. The other end,
                  // i.e., edges[jNext][1] will be, or already was, put while processing the
                  // edges of the opporite vertex, i.e., edges[j][1].
                  coEdges[j].push( edges[ jPrev ].q );
                  sideEdges[j].push( jPrev, jNext );
                }
              }

              // Amend external edges
              function disjoint (i, j) { return edges[j].p !== i && edges[j].q !== i }
              for( j in 0...edges.length ){
                if( !edges[j].external ) continue;
                var ce = coEdges[ j ]; 
                var ses = sideEdges[ j ];

                // If the whole mesh is a triangle, just remove one of the duplicate entries
                if( ce.p === ce.q ) {
                  ce.q = ses.b = ses.c = null;
                  continue;
                }
                // If the arms of a supported triangle are also external, remove.
                if( edges[ ses.a ].external && edges[ ses.d ].external)
                  ce.p = ses.a = ses.d = null;
                if( edges[ ses.b ].external && edges[ ses.c ].external)
                  ce.q = ses.b = ses.c = null;
              }

              return { coEdges: coEdges, sideEdges: sideEdges };
            }
}
