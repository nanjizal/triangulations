package triangulations;
/**
 * typedef to double linked list of Int
 **/
typedef DllNodeInt = DllNode<Int>;
/**
 * Double Linked List Node
 **/
class DllNode<T> {
    /**
     * previous Node
     **/
    public var prev: DllNode<T>;
    /** 
     * next node
     **/
    public var next: DllNode<T>;
    /**
     * node value 
     **/
    public var value: Null<T>;
    /**
     * constructor
     **/
    public function new( value_: T ){
        value = value_;
    }
    /**
     * custom toString for easier debug
     **/
    @:keep
    public function toString() {
        var p = prev.value;
        var n = next.value;
        return '$p -> $value -> $n';
    }
}
