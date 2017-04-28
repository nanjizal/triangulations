package tests.visualTests;
import triangulations.FillShape;
import triangulations.Triangulate;
import triangulations.Delaunay;
import triangulations.Edges;
import triangulations.SideEdge;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
class TestTriangulate {
    public static inline 
    function draw( shape: FillShape, drawHelper: DrawHelper ){
        // geom
        var vert = shape.vertices;
        var face = shape.faces;
        var diags = Triangulate.triangulateFace( vert, face[0] );
        var extra = shape.edges.clone().add( diags );
        // render
        var thick = 4;
        var ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.fill = true;
        ctx.setColor( 0, 3 );
        drawHelper.faces( shape, ctx, false );
        ctx.fill = false;
        ctx.setColor( 4, 3 );
        ctx.moveTo( 0, 0 );
        drawHelper.edges( extra, shape, ctx, true );
        ctx.setColor( 0, 3 );
        drawHelper.faces( shape, ctx, false );
        ctx.render( thick, false );
        return ctx;
    }
}
