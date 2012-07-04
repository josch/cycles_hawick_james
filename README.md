Finding all the circuits of a directed graph with self-arcs and multiple-arcs
-----------------------------------------------------------------------------

Algorithm and code by K.A. Hawick and H.A. James

    Enumerating Circuits and Loops in Graphs with Self-Arcs and Multiple-Arcs
    K.A. Hawick and H.A. James
    Computer Science, Institute for Information and Mathematical Sciences,
    Massey University, North Shore 102-904, Auckland, New Zealand
    k.a.hawick@massey.ac.nz; heath.james@sapac.edu.au
    Tel: +64 9 414 0800
    Fax: +64 9 441 8181
    Technical Report CSTN-013

Usage
-----

    make
    ./circuits_hawick 4 0,1 0,2 1,0 1,3 2,0 3,0 3,1 3,2

First argument is the number of vertices. Subsequent arguments are ordered
pairs of comma separated vertices that make up the directed edges of the
graph.

DOT file input
--------------

For simplicity, there is no DOT file parser included but the following allows
to create a suitable argument string for simple DOT graphs.

Given a DOT file of a simple (no labels, colors, styles, only pairs of
vertices...) directed graph, the following line produces commandline
arguments in the above format for that graph.

	echo `sed -n -e '/^\s*[0-9]\+;$/p' graph.dot | wc -l` `sed -n -e 's/^\s*\([0-9]\) -> \([0-9]\);$/\1,\2/p' graph.dot`

The above line works on DOT files like the following:

    digraph G {
      0;
      1;
      2;
      0 -> 1;
      0 -> 2;
      1 -> 0;
      2 -> 0;
      2 -> 1;
      }

It would produce the following output:

    3 0,1 0,2 1,0 2,0 2,1

Reproducing the example from the paper
--------------------------------------

Figure 10 of the paper cited above:

    0  10  11  6  13   3  4  15  0                    1   8   4  13  12  1
    0  10  11  6  13  12  1   8  0                    1   8   4  13  12  1
    0  10  11  6  13  12  1   8  4  15  0             3   3
    0  10  11  6  13  12  1   8  0                    3   4  13   3
    0  10  11  6  13  12  1   8  4  15  0             3   6  13   3
    0  10  11  6  13  15  0                           6  13  12  10  11  6
    0  14  11  6  13   3  4  15  0                    6  13  12  14  11  6
    0  14  11  6  13  12  1   8  0                    8   8
    0  14  11  6  13  12  1   8  4  15  0             9   9
    0  14  11  6  13  12  1   8  0                   12  12
    0  14  11  6  13  12  1   8  4  15  0
    0  14  11  6  13  15  0

Figure 10: 22 Circuits found in the network shown in figure 9 which has 16
nodes and 32 arcs and allows self-arcs. Note there are repeated circuits due to
the presence of a multiple-arc connecting nodes 12 and 1.

The input graph, which is shown in figure 9, can be given as an input to the
program using above format as follows:

    ./circuits_hawick 16 0,2 0,10 0,14 1,5 1,8 2,7 2,9 3,3 3,4 3,6 4,5 4,13 \
    4,15 6,13 8,0 8,4 8,8 9,9 10,7 10,11 11,6 12,1 12,1 12,2 12,10 12,12 \
    12,14 13,3 13,12 13,15 14,11 15,0
