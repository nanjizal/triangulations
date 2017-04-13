package triangulations;

class SideEdge {
    public var length: Int = 4;
    public var a: Null<Int>;
    public var b: Null<Int>;
    public var c: Null<Int>;
    public var d: Null<Int>;
    public var count: Int = 0;
    public function new( a_: Null<Int>, b_: Null<Int>, c_: Null<Int>, d_: Null<Int> ){
        a = a_;
        b = b_;
        c = c_;
        d = d_;
    }
    public static inline 
    function getEmpty(){
        return new SideEdge( null, null, null, null );
    }
    public inline
    function iterator<Int>():Iterator<Int> { 
        count = 0;
        return cast this;
    }
    
    public inline
    function hasNext(): Bool {
        return count < length;
    }
    
    public inline
    function next(): Null<Int> { 
        var out: Null<Int>;
        switch( count ){
            case 0:
                out = a;
            case 1:
                out = b;
            case 2:
                out = c;
            case 3:
                out = d;
            default:
                out = a;
        }
        count++;
        return out; 
    }
    
    public inline 
    function getByIndex( i: Int ): Null<Int> {
        var out: Int;
        switch( count ){
            case 0:
                out = a;
            case 1:
                out = b;
            case 2:
                out = c;
            case 3:
                out = d;
            default:
                out = a;
        }
        return out;
    }
    
    public inline
    function substitute( x: Null<Int>, y: Null<Int> ) {
        if( x == a ){
            a = y;
        } else if( x == b ){
            b = y;
        } else if( x == c ){
            c = y;
        } else {
            d = y;
        }
    }
}
