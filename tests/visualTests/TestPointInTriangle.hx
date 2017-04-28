package tests.visualTests;
import triangulations.FillShape;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
class TestPointInTriangle {
    public static inline 
    function draw( shape: FillShape, drawHelper: DrawHelper ){
        // geom
        var vert = shape.vertices;
        var v0 = vert[0];
        var v1 = vert[1];
        var v2 = vert[2];
        var v3 = vert[3];
        var v4 = vert[4];
        var inTriangle = Geom2.pointInTriangle( v1, v2, v3 );
        vert[4] = Geom2.circumcenter( v1, v2, v3 );
        v4 = vert[4];
        var c0 = inTriangle(v0) ? 1 : 4;
        var radius = Math.sqrt( v4.distSq(v1) );
        // render
        var thick = 4;
        var ctx = new PathContext( 1, 1024, 0, 0 );
        // draw outer circle
        ctx.setThickness( 4 );
        ctx.setColor( 0, 3 );// red 
        ctx.fill = false;// just border?
        ctx.regularPoly( PolySides.hexacontagon, v4.x, v4.y, radius, 0 ); // 20 sides
        ctx.moveTo( v4.x, v4.y );
        ctx.setColor( 1, 2 );
        ctx.fill = true; // with polyK
        drawHelper.faces( shape, ctx, false );
        ctx.setColor( 0, 3 );
        ctx.fill = true; // with polyK
        drawHelper.verticesPoints( shape, ctx, 0, 0, 5 );
        ctx.setColor( c0, c0  );
        drawHelper.square( 0, ctx, v0 );
        // geom
        trace( 'd ' + Geom2.pointToEdgeDistSq( v1, v2 )( v0 ) );
        // render
        ctx.render( thick, false );
        return ctx;
    }
}
