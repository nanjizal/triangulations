package triangulations;
import mathKha.Vector2D;
// Unsure if this is needed, but added for refineForRupert
class Settings {
    public var vertices: Array<Vector2>;
    public var edges: Array<Int>;
    public var k: Float;// Int?
    public var g: Float;// Int?
    public var d: Float;// Int?
    public var yMax: Float;//Int?
    public var maxSteinerPoints: Float; //Int?
    public var minAngle: Float; //Int?
    public var maxArea: Float; //Int?

    public function new(){
        verticies = new Array<Vector2>();
        edges = new Array<Int>();
        default();
    }
    
    private var default(){
        k = 10;
        g = 10;
        d = 0.5;
        yMax = 100;
        maxSteinerPoints = 50;
        minAngle = 20;
        maxArea = 1e30;
    }
}
