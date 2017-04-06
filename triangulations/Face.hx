package triangulations;
@:forward
abstract Face( Array<Int> ) from Array<Int> to Array<Int> {
    inline public function new( v: Array<Int> ) {
      this = v;
    }
}
