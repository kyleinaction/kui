package kimgui;

import kha.graphics2.Graphics;
import kha.input.Mouse;
import kimgui.themes.DarkTheme;

/**
 * Main interface for Kimgui.
 */
class Kimgui {
  /**
   * The current graphics context.
   */
  public var g:Graphics;

  /**
   * All UI nodes.
   */
  private var m_nodes: Array<Node>;

  /**
   * Full-screen node. This node gets resized based on the framebuffer size.
   */
  private var m_screenNode: Node;

  /**
   * The current window being drawn.
   */
  private var m_currentWindow: Window;

  /**
   * The current node being dragged (if any).
   */
  private var m_draggingNode: Node;

  /**
   * Current X position of the input.
   */
  public var inputX: Float;

  /**
   * Current X position of the input.
   */
  public var inputY: Float;

  /**
   * The delta of the X input since the last frame.
   */
  public var inputDX: Float;

  /**
   * The delta of the Y input since the last frame.
   */
  public var inputDY: Float;

  /**
   * True if the input was started this frame.
   */
  public var inputStarted: Bool;

  /**
   * True if the input was started this frame (right mouse button).
   */
  public var inputStartedR: Bool;

  /**
   * True if the input was released this frame.
   */
  public var inputReleased: Bool;

  /**
   * True if the input was released this frame (right mouse button).
   */
  public var inputReleasedR: Bool;

  /**
   * The X position of the input when it was started.
   */
  public var inputStartedX: Int;

  /**
   * The Y position of the input when it was started.
   */
  public var inputStartedY: Int;

  /**
   * True if the input is down.
   */
  public var inputDown: Bool;

  /**
   * True if the input is down (right mouse button).
   */
  public var inputDownR: Bool;

  /**
   * UI options.
   */
  private var m_options: Options;
  public var options(get, null): Options;
  public function get_options(): Options {
    return m_options;
  }

  /**
   * Render pipeline for text.
   */
  private var m_textPipeline: kha.graphics4.PipelineState; // Rendering text into rendertargets

  /**
   * The current window draw list.
   */
  public function new(options: Options) {
    m_nodes = [];
    m_screenNode = new Node(NodeSplitAxis.NONE);
    m_screenNode.draggable = false;
    m_nodes.push(m_screenNode);
    m_options = options;

    if (m_options.theme == null) {
      m_options.theme = DarkTheme.theme;
    }

    var textVS = kha.graphics4.Graphics2.createTextVertexStructure();
		m_textPipeline = kha.graphics4.Graphics2.createTextPipeline(textVS);
		m_textPipeline.alphaBlendSource = BlendOne;
		m_textPipeline.compile();

    registerInput();
  }

  /**
   * Destructor.
   * Unregisters all input events.
   */
  public function destroy():Void {
    unregisterInput();
  }

  /**
   * Set the size of the window.
   * This will resize all nodes to the given width and height.
   */
  public function setWindowSize(width: Float, height: Float) {
    if (m_screenNode.width != width || m_screenNode.height != height) {
      m_screenNode.resize(width, height);
    }
  }

  /**
   * Sets the current node being dragged.
   */
  public function setDraggingNode(node: Node) {
    m_draggingNode = node;
  }

  /**
   * Begins the drawing context.
   */
  public function begin(g: Graphics) {
    this.g = g;
  }

  /**
   * Merges two nodes together.
   * This will remove the first node and add all of its windows to the second node.
   *
   * @TODO: this needs to be updated to be recursive. All windows belongs to all children of nodeA 
   */
  private function mergeNodeWindows(nodeA: Node, nodeB: Node) {
    final windows = nodeA.getDescendantWindowsAndUnset();

    for (window in windows) {
      nodeB.addWindow(window);
    }

    nodeA.windows = [];
    m_nodes.remove(nodeA);
  }

  /**
   * Renders the final node/window contents.
   */
  public function end() {
    if (m_currentWindow != null) {
      endWindow();
    }

    g.begin(false);
      // Render node contents
      for (node in m_nodes) {
        node.render(this, m_options.theme);
      }

      handleDraggingNode(m_nodes);
      
      // Update the position of the dragged node
      if (m_draggingNode != null) {
        m_draggingNode.x = m_draggingNode.x + inputDX;
        m_draggingNode.y = m_draggingNode.y + inputDY;
      }
      
      // Stop dragging if the mouse isn't down anymore
      if (inputReleased) {
        m_draggingNode = null;
      }
    g.end();

    endInput();
  }

  /**
   * Creates a new window.
   */
  public function window(handle:Handle, title:String = "", x:Float = 0.0, y:Float = 0.0, width:Float = 200.0, height:Float = 200.0):Bool {
    if (m_currentWindow != null) {
      endWindow();
    }

    if (handle.window == null) {
      // Create new node
      var node = new Node(NodeSplitAxis.NONE, x, y, width, height);
      m_nodes.push(node);

      // Create new window and add it to the node
      m_currentWindow = new Window();
      node.addWindow(m_currentWindow);
      handle.window = m_currentWindow;
    } else {
      m_currentWindow = handle.window;
    }

    m_currentWindow.title = title;

    return true;
  }

  /**
   * Ends the current window.
   */
  public function endWindow() {
    m_currentWindow = null;
  }

  /**
   * Draws a rectangle.
   */
  public function drawRect(x: Float, y: Float, width: Float, height: Float, color: Int) {
    g.color = color;
    g.fillRect(x, y, width, height);
  }

  /**
   * Draws a string of text.
   */
  public function drawString(text: String, x: Float, y: Float, color: Int, fontSize: Int = 12) {
    g.pipeline = m_textPipeline;
    g.font = m_options.font;
		g.fontSize = fontSize;
    g.color = color;
    g.drawString(text, x, y);
    g.pipeline = null;
  }

  /**
   * Returns true if the current input is within the bounds.
   */
  public function getInputInRect(x: Float, y: Float, w: Float, h: Float, scale = 1.0): Bool {
		return inputX >= x * scale && inputX < (x + w) * scale &&
			     inputY >= y * scale && inputY < (y + h) * scale;
	}

  /**
   * Called when a mouse button is pressed. 
   */
  private function onMouseDown(button: Int, x: Int, y: Int) { // Input events
		button == 0 ? inputStarted = true : inputStartedR = true;
		button == 0 ? inputDown = true : inputDownR = true;

		inputStartedX = x;
		inputStartedY = y;
	}

  /**
   * Called when a mouse button is released.
   */
  public function onMouseUp(button: Int, x: Int, y: Int) {
    button == 0 ? inputReleased = true : inputReleasedR = true;
    button == 0 ? inputDown = false : inputDownR = false;
  }

  /**
   * Called when the mouse is moved.
   */
  public function onMouseMove(x: Int, y: Int, movementX: Int, movementY: Int) {
    inputDX = x - inputX;
    inputDY = y - inputY;
		inputX = x;
    inputY = y;
	}

  /**
   * Called when the mouse wheel is scrolled.
   */
  public function onMouseWheel(delta: Int) {

	}

  /**
   * Registers input events.
   */
  private function registerInput() {
		Mouse.get().notifyWindowed(0, onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
		// Reset mouse delta on foreground
		kha.System.notifyOnApplicationState(function() { inputDX = inputDY = 0; }, null, null, null, null);
	}

  /**
   * Unregisters input events.
   */
	private function unregisterInput() {
		Mouse.get().removeWindowed(0, onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
		inputX = inputY = 0;
    inputDX = inputDY = 0;
	}

  /**
   * Prepares inputs for the next frame.
   */ 
  private function endInput() {
    inputStarted = false;
		inputStartedR = false;
		inputReleased = false;
		inputReleasedR = false;
		inputDX = 0;
		inputDY = 0;
  }

  /**
   * Handles the dragging of nodes.
   * This will check to see if the input is within the bounds of a node and if so, it will set that node as the current dragging node.
   */
  private function handleDraggingNode(nodes: Array<Node>) {
    for (node in nodes) {
      if (node == m_draggingNode) {
        continue;
      }

      var sx = node.getScreenX();
      var sy = node.getScreenY();

      // Check to see if there's a node we need to drag
      if (m_draggingNode == null) {
        if (getInputInRect(sx, sy, node.width, node.height) && inputStarted && node.parent == null && node.draggable) {
          m_draggingNode = node;
        }
      } else {
        // If the current node is not the one being dragged...
        if (node != m_draggingNode) {
          // ... check to see if the input is within the bounds of another unsplit node
          if (getInputInRect(sx, sy, node.width, node.height) && node.nodes.length == 0) {
            // If so, show and potentionally handle the drop zones
            drawNodeDropZones(node);
            if (handleNodeDropZones(node)) {
              break;
            }
          }
        }
      }

      // Process child nodes
      if (node.nodes.length > 0) {
        handleDraggingNode(node.nodes);
      }
    }
  }

  /**
   * Merges two nodes together.
   */
  private function mergeNodes(baseNode: Node, nodeB: Node, direction: NodeSplitDirection, x:Float, y:Float, w:Float, h:Float) {
    baseNode.x = x;
    baseNode.y = y;

    var axis = NodeSplitAxis.VERTICAL;
    if (direction == NodeSplitDirection.LEFT || direction == NodeSplitDirection.RIGHT) { 
      axis = NodeSplitAxis.HORIZONTAL; 
    }

    // Create a new node and apply nodeA's properties to it
    var nodeA = new Node(baseNode.splitAxis, 0, 0, baseNode.width, baseNode.height);
    for (window in baseNode.windows) {
      nodeA.addWindow(window);
    }
    for (child in baseNode.nodes) {
      nodeA.addChild(child);
    }

    // Remove all windows from nodeA
    baseNode.windows = [];
    baseNode.nodes = [];
    baseNode.splitAxis = axis;
    
    m_nodes.remove(nodeB);

    if (direction == NodeSplitDirection.LEFT || direction == NodeSplitDirection.TOP) {
      var temp = nodeA;
      nodeA = nodeB;
      nodeB = temp;
    }

    baseNode.addChild(nodeA);
    baseNode.addChild(nodeB);

    nodeA.x = 0;
    nodeA.y = 0;

    // Split horizontally
    if (axis == NodeSplitAxis.HORIZONTAL) {

      nodeA.width = baseNode.width / 2;
      nodeB.width = baseNode.width - nodeA.width;

      nodeA.height = baseNode.height;
      nodeB.height = baseNode.height;
      
      nodeB.y = 0;
      nodeB.x = nodeA.width;
      
    // Split vertically
    } else {
      nodeA.height = baseNode.height / 2;
      nodeB.height = baseNode.height - nodeA.height;        
      nodeA.width  = baseNode.width;
      nodeB.width  = baseNode.width;
      
      nodeB.x = 0;
      nodeB.y = nodeA.height;
    }

    baseNode.resizeAncestors();
  }

  /**
   * Returns the drop zone rectangle for a node given a direction (top, bottom, etc.) and location (inner, outer).
   */
  private function getNodeDropZoneRect(node: Node, direction: NodeSplitDirection, location: NodeSplitLocation): Array<Float> {
    // Get the drop zone rectangle for the node
    var sx = node.getScreenX();
    var sy = node.getScreenY();

    var centerX = sx + (node.width / 2);
    var centerY = sy + (node.height / 2);

    var size    = 30;
    var height  = size;
    var width   = size / 2;

    var halfHeight = height / 2;
    var halfWidth  = width / 2;

    var innerOffset = 0.0;
    if (location == NodeSplitLocation.INNER) {
      innerOffset = width + 1.0;
    }

    if (direction == NodeSplitDirection.NONE) {
      return [centerX - size / 2, centerY - size / 2, size, size];

    } else if (direction == NodeSplitDirection.LEFT) {
      return [sx + innerOffset, centerY - halfHeight, width, height];

    } else if (direction == NodeSplitDirection.RIGHT) {
      return [sx + node.width - width - innerOffset, centerY - halfHeight, width, height];

    } else if (direction == NodeSplitDirection.TOP) {
      return [centerX - halfHeight, sy + innerOffset, height, width];

    } else if (direction == NodeSplitDirection.BOTTOM) {
      return [centerX - halfHeight, sy + node.height - width - innerOffset, height, width];
    }

    return [0, 0, 0, 0];
  }

  /**
   * Handles the drop zones for a node.
   */
  private function handleNodeDropZones(node: Node):Bool {
    if (!inputReleased) {
      return false;
    }

    if (handleNodeDropZone(node, NodeSplitDirection.LEFT,   NodeSplitLocation.INNER)) { return true; }
    if (handleNodeDropZone(node, NodeSplitDirection.RIGHT,  NodeSplitLocation.INNER)) { return true; }
    if (handleNodeDropZone(node, NodeSplitDirection.TOP,    NodeSplitLocation.INNER)) { return true; }
    if (handleNodeDropZone(node, NodeSplitDirection.BOTTOM, NodeSplitLocation.INNER)) { return true; }
    if (handleNodeDropZone(node, NodeSplitDirection.NONE,   NodeSplitLocation.INNER)) { return true; }
    
    return false;
  }

  /**
   * Handles a single drop zone for a node.
   * This will check to see if the input is within the bounds of a dropzone and if so,
   * it will merge the node and the dragging node together.
   */
  private function handleNodeDropZone(node: Node, direction: NodeSplitDirection, location: NodeSplitLocation):Bool {
    var dropZone = getNodeDropZoneRect(node, direction, location);

    // If we're not in the drop zone.
    if (!getInputInRect(dropZone[0], dropZone[1], dropZone[2], dropZone[3])) {
      return false;
    }

    // If we're dropping into the center node, we need to merge the windows, and not split.
    if (direction == NodeSplitDirection.NONE) {
      mergeNodeWindows(m_draggingNode, node);
      return true;
    }

    var nodeA = node;
    var nodeB = m_draggingNode;

    mergeNodes(nodeA, nodeB, direction, node.x, node.y, node.width, node.height);
    return true;
  }

  /**
   * Draws the drop zones for a node.
   */
  private function drawNodeDropZones(node: Node) {
    drawNodeDropZone(node, NodeSplitDirection.LEFT,   NodeSplitLocation.INNER);
    drawNodeDropZone(node, NodeSplitDirection.RIGHT,  NodeSplitLocation.INNER);
    drawNodeDropZone(node, NodeSplitDirection.TOP,    NodeSplitLocation.INNER);
    drawNodeDropZone(node, NodeSplitDirection.BOTTOM, NodeSplitLocation.INNER);
    drawNodeDropZone(node, NodeSplitDirection.NONE,   NodeSplitLocation.INNER);
  }

  /**
   * Draws a single drop zone for a node.
   */
  private function drawNodeDropZone(node: Node, direction: NodeSplitDirection, location: NodeSplitLocation) {
    var dropZone = getNodeDropZoneRect(node, direction, location);
    var color = m_options.theme.NODE_HIGHLIGHT_COLOR;

    if (getInputInRect(dropZone[0], dropZone[1], dropZone[2], dropZone[3])) {
      color = m_options.theme.NODE_HIGHLIGHT_COLOR_ACTIVE;
    }
    
    drawRect(dropZone[0], dropZone[1], dropZone[2], dropZone[3], color);
  }
}