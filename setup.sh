#!/bin/bash

directories=(
    "python"
    "typescript"
    "javascript"
    "java"
    "cpp"
    "c"
    "dart"
    "php"
    "csharp"
    "go"
    "rust"
    "ruby"
    "swift"
    "kotlin"
)

get_extension() {
    case "$1" in
        python) echo "py" ;;
        typescript) echo "ts" ;;
        javascript) echo "js" ;;
        java) echo "java" ;;
        cpp) echo "cpp" ;;
        c) echo "c" ;;
        dart) echo "dart" ;;
        php) echo "php" ;;
        csharp) echo "cs" ;;
        go) echo "go" ;;
        rust) echo "rs" ;;
        ruby) echo "rb" ;;
        swift) echo "swift" ;;
        kotlin) echo "kt" ;;
        *) echo "" ;;
    esac
}

create_dsa_structure() {
    local dir="$1"
    local ext="$2"
    
    echo -e "${YELLOW}Creating DSA structure for $dir...${NC}"
    
    mkdir -p "$dir/dsa"
    touch "$dir/README.md"
    touch "$dir/dsa/README.md"

    if [ -n "$ext" ]; then
        mkdir -p "$dir/dsa/algorithms/greedy-algorithms"
        touch "$dir/dsa/algorithms/greedy-algorithms/dijkstra.$ext"
        touch "$dir/dsa/algorithms/greedy-algorithms/ford-fulkerson.$ext"
        touch "$dir/dsa/algorithms/greedy-algorithms/huffman.$ext"
        touch "$dir/dsa/algorithms/greedy-algorithms/kruskal.$ext"
        touch "$dir/dsa/algorithms/greedy-algorithms/prim.$ext"
        
        mkdir -p "$dir/dsa/algorithms/other"
        touch "$dir/dsa/algorithms/other/robin-karp-algorithm.$ext"
        
        mkdir -p "$dir/dsa/algorithms/searching-sorting-algorithms"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/binary-search.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/bubble.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/bucket.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/counting.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/heap.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/insertion-sort.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/linear-search.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/merge-sort.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/quick-sort.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/redix.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/selection-sort.$ext"
        touch "$dir/dsa/algorithms/searching-sorting-algorithms/shell.$ext"
        
        touch "$dir/dsa/algorithms/source.md"
        
        mkdir -p "$dir/dsa/data-structure/graph-based"
        touch "$dir/dsa/data-structure/graph-based/adjacency-list.$ext"
        touch "$dir/dsa/data-structure/graph-based/adjacency-matrix.$ext"
        touch "$dir/dsa/data-structure/graph-based/bellman-fords-algorithm.$ext"
        touch "$dir/dsa/data-structure/graph-based/breadth-first-search.$ext"
        touch "$dir/dsa/data-structure/graph-based/dfs-algorithm.$ext"
        
        mkdir -p "$dir/dsa/data-structure/misc"
        touch "$dir/dsa/data-structure/misc/fibonacci-heap.$ext"
        touch "$dir/dsa/data-structure/misc/gap-buffer.$ext"
        touch "$dir/dsa/data-structure/misc/hash-table.$ext"
        touch "$dir/dsa/data-structure/misc/heap-ds.$ext"
        touch "$dir/dsa/data-structure/misc/linked-list.$ext"
        
        mkdir -p "$dir/dsa/data-structure/misc/matrix"
        touch "$dir/dsa/data-structure/misc/matrix/martix-transportation.$ext"
        touch "$dir/dsa/data-structure/misc/matrix/matrix.$ext"
        touch "$dir/dsa/data-structure/misc/matrix/matrix-addition.$ext"
        touch "$dir/dsa/data-structure/misc/matrix/matrix-multiplication.$ext"
        touch "$dir/dsa/data-structure/misc/matrix/scalar-multiplication.$ext"
        
        mkdir -p "$dir/dsa/data-structure/misc/queue"
        touch "$dir/dsa/data-structure/misc/queue/circular-queue.$ext"
        touch "$dir/dsa/data-structure/misc/queue/deque.$ext"
        touch "$dir/dsa/data-structure/misc/queue/priority-queue.$ext"
        touch "$dir/dsa/data-structure/misc/queue/queue.$ext"
        
        touch "$dir/dsa/data-structure/misc/stack.$ext"
        touch "$dir/dsa/data-structure/source.md"
        
        mkdir -p "$dir/dsa/data-structure/tree-based"
        touch "$dir/dsa/data-structure/tree-based/avl-tree.$ext"
        
        mkdir -p "$dir/dsa/data-structure/tree-based/b-plus-tree"
        touch "$dir/dsa/data-structure/tree-based/b-plus-tree/b-plus-tree-deletion.$ext"
        touch "$dir/dsa/data-structure/tree-based/b-plus-tree/b-plus-tree-insertion.$ext"
        touch "$dir/dsa/data-structure/tree-based/b-plus-tree/b-plus-tree.$ext"
        
        mkdir -p "$dir/dsa/data-structure/tree-based/b-tree"
        touch "$dir/dsa/data-structure/tree-based/b-tree/b-tree-deletion.$ext"
        touch "$dir/dsa/data-structure/tree-based/b-tree/b-tree-insertion.$ext"
        touch "$dir/dsa/data-structure/tree-based/b-tree/b-tree.$ext"
        
        touch "$dir/dsa/data-structure/tree-based/balanced-binary-tree.$ext"
        touch "$dir/dsa/data-structure/tree-based/binary-search-tree.$ext"
        touch "$dir/dsa/data-structure/tree-based/binary-tree.$ext"
        touch "$dir/dsa/data-structure/tree-based/completed-binary-tree.$ext"
        touch "$dir/dsa/data-structure/tree-based/full-binary-tree.$ext"
        touch "$dir/dsa/data-structure/tree-based/perfect-binary-tree.$ext"
        
        mkdir -p "$dir/dsa/data-structure/tree-based/red-black-tree"
        touch "$dir/dsa/data-structure/tree-based/red-black-tree/red-black-tree-deletion.$ext"
        touch "$dir/dsa/data-structure/tree-based/red-black-tree/red-black-tree-insertion.$ext"
        touch "$dir/dsa/data-structure/tree-based/red-black-tree/red-black-tree.$ext"
        
        touch "$dir/dsa/data-structure/tree-based/tree-traversal.$ext"
        
        mkdir -p "$dir/dsa/dynamic-programming"
        touch "$dir/dsa/dynamic-programming/floyd-warshall-algorithm.$ext"
        touch "$dir/dsa/dynamic-programming/longest-common-sequence.$ext"

        mkdir -p "$dir/oop"
        touch "$dir/oop/README.md"

        case "$dir" in
            python|java|cpp|csharp|kotlin|swift|dart)
                touch "$dir/oop/inheritance.$ext"
                touch "$dir/oop/polymorphism.$ext"
                touch "$dir/oop/encapsulation.$ext"
                touch "$dir/oop/abstraction.$ext"
                touch "$dir/oop/interfaces.$ext"
                ;;
            typescript|javascript|php|ruby)
                touch "$dir/oop/classes.$ext"
                touch "$dir/oop/prototypes.$ext"
                touch "$dir/oop/mixins.$ext"
                ;;
            go|rust)
                touch "$dir/oop/structs.$ext"
                touch "$dir/oop/traits.$ext"
                touch "$dir/oop/composition.$ext"
                ;;
        esac
    fi
}

for dir in "${directories[@]}"; do
    ext=$(get_extension "$dir")
    if [ -n "$ext" ]; then
        create_dsa_structure "$dir" "$ext"
        echo -e "${GREEN}Created directory structure for: $dir${NC}"
    else
        echo -e "${RED}Unsupported language: $dir${NC}"
    fi
done

chmod +x setup.sh
echo -e "${GREEN}Setup complete! Language directories and DSA folders have been created.${NC}"
