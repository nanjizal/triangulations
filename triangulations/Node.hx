package triangulations;

class Node<T> {
    public var prev: Node<T>;
    public var next: Node<T>;
    public var value: T = Null<T>;
    public function new( value_: T ){
        value = value_;
    }
    @:keep
    public function toString() {
        return value;
    }
    public function toStringOrder() {
        var p = prev.value;
        var n = next.value;
        return '$p->$value->$n';
    }
}
