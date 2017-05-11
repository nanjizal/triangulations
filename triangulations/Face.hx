package triangulations;
/**
 * Face is an abstract of an array of Vertices indicies.
 **/
@:forward
abstract Face( Array<Int> ) from Array<Int> to Array<Int> {
    public inline 
    function new( ?v: Array<Int> ) {
      if( v == null ) v = getEmpty();
      this = v;
    }
    /** 
     * allows easier creation of an empty Face
     **/
    public static inline 
    function getEmpty(){
        return new Face( new Array<Int>() );
    }
    /** 
     * clones a face, so for instance with a FillShape so only a copy of a Face is changed
     **/
    public inline
    function clone(){
        var f: Face = getEmpty();
        var l = this.length;
        for( i in 0...l ) f[i] = this[ i ];
        return f;
    }
}
