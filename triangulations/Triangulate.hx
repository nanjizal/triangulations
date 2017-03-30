package triangulations;
import mathKha.Vector2D;
class triangulate {
    
    public inline static function makeLinkedPoly( face: Array<Int> ): NodeInt {
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
    
    public static inline function aux( a: Vector2D, b: Vector2D, node: NodeInt ): Bool {
        var c = vertices[node.i];
        var d = vertices[node.next.i];
        return c !== a && c !== b && d !== a && d !== b && Geom2.edgesIntersect(a, b, c, d);
    }
    
    // Checks wether any edge on path [nodeBeg, nodeEnd] intersects the segment ab.
    // If nodeEnd is not provided, nodeBeg is interpreted as lying on a cycle and
    // the whole cycle is tested. Edges spanned on equal (===) vertices are not
    // considered intersecting.
    public static inline function intersects( a: Vector2D, b: Vector2D
                                            , vertices: Array<Vector2D>
                                            , nodeBeg: Node<Int>, nodeEnd: Node ) {
       var out = false;
       if( nodeEnd === undefined ) {
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
              if( aux(a,b,node) ){ 
                  out = true;
                  break;
              } else {
                  node = node.next;
              }
          }
      }
      return out;
    }
    
    public static inline function findDeepestInside( a: Vector2, b: Vector2, c: Vector2)
                            : Array<Vector2> -> NodeInt -> NodeInt -> NodeInt -> NodeInt {
      
      var inabc     = Geom2.pointInTriangle(a, b, c);
      var acDistSq  = Geom2.pointToEdgeDistSq(a, c);
      
      return 
          function (vertices: Array<Vector2>, nodeBeg: NodeInt, nodeEnd: NodeInt, bestNode: NodeInt ): NodeInt {
              var v: NodeInt; 
              var maxDepthSq = 
              if( bestNode != undefined ){
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

    //TODO: continue port
    public inline static function faces( vertices: Array<Vertex>, faces: Array<Vector2> ){
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
                a = vertices[node.prev.value];
                b = vertices[node.value];
                c = vertices[node.next.value];
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
            //TODO: continue port        
        }
}
