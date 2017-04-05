package triangulations;
import triangulations.Geom2;
import khaMath.Vector2;
@:forward
abstract Vertices( Array<Vector2> ) from Array<Vector2> to Array<Vector2> {
    inline public function new( v: Array<Vector2> ) {
      this = v;
    }
    
    public inline static 
    function getEmpty(){
        return new Vertices( new Array<Vector2>() );
    }
    // Given a simple polygon, returns its orientation, namely 1, if it's clockwise,
    // -1, if it's counter-clockwise, and 0 if the orientation is undefined, i.e.,
    // the area is 0.
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
    
    // Given a polygon a point, determines whether the point lies strictly inside
    // the polygon using the even-odd rule.
    // TODO: need to think about inline
    public function pointInPolygon ( poly: Array<Int>, w: Vector2 ): Bool {
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
    
    public inline
    function clone(): Vertices {
        var v = getEmpty();
        var l = this.length;
        for( i in 0...l ){
            v[ i ].x = this[ i ].x;
            v[ i ].y = this[ i ].y;
        }
        return v;
    }
    
    public inline
    function fitClone( width: Float, height: Float, ?margin: Float = 10 ): Vertices {
        var v = clone();
        fit( width, height, margin );
        return v;
    }
    
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
