/*
 * Enumerating Circuits and Loops in Graphs with Self-Arcs and Multiple-Arcs
 * K.A. Hawick and H.A. James
 * Computer Science, Institute for Information and Mathematical Sciences,
 * Massey University, North Shore 102-904, Auckland, New Zealand
 * k.a.hawick@massey.ac.nz; heath.james@sapac.edu.au
 * Tel: +64 9 414 0800
 * Fax: +64 9 441 8181
 * Technical Report CSTN-013
 */

import std.stdio;

int nVertices = 0;           // number of vertices
int start = 0;               // starting vertex index
int [][] Ak;                 // integer array size n of lists
                             // ie the arcs from the vertex
int [][] B;                  // integer array size n of lists
bool [] blocked;             // logical array indexed by vertex
ulong nCircuits = 0;         // total number of circuits found;
ulong [] lengthHistogram;    // histogram of circuit lengths
ulong [][] vertexPopularity; // adjacency table of occurrences of
                             // vertices in circuits of each length
int [] longestCircuit;       // the (first) longest circuit found
int lenLongest = 0;          // its length
bool enumeration = true;     // explicitly enumerate circuits
int [] stack = null;         // stack of integers
static int stackTop = 0;     // the number of elements on the stack
                             // also the index "to put the next one"

// return a pointer to a list of fixed max size
int [] newList(int max) {
    int[] retval;
    retval.length = max + 1;
    retval[0] = 0;
    return retval;
}

// return TRUE if value is NOT in the list
bool notInList (int [] list, int val) {
    assert(list != null);
    assert(list [0] < list.length);
    for (int i = 1; i <= list[0]; i++) {
        if (list[i] == val)
            return false;
    }
    return true;
}

// return TRUE if value is in the list
bool inList (int [] list, int val) {
    assert(list != null);
    assert(list[0] < list.length);
    for (int i = 1; i <= list[0]; i++) {
        if (list[i] == val)
            return true;
    }
    return false;
}

// empties a list by simply zeroing its size
void emptyList (int [] list) {
    assert(list != null);
    assert(list[0] < list.length);
    list[0] = 0;
}

// adds on to the end (making extra space if needed)
void addToList (ref int [] list, int val) {
    assert(list != null);
    assert(list[0] < list.length);
    int newPos = list[0] + 1;
    if (newPos >= list.length)
        list.length = list.length + 1;
    list[newPos] = val;
    list[0] = newPos;
}

// removes all occurences of val in the list
int removeFromList(int [] list, int val) {
    assert(list != null);
    assert(list[0] < list.length);
    int nOccurrences = 0;
    for (int i = 1; i <= list[0]; i++) {
        if (list[i] == val) {
            nOccurrences++;
            for (int j = i; j<list[0]; j++) {
                list[j] = list[j+1];
            }
            --list[0]; // should be safe as list[0] is
                       // re-evaluated each time around the i-loop
            --i;
        }
    }
    return nOccurrences;
}

void stackPrint3d() {
    int i;
    for (i = 0; i < stackTop-1; i++) {
        std.stdio.writef("%d ", stack[i]);
    }
    std.stdio.writefln("%d", stack[i]);
}

int countAkArcs () { // return number of Arcs in graph
    int nArcs = 0;
    for (int i =0; i<nVertices; i ++) {
        nArcs += Ak[i][0]; // zero’th element gives nArcs for i
    }
    return nArcs;
}

void unblock (int u) {
    blocked [u] = false;
    for (int wPos = 1; wPos <= B[u][0]; wPos++) {
        // for each w in B[u]
        int w = B[u][wPos];
        wPos -= removeFromList(B[u], w);
        if (blocked[w])
            unblock(w);
    }
}

// initialise the stack to some size max
void stackInit(int max) {
    stack.length = max;
    assert(stack != null);
    stackTop = 0;
}

// push an int onto the stack, extending if necessary
void stackPush (int val) {
    if (stackTop >= stack.length)
        stack.length = stack.length + 1;
    stack[stackTop++] = val;
}

int stackSize() {
    return stackTop;
}

int stackPop () {
    // pop an int off the stack
    assert(stackTop > 0);
    return stack[--stackTop];
}

void stackClear () {
    // clear the stack
    stackTop = 0;
}

bool circuit(int v) { // based on Johnson ’s logical procedure CIRCUIT
    bool f = false;
    stackPush(v);
    blocked[v] = true;
    for (int wPos = 1; wPos <= Ak[v][0]; wPos++) { // for each w in list Ak[v]:
        int w = Ak[v][wPos];
        if (w < start) continue; // ignore relevant parts of Ak
        if (w == start) { // we have a circuit,
            if (enumeration) {
                stackPrint3d(); // print out the stack to record the circuit
            }
            assert (stackTop <= nVertices);
            ++lengthHistogram[stackTop]; // add this circuit ’s length to the length histogram
            nCircuits++; // and increment count of circuits found
            if (stackTop > lenLongest) { // keep a copy of the longest circuit found
                lenLongest = stackTop;
                longestCircuit = stack.dup;
            }
            for (int i = 0; i < stackTop; i ++) // increment [circuit-length][vertex] for all vertices in this circuit
                 ++vertexPopularity[stackTop][stack[i]];
            f = true;
        } else if (!blocked[w]) {
            if (circuit(w)) f = true;
        }
    }
    if (f) {
        unblock (v);
    } else {
        for (int wPos = 1; wPos <= Ak[v][0]; wPos++) { // for each w in list Ak[v]:
            int w = Ak[v][wPos];
            if (w < start) continue;  // ignore relevant parts of Ak
            if (notInList(B[w], v)) addToList(B[w], v);
        }
    }
    v = stackPop();
    return f;
}

void setupGlobals(string[] args) {  // presupposes nVertices is set up
    nVertices = std.conv.parse!int(args[1]);
    Ak.length = nVertices; // Ak[i][0] is the number of members, Ak[i][1]..Ak[i][n] ARE the members, i>0
    B.length = nVertices;  // B[i][0] is the number of members, B[i][1]..B[i][n] ARE the members , i>0
    blocked.length = nVertices; // we use blocked [0]..blocked[n-1], i> = 0
    for (int i = 0; i < nVertices; i++) {
        Ak[i] = newList(nVertices);
        B[i] = newList(nVertices);
        blocked[i] = false;
    }

    for (int i = 2; i < args.length; i++) {
        string[] vertices = std.array.split(args[i], ",");
        int v1 = std.conv.parse!int(vertices[0]);
        int v2 = std.conv.parse!int(vertices[1]);
        addToList(Ak[v1], v2);
    }

    lengthHistogram.length = nVertices+1; // will use as [1]...[n] to histogram circuits by length
                                          // [0] for zero length circuits, which are impossible
    for (int len = 0; len < lengthHistogram.length; len++) // initialise histogram bins to empty
        lengthHistogram[len] = 0;
    stackInit(nVertices);
    vertexPopularity.length = nVertices+1; // max elementary circuit length is exactly nVertices
    for (int len = 0; len <= nVertices; len++) {
        vertexPopularity[len].length = nVertices;
        for (int j = 0; j < nVertices; j++) {
            vertexPopularity[len][j] = 0;
        }
    }
}

/*
 * to replicate the result from figure 10 in the paper, run the program as
 * follows:
 *
 * ./circuits_hawick 16 0,2 0,10 0,14 1,5 1,8 2,7 2,9 3,3 3,4 3,6 4,5 4,13 \
 * 4,15 6,13 8,0 8,4 8,8 9,9 10,7 10,11 11,6 12,1 12,1 12,2 12,10 12,12 \
 * 12,14 13,3 13,12 13,15 14,11 15,0
 */
int main(string[] args) {
    if (args.length < 3) {
        std.stdio.writefln("usage: %s num_vertices [v1,v2...]", args[0]);
        return 1;
    }
    setupGlobals(args);
    stackClear();
    start = 0;
    bool verbose = false;
    while (start < nVertices) {
        if (verbose && enumeration) std.stdio.writefln("Starting s = %d\n", start);
        for (int i = 0; i < nVertices; i++) { // for all i in Vk
            blocked[i] = false;
            emptyList(B[i]);
        }
        circuit(start);
        start = start + 1;
    }
    return 0;
}
