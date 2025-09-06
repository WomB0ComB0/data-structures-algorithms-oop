/*
Huffman coding is a lossless data compression algorithm. The idea is to assign varable-length codes to input characters, length of the assigned codes are based on the frequenceies of corresponding characters.

The variable-length codes assigned to input characters are Prefix Codes, means the codes (bit seuqneces) are assigned in such a way that the code assigned to one character is not the prefix of code assgined to any other character. This is how Huffman Coding makes sure that there is no ambiguity decoding the genrate bitstream.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
  int freq;
  int idx;
  struct Node *left;
  struct Node *right;
} Node;

typedef struct {
  Node **a;
  int size;
  int cap;
} MinHeap;

static void heap_swap(Node **x, Node **y) {
  Node *t = *x; *x = *y; *y = t;
}

static MinHeap *heap_new(int cap)
{
  MinHeap *h = (MinHeap *)malloc(sizeof(MinHeap));
  h->a = (Node **)malloc(sizeof(Node *) * cap);
  h->size = 0;
  h->cap = cap;
  return h;
}

static void heap_free(MinHeap *h) {
  free(h->a);
  free(h);
}

static void heap_shift_up(MinHeap *h, int i) {
  while (i > 0) {
    int p = (i - 1) / 2;
    if (h->a[p]->freq <= h->a[i]->freq) break;
    heap_swap(&h->a[p],&h->a[i]);
    i = p;
  }
}

static void heap_shift_down(MinHeap *h, int i) {
  for (;;) {
    int l = 2*i + 1, r = 2*i + 2, smallest = i;
    if (l < h->size && h->a[l]->freq < h->a[smallest]->freq) smallest = l;
    if (r < h->size && h->a[r]->freq < h->a[smallest]->freq) smallest = r;
    if (smallest == i) break;
    heap_swap(&h->a[i], &h->a[smallest]);
    i = smallest;
  }
}

static void heap_push(MinHeap *h, Node *x) {
  if (h-> size == h->cap) {
    h->cap = h->cap ? h->cap * 2 : 8;
    h->a = (Node **)realloc(h->a, sizeof(Node *) * h->cap); 
  }
  h->a[h->size] = x;
  heap_shift_up(h, h->size);
  h->size++;
}

static Node *heap_pop(MinHeap *h) {
  if (h->size == 0) return NULL;
  Node *min = h->a[0];
  h->a[0] = h->a[--h->size];
  if (h->size > 0) heap_shift_down(h, 0);
  return min;
}

// Node Utilities
static Node *new_leaf(int freq, int idx) {
  Node *n = (Node *)malloc(sizeof(Node));
  n->freq = freq;
  n->idx = idx;
  n->left = n->right = NULL;
  return n ;
}

static Node *new_internal(Node *l, Node *r) {
  Node *n = (Node *)malloc(sizeof(Node));
  n-> freq = l->freq + r->freq;
  n->idx = -1;
  n->left = l;
  n->right = r;
  return n;
}

static void free_tree(Node *root) {
  if (!root) return;
  free_tree(root->left);
  free_tree(root->right);
  free(root);
}

// Preorder traversal to collect codes
static void collect_codes(Node *root, char **out_codes, char *buf, int depth) {
  if (!root) return;
  
  // Leaf: record the code
  if (!root->left && !root->right) {
    buf[depth] = '\0';
    
    if (depth == 0) {
      out_codes[root->idx] = malloc(2);
      strcpy(out_codes[root->idx], "0");
    } else {
      size_t len = strlen(buf);
      out_codes[root->idx] = malloc(len + 1); 
      if (out_codes[root->idx]) {
        strcpy(out_codes[root->idx], buf);
      }
    }
    return;
  }

  // Go left with '0'
  buf[depth] = '0';
  collect_codes(root->left, out_codes, buf, depth + 1);
  
  // Go right with '1'
  buf[depth] = '1';
  collect_codes(root->right, out_codes, buf, depth + 1);
}

// Main Huffman routine
// s: characeres (lenght s), freq: frequencies (lenght n)
// out_codes: array of n char* (allocated by this funciton). Caller must free each string.
static void huffman_codes(const char *s, const int *freq, int n, char **out_codes) {
  (void)s; // we only need indicies; s is useful for the caller's mapping

  // Build heap of leaves
  MinHeap *h = heap_new(n);
  for (int i = 0; i < n; i++) {
    heap_push(h, new_leaf(freq[i], i));
  }

  while (h->size >= 2) {
    Node *l = heap_pop(h);    
    Node *r = heap_pop(h);  
    Node *p = new_internal(l, r);
    heap_push(h, p);
  }

  Node *root = heap_pop(h);
  heap_free(h);

  // Traverse and collect codes. Max code length for n leaves is at most n-1
  char *buf = (char *)malloc((n > 0 ? n : 1) + 1);
  collect_codes(root, out_codes, buf, 0);
  free(buf);

  free_tree(root);
}

int main(void) {
  const char *s = "abcdef";
  int freq[] = { 5, 9, 12, 13, 16, 45 };
  int n = (int)strlen(s);
  
  char **codes = (char **)calloc((size_t)n, sizeof(char *));
  if (!codes) return 1;

  huffman_codes(s, freq, n, codes);
  
  for (int i = 0; i < n; i++) {
    printf("%c: %s\n", s[i], codes[i]);
    free(codes[i]);
  }
  free(codes);

  return 0;
}
