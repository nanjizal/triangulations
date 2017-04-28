package tests.visualTests;
import triangulations.FillShape;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
class TestShape {
    public static inline 
    function draw( shape: FillShape, drawHelper: DrawHelper ){
        // geom
        // render
        var thick = 4;
        var ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        ctx.lineType = TriangleJoinCurve;
        drawHelper.vertices( shape, ctx, false );
        ctx.setColor( 0 );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        //drawHelper.faces( shape, ctx );
        drawHelper.verticesPoints( shape, ctx, -1, 1, 5 );
        ctx.render( thick, false );
        return ctx;
    }
}
