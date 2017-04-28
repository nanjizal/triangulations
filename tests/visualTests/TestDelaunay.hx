package tests.visualTests;
import triangulations.FillShape;
import triangulations.Triangulate;
import triangulations.Delaunay;
import triangulations.Edges;
import triangulations.SideEdge;
import justTriangles.PathContext;
import tests.DrawHelper;
import triangulations.Geom2;
import khaMath.Vector2;
class TestDelaunay {
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
        var centres = new Array<Vector2>();
        var radius = new Array<Float>();
        var count: Int = 0;
        for( j in edges.length...all.length ){
          var edge = all[j];
          var coEdge = coEdges[j];
          var w = vert[edge.p];
          var y = vert[edge.q];
          var x = vert[coEdge.p];
          var z = vert[coEdge.q];
          var p = Geom2.circumcenter( w, y, x );
          var r = Math.sqrt( w.distSq( p ) );
          centres[count] = p;
          radius[count] = r;
          count++;
        }
        // render
        var ctx = new PathContext( 1, 1024, 0, 0 );
        var thick = 4;
        ctx.setThickness( 4 );
        ctx.setColor( 4, 0 );
        ctx.fill = false;
        var l = centres.length;
        var c: Vector2;
        for( i in 0...l ){
            c = centres[ i ];
            ctx.regularPoly( PolySides.hexacontagon, c.x, c.y, radius[i], 0 );
        }
        ctx.setColor( 0, 3 );
        ctx.moveTo( 0, 0 );
        //faces( shape, ctx );
        drawHelper.edges( all, shape, ctx, true );
        ctx.setColor( 1, 3 );
        ctx.moveTo( 0, 0 );
        drawHelper.edges( edges, shape, ctx, true );
        ctx.render( thick, false );
        return ctx;
    }
}
