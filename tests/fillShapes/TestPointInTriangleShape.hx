package tests.fillShapes;
import triangulations.FillShape;
import triangulations.Face;

abstract TestPointInTriangleShape( FillShape ) from FillShape to FillShape {
    inline public function new(){
        this = new FillShape();
        this.vertices = [
                        [200., 200.],
                        [100., 100.],
                        [300., 200.],
                        [200., 300.],
                        [  0.,   0.],
                        ];
        this.edges = [[]];
        var face: Face = [3, 2, 1];
        this.faces = [[face]];
    }
}
