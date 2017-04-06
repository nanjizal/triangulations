package tests;
import triangulations.Edge;
import triangulations.Edges;
import triangulations.Vertices;
import triangulations.Geom2;
import triangulations.Node;
import triangulations.Queue;
import triangulations.SideEdge;
import triangulations.Settings;
import triangulations.Graph;
//import triangulations.Rupert;
import triangulations.Triangulate;
import tests.fillShapes.Bannana;
import tests.fillShapes.Guitar;
import tests.fillShapes.Key;
import tests.fillShapes.Sheet;
import triangulations.FillShape;
class MainTestSetup {
    
    static function main(){
        new MainTestSetup();
    }
    
    public function new(){
        trace( 'Testing Triangulations ');
        var fillShape: FillShape = new Bannana();
        var fillShape: FillShape = new Guitar();
        var fillShape: FillShape = new Key();
        var fillShape: FillShape = new Sheet();
    }
    
}
