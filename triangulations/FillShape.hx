package triangulations;
import triangulations.Vertices;
import triangulations.Edges;
import triangulations.Face;
import khaMath.Vector2;
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
    public inline
    function clone(){
        var f = new FillShape();
        f.edges     = edges.clone();
        f.vertices  = vertices.clone();
        f.faces     = cloneFaces();
        return f;
    }
    public inline
    function cloneFaces(){
        var f = new Array<Array<Face>>();
        var l0 = faces.length;
        var l1: Int;
        var arrFace: Array<Face>;
        for( i in 0...l0 ){
            var temp = new Array<Face>();
            arrFace = faces[i];
            l1 = arrFace.length;
            for( j in 0...l1 ){
                temp[j] = arrFace[j].clone();
            }
            f[i] = temp;
        }
        return f;
    }
}
