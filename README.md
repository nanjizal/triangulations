# triangulations ( WIP )

Haxe port of [triangulations](https://github.com/mkacz91/Triangulations) *( based on the work by Marcin Kaczmarek )*

One important aspect of the port is that I have separated graphics tests from the core algorithms. In this repository there is no platform dependant code.  The code relies on [khaMath](https://github.com/nanjizal/khaMath) for Vector2 functionality. The port also seeks to swap extensive *arrays* and very functional code for *classes* and *abstracts* while still keeping some functional aspects, hopefully the changes have improve both speed and readability?

### [git for visual testing and WebGL use](https://github.com/nanjizal/triangulationsWebGLtest).

[WebGL tests](https://rawgit.com/nanjizal/triangulationsWebGLtest/master/index.html) 
Use <- Arrow -> keys for navigation and you can normally drag vertices with the mouse.

I am still working on the triangulate algorithm class, but basic triangulation and Delaunay work, Rupert functionality still requires some debugging.

# Issues
 - Currently the 'Rupert' visual test is failing to render but compiles.



<sup>**note:  The Queue class has inline licence as it is ported from it's own project, and required that form of licence.**</sup>
