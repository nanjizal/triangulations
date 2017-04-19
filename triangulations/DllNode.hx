package triangulations;
// Double Linked List Node
typedef DllNodeInt = DllNode<Int>;
class DllNode<T> {
    public var prev: DllNode<T>;
    public var next: DllNode<T>;
    public var value: Null<T>;
    public function new( value_: T ){
        value = value_;
    }
    @:keep
    public function toString() {
        var p = prev.value;
        var n = next.value;
        return '$p -> $value -> $n';
    }
}
