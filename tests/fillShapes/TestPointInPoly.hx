package tests.fillShapes;
import triangulations.FillShape;
import triangulations.Face;

abstract TestPointInPolyShape( FillShape ) from FillShape to FillShape {
    inline public function new(){
        this = new FillShape();
        this.vertices = [
                        [200., 300.],
                        [100., 200.],
                        [100., 300.],
                        [300., 400.],
                        [300., 300.],
                        [400., 200.],
                        [300., 200.],
                        [300., 100.],
                        [200., 200.],
                        [200., 100.]
                        ];
        this.edges = [];
        var face: Face = [1, 2, 3, 4, 5, 6, 7, 8];
        this.faces = [[face]];
    }
}
