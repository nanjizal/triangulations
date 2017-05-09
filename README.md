# triangulations ( WIP )

<img width="972" alt="delaunay" src="https://cloud.githubusercontent.com/assets/20134338/25845345/7e720c90-34a5-11e7-9b2a-d3655dce2d84.png">

[DEMO - WebGL test using justTriangles](https://rawgit.com/nanjizal/triangulationsWebGLtest/master/index.html) 

Use <- Arrow -> keys for navigation and you can normally drag vertices with the mouse.

Haxe port of [triangulations](https://github.com/mkacz91/Triangulations) *( based on the work by Marcin Kaczmarek )*

One important aspect of the port is that I have separated graphics tests from the core algorithms. In this repository there is no platform dependant code.  The code relies on [khaMath](https://github.com/nanjizal/khaMath) for Vector2 functionality. The port also seeks to swap extensive *arrays* and very functional code for *classes* and *abstracts* while still keeping some functional aspects, hopefully the changes have improve both speed and readability?

### [triangulationsWebGLtest - git for visual testing and WebGL use](https://github.com/nanjizal/triangulationsWebGLtest).

I am still working on the triangulate algorithm class, but basic triangulation and Delaunay work, Rupert functionality still requires some debugging.

# Issues
 - Currently the 'Rupert' visual test is failing to render but compiles.
 - 'Split' test needs improving.


<sup>**note:  The Queue class has inline licence as it is ported from it's own project, and required that form of licence.**</sup>
