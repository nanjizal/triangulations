package tests.visualTests;
import triangulations.FillShape;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
class TestPointInPoly {
    public static inline 
    function draw( shape: FillShape, drawHelper: DrawHelper ){
        // geom
        var verts = shape.vertices;
        var c = ( verts.pointInPolygon( shape.faces[0][0], verts[0] ) )? 4: 1;
        // render
        var thick = 4;
        var ctx = new PathContext( 1, 1024, 0, 0 );
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        ctx.lineType = TriangleJoinCurve;
        drawHelper.faces( shape, ctx, false );
        ctx.fill = true; // with polyK 
        ctx.lineType = TriangleJoinCurve; // - default
        ctx.setColor( c, c  );
        drawHelper.square( 0, ctx, verts[0] );
        drawHelper.verticesPoints( shape, ctx, 0, c, 5 );
        ctx.render( thick, false );
        return ctx;
    }
}
