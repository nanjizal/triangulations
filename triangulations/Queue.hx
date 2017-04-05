package triangulations;
/*
Queue.hx

A function to represent a queue ported to Haxe

Origitally created by Stephen Morley - http://code.stephenmorley.org/ - and released under
the terms of the CC0 1.0 Universal legal code:

http://creativecommons.org/publicdomain/zero/1.0/legalcode

*/

//Creates a new queue. A queue is a first-in-first-out (FIFO) data structure -
//items are added to the end of the queue and removed from the front.
class Queue<T> {
    // initialise the queue and offset
    public var queue  = [];
    public var offset = 0;
    
    public function new(){
        queue = new Array<T>();
    }
    // Returns the length of the queue.
    function getLength():Int{
        return ( queue.length - offset );
    }

    // Returns true if the queue is empty, and false otherwise.
    public inline function isEmpty(): Bool {
        return ( queue.length == 0) ;
    }

    // Enqueues the specified item. The parameter is:
    // item - the item to enqueue
    public inline function equeue( item: Null<T> ){
        queue.push( item );
    }

    // Dequeues an item and returns it. If the queue is empty, the value
    // null is returned.
    public inline function dequeue(): Null<T>{
        var item:T = null;
        // if the queue is empty, return immediately
        if( queue.length == 0 ) {
            item = null;
        } else {
            // store the item at the front of the queue
            item = queue[ offset ];
            // increment the offset and remove the free space if necessary
            if (++ offset * 2 >= queue.length){
               queue  = queue.slice( offset );
               offset = 0;
            }
        }
        // return the dequeued item
        return item;
    }

    // Returns the item at the front of the queue (without dequeuing it). If the
    // queue is empty then null is returned.
    public inline function peak(): Null<T> {
      return if( queue.length > 0 ) {
                  queue[ offset ]; 
              }else { 
                  null; 
              };
    }
}
