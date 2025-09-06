// Ford–Fulkerson (Edmonds–Karp via BFS) in C
// T: O(|V| * E^2)
// S: O(V)
// source: https://www.geeksforgeeks.org/dsa/ford-fulkerson-algorithm-for-maximum-flow-problem/#

#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <stdbool.h>

#define V 6  // number of vertices

// Returns true if there is a path from s to t in residual graph rGraph.
// Also fills parent[] to store the path.
static bool bfs(int rGraph[V][V], int s, int t, int parent[V]) {
    bool visited[V];
    memset(visited, 0, sizeof(visited));

    // Simple array queue
    int q[V];
    int front = 0, back = 0;

    q[back++] = s;
    visited[s] = true;
    parent[s]  = -1;

    while (front < back) {
        int u = q[front++];

        for (int v = 0; v < V; v++) {
            if (!visited[v] && rGraph[u][v] > 0) {
                parent[v] = u;
                visited[v] = true;
                if (v == t) {
                    return true; // found augmenting path to sink
                }
                q[back++] = v;
            }
        }
    }
    return false;
}

int fordFulkerson(int graph[V][V], int s, int t) {
    int rGraph[V][V]; // residual capacities

    // Initialize residual graph with original capacities
    for (int u = 0; u < V; u++) {
        for (int v = 0; v < V; v++) {
            rGraph[u][v] = graph[u][v];
        }
    }

    int parent[V];
    int max_flow = 0;

    // Augment the flow while there is a path from source to sink
    while (bfs(rGraph, s, t, parent)) {
        // Find minimum residual capacity along the path found by BFS
        int path_flow = INT_MAX;
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            if (rGraph[u][v] < path_flow) path_flow = rGraph[u][v];
        }

        // Update residual capacities along the path (forward and reverse edges)
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            rGraph[u][v] -= path_flow;
            rGraph[v][u] += path_flow;
        }

        // Add path flow to overall flow
        max_flow += path_flow;
    }

    return max_flow;
}

int main(void) {
    int graph[V][V] = {
        { 0, 16, 13,  0,  0,  0 },
        { 0,  0, 10, 12,  0,  0 },
        { 0,  4,  0,  0, 14,  0 },
        { 0,  0,  9,  0,  0, 20 },
        { 0,  0,  0,  7,  0,  4 },
        { 0,  0,  0,  0,  0,  0 }
    };

    int max_flow = fordFulkerson(graph, 0, 5);
    printf("The maximum possible flow is %d\n", max_flow);
    return 0;
}
