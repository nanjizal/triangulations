package triangulations;
import khaMath.Vector2;
import triangulations.Vertices;
import triangulations.Edges;
// Unsure if this is needed, but added for refineForRupert
class Settings {
    public var vertices: Vertices;
    public var edges: Edges;
    public var k: Float;// Int?
    public var g: Float;// Int?
    public var d: Float;// Int?
    public var yMax: Float;//Int?
    public var maxSteinerPoints: Float; //Int?
    public var minAngle: Float; //Int?
    public var maxArea: Float; //Int?

    public function new(){
        vertices = Vertices.getEmpty();
        edges = Edges.getEmpty();
        defaults();
    }
    
    private function defaults(){
        k = 10;
        g = 10;
        d = 0.5;
        yMax = 100;
        maxSteinerPoints = 50;
        minAngle = 20;
        maxArea = 1e30;
    }
}
