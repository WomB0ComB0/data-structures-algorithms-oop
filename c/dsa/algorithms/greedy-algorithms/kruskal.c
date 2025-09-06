/*
A minimum spanning tree (MST) or minimum weight psanning tree for a weighted, conneced, and undirected graph is a spanning tree (no cycles and connects all vertices) that has minimum weight. The weight of a spanning tree is the sum of all edges in the tree.

In Kruskal's algorithm, we sort all edges of the given graph in increasing order. THen it keeps on adding new edges and nodes in the MST if the newly added edge does not form a cycle. it picks the minimum weighted edge at first and the maximum weighted edge at last. Thus we can say that it makes a locally optimal choice in each step in order to find the optimal solution. Hence this is a Greedy Algorithm.
*/