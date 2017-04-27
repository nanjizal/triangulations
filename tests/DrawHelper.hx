package tests;
import justTriangles.SevenSeg;
import justTriangles.Triangle;
import justTriangles.PathContext;
import khaMath.Vector2;
import triangulations.FillShape;
import triangulations.Edges;
import triangulations.Edge;
import triangulations.Face;
import justTriangles.Point;
import justTrianglesWebGL.Drawing;
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
class DrawHelper {
    
    public var sevenSegOnPoints:      Bool = true;
    public var sevenSegOnEdges:       Bool = false;
    var sevenSegPoints: SevenSeg;
    var sevenSegEdges: SevenSeg;
    public var webgl: Drawing;
    public var testScene: Void->Void;
    var rainbow = [ Black, Red, Orange, Yellow, Green, Blue, Indigo, Violet, White ];
    
    public function new(){
        webgl = Drawing.create( 512*2 );
        var dom = cast webgl.canvas;
        dom.style.setProperty("pointer-events","none");
        sevenSegPoints = new justTriangles.SevenSeg( 6, 6, 0.015, 0.025 );
        sevenSegEdges = new justTriangles.SevenSeg( 7, 5, 0.015, 0.025 );
    }

    public function render(){
        Triangle.triangles = new Array<Triangle>();
        sevenSegPoints.clear();
        sevenSegEdges.clear();
        if( testScene != null ) testScene();
        webgl.clearVerticesAndColors();
        sevenSegPoints.render();
        sevenSegEdges.render();
        webgl.setTriangles( Triangle.triangles, cast rainbow );
    }
    
    
    public inline function square( i: Int, ctx: PathContext, v: Vector2 ){
        ctx.regularPoly( PolySides.square, v.x, v.y, 10, Math.PI/4 );
        ctx.moveTo( v.x, v.y );
    }
    
    public inline function point( i: Int, ctx: PathContext, v: Vector2 ){
        if( sevenSegOnPoints ){
            var p: justTriangles.Point = { x: v.x, y: v.y };
            p = ctx.pt( p.x, p.y );
            var w = sevenSegPoints.numberWidth( i );
            sevenSegPoints.addNumber( i, p.x - 2*w, p.y - sevenSegPoints.height );
        }
        ctx.regularPoly( PolySides.icosagon, v.x, v.y, 5, 0 ); // 20 sides
        ctx.moveTo( v.x, v.y );
    }
    
    public function faces( fillShape: FillShape, ctx_: PathContext, showPoints: Bool = true ){
        var faces_ = fillShape.faces;
        var somefaces: Array<Face>;
        var face_: Face;
        for( j in 0...faces_.length ){
            somefaces = faces_[j];
            for( k in 0...somefaces.length ){
                face_ = somefaces[k];
                for( i in 0...face_.length ) face( face_, fillShape, ctx_, showPoints );
            }
        }
    }
    public function face( face_: Face, fillShape: FillShape, ctx_: PathContext, showPoints: Bool = true ){
        var verts = fillShape.vertices;
        var l: Int = face_.length;
        var f0 = face_[0];
        var v0 = verts[f0];
        var f: Int;
        ctx_.moveTo( v0.x, v0.y );
        if( showPoints ) point( f0, ctx_, v0 );
        var v: Vector2;
        for( i in 1...l ){
            f = face_[i];
            v = verts[f];
            ctx_.lineTo( v.x, v.y );
            if( showPoints ) point( f, ctx_, v );
        }
        ctx_.lineTo( v0.x, v0.y );
    }
    public function edges( edges: Edges, fillShape: FillShape, ctx: PathContext, showPoints: Bool = true ){
        var verts = fillShape.vertices;
        var l: Int = edges.length;
        var e: Edge;
        var v0: Vector2;
        var v1: Vector2;
        var p: Int;
        var q: Int;
        var mid: Vector2;
        var w: Float;
        var p_: Point;
        for( i in 0...l ){
            e = edges[i];
            if( e.isNull() ) continue;
            p = e.p;
            q = e.q;
            v0 = verts[p];
            if( v0 == null ) continue;
            ctx.moveTo( v0.x, v0.y );
            if( showPoints ) point( p, ctx, v0 );
            v1 = verts[q];
            if( v1 == null ) continue;
            ctx.lineTo( v1.x, v1.y );
            if( showPoints ) point( q, ctx, v1 );
            if( sevenSegOnEdges ){
                mid = v0.mid( v1 );
                p_ = { x: mid.x, y: mid.y };
                p_ = ctx.pt( p_.x, p_.y );
                w = sevenSegEdges.numberWidth( i );
                sevenSegEdges.addNumber( i, p_.x, p_.y, true );
            }
        }
    }
    public function verticesPoints( fillShape: FillShape, ctx: PathContext, specialPoint: Int = -1, specialColor: Int, normalColor: Int ){
        var verts = fillShape.vertices;
        var v: Vector2;
        var v0 = verts[0];
        if( specialPoint == 0 ){
            ctx.setColor( specialColor, specialColor );
            point( 0, ctx, v0 );
        } else {
            ctx.setColor( normalColor, normalColor );
            point( 0, ctx, v0 );
        }
        var l = verts.length;
        for( i in 1...l ){
            v = verts[i];
            if( specialPoint == i ){
                ctx.setColor( specialColor, specialColor );
                point( i, ctx, v );
                
            } else {
                ctx.setColor( normalColor, normalColor );
                point( i, ctx, v );
            }
        }
    }
    public function vertices( fillShape: FillShape, ctx: PathContext, showPoints: Bool = true ){
        var verts = fillShape.vertices;
        var v0 = verts[0];
        var v: Vector2;
        ctx.moveTo( v0.x, v0.y );
        if( showPoints ) point( 0, ctx, v0 );
        var l = verts.length;
        for( i in 1...l ){
            v = verts[i];
            ctx.lineTo( v.x, v.y );
            if( showPoints ) point( i, ctx, v );
        }
        ctx.lineTo( v0.x, v0.y );
    }
}
