package tests;
import triangulations.Edge;
import triangulations.Edges;
import triangulations.Vertices;
import triangulations.Geom2;
import triangulations.Node;
import triangulations.Queue;
import triangulations.SideEdge;
import triangulations.Settings;
import triangulations.Graph;
import triangulations.Face;
//import triangulations.Rupert;
import triangulations.Triangulate;
import tests.fillShapes.Banana;
import tests.fillShapes.Guitar;
import tests.fillShapes.Key;
import tests.fillShapes.Sheet;
import tests.fillShapes.Ty; 
import triangulations.FillShape;
import khaMath.Vector2;
// drawing specific
import js.Browser;
import khaMath.Matrix4;
import justTrianglesWebGL.Drawing;
import justTriangles.Triangle;
import justTriangles.Draw;
import justTriangles.Point;
import justTriangles.PathContext;
import justTriangles.ShapePoints;
import justTriangles.QuickPaths;
import justTriangles.Point;
import htmlHelper.tools.CSSEnterFrame;
import justTriangles.SvgPath;
import justTriangles.PathContextTrace;
import tests.Tests;
import justTrianglesWebGL.InteractionSurface;
// js Specifc
import js.Browser;
import js.html.HTMLDocument;
import js.html.DivElement;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
@:enum
abstract RainbowColors( Int ){
    var Violet = 0x9400D3;
    var Indigo = 0x4b0082;
    var Blue   = 0x0000FF;
    var Green  = 0x00ff00;
    var Yellow = 0xFFFF00;
    var Orange = 0xFF7F00;
    var Red    = 0xFF0000;
    var Black  = 0x000000;
}
    
class MainTestSetup {
    static function main(){
        new MainTestSetup();
    }
    var banana:  FillShape;
    var guitar:  FillShape;
    var key:     FillShape;
    var sheet:   FillShape;
    var ty:      FillShape;
    var tests:   Tests;

    var webgl: Drawing;
    var verts: Vertices;
    var ctx: PathContext;
    var interactionSurface: InteractionSurface<Vector2>;
    public function fillShapesCreate(){
        banana  = new Banana();
        guitar  = new Guitar();
        key     = new Key();
        sheet   = new Sheet();
        ty      = new Ty();
    }
    var rainbow = [ Black, Red, Orange, Yellow, Green, Blue, Indigo, Violet ];   
    public function new(){
        trace( 'Testing Triangulations ');
        fillShapesCreate();
        webgl = Drawing.create( 512*2 );
        var dom = cast webgl.canvas;
        dom.style.setProperty("pointer-events","none");
        tests = new Tests();
        draw();
          interactionSurface = new InteractionSurface( 1024, 1024, '0xcccccc' );
        //interactionSurface.setup( banana.vertices, transform, draw );
        //interactionSurface.setup( tests.edgeIntersectShape.vertices, transform, draw );
          interactionSurface.setup( tests.pointInPolyShape.vertices, transform, draw );
        js.Browser.document.onkeydown = keyDownHandler;
    }
    function keyDownHandler( e: KeyboardEvent ) {
        e.preventDefault();
        if( e.keyCode == KeyboardEvent.DOM_VK_LEFT ){
            trace( "LEFT" );
        } else if( e.keyCode == KeyboardEvent.DOM_VK_RIGHT ){
            trace( "RIGHT" );
        }
        trace( e.keyCode );  
    }
    
    public function draw(){
        //trace('webgl drawing setup');
        Triangle.triangles = new Array<Triangle>();
        //bananaTest();
        //edgeIntersectTest();
        pointInPolyTest();
        webgl.clearVerticesAndColors();
        webgl.setTriangles( Triangle.triangles, cast rainbow );
    }
    
    function pointInPolyTest(){
        var thick = 4;
        var ctxFill = new PathContext( 2, 1024, 0, 0 );
        ctxFill.setColor( 0, 3 );
        ctxFill.fill = true; // with polyK
        ctxFill.lineType = TriangleJoinCurve;
        trace( tests.pointInPolyShape.vertices );
        drawFaces( tests.pointInPolyShape, ctxFill, false );
        ctxFill.render( thick, false );
        
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setColor( 6 );
        ctx.fill = false; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        var shape = tests.pointInPolyShape;
        var col = if( shape.vertices.pointInPolygon( shape.faces[0][0], shape.vertices[0] )){
            4;
        } else {
            1;
        }
        ctx.setColor( col );
        drawSquare( 0, ctx, shape.vertices[0] );
        trace( 'col ' + col );
        drawVerticesPoints( tests.pointInPolyShape, ctx, 0, col, 5 );
        ctx.render( thick, false );
    }
    
    function edgeIntersectTest(){
        var vert = tests.edgeIntersectShape.vertices;
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.fill = false;
        var v0 = vert[0];
        var v1 = vert[1];
        var v2 = vert[2];
        var v3 = vert[3];
        if( Geom2.edgesIntersect( v0, v1, v2, v3 ) == true ){
            ctx.setColor( 1 );
        } else {
            ctx.setColor( 3 );
        }
        drawEdges( tests.edgeIntersectShape.edges, tests.edgeIntersectShape, ctx, true );
        ctx.render( thick, false );
    }
    
    public function bananaTest(){
        
        var thick = 4;
        var ctxFill = new PathContext( 2, 1024, 0, 0 );
        ctxFill.setColor( 0, 3 );
        ctxFill.fill = true; // with polyK
        ctxFill.lineType = TriangleJoinCurve;
        drawVertices( banana, ctxFill, false );
        ctxFill.render( thick, false );
        
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setColor( 0 );
        ctx.fill = false; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        //drawVertices( banana, ctx );
        //drawFaces( guitar, ctx );
        drawVerticesPoints( banana, ctx, 0, 1, 4 );
        ctx.render( thick, false );
    }
    
    public static inline function drawSquare( i: Int, ctx: PathContext, v: Vector2 ){
        ctx.moveTo( v.x, v.y );
        ctx.regularPoly( PolySides.square, v.x, v.y, 10, 0 );
        ctx.moveTo( v.x, v.y );
    }
    
    public static inline function drawPoint( i: Int, ctx: PathContext, v: Vector2 ){
        //ctx.moveTo( v.x, v.y );
        ctx.regularPoly( PolySides.hexacontagon, v.x, v.y, 5, 0 );
        ctx.moveTo( v.x, v.y );
    }
    @:access( justTriangles.PathContext )
    public inline function transform( x: Float, y: Float ): Point {
       return ctx.pt( x, y );
    }
        
    public function drawFaces( fillShape: FillShape, ctx_: PathContext, showPoints: Bool = true ){
        var faces = fillShape.faces;
        var somefaces: Array<Face>;
        var face: Face;
        for( j in 0...faces.length ){
            somefaces = faces[j];
            for( k in 0...somefaces.length ){
                face = somefaces[k];
                trace( 'face.length ' + face.length );
                for( i in 0...face.length ) drawFace( face, fillShape, ctx_, showPoints );
            }
        }
    }
    public function drawFace( face: Face, fillShape: FillShape, ctx_: PathContext, showPoints: Bool = true ){
        var verts = fillShape.vertices;
        var l: Int = face.length;
        var f0 = face[0];
        var v0 = verts[f0];
        var f: Int;
        ctx_.moveTo( v0.x, v0.y );
        if( showPoints ) drawPoint( f0, ctx_, v0 );
        var v: Vector2;
        for( i in 1...l ){
            f = face[i];
            v = verts[f];
            ctx_.lineTo( v.x, v.y );
            if( showPoints ) drawPoint( f, ctx_, v );
        }
        ctx_.lineTo( v0.x, v0.y );
    }
    public function drawEdges( edges: Edges, fillShape: FillShape, ctx: PathContext, showPoints: Bool = true ){
        var verts = fillShape.vertices;
        trace(' verts ' + verts );
        var l: Int = edges.length;
        var e: Edge;
        var v: Vector2;
        var p: Int;
        var q: Int;
        for( i in 0...l ){
            e = edges[i];
            p = e.p;
            q = e.q;
            v = verts[p];
            ctx.moveTo( v.x, v.y );
            if( showPoints ) drawPoint( p, ctx, v );
            v = verts[q];
            ctx.lineTo( v.x, v.y );
            if( showPoints ) drawPoint( q, ctx, v );
        }
    }
    public function drawVerticesPoints( fillShape: FillShape, ctx: PathContext, specialPoint: Int = -1, specialColor: Int, normalColor: Int ){
        verts = fillShape.vertices;
        var v: Vector2;
        /*var v0 = verts[0];
        trace( 'specialPoint ' + specialPoint );
        if( specialPoint == 0 ){
            ctx.setColor( specialColor );
            drawPoint( 0, ctx, v0 );
        } else {
            ctx.setColor( normalColor );
            drawPoint( 0, ctx, v0 );
            }*/
        var l = verts.length;
        for( i in 1...l ){
            v = verts[i];
            if( specialPoint == i ){
                //ctx.setColor( specialColor );
                drawPoint( i, ctx, v );
                
            } else {
                ctx.setColor( normalColor );
                drawPoint( i, ctx, v );
            }
        }
    }
    public function drawVertices( fillShape: FillShape, ctx: PathContext, showPoints: Bool = true ){
        verts = fillShape.vertices;
        var v0 = verts[0];
        var v: Vector2;
        ctx.moveTo( v0.x, v0.y );
        if( showPoints ) drawPoint( 0, ctx, v0 );
        var l = verts.length;
        for( i in 1...l ){
            v = verts[i];
            ctx.lineTo( v.x, v.y );
            if( showPoints ) drawPoint( i, ctx, v );
        }
        ctx.lineTo( v0.x, v0.y );
    }
}
