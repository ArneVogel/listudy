function Node(move) {
    this.move = move;
    this.value = 0;
    this.children = [];
}
 
function Tree(data) {
    var node = new Node(data);
    this.root = node;
}
 
export { Node, Tree };
