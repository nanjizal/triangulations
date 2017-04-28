package tests.visualTests;
import triangulations.FillShape;
import triangulations.Triangulate;
import triangulations.Delaunay;
import triangulations.Edges;
import triangulations.SideEdge;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
class TestSplit {
    public static inline 
    function draw( shape: FillShape, drawHelper: DrawHelper ){
        // geom
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
        var extra = all.clone();
        //for( i in 0...10 ){
            Triangulate.splitEdge( vert, extra, coEdges, sideEdges, 19 );
            Triangulate.splitEdge( vert, extra, coEdges, sideEdges, 16 );
            Triangulate.splitEdge( vert, extra, coEdges, sideEdges, 21 );
            //}
        //all.clone().add( extra );
        
        // render
        drawHelper.sevenSegOnEdges = true;
        drawHelper.sevenSegOnPoints = false;
        var ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 0 );
        ctx.moveTo( 0, 0 );
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
}
