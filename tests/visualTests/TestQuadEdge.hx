package tests.visualTests;
import triangulations.FillShape;
import triangulations.Triangulate;
import triangulations.Delaunay;
import triangulations.Edges;
import triangulations.SideEdge;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
class TestQuadEdge {
    public static inline 
    function draw( shape: FillShape, drawHelper: DrawHelper ){
        // geom
        var vert = shape.vertices;
        var face = shape.faces;
        var edges = shape.edges;
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, edges, coEdges, sideEdges );
        // render
        //edges.flipEdge( coEdges, sideEdges, 12 );
        var ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.fill = true;
        ctx.setColor( 0, 3 );
        ctx.moveTo( 0, 0 );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.fill = true;
        ctx.setColor( 5, 2 );
        ctx.moveTo( 0, 0 );
        // geom
        edges.flipEdge( coEdges, sideEdges, 12 );
        // render
        drawHelper.edges( edges, shape, ctx, true );
        ctx.render( thick, false );
        return ctx;
    }
}
