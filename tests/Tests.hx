package tests;
import triangulations.FillShape;
import tests.fillShapes.*;
import triangulations.Geom2;
import triangulations.Triangulate;
class Tests {
    
    // Shape data for Triangulation Tests
    public var angleCompareShape:    FillShape;
    public var delaunayShape:        FillShape;
    public var edgeIntersectShape:   FillShape;
    public var enclosingTriangle:    FillShape;
    public var graphShape:           FillShape;
    public var pointInPolyShape:     FillShape;
    public var pointInTriangleShape: FillShape;
    public var quadEdgeShape:        FillShape;
    public var splitShape:           FillShape;
    public var triangulateShape:     FillShape;
    
    public function new(){
        createFillData();
        /*
        angleCompareTest();
        delaunayTest();
        edgeIntersectTest();
        enclosingTriangleTest();
        graphTest();
        pointInPolyTest();
        pointInTriangleTest();
        quadEdgeTest();
        ruppertTest();
        splitTest();
        triangulateTest();*/
    }
    
    public function createFillData(){
        angleCompareShape       = new TestAngleCompareShape();
        delaunayShape           = new TestDelaunayShape();
        edgeIntersectShape      = new TestEdgeIntersectShape();
        enclosingTriangle       = new TestEnclosingTriangleShape();
        graphShape              = new TestGraphShape();
        pointInPolyShape        = new TestPointInPolyShape();
        pointInTriangleShape    = new TestPointInTriangleShape();
        quadEdgeShape           = new TestQuadEdgeShape();
        splitShape              = new TestSplitShape();
        triangulateShape        = new TestTriangulateShape();
    }
    
    function angleCompareTest(){
        var vert = angleCompareShape.vertices;
        var cmp = Geom2.angleCompare( vert[0], vert[1] );
        var r = cmp( vert[2], vert[3] );
        trace( 'r ' + r );
    }
    
    function delaunayTest(){
        
    }
    
    function edgeIntersectTest(){
        var vert = edgeIntersectShape.vertices;
        trace( 'Edge cross intersect ' + Geom2.edgesIntersect( vert[0], vert[1], vert[2], vert[3] ) );
        trace( 'Edge parallel intersect ' + Geom2.edgesIntersect( vert[0], vert[2], vert[1], vert[3] ) );
        trace( 'Edge parallel intersect ' + Geom2.edgesIntersect( vert[0], vert[2], vert[1], vert[3] ) );
    }
    
    function enclosingTriangleTest(){
    
    }
    
    function graphTest(){
    
    }
    
    function pointInPolyTest(){
    
    }
    
    function pointInTriangleTest(){
    
    }
    
    function quadEdgeTest(){
    
    }
    
    function ruppertTest(){
    
    }
    
    function splitTest(){
        var diags = Triangulate.triangulateFace( splitShape.vertices, splitShape.faces[0] );
        trace( diags );
        trace( splitShape.edges );
        var edges = splitShape.edges.clone();
        edges.add( diags );
        trace( edges );
        //var qe = Triangulate.makeQuadEdge(split.vertices, edges);
        //edges.add( diags );
    }
    
    function triangulateTest(){
    
    }
    
}
