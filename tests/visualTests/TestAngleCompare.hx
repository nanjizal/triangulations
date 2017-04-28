package tests.visualTests;
import triangulations.FillShape;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
class TestAngleCompare {
    public static inline 
    function draw( shape: FillShape, drawHelper: DrawHelper ){
        // geom
        var vert = shape.vertices;
        var v0 = vert[0];
        var v1 = vert[1];
        var v2 = vert[2];
        var v3 = vert[3];
        var cmp = Geom2.angleCompare( v0, v1 );
        var r = cmp( v2, v3 );
        // render
        var thick = 4;
        var ctx = new PathContext( 1, 1024, 0, 0 );
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
        return ctx;
    }
}
