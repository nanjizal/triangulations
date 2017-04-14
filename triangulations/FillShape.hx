package triangulations;
import triangulations.Vertices;
import triangulations.Edges;
import triangulations.Face;

class FillShape {
    public var vertices: Vertices;
    public var edges: Edges;
    public var faces: Array<Array<Face>>;
    public function new(){}
    public inline 
    function scale( s: Float ){
        vertices.scale( s );
    }
    public inline 
    function translate( x: Float, y: Float ){
        vertices.translate( x, y );
    }
    public inline
    function fit( w: Float, h: Float, ?margin: Float = 10 ){
        vertices.fit( w, h, margin );
    }
    public inline
    function set_fixedExternal( val: Bool ){
        edges.set_fixedExternal( val );
    }
}
