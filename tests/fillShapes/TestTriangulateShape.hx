package tests.fillShapes;
import triangulations.FillShape;
import triangulations.Face;

abstract TestTriangulateShape( FillShape ) from FillShape to FillShape {
    inline public function new(){
        this = new FillShape();
        this.vertices = [
                        [100., 200.],
                        [100., 300.],
                        [300., 400.],
                        [300., 300.],
                        [400., 200.],
                        [300., 200.],
                        [300., 100.],
                        [200., 200.],
                        [200., 100.],
                        [150., 200.],
                        [250., 300.],
                        [150., 300.]
                        ];
        this.edges = [
                        [ 0,  1],
                        [ 1,  2],
                        [ 2,  3],
                        [ 3,  4],
                        [ 4,  5],
                        [ 5,  6],
                        [ 6,  7],
                        [ 7,  8],
                        [ 8,  0],
                        [ 9, 10],
                        [10, 11],
                        [11,  9]
                      ];
        var face0: Face = [0, 1, 2, 3, 4, 5, 6, 7, 8];
        var face1: Face = [9,10,11];
        this.faces = [[face0,face1]];
    }
}
