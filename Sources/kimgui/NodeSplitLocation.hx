package kimgui;

/**
 * Enum representing the location of a node split.
 * Nodes can either be split inner or outer; inner split means the size of the base node is not changed.
 * And outer split results in the baseNode being resized to fit both nodes.
 */
enum NodeSplitLocation {
  INNER;
  OUTER;
}
