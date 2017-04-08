package tests.fillShapes;
import triangulations.FillShape;
import triangulations.Face;

abstract TestEdgeIntersectShape( FillShape ) from FillShape to FillShape {
    inline public function new(){
        this = new FillShape();
        this.vertices = [
                        [ 10,  10],
                        [100, 100],
                        [100,  10],
                        [ 10, 100]
                        ];
        this.edges = [
                        [0, 1],
                        [2, 3]
                    ];
        var face: Face = [];
        this.faces = [[face]];
    }
}
