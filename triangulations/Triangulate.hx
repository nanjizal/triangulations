package triangulations;

import mathKha.Vector2D;
import triangulations.Node;

class Triangulate {
    
    // functions ported.
    // key of status
    //      notStarted - not attempted porting.
    //      partial - partially ported still trying to understand details.
    //      untested - looks reasonable haxe.
    //      compiles - compiles with Haxe but may not function properly.
    //      functions - compiles and seems to function ok.
    //
    // triangulateFaces - partial
    // makeLinkedPoly - untested
    // makeArrayPoly - untested
    // intersects ( split out aux ) - untested
        // aux - untested
    // findDeepestInside - untested
    // triangleSimple - partial not sure on inputs
    // makeQuadEdge - notStarted
    // 
    // still analysing
    
    public static inline 
    function arrToBack( a:Array<Int>, i: Int ){
        var tmp = a[ i ];
        a[ i ] = a[ a.length - 1 ];
        a[ a.length - 1 ] = tmp;
    } 
    
    public static inline
    function triangulateSimple( vertices:Array<Vector2>, edges, faces /*, trace */ ) {
        for ( k in 0...faces.length ) {
            var diags = triangulateFace( vertices, faces[ k ] /*, trace */ );
            var len = edges.length;
            for( i in 0...diags ) edges[ l + i ] = diags[ i ];// concat Array.prototype.push.apply(edges, diags);
        }
    }
    
    public static inline
    function arraySubst2( a: Array<Int>, x: Float, y: Float ) {
        if( a[0] === x ){
            a[0] = y;
        } else {
            a[1] = y;
        }
    }

    function arraySubst4( a: Array<Int>, x: Float, y: Float ) {
        if( a[0] === x ) a[0] = y; else
        if( a[1] === x ) a[1] = y; else
        if (a[2] === x ) a[2] = y;
        else            a[3] = y;
    }
    
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
    
    public static inline
    function makeArrayPoly( linkedPoly: NodeInt ): NodeInt {
        var poly = [];
        var node = linkedPoly;
        var l = 0;
        do {
            poly[l] = node.value;
            ++l;
            node = node.next;
        } while (node !== linkedPoly);
        return poly;
    }
    
    public static inline
    function aux( a: Vector2D, b: Vector2D, node: NodeInt ): Bool {
        var c = vertices[ node.value ];
        var d = vertices[ node.next.value ];
        return c !== a && c !== b && d !== a && d !== b && Geom2.edgesIntersect(a, b, c, d);
    }
    
    // Checks wether any edge on path [nodeBeg, nodeEnd] intersects the segment ab.
    // If nodeEnd is not provided, nodeBeg is interpreted as lying on a cycle and
    // the whole cycle is tested. Edges spanned on equal (===) vertices are not
    // considered intersecting.
    public static inline
    function intersects(    a: Vector2D, b: Vector2D
                        ,   vertices: Array<Vector2D>
                        ,   nodeBeg: Node<Int>, nodeEnd: Node ) {
       var out = false;
       if( nodeEnd === null ) {
         if( aux(a,b,nodeBeg)){
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
                  if(v !== a && v !== b && v !== c && inabc(v)) {
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
    function findEnclosingTriangle( vertices:Array<Vector2>
                                  , edges:   NodeInt
                                  , coEdges: NodeInt
                                  , sideEdges
                                  , p: NodeInt, j0) {}
    var enqueued = [];
    var cookie = 0;
    return function  {
      var queue = new Queue();
      ++cookie;
      // We use a helper function to enqueue triangles since our indexing is
      // ambiguous -- each triangle has three indices. To prevent multiple visits,
      // all three are marked as already enqueued. Trianglea already enqueued and
      // Invalid triangles supported by external edges are rejected.
      function tryEnqueue (j, k) {
        var t = 2 * j + k;
        if (enqueued[t] === cookie || coEdges[j][k] === undefined)
          return;
        queue.enqueue(t);
        var j0 = sideEdges[j][0 + k];
        var j1 = sideEdges[j][3 - k];
        enqueued[t] = enqueued[2 * j0 + ( coEdges[j0][0] === edges[j][0] ? 0 : 1)]
                    = enqueued[2 * j1 + ( coEdges[j1][0] === edges[j][1] ? 0 : 1)]
                    = cookie;
      }

      // We start at two triangles adjecent to edge j.
      tryEnqueue(j0, 0); tryEnqueue(j0, 1);
      while (!queue.isEmpty()) {
        var t = queue.dequeue();
        var k = t % 2, j = (t - k) / 2;
        var ai = edges[j][0],   a = vertices[ai];
        var bi = coEdges[j][k], b = vertices[bi];
        var ci = edges[j][1],   c = vertices[ci];

        if (geom.pointInTriangle(a, b, c)(p))
          return t;

        // Continue search to triangles adjecent to edges opposite to vertices a and
        // c. The other triangle, adjecent to edge j, i.e., oppisite to b, is not
        // further examined as this is the direction we are coming from.
        var ja = sideEdges[j][0 + k], jc = sideEdges[j][3 - k];
        // Falling through a fixed edge is not allowed.
        if (!edges[ja].fixed)
          tryEnqueue(ja, coEdges[ja][0] == ai ? 1 : 0);
        if (!edges[jc].fixed)
          tryEnqueue(jc, coEdges[jc][0] == ci ? 1 : 0);
      }
    }})();
    
    public static inline
    function splitEdge(     vertices: Array<Vector2>
                        ,   edges: NodeInt
                        ,   coEdges: NodeInt
                        ,   sideEdges
                        ,   j ) {
      var edge = edges[j];
      var coEdge = coEdges[j];
      var ia = edge[0], ic = edge[1];
      var ib = coEdge[0], id = coEdge[1];
      var p = mid(vertices[ia], vertices[ic]);
      var unsureEdges = [];

      var ip = vertices.push(p) - 1;
      edges[j] = [ia, ip]; var ja = j; // Reuse the index
      var jc = edges.push([ip, ic]) - 1;

      // One of the supported triangles is is not present if the edge is external,
      // which is typical for fixed edges.
      var jb;
      var j0;
      var j3;
      if (ib != null) {
        jb = edges.push([ib, ip]) - 1;
        j0 = sideEdges[j][0]; j3 = sideEdges[j][3];

        arraySubst2(coEdges[j0], ia, ip);
        arraySubst4(sideEdges[j0],  j, jc);
        arraySubst4(sideEdges[j0], j3, jb);

        arraySubst2(coEdges[j3], ic, ip);
      //arraySubst4(sideEdges[j3],  j, ja); // Not needed, ja == j
        arraySubst4(sideEdges[j3], j0, jb);

        coEdges[jb] = [ia, ic];
        sideEdges[jb] = [ja, jc, j0, j3];

        if (!edges[j0].fixed)
          unsureEdges.push(j0);
        if (!edges[j3].fixed)
          unsureEdges.push(j3);
      }
      var jd = undefined, j1 = undefined, j2 = undefined;
      if (id !== undefined) {
        jd = edges.push([ip, id]) - 1;
        j1 = sideEdges[j][1]; 
        j2 = sideEdges[j][2];

        arraySubst2(coEdges[j1], ia, ip);
        arraySubst4(sideEdges[j1],  j, jc);
        arraySubst4(sideEdges[j1], j2, jd);

        arraySubst2(coEdges[j2], ic, ip);
      //arraySubst4(sideEdges[j2],  j, ja); // Not needed, ja == j
        arraySubst4(sideEdges[j2], j1, jd);

        coEdges[jd] = [ia, ic];
        sideEdges[jd] = [j2, j1, jc, ja];

        if (!edges[j1].fixed)
          unsureEdges.push(j1);
        if (!edges[j2].fixed)
          unsureEdges.push(j2);
      }

    //coEdges[ja] = [ib, id]; // Not needed, already there.
      sideEdges[ja] = [jb, jd, j2, j3];

      coEdges[jc] = [ib, id];
      sideEdges[jc] = [j0, j1, jd, jb];

      // Splitting a fixed edge yields fixed edges. Same with external.
      if (edge.fixed)
        edges[ja].fixed = edges[jc].fixed = true;
      if (edge.external)
        edges[ja].external = edges[jc].external = true;

      var affectedEdges = maintainDelaunay(vertices, edges, coEdges, sideEdges,
                                           unsureEdges);
      affectedEdges.push(ja, jc);
      if (jb !== undefined)
        affectedEdges.push(jb);
      if (jd !== undefined)
        affectedEdges.push(jd);
      return affectedEdges;
    }
    function tryInsertPoint (vertices, edges, coEdges, sideEdges, p, j0) {
      var t = findEnclosingTriangle(vertices, edges, coEdges, sideEdges, p, j0);
      if (t === undefined)
        throw "impossibru";//return { success: true, affectedEdges: [] };

      var k = t % 2, j = (t - k) / 2;
      var edge = edges[j], coEdge = coEdges[j];
      var ai = edge[0],   a = vertices[ai], bcj = sideEdges[j][0 + k];
      var bi = coEdge[k], b = vertices[bi], caj = j;
      var ci = edge[1],   c = vertices[ci]; abj = sideEdges[j][3 - k];

      var encroachedEdges = [];
      if (edges[bcj].fixed && pointEncroachesEdge(b, c, p))
        encroachedEdges.push(bcj);
      if (edges[caj].fixed && pointEncroachesEdge(c, a, p))
        encroachedEdges.push(caj);
      if (edges[abj].fixed && pointEncroachesEdge(a, b, p))
        encroachedEdges.push(abj);
      if (encroachedEdges.length > 0)
        return { success: false, encroachedEdges: encroachedEdges };

      var pi = vertices.push(p) - 1;
      var paj = edges.push([pi, ai]) - 1;
      var pbj = edges.push([pi, bi]) - 1;
      var pcj = edges.push([pi, ci]) - 1;

      coEdges[paj] = [bi, ci];
      sideEdges[paj] = [abj, caj, pcj, pbj];

      coEdges[pbj] = [ci, ai];
      sideEdges[pbj] = [bcj, abj, paj, pcj];

      coEdges[pcj] = [ai, bi];
      sideEdges[pcj] = [caj, bcj, pbj, paj];

      arraySubst2(coEdges[bcj], ai, pi);
      arraySubst4(sideEdges[bcj], caj, pcj);
      arraySubst4(sideEdges[bcj], abj, pbj);

      arraySubst2(coEdges[caj], bi, pi);
      arraySubst4(sideEdges[caj], abj, paj);
      arraySubst4(sideEdges[caj], bcj, pcj);

      arraySubst2(coEdges[abj], ci, pi);
      arraySubst4(sideEdges[abj], bcj, pbj);
      arraySubst4(sideEdges[abj], caj, paj);

      var unsureEdges = [];
      if (!edges[bcj].fixed)
        unsureEdges.push(bcj);
      if (!edges[caj].fixed)
        unsureEdges.push(caj);
      if (!edges[abj].fixed)
        unsureEdges.push(abj);

      return {
        success: true,
        affectedEdges: maintainDelaunay(vertices, edges, coEdges, sideEdges,
                                        unsureEdges)
      };
    }
    
    
    // TODO: Really needs more checking work.
    public static inline 
    function edgeIsEncroached(  vertices: Array<Vertex>
                            ,   edges:    Array<Vector2>
                            ,   coEdges:  Array<Vector2>
                            ,   j: Int    ): Bool
    {
      var edge = edges[j];
      var coEdge = coEdges[j];
      var a = vertices[edge[0]];
      var c = vertices[edge[1]];
      var p = a.mid(c);
      var rSq = p.distSq(a);
      return ( coEdge.x !== null && p.distSq( vertices[ coEdge.x ] ) <= rSq) ||
             ( coEdge.y !== null && p.distSq( vertices[ coEdge.y ] ) <= rSq);
    }
    
    var maintainDelaunay = (function () {
    var unsure = [];
    var tried = [];
    var cookie = 0;
    return function (vertices, edges, coEdges, sideEdges, unsureEdges, trace) {
      ++cookie;
      var triedEdges = unsureEdges.slice();
      for (var l = 0; l < unsureEdges.length; ++l) {
        unsure[unsureEdges[l]] = true;
        tried[unsureEdges[l]] = cookie;
      }

      // The procedure used is the incremental Flip Algorithm. As long as there are
      // any, we fix the triangulation around an unsure edge and mark the
      // surrounding ones as unsure.
      while (unsureEdges.length > 0) {
        var j = unsureEdges.pop();
        unsure[j] = false;

        var traceEntry = { ensured: j };
        if (
          !edges[j].fixed &&
          ensureDelaunayEdge(vertices, edges, coEdges, sideEdges, j)
        ) {
          traceEntry.flippedTo = edges[j].slice();
          var newUnsureCnt = 0;
          for (var k = 0; k < 4; ++k) {
            var jk = sideEdges[j][k];
            if (!unsure[jk]) {
              if (tried[jk] !== cookie) {
                triedEdges.push(jk);
                tried[jk] = cookie;
              }
              if (!edges[jk].fixed) {
                unsureEdges.push(jk);
                unsure[jk] = true;
                ++newUnsureCnt;
              }
            }
          }
          if (newUnsureCnt > 0)
            traceEntry.markedUnsure = unsureEdges.slice(-newUnsureCnt);
        }
        if (trace !== undefined)
          trace.push(traceEntry);
      }

      return triedEdges;
    }})();
    
    
    /*
    //TODO: continue port
    public static inline
    function triangulateFaces( vertices: Array<Vertex>, faces: Array<Vector2> ){
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
        while (polies.length > 0) {
            var poly = polies.pop();

            // First we find a locally convex vertex.
            var node = poly;
            var a: Vector2D;
            var b: Vector2D;
            var c: Vector2D;
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
            var inabc = Geom2.pointInTriangle(a, b, c);
            acOK = !inabc(vertices[aNode.prev.i]) && !inabc(vertices[cNode.next.i]);
            
            // Now we proceed with checking the intersections with ac.
            if( acOK ) acOK = !intersects(a, c, vertices, cNode.next, aNode.prev);
            
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
        
        /*
        public static inline 
        function refineToRuppert(vertices, edges, coEdges, sideEdges, settings) {
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
              if (edgeIsEncroached(vertices, edges, coEdges, j)) {
                affectedEdges = splitEdge(vertices, edges, coEdges, sideEdges, j);
                --steinerLeft;
                traceEntry.split = [j];
              }
            } else if (badTriangles.length > 0) {
              var s = Math.floor(Math.random() * badTriangles.length);
              arrToBack(badTriangles, s);
              var j = badTriangles[badTriangles.length - 1];
              var edge = edges[j], coEdge = coEdges[j];
              var a = vertices[edge[0]], c = vertices[edge[1]];
              var okCnt = 0;
              for (var k = 0; k < 2; ++k) {
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
              var affectedEdgesPart = splitEdge(vertices, edges, coEdges, sideEdges, j);
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
        }})();*/
            
            
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
              for (var j = 0; j < edges.length; ++j) {
                coEdges[j] = [];
                sideEdges[j] = [];
              }

              // Find the outgoing edges for each vertex
              var outEdges = [];
package triangulations;

import mathKha.Vector2D;
import triangulations.Node;
import triangulations.SideEdge;
import triangulations.Edge;

class Triangulate {
    
    // functions ported.
    // key of status
    //      notStarted - not attempted porting.
    //      partial - partially ported still trying to understand details.
    //      untested - looks reasonable haxe.
    //      compiles - compiles with Haxe but may not function properly.
    //      functions - compiles and seems to function ok.
    //
    // triangulateFaces - partial
    // makeLinkedPoly - untested
    // makeArrayPoly - untested
    // intersects ( split out aux ) - untested
        // aux - untested
    // findDeepestInside - untested
    // triangleSimple - partial not sure on inputs
    // makeQuadEdge - notStarted
    // arraySubst2 - moved to Edge class
    // arraySubst4 - moved to SideEdge class
    // flipEdge - not quite sure on types
    
    // still analysing
    
    public static inline 
    function arrToBack( a:Array<Int>, i: Int ){
        var tmp = a[ i ];
        a[ i ] = a[ a.length - 1 ];
        a[ a.length - 1 ] = tmp;
    } 
    
    public static inline
    function triangulateSimple( vertices:Array<Vector2>, edges:Array<Edge>, faces /*, trace */ ) {
        for ( k in 0...faces.length ) {
            var diags = triangulateFace( vertices, faces[ k ] /*, trace */ );
            var len = edges.length;
            for( i in 0...diags ) edges[ l + i ] = diags[ i ];// concat Array.prototype.push.apply(edges, diags);
        }
    }
    
    /*
    public static inline
    function arraySubst2( a: Array<Int>, x: Float, y: Float ) {
        if( a[0] === x ){
            a[0] = y;
        } else {
            a[1] = y;
        }
    }
        */
    /*
    public static inline
    function arraySubst4( a: Array<Int>, x: Float, y: Float ) {
        if( a[0] === x ) a[0] = y; else
        if( a[1] === x ) a[1] = y; else
        if (a[2] === x ) a[2] = y;
        else            a[3] = y;
    }
    */
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
      arraySubst2(coEdges[j0], edge.p, coEdge.q);
      se = sideEdge[j0];
      se.substitute( j, j1 );
      se.substitute( j3, j );

      arraySubst2(coEdges[j1], edge.p, coEdge.p);
      se = sideEdges[j1];
      se.substitute( j , j0);
      se.substitute( j2, j );

      arraySubst2(coEdges[j2], edge.q, coEdge.p);
      se = sideEdge[j2];
      se.substitute( j , j3);
      se.substitute( j1, j );

      arraySubst2(coEdges[j3], edge.q, coEdge.q);
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
    
    public static inline
    function isDelaunayEdge( vertices: Array<Vector2>, edge: Array<Edge>, coEdge: Array<Edge> ): Bool{
      var a = vertices[edge.p], c = vertices[edge.q];
      var b = vertices[coEdge.p], d = vertices[coEdge.q];
      return !geom.pointInCircumcircle(a, c, b, d) &&
             !geom.pointInCircumcircle(a, c, d, b);
    }
    
    // Given edges along with their quad-edge datastructure, flips the chosen edge
    // j if it doesn't form a Delaunay triangulation with its enclosing quad.
    // Returns true if a flip was performed.
    public static inline
    function ensureDelaunayEdge(  vertices: Array<Vector2>
                                , edges: Array<Edge>, coEdges: Array<Edge>
                                , sideEdges: Array<SideEdge>, j ): Bool {
      var out: Bool;
      if( isDelaunayEdge( vertices, edges[j], coEdges[j]) ) {
          out = false;
      } else { 
          flipEdge( edges, coEdges, sideEdges, j );
          out = true;
      }
      return out;
    }
    
    // Refines the given triangulation graph to be a Conforming Delaunay
    // Triangulation (abr. CDT). Edges with property fixed = true are not altered.
    //
    // The edges are modified in place and returned is an array of indeces tried to
    // flip. The flip was performed unless the edge was fixed. If a trace array is
    // provided, the algorithm will log key actions into it.
    public static inline
    function refineToDelaunay(  vertices: Array<Vector2>
                            ,   edges: Array<Edge>, coEdges: Array<Edge>
                            ,   sideEdges: Array<SideEdge> ) {
      // We mark all edges as unsure, i.e., we don't know whether the enclosing
      // quads of those edges are properly triangulated.
      var unsureEdges = Array<Int>();
      for( j in 0...edges.length ){
          if( !edges[j].fixed )
              unsureEdges.push( j );
          }
      }

      return maintainDelaunay(
        vertices, edges, coEdges, sideEdges, unsureEdges, trace
      );
    }
    
    
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
    
    public static inline
    function makeArrayPoly( linkedPoly: NodeInt ): NodeInt {
        var poly = [];
        var node = linkedPoly;
        var l = 0;
        do {
            poly[l] = node.value;
            ++l;
            node = node.next;
        } while (node !== linkedPoly);
        return poly;
    }
    
    public static inline
    function aux( a: Vector2D, b: Vector2D, node: NodeInt ): Bool {
        var c = vertices[ node.value ];
        var d = vertices[ node.next.value ];
        return c !== a && c !== b && d !== a && d !== b && Geom2.edgesIntersect(a, b, c, d);
    }
    
    // Checks wether any edge on path [nodeBeg, nodeEnd] intersects the segment ab.
    // If nodeEnd is not provided, nodeBeg is interpreted as lying on a cycle and
    // the whole cycle is tested. Edges spanned on equal (===) vertices are not
    // considered intersecting.
    public static inline
    function intersects(    a: Vector2D, b: Vector2D
                        ,   vertices: Array<Vector2D>
                        ,   nodeBeg: Node<Int>, nodeEnd: Node ) {
       var out = false;
       if( nodeEnd === null ) {
         if( aux(a,b,nodeBeg)){
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
                  if(v !== a && v !== b && v !== c && inabc(v)) {
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
                                  , p: NodeInt, j0) {}
    var enqueued = [];
    var cookie = 0;
    return function  {
      var queue = new Queue();
      ++cookie;
      // We use a helper function to enqueue triangles since our indexing is
      // ambiguous -- each triangle has three indices. To prevent multiple visits,
      // all three are marked as already enqueued. Trianglea already enqueued and
      // Invalid triangles supported by external edges are rejected.
      function tryEnqueue (j, k) {
        var t = 2 * j + k;
        if (enqueued[t] === cookie || coEdges[j][k] === undefined)
          return;
        queue.enqueue(t);
        var j0 = sideEdges[j][0 + k];
        var j1 = sideEdges[j][3 - k];
        enqueued[t] = enqueued[2 * j0 + ( coEdges[j0][0] === edges[j][0] ? 0 : 1)]
                    = enqueued[2 * j1 + ( coEdges[j1][0] === edges[j][1] ? 0 : 1)]
                    = cookie;
      }

      // We start at two triangles adjecent to edge j.
      tryEnqueue(j0, 0); tryEnqueue(j0, 1);
      while (!queue.isEmpty()) {
        var t = queue.dequeue();
        var k = t % 2, j = (t - k) / 2;
        var ai = edges[j][0],   a = vertices[ai];
        var bi = coEdges[j][k], b = vertices[bi];
        var ci = edges[j][1],   c = vertices[ci];

        if (geom.pointInTriangle(a, b, c)(p))
          return t;

        // Continue search to triangles adjecent to edges opposite to vertices a and
        // c. The other triangle, adjecent to edge j, i.e., oppisite to b, is not
        // further examined as this is the direction we are coming from.
        var ja = sideEdges[j][0 + k], jc = sideEdges[j][3 - k];
        // Falling through a fixed edge is not allowed.
        if (!edges[ja].fixed)
          tryEnqueue(ja, coEdges[ja][0] == ai ? 1 : 0);
        if (!edges[jc].fixed)
          tryEnqueue(jc, coEdges[jc][0] == ci ? 1 : 0);
      }
    }})();
    
    public static inline
    function splitEdge(     vertices: Array<Vector2>
                        ,   edges: NodeInt
                        ,   coEdges: NodeInt
                        ,   sideEdges
                        ,   j ) {
      var edge = edges[j];
      var coEdge = coEdges[j];
      var ia = edge[0], ic = edge[1];
      var ib = coEdge[0], id = coEdge[1];
      var p = mid(vertices[ia], vertices[ic]);
      var unsureEdges = [];

      var ip = vertices.push(p) - 1;
      edges[j] = [ia, ip]; var ja = j; // Reuse the index
      var jc = edges.push([ip, ic]) - 1;

      // One of the supported triangles is is not present if the edge is external,
      // which is typical for fixed edges.
      var jb;
      var j0;
      var j3;
      if (ib != null) {
        jb = edges.push([ib, ip]) - 1;
        j0 = sideEdges[j].a; j3 = sideEdges[j].d;

        arraySubst2(coEdges[j0], ia, ip);
        arraySubst4(sideEdges[j0],  j, jc);
        arraySubst4(sideEdges[j0], j3, jb);

        arraySubst2(coEdges[j3], ic, ip);
      //arraySubst4(sideEdges[j3],  j, ja); // Not needed, ja == j
        arraySubst4(sideEdges[j3], j0, jb);

        coEdges[jb] = [ia, ic];
        sideEdges[jb] = [ja, jc, j0, j3];

        if (!edges[j0].fixed)
          unsureEdges.push(j0);
        if (!edges[j3].fixed)
          unsureEdges.push(j3);
      }
      var jd = undefined, j1 = undefined, j2 = undefined;
      if (id !== undefined) {
        jd = edges.push([ip, id]) - 1;
        j1 = sideEdges[j][1]; 
        j2 = sideEdges[j][2];

        arraySubst2(coEdges[j1], ia, ip);
        arraySubst4(sideEdges[j1],  j, jc);
        arraySubst4(sideEdges[j1], j2, jd);

        arraySubst2(coEdges[j2], ic, ip);
      //arraySubst4(sideEdges[j2],  j, ja); // Not needed, ja == j
        arraySubst4(sideEdges[j2], j1, jd);

        coEdges[jd] = [ia, ic];
        sideEdges[jd] = [j2, j1, jc, ja];

        if (!edges[j1].fixed)
          unsureEdges.push(j1);
        if (!edges[j2].fixed)
          unsureEdges.push(j2);
      }

    //coEdges[ja] = [ib, id]; // Not needed, already there.
      sideEdges[ja] = [jb, jd, j2, j3];

      coEdges[jc] = [ib, id];
      sideEdges[jc] = [j0, j1, jd, jb];

      // Splitting a fixed edge yields fixed edges. Same with external.
      if (edge.fixed)
        edges[ja].fixed = edges[jc].fixed = true;
      if (edge.external)
        edges[ja].external = edges[jc].external = true;

      var affectedEdges = maintainDelaunay(vertices, edges, coEdges, sideEdges,
                                           unsureEdges);
      affectedEdges.push(ja, jc);
      if (jb !== undefined)
        affectedEdges.push(jb);
      if (jd !== undefined)
        affectedEdges.push(jd);
      return affectedEdges;
    }
    function tryInsertPoint (vertices, edges, coEdges, sideEdges, p, j0) {
      var t = findEnclosingTriangle(vertices, edges, coEdges, sideEdges, p, j0);
      if (t === undefined)
        throw "impossibru";//return { success: true, affectedEdges: [] };

      var k = t % 2, j = (t - k) / 2;
      var edge = edges[j], coEdge = coEdges[j];
      var ai = edge[0],   a = vertices[ai], bcj = sideEdges[j][0 + k];
      var bi = coEdge[k], b = vertices[bi], caj = j;
      var ci = edge[1],   c = vertices[ci]; abj = sideEdges[j][3 - k];

      var encroachedEdges = [];
      if (edges[bcj].fixed && pointEncroachesEdge(b, c, p))
        encroachedEdges.push(bcj);
      if (edges[caj].fixed && pointEncroachesEdge(c, a, p))
        encroachedEdges.push(caj);
      if (edges[abj].fixed && pointEncroachesEdge(a, b, p))
        encroachedEdges.push(abj);
      if (encroachedEdges.length > 0)
        return { success: false, encroachedEdges: encroachedEdges };

      var pi = vertices.push(p) - 1;
      var paj = edges.push([pi, ai]) - 1;
      var pbj = edges.push([pi, bi]) - 1;
      var pcj = edges.push([pi, ci]) - 1;

      coEdges[paj] = [bi, ci];
      sideEdges[paj] = [abj, caj, pcj, pbj];

      coEdges[pbj] = [ci, ai];
      sideEdges[pbj] = [bcj, abj, paj, pcj];

      coEdges[pcj] = [ai, bi];
      sideEdges[pcj] = [caj, bcj, pbj, paj];

      arraySubst2(coEdges[bcj], ai, pi);
      arraySubst4(sideEdges[bcj], caj, pcj);
      arraySubst4(sideEdges[bcj], abj, pbj);

      arraySubst2(coEdges[caj], bi, pi);
      arraySubst4(sideEdges[caj], abj, paj);
      arraySubst4(sideEdges[caj], bcj, pcj);

      arraySubst2(coEdges[abj], ci, pi);
      arraySubst4(sideEdges[abj], bcj, pbj);
      arraySubst4(sideEdges[abj], caj, paj);

      var unsureEdges = [];
      if (!edges[bcj].fixed)
        unsureEdges.push(bcj);
      if (!edges[caj].fixed)
        unsureEdges.push(caj);
      if (!edges[abj].fixed)
        unsureEdges.push(abj);

      return {
        success: true,
        affectedEdges: maintainDelaunay(vertices, edges, coEdges, sideEdges,
                                        unsureEdges)
      };
    }
    
    
    // TODO: Really needs more checking work.
    public static inline 
    function edgeIsEncroached(  vertices: Array<Vertex>
                            ,   edges:    Array<Vector2>
                            ,   coEdges:  Array<Vector2>
                            ,   j: Int    ): Bool
    {
      var edge = edges[j];
      var coEdge = coEdges[j];
      var a = vertices[edge[0]];
      var c = vertices[edge[1]];
      var p = a.mid(c);
      var rSq = p.distSq(a);
      return ( coEdge.x !== null && p.distSq( vertices[ coEdge.x ] ) <= rSq) ||
             ( coEdge.y !== null && p.distSq( vertices[ coEdge.y ] ) <= rSq);
    }
    
    var maintainDelaunay = (function () {
    var unsure = [];
    var tried = [];
    var cookie = 0;
    return function (vertices, edges, coEdges, sideEdges, unsureEdges, trace) {
      ++cookie;
      var triedEdges = unsureEdges.slice();
      for (var l = 0; l < unsureEdges.length; ++l) {
        unsure[unsureEdges[l]] = true;
        tried[unsureEdges[l]] = cookie;
      }

      // The procedure used is the incremental Flip Algorithm. As long as there are
      // any, we fix the triangulation around an unsure edge and mark the
      // surrounding ones as unsure.
      while (unsureEdges.length > 0) {
        var j = unsureEdges.pop();
        unsure[j] = false;

        var traceEntry = { ensured: j };
        if (
          !edges[j].fixed &&
          ensureDelaunayEdge(vertices, edges, coEdges, sideEdges, j)
        ) {
          traceEntry.flippedTo = edges[j].slice();
          var newUnsureCnt = 0;
          for (var k = 0; k < 4; ++k) {
            var jk = sideEdges[j][k];
            if (!unsure[jk]) {
              if (tried[jk] !== cookie) {
                triedEdges.push(jk);
                tried[jk] = cookie;
              }
              if (!edges[jk].fixed) {
                unsureEdges.push(jk);
                unsure[jk] = true;
                ++newUnsureCnt;
              }
            }
          }
          if (newUnsureCnt > 0)
            traceEntry.markedUnsure = unsureEdges.slice(-newUnsureCnt);
        }
        if (trace !== undefined)
          trace.push(traceEntry);
      }

      return triedEdges;
    }})();
    
    
    /*
    //TODO: continue port
    public static inline
    function triangulateFaces( vertices: Array<Vertex>, faces: Array<Vector2> ){
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
        while (polies.length > 0) {
            var poly = polies.pop();

            // First we find a locally convex vertex.
            var node = poly;
            var a: Vector2D;
            var b: Vector2D;
            var c: Vector2D;
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
            var inabc = Geom2.pointInTriangle(a, b, c);
            acOK = !inabc(vertices[aNode.prev.i]) && !inabc(vertices[cNode.next.i]);
            
            // Now we proceed with checking the intersections with ac.
            if( acOK ) acOK = !intersects(a, c, vertices, cNode.next, aNode.prev);
            
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
        
        /*
        public static inline 
        function refineToRuppert(vertices, edges, coEdges, sideEdges, settings) {
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
              if (edgeIsEncroached(vertices, edges, coEdges, j)) {
                affectedEdges = splitEdge(vertices, edges, coEdges, sideEdges, j);
                --steinerLeft;
                traceEntry.split = [j];
              }
            } else if (badTriangles.length > 0) {
              var s = Math.floor(Math.random() * badTriangles.length);
              arrToBack(badTriangles, s);
              var j = badTriangles[badTriangles.length - 1];
              var edge = edges[j], coEdge = coEdges[j];
              var a = vertices[edge[0]], c = vertices[edge[1]];
              var okCnt = 0;
              for (var k = 0; k < 2; ++k) {
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
              var affectedEdgesPart = splitEdge(vertices, edges, coEdges, sideEdges, j);
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
        }})();*/
            
            
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
              for (var j = 0; j < edges.length; ++j) {
                coEdges[j] = [];
                sideEdges[j] = [];
              }

              // Find the outgoing edges for each vertex
              var outEdges = [];
              for (var i = 0; i < vertices.length; ++i)
                outEdges[i] = [];
              for (var j = 0; j < edges.length; ++j) {
                var e = edges[j];
                outEdges[e[0]].push(j);
                outEdges[e[1]].push(j);
              }

              // Process edges around each vertex.
              for (var i = 0; i < vertices.length; ++i) {
                var v = vertices[i];
                var js = outEdges[i];

                // Reverse edges, so that they point outward and sort them angularily.
                for (var k = 0; k < js.length; ++k) {
                  var e = edges[js[k]];
                  if (e[0] != i) {
                    e[1] = e[0];
                    e[0] = i;
                  }
                }
                var angleCmp = geom.angleCompare(v, vertices[edges[js[0]][1]]);
                js.sort(function (j1, j2) {
                  return angleCmp(vertices[edges[j1][1]], vertices[edges[j2][1]]);
                });

                // Associate each edge with neighbouring edges appropriately.
                for (var k = 0; k < js.length; ++k) {
                  var jPrev = js[(js.length + k - 1) % js.length];
                  var j     = js[k];
                  var jNext = js[(k + 1) % js.length];
                  // Node that although we could determine the whole co-edge just now, we
                  // we choose to push only the endpoint edges[jPrev][1]. The other end,
                  // i.e., edges[jNext][1] will be, or already was, put while processing the
                  // edges of the opporite vertex, i.e., edges[j][1].
                  coEdges[j].push(edges[jPrev][1]);
                  sideEdges[j].push(jPrev, jNext);
                }
              }

              // Amend external edges
              function disjoint (i, j) { return edges[j][0] !== i && edges[j][1] !== i }
              for (var j = 0; j < edges.length; ++j) {
                if (!edges[j].external)
                  continue;
                var ce = coEdges[j], ses = sideEdges[j];

                // If the whole mesh is a triangle, just remove one of the duplicate entries
                if (ce[0] === ce[1]) {
                  ce[1] = ses[1] = ses[2] = undefined;
                  continue;
                }
                // If the arms of a supported triangle are also external, remove.
                if (edges[ses[0]].external && edges[ses[3]].external)
                  ce[0] = ses[0] = ses[3] = undefined;
                if (edges[ses[1]].external && edges[ses[2]].external)
                  ce[1] = ses[1] = ses[2] = undefined;
              }

              return { coEdges: coEdges, sideEdges: sideEdges };
            }
}
