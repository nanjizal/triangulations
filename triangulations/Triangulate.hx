package triangulations;

import khaMath.Vector2;
import triangulations.DllNode;
import triangulations.SideEdge;
import triangulations.Edge;
import triangulations.Edges;
import triangulations.Vertices;
import triangulations.Queue;
import triangulations.Face;
import triangulations.Triangulate;
/**
 * Core static functions used for simple and delaunay triangulation
 **/
class Triangulate {
    /** 
     * Simple triangulatation for an array of faces, loops through to triangulateFace
     * 
     * @param	vertices		Array of Vertex data in the form Vector2
     * @param   edges           Array of Edge, where an Edge contains indices to Vertices.
     * @param   face            Array of faces
     **/
    public static
    function triangulateSimple( vertices: Vertices, edges: Edges, face: Array<Array<Face>> ) {
        for ( k in 0...face.length ) {
            var diags = triangulateFace( vertices, face[ k ] );
            edges.add( diags );
        }
    }
    /** 
     * Simple triangulation of Face, assumes other faces are holes.
     * 
     * @param vertices          Array of Vertex data in the form Vector2
     * @param face              Array of face, first is assume the main face others holes.
     * @return
     **/
    public static
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
    /**
     * Given a polygon as a list of vertex indices, returns it in a form of
     * a doubly linked list.
     * 
     * @param   face        Array of Vertices indicies used to define a Face
     * @return  returns face in the form of double linked list 
     **/
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
    /**
     * Checks whether any edge on path [nodeBeg, nodeEnd] intersects the segment ab.
     * If nodeEnd is not provided, nodeBeg is interpreted as lying on a cycle and
     * the whole cycle is tested. Edges spanned on equal (===) vertices are not
     * considered intersecting.
     * 
     * @param   a           First point defining a segment
     * @param   b           Second point defining a segment
     * @param   vertices    coordinates as Vector2
     * @param   nodeBeg     Start of path
     * @param   nodeEnd     End of path optional
     **/
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
    /**
     * Helper function  
     *
     * @param   vertices            coordinates as Vector2
     * @param   a                   segment start
     * @param   b                   segment end
     * @param   node                on linked list path
     **/ 
    public static inline
    function aux( vertices: Vertices, a: Vector2, b: Vector2, node: DllNodeInt ): Bool {
        var c = vertices[ node.value ];
        var d = vertices[ node.next.value ];
        return c != a && c != b && d != a && d != b && Geom2.edgesIntersect( a, b, c, d );
    }
    
    public static
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
    /**
     * Given a triangulation graph, produces the quad-edge datastructure for fast
     * local traversal. The result consists of two arrays: coEdges and sideEdges
     * with one entry per edge each. The coEdges array is returned as list of vertex
     * index pairs, whereas sideEdges are represented by edge index quadruples.
     *
     * Consider edge ac enclosed by the quad abcd. Then its co-edge is bd and the
     * side edges are: bc, cd, da, ab, in that order. Although the graph is not
     * directed, the edges have direction implied by the implementation. The order
     * of side edges is determined by the de facto orientation of the primary edge
     * ac and its co-edge bd, but the directions of the side edges are arbitrary.
     * 
     * External edges are handled by setting indices describing one supported
     * triangle to undefined. Which triangle it will be is not determined.
     *
     *  WARNING: The procedure will change the orientation of edges.
     **/
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
        // problematic if the connector is between the two sides rather than along edge.
        
        // If the arms of a supported triangle are also external, remove.
        if( edges[ ses.a ].external && edges[ ses.d ].external)
          ce.p = ses.a = ses.d = null;
        if( edges[ ses.b ].external && edges[ ses.c ].external)
          ce.q = ses.b = ses.c = null;  
        
      }
    }
    /**    
     * makeArrayPoly
     **/
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
    /**
     * Splits an edge creating new vertices and edges.
     *
     * @param   vertices             coordinates of Vector2
     * @param   edges                edges, each edge is two vertices indicies
     * @param   coEdges
     * @param   sideEdges          
     **/
    public static
    function splitEdge(     vertices:   Vertices
                        ,   edges:      Edges
                        ,   coEdges:    Edges
                        ,   sideEdges:  Array<SideEdge>
                        ,   j ) {
      var edge   = edges[j];
      var coEdge = coEdges[j];
      var ia = edge.p;
      var ic = edge.q;
      var ib = coEdge.p;
      var id = coEdge.q;
      var p = (vertices[ia]).mid( vertices[ic] ) ;
      var unsureEdges = [];
      vertices.push( p );
      var ip = vertices.length - 1;
      edges[ j ] = new Edge( ia, ip ); 
      var ja = j; // Reuse the index
      edges.push( new Edge( ip, ic ) );
      var jc = edges.length - 1;
      // One of the supported triangles is is not present if the edge is external,
      // which is typical for fixed edges.
      var jb = null;
      var j0 = null;
      var j3 = null;
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
      sideEdges[ jc ] = new SideEdge( j0, j1, jd, jb );
      // Splitting a fixed edge yields fixed edges. Same with external.
      if( edge.fixed ) {
          edges[ ja ].fixed = true;
          edges[ jc ].fixed = true;
      }
      if( edge.external ){
        edges[ ja ].external = true;
        edges[ jc ].external = true;
     }
      var delaunay = new Delaunay();
      var affectedEdges = delaunay.calculate(   vertices
                                            ,   edges
                                            ,   coEdges
                                            ,   sideEdges
                                            ,   unsureEdges );
      affectedEdges.push( ja );
      affectedEdges.push( jc );
      if (jb != null ) affectedEdges.push( jb );
      if (jd != null ) affectedEdges.push( jd );
      return affectedEdges;
    }
}
