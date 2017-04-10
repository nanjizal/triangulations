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
// js Specifc
import js.Browser;
import js.html.HTMLDocument;
import js.html.DivElement;
import js.html.Event;
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
typedef Limit = {
    var left: Float;
    var right: Float;
    var top: Float;
    var bottom: Float;
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
    var limits: Array<Limit> = [];
    var doc: HTMLDocument;
    var bg: DivElement;
    var currVertex: Int; 
    var webgl: Drawing;
    var verts: Vertices;
    var ctx: PathContext;
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
        createBackground();
        initVerticesHits();
    }
    function createBackground(){
        doc = Browser.document;
        //doc.body.style.margin = '8px';
        bg = doc.createDivElement();
        bg.style.backgroundColor = '#cccccc';
        bg.style.width = '1024px';
        bg.style.height = '1024px';
        bg.style.position = "absolute";
        bg.style.left = '0px';
        bg.style.top = '0px';
        bg.style.zIndex = '-100';
        bg.style.cursor = "default";
        doc.body.appendChild( bg );
        bg.addEventListener( 'mousedown', makePointsDragable );
    }
    function makePointsDragable( e: MouseEvent ){
        var i: Int = hitVertex( e.clientX * 2, e.clientY * 2 );
        if( i != null ) {
            currVertex = i;
            bg.style.cursor = "move";
            bg.addEventListener( 'mousemove', repositionVertex );
            bg.addEventListener( 'mouseup', killMouseMove );
        }
    }
    function killMouseMove( e: MouseEvent ){
        bg.style.cursor = "default";
        bg.removeEventListener( 'mousemove', repositionVertex );
        bg.removeEventListener( 'mouseup', killMouseMove );
    }
    function repositionVertex( e: MouseEvent ){
        var x: Float = e.clientX ;
        var y: Float = e.clientY ;
        moveVertex( currVertex, x, y );
    }
    @:access( justTriangles.PathContext )
    public function hitVertex( x: Float, y: Float ){
        var aLimit: Limit;
        var p = ctx.pt( x, y );
        for( i in 0...limits.length ){
            aLimit = limits[ i ];
            if( p.x > aLimit.left && p.x < aLimit.right ){
                if( p.y > aLimit.top && p.y < aLimit.bottom ){
                    return i;
                }
            }
        }
        return null;
    }
    public function draw(){
        trace('webgl drawing setup');
        Triangle.triangles = new Array<Triangle>();
        Draw.colorFill_id = 3;
        Draw.colorLine_id = 3;
        Draw.extraLine_id = 3;
        Draw.extraFill_id = 3;
        var thick = 4;
        var ctxFill = new PathContext( 2, 1024, 0, 0 );
        ctxFill.fill = true; // with polyK
        ctxFill.lineType = TriangleJoinCurve;
        drawVertices( banana, ctxFill, false );
        ctxFill.render( thick, false );
        Draw.colorFill_id = 0;
        Draw.colorLine_id = 0;
        Draw.extraLine_id = 0;
        Draw.extraFill_id = 0;
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.fill = false; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        drawVertices( banana, ctx );
        ctx.render( thick, false );
        webgl.clearVerticesAndColors();
        webgl.setTriangles( Triangle.triangles, cast rainbow );
    }
    public static inline function drawPoint( i: Int, ctx: PathContext, v: Vector2 ){
        ctx.regularPoly( PolySides.hexacontagon, v.x, v.y, 5, 0 );
        ctx.moveTo( v.x, v.y );
    }
    function moveVertex( i: Int, x: Float, y: Float ){
        setVertexLimit( i, x, y );
        var v = verts[ i ];
        v.x = (x ) * 2;
        v.y = (y ) * 2;
        draw();
    }
    @:access( justTriangles.PathContext )
    public inline function setVertexLimit( i: Int, x: Float, y: Float ){
        var p0 = ctx.pt( x - 15, y - 15 );
        var p1 = ctx.pt( x + 15, y + 15 );
        limits[ i ] = cast { left: p0.x, top: p0.y, right: p1.x, bottom: p1.y };
    }
    public function initVerticesHits(){
        var l = verts.length;
        var v: Vector2;
        for( i in 0...l ){
            v = verts[i];
            setVertexLimit( i, v.x, v.y );
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
