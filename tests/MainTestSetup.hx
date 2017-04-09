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
import htmlHelper.tools.CSSEnterFrame;
import justTriangles.SvgPath;
import justTriangles.PathContextTrace;
import tests.Tests;
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
        var webgl = Drawing.create( 570*2 );
        fillShapesCreate();
        tests = new Tests();
        draw();
        webgl.setTriangles( Triangle.triangles, cast rainbow );
    }
    
    public function draw(){
        trace('webgl drawing setup');
        Draw.colorFill_id = 1;
        Draw.colorLine_id = 0;
        Draw.colorLine_id = 7;
        Draw.extraFill_id = 2;
        var ctx;
        var thick = 2;
        ctx = new PathContext( 1, 1000, 100, 100 );
        ctx.lineType = TriangleJoinCurve; // - default
        drawVertices( banana, ctx );
        ctx.render( thick, false );
        
    }
    
    public function drawVertices( fillShape: FillShape, ctx: PathContext ){
        var verts = fillShape.vertices;
        var v0 = verts[0];
        var v: Vector2;
        ctx.moveTo( v0.x, v0.y );
        var l = verts.length;
        for( i in 1...l ){
            v = verts[i];
            ctx.lineTo( v.x, v.y );
        }
        ctx.lineTo( v0.x, v0.y );
    }
}
