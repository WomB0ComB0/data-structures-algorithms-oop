// O(V^2)
#include <stdio.h>
#include <stdlib.h>

#define MAX 20 
#define INF 999

int mat[MAX][MAX];
int V;

int dist[MAX];

int q[MAX];
int qp = 0;

int visited[MAX];
int vp = 0;

void enqueue(int v) { q[qp++] = v; }

/* Comparator for qsort: order vertices by descending dist[], so the smallest
   distance ends up at the END of the array (q[qp-1]) and we can pop it. */
int cmp_desc_by_dist(const void *a, const void *b)
{
  int va = *(const int *)a;
  int vb = *(const int *)b;

  if (dist[va] <  dist[vb]) return 1;
  if (dist[va] >  dist[vb]) return -1;
  return 0;
}

int dequeue()
{
  /* sort q[0..qp-1] by current distances */
  qsort(q, qp, sizeof(int), cmp_desc_by_dist);
  return q[--qp];
}

int queue_has_something() { return (qp > 0); }

void dijkstra(int s)
{
  for (int i = 0; i < V; ++i)
  {
    dist[i] = (i == s) ? 0 : INF;
    visited[i] = 0;
    enqueue(i);
  }

  while (queue_has_something())
  {
    int u = dequeue();
    if (visited[u]) continue;
    visited[u] = 1; 
    
    if (dist[u] == INF) continue;

    for (int i = 0; i < V; ++i)
    {
      int w = mat[u][i];
      if (w > 0 && !visited[i])
      {
        if (dist[i] > dist[u] + w)
        {
          dist[i] = dist[u] + w;
        }
      }
    }
  }
}

int main(int argc, char const *argv[])
{
  printf("Enter the number of verticies: ");
  scanf(" %d", &V);
  printf("Enter the adj matrix: ");
  int i, j;
  for (i = 0; i < V; ++i)
  {
    for (j = 0; j < V; ++j)
    {
      scanf(" %d", &mat[i][j]);
    }
  }

  dijkstra(0);

  printf("\nNode\tDist\n");
  for (i = 0; i < V; ++i)
  {
    printf("%d\t%d\n", i, dist[i]);
  }
  return 0;
}
