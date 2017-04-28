package tests;
import triangulations.Edge;
import triangulations.Edges;
import triangulations.Vertices;
import triangulations.Geom2;
import triangulations.Queue;
import triangulations.SideEdge;
import triangulations.Settings;
import triangulations.Graph;
import triangulations.Face;
import triangulations.Triangulate;
import triangulations.FindEnclosingTriangle;
import triangulations.Rupert;
import tests.fillShapes.*;
import triangulations.FillShape;
import triangulations.Delaunay;
import khaMath.Vector2;
import tests.DrawHelper;
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
import justTriangles.SevenSeg;
import justTriangles.Point;
import htmlHelper.tools.CSSEnterFrame;
import justTriangles.SvgPath;
import justTriangles.PathContextTrace;
import justTrianglesWebGL.InteractionSurface;
// js Specifc
import js.Browser;
import js.html.HTMLDocument;
import js.html.DivElement;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
// tests
import tests.visualTests.TestShape;
import tests.visualTests.TestAngleCompare;
import tests.visualTests.TestSplit;
import tests.visualTests.TestTriangulate;
import tests.visualTests.TestQuadEdge;
import tests.visualTests.TestDelaunay;
import tests.visualTests.TestEdgeIntersect;
import tests.visualTests.TestPointInTriangle;
import tests.visualTests.TestPointInPoly;

class MainTestSetup {
    static function main(){
        new MainTestSetup();
    }
    var banana:  FillShape;
    var guitar:  FillShape;
    var keyShape:     FillShape;
    var sheet:   FillShape;
    var ty:      FillShape;
    var angleCompareShape:    FillShape;
    var delaunayShape:        FillShape;
    var edgeIntersectShape:   FillShape;
    var enclosingTriangleShape:    FillShape;
    var graphShape:           FillShape;
    var pointInPolyShape:     FillShape;
    var pointInTriangleShape: FillShape;
    var quadEdgeShape:        FillShape;
    var splitShape:           FillShape;
    var triangulateShape:     FillShape;
    var verts: Vertices;
    var ctx: PathContext;
    var interactionSurface:   InteractionSurface<Vector2>;
    
    public function createFillData(){
        banana  = new Banana();
        guitar  = new Guitar();
        keyShape = new Key();
        sheet   = new Sheet();
        ty      = new Ty();
        angleCompareShape       = new TestAngleCompareShape();
        delaunayShape           = new TestDelaunayShape();
        edgeIntersectShape      = new TestEdgeIntersectShape();
        enclosingTriangleShape  = new TestEnclosingTriangleShape();
        graphShape              = new TestGraphShape();
        pointInPolyShape        = new TestPointInPolyShape();
        pointInTriangleShape    = new TestPointInTriangleShape();
        quadEdgeShape           = new TestQuadEdgeShape();
        splitShape              = new TestSplitShape();
        triangulateShape        = new TestTriangulateShape();
        var dataShapes = [  banana
                        ,   guitar
                        ,   keyShape
                        ,   sheet
                        ,   ty
                        ,   angleCompareShape
                        ,   delaunayShape 
                        ,   edgeIntersectShape  
                        ,   enclosingTriangleShape  
                        ,   graphShape  
                        ,   pointInPolyShape 
                        ,   pointInTriangleShape 
                        ,   quadEdgeShape 
                        ,   splitShape 
                        ,   triangulateShape ];
        var l = dataShapes.length;
        var shape: FillShape;
        for( i in 0...l ) {
            shape = dataShapes[i];
            shape.fit( 1024, 1024, 120 );
            // set the outline!
            shape.set_fixedExternal( true );
        }
    }
    var drawHelper: DrawHelper;
    var navHelper: NavHelper;
    public function new(){
        trace( 'Testing Triangulations ');
        createFillData();
        drawHelper = new DrawHelper();
        interactionSurface = new InteractionSurface( 1024, 1024, '0xcccccc' );
        navSetup();
    }
    function navSetup(){
        var startScene = 0;
        var maxScene = 10;
        var mouseScenes = [8];
        navHelper = new NavHelper( startScene, maxScene, mouseScenes );
        navHelper.onSceneChange = sceneSetup;
        navHelper.setTransform = animateAssign;
        navHelper.mouseMoveUpdate = drawHelper.render;
        navHelper.start();
    }
    public function animateAssign( animation: Void -> Matrix4 ) {
        drawHelper.webgl.transformationFunc = animation;
    }
    function sceneSetup( val: Int ){
        var scene = val;
        var vert: Vertices =
        switch( scene ){
            case 0:
                trace( 'banana test' );
                banana.vertices;
            case 1:
                trace( 'edge intersect' );
                edgeIntersectShape.vertices;
            case 2:
                trace( 'poly in point' );
                pointInPolyShape.vertices;
            case 3: 
                trace( 'angle compare');
                angleCompareShape.vertices;
            case 4: 
                trace( 'point in Triangle' );
                pointInTriangleShape.vertices;
            case 5: 
                trace( 'triangulate test' );
                triangulateShape.vertices;
            case 6:
                trace( 'quad edge test');
                quadEdgeShape.vertices;
            case 7: 
                trace( 'delaunay test');
                delaunayShape.vertices;
            case 8:
                trace('enclosing triangle test');
                enclosingTriangleShape.vertices;
            case 9:
                trace('split test');
                splitShape.vertices;
            case 10:
                trace('rupert test');
                triangulateShape.vertices;
            default:
                trace( 'no test');
                null;
        }
       drawHelper.testScene = switch( scene ){
            case 0:
                bananaTest;
            case 1:
                edgeIntersectTest;
            case 2:
                pointInPolyTest;
            case 3: 
                angleCompareTest;
            case 4:
                pointInTriangleTest;
            case 5:
                triangulateTest;
            case 6:
                quadEdgeTest;
            case 7:
                delaunayTest;
            case 8: 
                enclosingTriangleTest;
            case 9: 
                splitTest;
            case 10:
                rupertTest;
            default:
                bananaTest;
        }
        drawHelper.render();
        interactionSurface.setup( vert, transform, drawHelper.render );
    }
    public var testScene: Void -> Void;
    
    function pointInPolyTest(){
        ctx = TestPointInPoly.draw( pointInPolyShape, drawHelper );
    }
    // Don't really understand this one but looks like it's working!!
    function angleCompareTest(){
        ctx = TestAngleCompare.draw( angleCompareShape, drawHelper );
    }
    function pointInTriangleTest(){
        ctx = TestPointInTriangle.draw( pointInTriangleShape, drawHelper );
    }
    function edgeIntersectTest(){
        ctx = TestEdgeIntersect.draw( edgeIntersectShape, drawHelper );
    }
    function triangulateTest(){
        ctx = TestTriangulate.draw( triangulateShape, drawHelper );
    }
    function quadEdgeTest(){
        ctx = TestQuadEdge.draw( quadEdgeShape, drawHelper );
    }
    function delaunayTest(){
        ctx = TestDelaunay.draw( delaunayShape, drawHelper );
    }
    var all: Edges;
    var vert: Vertices;
    var shape: FillShape;
    var coEdges: Edges;
    var sideEdges: Array<SideEdge>;
    public function enclosingTriangleTest(){
        shape = enclosingTriangleShape;
        vert = shape.vertices;//.clone();
        var face = shape.faces;
        var edges = shape.edges;
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.lineType = TriangleJoinCurve;
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 3 );
        ctx.fill = true; // with polyK
        var diags = Triangulate.triangulateFace( vert, face[0] );
        all = edges.clone().add( diags );
        coEdges = new Edges();
        sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, all, coEdges, sideEdges );
        ctx.moveTo( 0, 0 );
        //drawVertices( shape, ctx, false );
        drawHelper.faces( shape, ctx, false );
        //drawEdges( edges, shape, ctx, false );
        ctx.setColor( 0 );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        drawHelper.verticesPoints( shape, ctx, -1, 1, 5 );
        ctx.render( thick, false );
        encloseTriangleDraw();
    }
    
    // TODO: Refactor to be only called rather than method above when triangle moves.
    public function encloseTriangleDraw(){
        var p = new Vector2( navHelper.mX, navHelper.mY );
        //square( 0, ctx, p );
        var ctx2 = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx2.setThickness( 4 );
        var findTri = new FindEnclosingTriangle();
        var triangle = findTri.getFace( vert, all, coEdges, sideEdges, p, 0 );
        ctx2.setColor( 7, 7 );
        ctx2.fill = true; // with polyK 
        if( triangle != null ) drawHelper.face( triangle, shape, ctx2, false );
        ctx2.render( thick, false );
    }
    
    public function rupertTest(){

        shape = triangulateShape;//keyShape;
        var vert = shape.vertices;
        var face = shape.faces;
        var edges = shape.edges;
        Triangulate.triangulateSimple( vert, edges, [face[0]] );
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, edges, coEdges, sideEdges );
        var delaunay = new Delaunay();
        delaunay.refineToDelaunay( vert, edges, coEdges, sideEdges );
        
        /*
        var verticesBackup = vertices.clone();
        var edgesBackup = edges.clone();
        var coEdgesBackup = coEdges.clone();
        var sideEdgesBackup = [];
        var l = edges.length;
        for ( j in 0... l ) sideEdgesBackup[j] = sideEdges[j].clone();
        */
           
        var setting = new Settings();
        //setting.maxSteinerPoints = 50;
        //setting.minAngle = 20;
        Rupert.refineTo( vert, edges, coEdges, sideEdges, setting );
        
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.lineType = TriangleJoinCurve;
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 3 );
        ctx.fill = true; // with polyK
        ctx.moveTo( 0, 0 );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.setColor( 0, 3 );
        drawHelper.faces( shape, ctx, false );
        ctx.render( thick, false );
        
    }
    
    public function splitTest(){
        TestSplit.draw( splitShape, drawHelper );
    }
    
    public inline function transform( x: Float, y: Float ): Point {
       return ctx.pt( x, y );
    }
    
    public function bananaTest(){
        ctx = TestShape.draw( banana, drawHelper );
    }
}
