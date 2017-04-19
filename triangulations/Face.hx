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
}
