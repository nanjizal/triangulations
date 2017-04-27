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
    public function new(){
        trace( 'Testing Triangulations ');
        createFillData();
        drawHelper = new DrawHelper();
        interactionSurface = new InteractionSurface( 1024, 1024, '0xcccccc' );
        sceneSetup();
        js.Browser.document.onkeydown = keyDownHandler;
    }
    var updateFunction: Void->Void;
    var mX: Float;
    var mY: Float;
    var theta: Float = 0;
    inline function spinForwards(): Matrix4 {
        if( theta > Math.PI/2 ) {
            drawHelper.webgl.transformationFunc = null;
            theta = 0;
            if( scene++ == sceneMax ) scene = 0;
            js.Browser.document.onkeydown = keyDownHandler;
            sceneSetup();
        }
        return Matrix4.rotationX( theta += Math.PI/75 ).multmat( Matrix4.rotationY( theta ) );
    }
    inline function spinBackwards(): Matrix4 {
        if( theta > Math.PI/2 ) {
            drawHelper.webgl.transformationFunc = null;
            theta = 0;
            if( scene-- == 0 ) scene = sceneMax;
            js.Browser.document.onkeydown = keyDownHandler;
            sceneSetup();
        }
        return Matrix4.rotationY( theta += Math.PI/75 ).multmat( Matrix4.rotationX( theta ) );
    }
    
    var scene = 0;
    var sceneMax = 10;
    function keyDownHandler( e: KeyboardEvent ) {
        e.preventDefault();
        if( e.keyCode == KeyboardEvent.DOM_VK_LEFT ){
            trace( "LEFT" );
            drawHelper.webgl.transformationFunc = spinBackwards;
        } else if( e.keyCode == KeyboardEvent.DOM_VK_RIGHT ){
            trace( "RIGHT" );
            drawHelper.webgl.transformationFunc = spinForwards;
        }
        trace( e.keyCode );  
    }
    
    function sceneSetup(){
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
        if( scene == 8 ) {
            js.Browser.document.onmousemove = function ( e: MouseEvent ){
                mX = e.clientX * 2;
                mY = e.clientY * 2;
                if( updateFunction != null ) {
                    updateFunction();
                }
            }
            // excessive don't really need to redraw all the triangles could use a secondary PathContext 
            // save the triangles before drawing in then add extra on.
            updateFunction = drawHelper.render;
        } else {
            updateFunction = null;
            js.Browser.document.onmousemove = null;
        }
    }
    public var testScene: Void -> Void;
    
    function pointInPolyTest(){
        var thick = 4;
        var shape = pointInPolyShape;
        var verts = shape.vertices;
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        ctx.lineType = TriangleJoinCurve;
        drawHelper.faces( shape, ctx, false );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        var col = if( verts.pointInPolygon( shape.faces[0][0], verts[0] ) ){
            4;
        } else {
            1;
        }
        ctx.setColor( col, col  );
        drawHelper.square( 0, ctx, verts[0] );
        drawHelper.verticesPoints( shape, ctx, 0, col, 5 );
        ctx.render( thick, false );
    }
    // Don't really understand this one but looks like it's working!!
    function angleCompareTest(){
        var shape = angleCompareShape;
        var vert = shape.vertices;
        var v0 = vert[0];
        var v1 = vert[1];
        var v2 = vert[2];
        var v3 = vert[3];
        var cmp = Geom2.angleCompare( v0, v1 );
        var r = cmp( v2, v3 );
        var thick = 4;
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        drawHelper.edges( shape.edges, shape, ctx, true );
        drawHelper.verticesPoints( shape, ctx, 0, 0, 5 );
        var c2 = r < 0 ? 1 : 0;
        var c3 = r > 0 ? 1 : 0;
        ctx.setColor( c2, c2  );
        drawHelper.square( 0, ctx, v2 );
        ctx.setColor( c3, c3  );
        drawHelper.square( 0, ctx, v3 );
        ctx.render( thick, false );
    }
    function pointInTriangleTest(){
        var shape = pointInTriangleShape;
        var vert = shape.vertices;
        var v0 = vert[0];
        var v1 = vert[1];
        var v2 = vert[2];
        var v3 = vert[3];
        var v4 = vert[4];
        var inTriangle = Geom2.pointInTriangle( v1, v2, v3 );
        vert[4] = Geom2.circumcenter( v1, v2, v3 );
        v4 = vert[4];
        var thick = 4;
        ctx = new PathContext( 1, 1024, 0, 0 );
        // draw outer circle
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );// red 
        ctx.fill = false;// just border?
        ctx.regularPoly( PolySides.hexacontagon, v4.x, v4.y, Math.sqrt( v4.distSq(v1) ), 0 ); // 20 sides
        ctx.moveTo( v4.x, v4.y );
        
        ctx.setColor( 1, 2 );
        ctx.fill = true; // with polyK
        drawHelper.faces( shape, ctx, false );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        drawHelper.verticesPoints( shape, ctx, 0, 0, 5 );
        var c0 = inTriangle(v0) ? 1 : 4;
        ctx.setColor( c0, c0  );
        drawHelper.square( 0, ctx, v0 );
        trace( 'd ' + Geom2.pointToEdgeDistSq( v1, v2 )( v0 ) );
        ctx.render( thick, false );
    }
    function edgeIntersectTest(){
        var shape = edgeIntersectShape;
        var vert = shape.vertices;
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.fill = false;
        var v0 = vert[0];
        var v1 = vert[1];
        var v2 = vert[2];
        var v3 = vert[3];
        if( Geom2.edgesIntersect( v0, v1, v2, v3 ) == true ){
            ctx.setColor( 1);
        } else {
            ctx.setColor( 4 );
        }
        drawHelper.edges( shape.edges, shape, ctx, true );
        ctx.render( thick, false );
    }
    function triangulateTest(){
        var shape = triangulateShape;
        var vert = shape.vertices;
        var face = shape.faces;
        var diags = Triangulate.triangulateFace( vert, face[0] );
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.fill = true;
        ctx.setColor( 0, 3 );
        drawHelper.faces( shape, ctx, false );
        ctx.fill = false;
        ctx.setColor( 4, 3 );
        ctx.moveTo( 0, 0 );
        var edges = shape.edges.clone().add( diags );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.setColor( 0, 3 );
        drawHelper.faces( shape, ctx, false );
        ctx.render( thick, false );
    }
    function quadEdgeTest(){
        var shape = quadEdgeShape;
        var vert = shape.vertices;
        var face = shape.faces;
        var edges = shape.edges;
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, edges, coEdges, sideEdges );
        //edges.flipEdge( coEdges, sideEdges, 12 );
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.fill = true;
        ctx.setColor( 0, 3 );
        ctx.moveTo( 0, 0 );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.fill = true;
        ctx.setColor( 5, 2 );
        ctx.moveTo( 0, 0 );
        edges.flipEdge( coEdges, sideEdges, 12 );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.render( thick, false );
    }
    function delaunayTest(){
        var shape = delaunayShape;
        var vert = shape.vertices;
        var face = shape.faces;
        var edges = shape.edges;
        var diags = Triangulate.triangulateFace( vert, face[0] );
        var all = edges.clone().add( diags );
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, all, coEdges, sideEdges );
        var delaunay = new Delaunay();
        delaunay.refineToDelaunay( vert, all, coEdges, sideEdges );
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 0 );
        ctx.fill = false;
        for( j in edges.length...all.length ){
          var edge = all[j];
          var coEdge = coEdges[j];
          var w = vert[edge.p];
          var y = vert[edge.q];
          var x = vert[coEdge.p];
          var z = vert[coEdge.q];
          var p = Geom2.circumcenter( w, y, x );
          var r = Math.sqrt( w.distSq( p ) );
          ctx.regularPoly( PolySides.hexacontagon, p.x, p.y, r, 0 );
        }
        ctx.fill = false;
        ctx.setColor( 0, 3 );
        ctx.moveTo( 0, 0 );
        //faces( shape, ctx );
        drawHelper.edges( all, shape, ctx, true );
        ctx.setColor( 1, 3 );
        ctx.moveTo( 0, 0 );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.render( thick, false );
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
        var p = new Vector2( mX, mY );
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
        drawHelper.sevenSegOnEdges = true;
        drawHelper.sevenSegOnPoints = false;
        var shape = splitShape;
        var vert = shape.vertices;
        var face = shape.faces;
        var edges = shape.edges;
        var diags = Triangulate.triangulateFace( vert, face[0] );
        var all = edges.clone().add( diags );
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, all, coEdges, sideEdges );
        var delaunay = new Delaunay();
        delaunay.refineToDelaunay( vert, all, coEdges, sideEdges );
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 0 );
        ctx.moveTo( 0, 0 );
        ctx.fill = false;
        var extra = all.clone();
        //for( i in 0...10 ){
            Triangulate.splitEdge( vert, extra, coEdges, sideEdges, 19 );
            Triangulate.splitEdge( vert, extra, coEdges, sideEdges, 16 );
            Triangulate.splitEdge( vert, extra, coEdges, sideEdges, 21 );
            //}
        //all.clone().add( extra );
        ctx.fill = false;
        ctx.setColor( 0, 3 );
        ctx.moveTo( 0, 0 );
        //faces( shape, ctx );
        drawHelper.edges( all, shape, ctx, true );
        drawHelper.edges( extra, shape, ctx, true );
        ctx.setColor( 1, 3 );
        ctx.moveTo( 0, 0 );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.render( thick, false );
        drawHelper.sevenSegOnEdges = false;
        drawHelper.sevenSegOnPoints = true;
    }
    
    public inline function transform( x: Float, y: Float ): Point {
       return ctx.pt( x, y );
    }
    
    public function bananaTest(){
        var thick = 4;
        
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        ctx.lineType = TriangleJoinCurve;
        drawHelper.vertices( banana, ctx, false );
        ctx.setColor( 0 );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        //drawHelper.drawVertices( banana, ctx );
        //drawHelper.faces( guitar, ctx );
        drawHelper.verticesPoints( banana, ctx, -1, 1, 5 );
        ctx.render( thick, false );
    }
}
