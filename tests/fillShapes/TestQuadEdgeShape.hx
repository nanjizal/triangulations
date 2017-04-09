package tests.fillShapes;
import triangulations.FillShape;
import triangulations.Face;

abstract TestQuadEdgeShape( FillShape ) from FillShape to FillShape {
    inline public function new(){
        this = new FillShape();
        this.vertices = [
                        [100., 100.],
                        [200., 100.],
                        [200., 200.],
                        [100., 200.],
                        [ 50., 150.],
                        [150.,  50.],
                        [250., 150.],
                        [150., 250.]
                        ];
        this.edges = [
                        [0, 1],
                        [1, 2],
                        [2, 3],
                        [3, 0],
                        [0, 5],
                        [5, 1],
                        [1, 6],
                        [6, 2],
                        [2, 7],
                        [7, 3],
                        [3, 4],
                        [4, 0],
                        [0, 2]
        ];
        var face: Face = [];
        this.faces = [[face]];
    }
}
