package triangulations;
import triangulations.Geom2;
import khaMath.Vector2;
/**
 * Vertices are an abstract over an Array<Vector2> and represent coordinates of the FillShape
 **/
@:forward
abstract Vertices( Array<Vector2> ) from Array<Vector2> to Array<Vector2> {
    inline public function new( ?v: Array<Vector2> ) {
        if( v == null ) v = getEmpty();
        this = v;
    }
    /**
     * creates empty Vertices
     * 
     * @param   empty vertices
     **/
    public inline static 
    function getEmpty(){
        return new Vertices( new Array<Vector2>() );
    }
    /** 
     * for scaling of vertices
     * 
     * @param   s     used to scale vertices
     **/
    public inline
    function scale( f: Float ){
        var l = this.length;
        for( i in 0...l ) this[i] = this[i].mult( f ); 
    }
    /** 
     * To translate vertices
     * 
     * @param dx     use to translate the vertices on the x axis by dx
     * @param dy     use to translate the vertices on the y axis by dy
     **/
    public inline
    function translate( dx: Float, dy: Float ){
        var t = new Vector2( dx, dy );
        var l = this.length;
        for( i in 0...l ) this[i] = this[i].add( t );
    }
    /**
      * Given a simple polygon, returns its orientation, namely 1, if it's clockwise,
      * -1, if it's counter-clockwise, and 0 if the orientation is undefined, i.e.,
      * the area is 0.
      * 
      * @param  poly
      **/
    public inline
    function polygonOrientation( poly: Array<Int> ): Int {
        var area = 0.;
        var l = poly.length;
        var v = this[ poly[ l - 1 ] ];
        for( i in 0...l ){
            var u = v;
            v = this[ poly[ i ] ];
            area += ( u.x + v.x ) * ( u.y - v.y );
        }
        return if( area > 0 ){
            return 1;
        } else if( area < 0 ){
            return -1;
        } else {
            return 0;
        }
    }
    
    /**
     * Given a polygon a point, determines whether the point lies strictly inside
     * the polygon using the even-odd rule.
     * 
     * @param   poly
     * @param   w    point
     * @return  true if in poly
     **/
    public inline
    function pointInPolygon ( poly: Array<Int>, w: Vector2 ): Bool {
        var l = poly.length;
        var v = this[ poly[ l - 1 ] ];
        var result = false;
        for( i in 0...l ){
            var u = v;
            v = this[ poly[ i ] ];
            if( u.y == v.y ){
                var wux = w.x - u.x;
                if( u.y == w.y && wux * wux <= 0 ){
                    return false;
                }
                continue;
            } else {
                var x = Geom2.edgeVSRay( u, v, w.y );
                if( x != null && w.x > x ){
                    result = !result;
                }
            }
        }
        return result;
    }
    /**
     * create clone instance of the vertices
     **/
    public inline
    function clone(): Vertices {
        var v = getEmpty();
        var l = this.length;
        for( i in 0...l ) v[ i ] = new Vector2( this[ i ].x, this[ i ].y );
        return v;
    }
    /**
     * clone and fit within width, height and margin 
     * 
     * @param   width
     * @param   height
     * @param   margin
     * @return  cloned and transformed vertices
     **/
    public inline
    function fitClone( width: Float, height: Float, ?margin: Float = 10 ): Vertices {
        var v = clone();
        fit( width, height, margin );
        return v;
    }
    /**
     * fit within width, height and margin
     * 
     * @param   width
     * @param   height
     * @param   margin
     **/
    public inline 
    function fit( width: Float, height: Float, ?margin: Float = 10 ){
        var xMin = Math.POSITIVE_INFINITY;
        var xMax = Math.NEGATIVE_INFINITY;
        var yMin = Math.POSITIVE_INFINITY;
        var yMax = Math.NEGATIVE_INFINITY;
        var l = this.length;
        for ( i in 0...this.length ) {
            var v = this[i];
            var x = v.x;
            var y = v.y;
            xMin = Math.min( x, xMin );
            xMax = Math.max( x, xMax );
            yMin = Math.min( y, yMin );
            yMax = Math.max( y, yMax );
        }
        var xdif = xMax - xMin;
        var ydif = yMax - yMin;
        var scaleX = (width - 2 * margin) / xdif;
        var scaleY = (height - 2 * margin) / ydif;
        var scale = Math.min( scaleX, scaleY );
        var marginX = ( width - scale * xdif ) / 2;
        var marginY = ( height - scale * ydif ) / 2;
        for( i in 0...this.length ) {
          var v = this[i];
          v.x = marginX + scale * (v.x - xMin);
          v.y = marginY + scale * (v.y - yMin);
        }
    }
    /**
     * allow creation of vertices nest array of floats.
     *
     * @param arr       nest array of floats to turn into vertices
     **/
    @:from
    static public function fromArrayArray( arr:Array<Array<Float>> ) {
        var v: Vertices = getEmpty();
        var arr2: Array<Float>;
        var l = arr.length;
        for( i in 0...l ) {
            arr2 = arr[i];
            v[ i ] = new Vector2( arr2[0], arr2[1] );
        }
        return v;
    }
}
