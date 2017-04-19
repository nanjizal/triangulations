# triangulations
triangulations Haxe library port of:

https://github.com/mkacz91/Triangulations

( based on the work by Marcin Kaczmarek )

In the Haxe port I have tried to separate graphics and algorithms more directly, and reduces use of Arrays to hopefully faster Classes and Abstracts, some rough Webgl tests can be seen here, they use JustTriangles for rendering.

https://rawgit.com/nanjizal/triangulations/master/index.html

I am still working on the triangulate algorithm class, but basic triangulation and Delaunay seems to work, 'Rupert' and some other algorithm functionality requires more work, and there is a weird hack in Delaunay that I need to check.

The Queue code has inline licence and also ported from another source, but not actually used yet in tests.  
Algorithms code rely on 'khaMath'.
