package triangulations;
@:forward
abstract Face( Array<Int> ) from Array<Int> to Array<Int> {
    public inline 
    function new( ?v: Array<Int> ) {
      if( v == null ) v = getEmpty();
      this = v;
    }
    public static inline 
    function getEmpty(){
        return new Face( new Array<Int>() );
    }
    public inline
    function clone(){
        var f: Face = getEmpty();
        var l = this.length;
        for( i in 0...l ){
            f[i] = this[i];
        }
        return f;
    }
}
