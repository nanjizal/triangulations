package triangulations;
import mathKha.Vector2D;
class triangulate {
    
    public inline static function makeLinkedPoly( face: Array<Int> ): Node<Int> {
        var linkedPoly = new Node<Int>( face[ 0 ] );
        var node = linkedPoly;
        for( i in 1...poly.length ) {
            var prevNode = node;
            node = new Node<Int>( face[ i ] );
            prevNode.next = node;
            node.prev = prevNode;
        }
        node.next = linkedPoly;
        linkedPoly.prev = node;
        return linkedPoly;
    }
    
    //TODO: continue port
    public inline static function faces( vertices: Array<Vertex>, faces: Array<Vector2D> ){
    
    }
}
