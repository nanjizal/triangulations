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
//import triangulations.Rupert;
import tests.fillShapes.*;
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
    var White  = 0xFFFFFF;
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
    var webgl: Drawing;
    var verts: Vertices;
    var ctx: PathContext;
    var interactionSurface:   InteractionSurface<Vector2>;
    static var sevenSegOnPoints:      Bool = true;
    static var sevenSegOnEdges:       Bool = false;
    
    public function createFillData(){
        banana  = new Banana();
        guitar  = new Guitar();
        key     = new Key();
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
                        ,   key
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
    var rainbow = [ Black, Red, Orange, Yellow, Green, Blue, Indigo, Violet, White ];   
    public function new(){
        trace( 'Testing Triangulations ');
        createFillData();
        webgl = Drawing.create( 512*2 );
        var dom = cast webgl.canvas;
        dom.style.setProperty("pointer-events","none");
        interactionSurface = new InteractionSurface( 1024, 1024, '0xcccccc' );
        sevenSegPoints = new justTriangles.SevenSeg( 6, 6, 0.015, 0.025 );
        sevenSegEdges = new justTriangles.SevenSeg( 7, 5, 0.015, 0.025 );
        sceneSetup();
        js.Browser.document.onkeydown = keyDownHandler;
    }
    var theta: Float = 0;
    inline function spinForwards(): Matrix4 {
        if( theta > Math.PI/2 ) {
            webgl.transformationFunc = null;
            theta = 0;
            if( scene++ == sceneMax ) scene = 0;
            js.Browser.document.onkeydown = keyDownHandler;
            sceneSetup();
        }
        return Matrix4.rotationX( theta += Math.PI/75 ).multmat( Matrix4.rotationY( theta ) );
    }
    inline function spinBackwards(): Matrix4 {
        if( theta > Math.PI/2 ) {
            webgl.transformationFunc = null;
            theta = 0;
            if( scene-- == 0 ) scene = sceneMax;
            js.Browser.document.onkeydown = keyDownHandler;
            sceneSetup();
        }
        return Matrix4.rotationY( theta += Math.PI/75 ).multmat( Matrix4.rotationX( theta ) );
    }
    
    var scene = 0;
    var sceneMax = 9;
    function keyDownHandler( e: KeyboardEvent ) {
        e.preventDefault();
        if( e.keyCode == KeyboardEvent.DOM_VK_LEFT ){
            trace( "LEFT" );
            webgl.transformationFunc = spinBackwards;
        } else if( e.keyCode == KeyboardEvent.DOM_VK_RIGHT ){
            trace( "RIGHT" );
            webgl.transformationFunc = spinForwards;
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
                trace( 'angle compare');
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
            default:
                trace( 'no test');
                null;
        }
        draw();
        interactionSurface.setup( vert, transform, draw );
    }
    
    public function draw(){
        //trace('webgl drawing setup');
        Triangle.triangles = new Array<Triangle>();
        sevenSegPoints.clear();
        sevenSegEdges.clear();
        switch( scene ){
            case 0:
                bananaTest();
            case 1:
                edgeIntersectTest();
            case 2:
                pointInPolyTest();
            case 3: 
                angleCompareTest();
            case 4:
                pointInTriangleTest();
            case 5:
                triangulateTest();
            case 6:
                quadEdgeTest();
            case 7:
                delaunayTest();
            case 8: 
                enclosingTriangleTest();
            case 9: 
                splitTest();
            default:
                
        }
        webgl.clearVerticesAndColors();
        sevenSegPoints.render();
        sevenSegEdges.render();
        webgl.setTriangles( Triangle.triangles, cast rainbow );
    }
    function pointInPolyTest(){
        var thick = 4;
        var shape = pointInPolyShape;
        var verts = shape.vertices;
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        ctx.lineType = TriangleJoinCurve;
        drawFaces( shape, ctx, false );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        var col = if( verts.pointInPolygon( shape.faces[0][0], verts[0] ) ){
            4;
        } else {
            1;
        }
        ctx.setColor( col, col  );
        drawSquare( 0, ctx, verts[0] );
        drawVerticesPoints( shape, ctx, 0, col, 5 );
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
        drawEdges( shape.edges, shape, ctx, true );
        drawVerticesPoints( shape, ctx, 0, 0, 5 );
        var c2 = r < 0 ? 1 : 0;
        var c3 = r > 0 ? 1 : 0;
        ctx.setColor( c2, c2  );
        drawSquare( 0, ctx, v2 );
        ctx.setColor( c3, c3  );
        drawSquare( 0, ctx, v3 );
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
        drawFaces( shape, ctx, false );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        drawVerticesPoints( shape, ctx, 0, 0, 5 );
        var c0 = inTriangle(v0) ? 1 : 4;
        ctx.setColor( c0, c0  );
        drawSquare( 0, ctx, v0 );
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
        drawEdges( shape.edges, shape, ctx, true );
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
        drawFaces( shape, ctx, false );
        ctx.fill = false;
        ctx.setColor( 4, 3 );
        ctx.moveTo( 0, 0 );
        var edges = shape.edges.clone().add( diags );
        drawEdges( edges, shape, ctx, true );
        ctx.setColor( 0, 3 );
        drawFaces( shape, ctx, false );
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
        trace( ' coEdges ' + coEdges );
        trace( ' edges ' + edges );
        //edges.flipEdge( coEdges, sideEdges, 12 );
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.fill = true;
        ctx.setColor( 0, 3 );
        ctx.moveTo( 0, 0 );
        drawEdges( edges, shape, ctx, true );
        ctx.fill = true;
        ctx.setColor( 5, 2 );
        ctx.moveTo( 0, 0 );
        edges.flipEdge( coEdges, sideEdges, 12 );
        drawEdges( edges, shape, ctx, true );
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
        
        Triangulate.refineToDelaunay( vert, all, coEdges, sideEdges );
        trace( 'all ' + all );
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
        //drawFaces( shape, ctx );
        drawEdges( all, shape, ctx, true );
        ctx.setColor( 1, 3 );
        ctx.moveTo( 0, 0 );
        drawEdges( edges, shape, ctx, true );
        ctx.render( thick, false );
    }
    public function enclosingTriangleTest(){
        var shape = enclosingTriangleShape;
        var vert = shape.vertices;//.clone();
        var face = shape.faces;
        var edges = shape.edges;
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.lineType = TriangleJoinCurve;
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 3 );
        ctx.fill = true; // with polyK
        var diags = Triangulate.triangulateFace( vert, face[0] );
        var all = edges.clone().add( diags );
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, all, coEdges, sideEdges );
        ctx.moveTo( 0, 0 );
        //drawVertices( shape, ctx, false );
        drawFaces( shape, ctx, false );
        //drawEdges( edges, shape, ctx, false );
        ctx.setColor( 0 );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        drawVerticesPoints( shape, ctx, -1, 1, 5 );
        
        
        var p = new Vector2( 300, 300 );
        var p2 = new Vector2( 350, 350 );
        drawSquare( 0, ctx, p );
        var findTri = new FindEnclosingTriangle();
        var triangle = findTri.getFace( vert, all, coEdges, sideEdges, p2, 0 )();
        ctx.setColor( 7, 1 );
        ctx.fill = true; // with polyK 
        //triangle = [0,1,2];
        if( triangle != null ) drawFace( triangle, shape, ctx, false );
        trace( 'found triangle ' + triangle );
        ctx.render( thick, false );
    }
    public function splitTest(){
        sevenSegOnEdges = true;
        sevenSegOnPoints = false;
        var shape = splitShape;
        var vert = shape.vertices;
        var face = shape.faces;
        var edges = shape.edges;
        
        var diags = Triangulate.triangulateFace( vert, face[0] );
        var all = edges.clone().add( diags );
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, all, coEdges, sideEdges );
        Triangulate.refineToDelaunay( vert, all, coEdges, sideEdges );
        ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 0 );
        ctx.moveTo( 0, 0 );
        ctx.fill = false;
        Triangulate.splitEdge( vert, all, coEdges, sideEdges, 23 );
        ctx.fill = false;
        ctx.setColor( 0, 3 );
        ctx.moveTo( 0, 0 );
        //drawFaces( shape, ctx );
        drawEdges( all, shape, ctx, true );
        ctx.setColor( 1, 3 );
        ctx.moveTo( 0, 0 );
        drawEdges( edges, shape, ctx, true );
        ctx.render( thick, false );
        sevenSegOnEdges = false;
        sevenSegOnPoints = true;
    }
    static var sevenSegPoints: SevenSeg;
    static var sevenSegEdges: SevenSeg;
    public function bananaTest(){
        var thick = 4;
        
        ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        ctx.lineType = TriangleJoinCurve;
        drawVertices( banana, ctx, false );
        ctx.setColor( 0 );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        //drawVertices( banana, ctx );
        //drawFaces( guitar, ctx );
        drawVerticesPoints( banana, ctx, -1, 1, 5 );
        ctx.render( thick, false );
    }
    
    public static inline function drawSquare( i: Int, ctx: PathContext, v: Vector2 ){
        ctx.regularPoly( PolySides.square, v.x, v.y, 10, Math.PI/4 );
        ctx.moveTo( v.x, v.y );
    }
    
    public static inline function drawPoint( i: Int, ctx: PathContext, v: Vector2 ){
        if( sevenSegOnPoints ){
            var p: justTriangles.Point = { x: v.x, y: v.y };
            p = ctx.pt( p.x, p.y );
            var w = sevenSegPoints.numberWidth( i );
            sevenSegPoints.addNumber( i, p.x - 2*w, p.y - sevenSegPoints.height );
        }
        ctx.regularPoly( PolySides.icosagon, v.x, v.y, 5, 0 ); // 20 sides
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
        var l: Int = edges.length;
        var e: Edge;
        var v0: Vector2;
        var v1: Vector2;
        var p: Int;
        var q: Int;
        var mid: Vector2;
        var w: Float;
        var point: Point;
        for( i in 0...l ){
            e = edges[i];
            if( e.isNull() ) continue;
            p = e.p;
            q = e.q;
            v0 = verts[p];
            if( v0 == null ) continue;
            ctx.moveTo( v0.x, v0.y );
            if( showPoints ) drawPoint( p, ctx, v0 );
            v1 = verts[q];
            if( v1 == null ) continue;
            ctx.lineTo( v1.x, v1.y );
            if( showPoints ) drawPoint( q, ctx, v1 );
            if( sevenSegOnEdges ){
                mid = v0.mid( v1 );
                point = { x: mid.x, y: mid.y };
                point = ctx.pt( point.x, point.y );
                w = sevenSegEdges.numberWidth( i );
                sevenSegEdges.addNumber( i, point.x, point.y, true );
            }
        }
    }
    public function drawVerticesPoints( fillShape: FillShape, ctx: PathContext, specialPoint: Int = -1, specialColor: Int, normalColor: Int ){
        verts = fillShape.vertices;
        var v: Vector2;
        var v0 = verts[0];
        if( specialPoint == 0 ){
            ctx.setColor( specialColor, specialColor );
            drawPoint( 0, ctx, v0 );
        } else {
            ctx.setColor( normalColor, normalColor );
            drawPoint( 0, ctx, v0 );
        }
        var l = verts.length;
        for( i in 1...l ){
            v = verts[i];
            if( specialPoint == i ){
                ctx.setColor( specialColor, specialColor );
                drawPoint( i, ctx, v );
                
            } else {
                ctx.setColor( normalColor, normalColor );
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
