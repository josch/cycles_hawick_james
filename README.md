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
    echo "0 1\n0 2\n1 0\n1 3\n2 0\n3 0\n3 1\n3 2" | ./circuits_hawick 4

First argument is the number of vertices. Subsequent arguments are ordered
pairs of comma separated vertices that make up the directed edges of the
graph.

DOT file input
--------------

For simplicity, there is no DOT file parser included but the following allows
to create a suitable argument string for simple DOT graphs.

Given a DOT file of a simple (no labels, colors, styles, only pairs of
vertices...) directed graph, the following lines generate the number of
vertices as well as the edge list expected on standard input.

        sed -n -e '/^\s*[0-9]\+;$/p' graph.dot | wc -l
        sed -n -e 's/^\s*\([0-9]\) -> \([0-9]\);$/\1 \2/p' graph.dot

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

They would produce the following output:

    3
    0 1
    0 2
    1 0
    2 0
    2 1

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

    echo "0 2\n0 10\n0 14\n1 5\n1 8\n2 7\n2 9\n3 3\n3 4\n3 6\n4 5\n4 13\n\
    4 15\n6 13\n8 0\n8 4\n8 8\n9 9\n10 7\n10 11\n11 6\n12 1\n12 1\n12 2\n12 10\n12 12\n\
    12 14\n13 3\n13 12\n13 15\n14 11\n15 0" | ./circuits_hawick 16
