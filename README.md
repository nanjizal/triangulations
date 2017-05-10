# triangulations 

Haxe port of [triangulations](https://github.com/mkacz91/Triangulations) *( based on the work by Marcin Kaczmarek )*

[HAXE WEBGL DEMO/Test using justTriangles](https://rawgit.com/nanjizal/triangulationsWebGLtest/master/index.html) 

Use <- Arrow -> keys for navigation and you can normally drag vertices with the mouse.

Covered Topics
--------------

  * Polygon Triangulation,
  * PSLG Triangulation,
  * Quadratic Algorithm for PSLG Triangulation
  * Delaunay Triangulation of a Point Set,
  * Constrained Delaunay Triangulation of a PSLG,
  * The Flip algorithm for CDT,
  * Ruppert's Delaunay Refine Algorithm for Quality Triangulation.

### Delaunay screenshot
<img width="972" alt="delaunay" src="https://cloud.githubusercontent.com/assets/20134338/25845345/7e720c90-34a5-11e7-9b2a-d3655dce2d84.png">

### Example of Delaunay Use

```haxe
        // create a FillShape and populate it's Vectices, Edges and Faces.
        var shape: FillShape = fillShape.clone();
        var vert = shape.vertices;
        var face = shape.faces;
        var edges = shape.edges;
        var diags = Triangulate.triangulateFace( vert, face[0] );
        var delaunayEdges = edges.clone().add( diags );
        var coEdges = new Edges();
        var sideEdges = new Array<SideEdge>();
        Triangulate.makeQuadEdge( vert, delaunayEdges, coEdges, sideEdges );
        var delaunay = new Delaunay();
        delaunay.refineToDelaunay( vert, delaunayEdges, coEdges, sideEdges );
        // implement your own drawing of the delaunayEdges ( Array<Edge> )
        // each Edge contains two vertices indices.
```

### Haxe Porting details
One important aspect of the port is that I have separated graphics tests from the core algorithms. In this repository there is no platform dependant code.  The code relies on [khaMath](https://github.com/nanjizal/khaMath) for Vector2 functionality. The port also seeks to swap extensive *arrays* and very functional code for *classes* and *abstracts* while still keeping some functional aspects, hopefully the changes have improved both speed and readability?

### Rupert screenshot
<img width="468" alt="ruppert" src="https://cloud.githubusercontent.com/assets/20134338/25898625/d14d6b00-3584-11e7-9066-e9859b5b8a01.png">

### Example of Ruppert Use

```haxe
        // Same as per Dealaunay example then
        var setting = new Settings(); // setting effect the amount of itereations 
        setting.maxSteinerPoints = 50;
        setting.minAngle = 20;
        Ruppert.refineTo( vert, delaunayEdges, coEdges, sideEdges, setting );
        // each solution will be randomly different but resolve to a similar resolution.
        // implement your own drawing of the delaunayEdges ( Array<Edge> )
        // each Edge contains two vertices indices.
```
### Test Git repository:
### [triangulationsWebGLtest - git for visual testing and WebGL use](https://github.com/nanjizal/triangulationsWebGLtest).

License
-------

This project is licensed under the terms of the MIT license.

<sup>**note:  The Queue class has inline licence as it is ported from it's own project, and required that form of licence.**</sup>
