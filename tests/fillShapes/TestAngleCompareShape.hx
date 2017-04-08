package tests.fillShapes;
import triangulations.FillShape;
import triangulations.Face;

abstract TestAngleCompareShape( FillShape ) from FillShape to FillShape {
    inline public function new(){
        this = new FillShape();
        this.vertices = [
                        [200., 200.],
                        [100., 300.],
                        [300., 200.],
                        [200., 100.]
                        ];
        this.edges = [
                    [0, 1],
                    [0, 2],
                    [0, 3]
                    ];
        var face: Face = [];
        this.faces = [[face]];
    }
}
