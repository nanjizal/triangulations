package triangulations

class SideEdge {
    public var length: Int = 4;
    public var a: Int;
    public var b: Int;
    public var c: Int;
    public var d: Int;
    public var curr: a;
    public function new( a_: Int, b_: Int, c_: Int, d_: Int ){
        a = a_;
        b = b_;
        c = c_;
        d = d_;
    }
    
    public inline
    function iterator ():Iterator<Int> { 
        count = 0;
        return this;
    }
    
    public inline
    public function hasNext(): Bool {
        return count < length;
    }
    
    public static inline
    function next(): Int { 
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
        count++;
        return out; 
    }
    
    public inline 
    function getByIndex( i: Int ){
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
    function substitute( x: Int, y: Int ) {
        switch( x ){
            case a:
                a = y;
            case b:
                b = y;
            case c:
                c = y;
            default:
                d = y;
        }
    }
}
