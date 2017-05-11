package triangulations;
import triangulations.Vertices;
import triangulations.Edges;
import triangulations.Face;
import khaMath.Vector2;
/**
 *  Basic structure used to store a Shape.
 *  vertices are coordinates of Vector2
 *  Edges are two vertices indices p and q to define an edge
 *  Faces is array of array of Faces ( polygons ).
 *
 **/
class FillShape {
    /**
     *  abstract of Array<Vector2> used to hold shape coordinates external at first and then later prehaps internal
     **/
    public var vertices: Vertices;
    /** 
     *  abstract of Array<Edge>, each edge holds two indicies of vertices p and q.
     **/
    public var edges: Edges;
    /**
     *  array of array of faces, so for instatce each array of face would be a letter
     *  in the Array<Face> the first Face is assumed the polygon outline and the other faces holes within
     **/
    public var faces: Array<Array<Face>>;
    /** 
     *  constructor empty but can be overridden by abstracts that might create a new shape.
     **/
    public function new(){}
    /** 
     * scales the vertices coordinates
     * 
     * @param   scale           scale factor
     **/
    public inline 
    function scale( s: Float ){
        vertices.scale( s );
    }
    /**
     * translates the coordinates by dx and dy amount.
     * 
     * @param   dx      translate on x axis by dx amount
     * @param   dy      translate on y axis by dy amount
     **/
    public inline 
    function translate( dx: Float, dy: Float ){
        vertices.translate( dx, dy );
    }
    /** 
     * fit the coordinates within width w, and height h with a outer margin all round
     *
     * @param   w               bounding width to fit coordinates within
     * @param   h               bounding height to fit coordinates within
     * @param   margin          margin within bounding box
     **/
    public inline
    function fit( w: Float, h: Float, ?margin: Float = 10 ){
        vertices.fit( w, h, margin );
    }
    /**
     * set edges to all be edges to be external fixed if true and not if false
     *
     * @param   val             true to set edges to be fixed and external, normally set after creating a new Fill Shape 
     **/
    public inline
    function set_fixedExternal( val: Bool ){
        edges.set_fixedExternal( val );
    }
    /**
     *  clones a FillShape, cloning it's properties and creating a new FillShape with them.
     *
     **/
    public inline
    function clone(){
        var f = new FillShape();
        f.edges     = edges.clone();
        f.vertices  = vertices.clone();
        f.faces     = cloneFaces();
        return f;
    }
    /** 
     *  clone helper for cloning faces property
     *
     **/
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
