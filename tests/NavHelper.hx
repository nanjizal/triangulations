package tests;
import js.Browser;
import khaMath.Matrix4;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;

class NavHelper{
    public var onSceneChange: Int -> Void;
    public var setTransform:  ( Void -> Matrix4 ) -> Void; 
    public var mouseMoveUpdate: Void->Void;
    var mouseScenes: Array<Int>;
    var updateFunction: Void->Void; 
    var scene = 0;
    var sceneMax = 10;
    public var mX: Float;
    public var mY: Float;
    var theta: Float = 0;
    
    public function new( startScene: Int, sceneMax_: Int, mouseScenes_: Array<Int> ){
        scene = startScene;
        sceneMax = sceneMax_;
        mouseScenes = mouseScenes_;
        Browser.document.onkeydown = keyDownHandler;
    }
    public function start(){
        onSceneChange( scene );
    }
    inline function spinForwards(): Matrix4 {
        if( theta > Math.PI/2 ) {
            setTransform( null );
            theta = 0;
            if( scene++ == sceneMax ) scene = 0;
            Browser.document.onkeydown = keyDownHandler;
            if( onSceneChange != null ) onSceneChange( scene );
            trackMouse();
        }
        return Matrix4.rotationX( theta += Math.PI/75 ).multmat( Matrix4.rotationY( theta ) );
    }
    inline function spinBackwards(): Matrix4 {
        if( theta > Math.PI/2 ) {
            setTransform( null );
            theta = 0;
            if( scene-- == 0 ) scene = sceneMax;
            js.Browser.document.onkeydown = keyDownHandler;
            if( onSceneChange != null ) onSceneChange( scene );
            trackMouse();
        }
        return Matrix4.rotationY( theta += Math.PI/75 ).multmat( Matrix4.rotationX( theta ) );
    }
    
    inline function trackMouse(){
        var storeMouse = false;
        for( sceneInt in mouseScenes ){
            if( sceneInt == scene ) {
                storeMouse = true;
                break;
            }
        }
        if( storeMouse ) {
            js.Browser.document.onmousemove = function ( e: MouseEvent ){
                mX = e.clientX * 2;
                mY = e.clientY * 2;
                if( updateFunction != null ) {
                    updateFunction();
                }
            }
            // excessive don't really need to redraw all the triangles could use a secondary PathContext 
            // save the triangles before drawing in then add extra on.
            if( mouseMoveUpdate != null ) updateFunction = mouseMoveUpdate;// drawHelper.render;
        } else {
            updateFunction = null;
            js.Browser.document.onmousemove = null;
        }
    }
    
    function keyDownHandler( e: KeyboardEvent ) {
        e.preventDefault();
        if( e.keyCode == KeyboardEvent.DOM_VK_LEFT ){
            trace( "LEFT" );
            //drawHelper.webgl.transformationFunc = spinBackwards;
            setTransform( spinBackwards );
        } else if( e.keyCode == KeyboardEvent.DOM_VK_RIGHT ){
            trace( "RIGHT" );
            setTransform( spinForwards );
            //drawHelper.webgl.transformationFunc = spinForwards;
        }
        trace( e.keyCode );  
    }
}
