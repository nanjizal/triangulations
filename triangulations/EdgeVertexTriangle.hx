package triangulations;

    // Created abstraction to make 't' cleaner to use.
    // Quote from 'findingEnclosedTriangle'
    // Indexing triangles here involves some evil hacking. 
    // A triangle is represented by an edge and a vertex of its co-edge.
    // Suppose the edge in question has number j, and k is 0 or 1 depending on which
    // co-edge vertex is chosen. Then the triangle index is t = 2 * j + k.
    
    // typedef and abstract used to represent j, edgeId and k, vertexId
    
typedef EdgeVertex = { edgeId: Null<Int>, vertexId: Null<Int> };

@:forward
abstract EdgeVertexTriangle( EdgeVertex ) from EdgeVertex to EdgeVertex {
    inline public function new( e: Int, v: Int ){
        this = { edgeId: e, vertexId: v };
    }
}
