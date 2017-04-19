package triangulations;
@:forward
abstract Face( Array<Int> ) from Array<Int> to Array<Int> {
    inline public function new( ?v: Array<Int> ) {
      if( v == null ) v = getEmpty();
      this = v;
    }
    public inline static 
    function getEmpty(){
        return new Face( new Array<Int>() );
    }
}
