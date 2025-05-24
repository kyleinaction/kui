package kimgui;

import kha.Color;
import haxe.Exception;

/**
 * The Node class represents a node in the UI tree. It can either contain two leaf nodes, OR it can
 * contain child windows.
 */
@:access(kimgui.Window)
class Node {
  /**
   * Global ID counter.
   */
  public static var ID: Int = 0;

  /**
   * Node ID.
   */
  public var id: Int;

  /**
   * The parent of this node, if one exists.
   */
  public var parent: Node;

  /**
   * Leaf nodes.
   */
  public var nodes: Array<Node>;

  /**
   * Child windows.
   */
  public var windows: Array<Window>;
  
  /**
   * The active window. This is the window that is currently being drawn.
   */
  private var m_activeWindow: Window;
  public var activeWindow(get, null):Window;
  public function get_activeWindow():Window { return m_activeWindow; }

  /**
   * The split axis of this node if it is a split node.
   */
  public var splitAxis: NodeSplitAxis;

  /**
   * The split ratio of this node if it is a split node. This is the ratio of the first child node
   * to the total width/height of the parent node.
   */
  public var splitRatio: Float;

  /**
   * The x position of this node.
   */
  public var x: Float;

  /**
   * The y position of this node.
   */
  public var y: Float;

  /**
   * The width of this node.
   */
  public var width: Float;

  /**
   * The height of this node.
   */
  public var height: Float;

  /**
   * Whether this node is draggable or not. 
   */
  public var draggable: Bool = true;

  /**
   * Whether this node is resizable or not. 
   */
  public var resizable: Bool = true;

  /**
   * Denotes where or not this node should be promoted when focused.
   * The screen node for the Kha window always needs to see behind detached windows.
   */
  public var stayBehind: Bool = false;

  /**
   * Whether this node should be persistent when empty. This means that the node will not be removed
   * from the tree when it no longer has any child windows. This is used for the screen node and the behavior
   * for any other node should be considered undefined.
   */
  public var persistWhenEmpty: Bool = false;

  /**
   * Whether this node is highlighted or not. This is used for dragging nodes.
   */
  public var highlighted: Bool = false;

  /**
   * True if this node or one of it's children is focused.
   */
  public var isFocused: Bool = false;

  /**
   * Debug border color.
   */
  private var m_debugColor: Int;

  /**
   * The constructor for the Node class.
   */
  public function new(splitAxis: NodeSplitAxis, x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
    this.splitAxis = splitAxis;
    
    windows   = [];
    nodes     = [];
    
    this.id        = ID++;
    this.x         = x;
    this.y         = y;
    this.width     = width;
    this.height    = height;

    this.m_debugColor = Color.fromFloats(Math.random(), Math.random(), Math.random(), 0.25);
  }

  /**
   * Blurs this node and all of it's children.
   */
  public function blur():Void {
    isFocused = false;
    if (nodes.length > 0) {
      for (node in nodes) {
        node.blur();
      }
    }
  }

  /**
   * Focuses this node and it's ancestors.
   */
  public function focus():Void {
    isFocused = true;
    if (parent != null) {
      parent.focus();
    }
  }

  /**
   * Returns the root node of this node. This is the topmost node in the tree.
   */
  public function getRoot():Node {
    if (parent == null) {
      return this;
    } else {
      return parent.getRoot();
    }
  }

  /**
   * Adds a child node to this node.
   */
  public function addChild(node: Node) {
    if (nodes.length >= 2) {
      throw "Cannot add more than 2 child nodes";
    }

    if (node.parent != null) {
      node.parent.nodes.remove(node);
    }

    node.parent = this;
    nodes.push(node);
  }

  /**
   * Returns the absolute x position of the node on the screen.
   */
  public function getScreenX(): Float {
    if (parent == null) {
      return x;
    } else {
      return parent.getScreenX() + x;
    }
  }

  /**
   * Returns the absolute y position of the node on the screen.
   */
  public function getScreenY(): Float {
    if (parent == null) {
      return y;
    } else {
      return parent.getScreenY() + y;
    }
  }

  /**
   * Resizes the node to the given width and height. This will also resize all child nodes.
   */
  public function resize(w: Float, h: Float, force: Bool = false) {
    if (width != w || height != h || force) {
      width = w;
      height = h;
      resizeNodes();
    }
  }

  /**
   * Returns all descendant windows of this node, and unsets the window array.
   */
  public function getDescendantWindowsAndUnset(wins: Array<Window> = null): Array<Window> {
    if (wins == null) { wins = []; }
    
    for (window in windows) {
      wins.push(window);
    }

    for (node in nodes) {
      wins = node.getDescendantWindowsAndUnset(wins);
    }

    windows = [];
    return wins;
  }

  /**
   * Removes a window from this node.
   */
  public function removeWindow(window:Window):Void {
    windows.remove(window);
    if (m_activeWindow == window) {
      m_activeWindow = null;
      if (windows.length > 0) {
        m_activeWindow = windows[0];
      }
    }
  }

  /**
   * Adds a child window to this node.
   */
  public function addWindow(window: Window) {
    if (window.node != null) {
      window.node.removeWindow(window);
    }

    window.node = this;
    windows.push(window);

    if (m_activeWindow == null) {
      m_activeWindow = window;
    }
  }

  /**
   * Resizes the child nodes.
   */
  public function resizeNodes() {
    // Don't resize if there are no nodes
    if (nodes.length == 0) {
      return;
    }

    if (splitAxis == NodeSplitAxis.NONE) {
      return;
    } else if (splitAxis == NodeSplitAxis.HORIZONTAL) {
      final firstNodeWidth = width * splitRatio;
      final secondNodeWidth = width - firstNodeWidth;

      nodes[0].resize(firstNodeWidth, height, true);
      nodes[1].resize(secondNodeWidth, height, true);
      nodes[1].x = firstNodeWidth;
      
    } else if (splitAxis == NodeSplitAxis.VERTICAL) {
      final firstNodeHeight = height * splitRatio;
      final secondNodeHeight = height - firstNodeHeight;

      nodes[0].resize(width, firstNodeHeight, true);
      nodes[1].resize(width, secondNodeHeight, true);

      nodes[1].y = firstNodeHeight;
    }
  }

  /**
   * Resizes the ancestors of this node. This will resize all the child nodes of the root node.
   */
  public function resizeAncestors() {
    if (parent != null) {
      // Drill down to the root node
      parent.resizeAncestors();
    } else {
      // Resize all the children of the root node
      resizeNodes();
    }
  }

  public function getBodyRect(theme:Theme): Array<Float> {
    var sx = getScreenX();
    var sy = getScreenY();

    var bodyX = sx + theme.WINDOW_BORDER_SIZE;
    var bodyY = sy + theme.WINDOW_BORDER_SIZE + theme.WINDOW_TITLEBAR_HEIGHT;
    var bodyWidth = width - (theme.WINDOW_BORDER_SIZE * 2);
    var bodyHeight = height - (theme.WINDOW_BORDER_SIZE * 2) - theme.WINDOW_TITLEBAR_HEIGHT;

    return [bodyX, bodyY, bodyWidth, bodyHeight];
  }

  /**
   * Renders the node and its children.
   */
  public function render(ui:Kimgui, theme:Theme) {
    var sx = getScreenX();
    var sy = getScreenY();

    // Draw debug border
    // ui.drawRect(sx - 10, sy - 10, width + 20, height + 20, m_debugColor);

    // This is a parent node, so delegate rendering to children
    if (nodes.length > 0) {
      for (node in nodes) {
        node.render(ui, theme);
      }
      return;
    }
    
    // Bailout of rendering if there are no windows
    if (windows.length == 0) {
      return;
    }

    var bodyRect = getBodyRect(theme);
    var bodyX = bodyRect[0];
    var bodyY = bodyRect[1];
    var bodyWidth = bodyRect[2];
    var bodyHeight = bodyRect[3];

    var titleX = sx + theme.WINDOW_BORDER_SIZE;
    var titleY = sy + theme.WINDOW_BORDER_SIZE;
    var titleWidth = width - (theme.WINDOW_BORDER_SIZE * 2);
    var titleHeight = theme.WINDOW_TITLEBAR_HEIGHT;

    // Draw border first
    ui.drawRect(sx, sy, width, height, theme.WINDOW_BORDER_COLOR);

    // Draw title bar
    ui.drawRect(titleX, titleY, titleWidth, titleHeight, theme.WINDOW_BORDER_COLOR);

    // Render the child window tabs
    var titleBarX = titleX;
    for (window in windows) {
      // Draw window tab
      var tabBackgrondColor = (m_activeWindow == window) ? theme.WINDOW_TITLEBAR_ACTIVE_COLOR : theme.WINDOW_TITLEBAR_COLOR;
      var tabWidth = ui.options.font.width(theme.WINDOW_TITLE_BAR_FONT_SIZE, window.title) + (theme.WINDOW_TITLE_BAR_PADDING * 2);
      ui.drawRect(titleBarX, titleY, tabWidth, titleHeight, tabBackgrondColor);

      // Draw window title
      ui.drawString(
        window.title,
        titleBarX + theme.WINDOW_TITLE_BAR_PADDING,
        titleY + theme.WINDOW_TITLE_BAR_PADDING,
        theme.WINDOW_TITLEBAR_TEXT_COLOR,
        theme.WINDOW_TITLE_BAR_FONT_SIZE
      );

      // Set the active window if the user clicks on the window tab
      if (ui.getInputInRect(titleBarX, titleY, tabWidth, titleHeight)) {
        if (ui.inputStarted) {
          m_activeWindow = window;
        }
        if (ui.inputReleasedR) {
          ui.unmergeWindow(window);
        }
      }

      titleBarX = titleBarX + tabWidth + 1;
    }

    // Copy the active window texture to the screen
    if (m_activeWindow != null) {
      ui.g.drawScaledSubImage(m_activeWindow.texture, 0, 0, 
        Std.int(bodyWidth), Std.int(bodyHeight), Std.int(bodyX), Std.int(bodyY), Std.int(bodyWidth), Std.int(bodyHeight));
    }

    if (highlighted) {
      ui.drawRect(sx, sy, width, height, theme.NODE_HIGHLIGHT_COLOR);
    }
  }

  /**
   * Returns the the ResizeHandle for this.
   */
  public function getResizingHandle(ui:Kimgui, theme:Theme):ResizingHandle {
    if (!resizable) {
      return null;
    }

    // Hide handles that would overlap with the parent node handles
    var canHaveTopHandle = true;
    var canHaveBottomHandle = true;
    var canHaveLeftHandle = true;
    var canHaveRightHandle = true;
    if (parent != null) {
      var isFirstChild = parent.nodes[0] == this;
      if (parent.splitAxis == NodeSplitAxis.HORIZONTAL) {
        canHaveTopHandle = false;
        canHaveBottomHandle = false;

        if (isFirstChild) {
          canHaveLeftHandle = false;
        } else {
          canHaveRightHandle = false;
        }
      } else if (parent.splitAxis == NodeSplitAxis.VERTICAL) {
        canHaveLeftHandle = false;
        canHaveRightHandle = false;

        if (isFirstChild) {
          canHaveTopHandle = false;
        } else {
          canHaveBottomHandle = false;
        }
      }
    }

    // Check top
    var topRect = getResizeHandleRect(NodeSplitDirection.TOP, theme);
    var bottomRect = getResizeHandleRect(NodeSplitDirection.BOTTOM, theme);
    var leftRect = getResizeHandleRect(NodeSplitDirection.LEFT, theme);
    var rightRect = getResizeHandleRect(NodeSplitDirection.RIGHT, theme);

    if (ui.getInputInRect(topRect[0], topRect[1], topRect[2], topRect[3]) && ui.inputStarted && canHaveTopHandle) {
      return {
        node: this,
        direction: NodeSplitDirection.TOP
      };
      
    // Check Bottom
    } else if (ui.getInputInRect(bottomRect[0], bottomRect[1], bottomRect[2], bottomRect[3]) && ui.inputStarted && canHaveBottomHandle) {
      return {
        node: this,
        direction: NodeSplitDirection.BOTTOM
      };
      
    // Check Left
    } else if (ui.getInputInRect(leftRect[0], leftRect[1], leftRect[2], leftRect[3]) && ui.inputStarted && canHaveLeftHandle) {
      return {
        node: this,
        direction: NodeSplitDirection.LEFT
      };
      
    // Check Right 
    } else if (ui.getInputInRect(rightRect[0], rightRect[1], rightRect[2], rightRect[3]) && ui.inputStarted && canHaveRightHandle) {
      return {
        node: this,
        direction: NodeSplitDirection.RIGHT
      };
    }

    return null;
  }

  /**
   * Resizes the node in the given direction using input from the user.
   */
  public function doResize(ui:Kimgui, theme:Theme, direction:NodeSplitDirection):Void {
    var sx = getScreenX();
    var sy = getScreenY();

    if (parent == null) {
      if (direction == NodeSplitDirection.RIGHT) {
        width = width + ui.inputDX;
      } else if (direction == NodeSplitDirection.LEFT) {
        width = width - ui.inputDX;
        x = sx + ui.inputDX;
      } else if (direction == NodeSplitDirection.BOTTOM) {
        height = height + ui.inputDY;
      } else if (direction == NodeSplitDirection.TOP) {
        height = height - ui.inputDY;
        y = sy + ui.inputDY;
      }

      this.resizeNodes();
      return;
    }

    if (direction == NodeSplitDirection.RIGHT) {
      width = width + ui.inputDX;

      if (parent.nodes[0] == this) {
        parent.nodes[1].resize(parent.width - this.width, parent.nodes[1].height);
        parent.nodes[1].x = this.width;
      } else {
        parent.nodes[0].resize(parent.width - this.width, parent.nodes[0].height);
      }
      
      parent.splitRatio = parent.nodes[0].width / parent.width;

    } else if (direction == NodeSplitDirection.LEFT) {
      width = width - ui.inputDX;
      
      if (parent.nodes[0] == this) {
        parent.nodes[1].resize(parent.width - this.width, parent.nodes[1].height);
      } else {
        parent.nodes[0].resize(parent.width - this.width, parent.nodes[0].height);
        parent.nodes[1].x = parent.nodes[0].width;
      }

      parent.splitRatio = parent.nodes[0].width / parent.width;

    } else if (direction == NodeSplitDirection.BOTTOM) {
      height = height + ui.inputDY;

      if (parent.nodes[0] == this) {
        parent.nodes[1].resize(parent.nodes[1].width, parent.height - this.height);
        parent.nodes[1].y = this.height;
      } else {
        parent.nodes[0].resize(parent.nodes[0].width, parent.height - this.height);
      }
      
      parent.splitRatio = parent.nodes[0].height / parent.height;

    } else if (direction == NodeSplitDirection.TOP) {
      height = height - ui.inputDY;

      if (parent.nodes[0] == this) {
        parent.nodes[1].resize(parent.nodes[1].width, parent.height - this.height);
      } else {
        parent.nodes[0].resize(parent.nodes[0].width, parent.height - this.height);
      }

      parent.splitRatio = parent.nodes[0].height / parent.height;
    }

    parent.resizeNodes();
  }

  /**
   * Renders the resize handles for this node.
   */
  public function renderResizeHandles(ui:Kimgui, theme:Theme):Bool {
    if (!resizable) {
      return false;
    }

    // Check top
    var topRect = getResizeHandleRect(NodeSplitDirection.TOP, theme);
    var bottomRect = getResizeHandleRect(NodeSplitDirection.BOTTOM, theme);
    var leftRect = getResizeHandleRect(NodeSplitDirection.LEFT, theme);
    var rightRect = getResizeHandleRect(NodeSplitDirection.RIGHT, theme);

    if (ui.getInputInRect(topRect[0], topRect[1], topRect[2], topRect[3])) {
      ui.drawRect(topRect[0], topRect[1], topRect[2], topRect[3], theme.WINDOW_RESIZE_HANDLE_COLOR);
      return true;
    // Check Bottom
    } else if (ui.getInputInRect(bottomRect[0], bottomRect[1], bottomRect[2], bottomRect[3])) {
      ui.drawRect(bottomRect[0], bottomRect[1], bottomRect[2], bottomRect[3], theme.WINDOW_RESIZE_HANDLE_COLOR);
      return true;
    // Check Left
    } else if (ui.getInputInRect(leftRect[0], leftRect[1], leftRect[2], leftRect[3])) {
      ui.drawRect(leftRect[0], leftRect[1], leftRect[2], leftRect[3], theme.WINDOW_RESIZE_HANDLE_COLOR);
      return true;
    // Check Right 
    } else if (ui.getInputInRect(rightRect[0], rightRect[1], rightRect[2], rightRect[3])) {
      ui.drawRect(rightRect[0], rightRect[1], rightRect[2], rightRect[3], theme.WINDOW_RESIZE_HANDLE_COLOR);
      return true;
    }

    return false;
  }

  /**
   * Returns the rectangle of the resize handle for the given direction.
   */
  private function getResizeHandleRect(direction: NodeSplitDirection, theme:Theme):Array<Float> {
    var sx = getScreenX();
    var sy = getScreenY();

    if (direction == NodeSplitDirection.TOP) {
      return [sx, sy, width, theme.WINDOW_RESIZE_HANDLE_THICKNESS];
    } else if (direction == NodeSplitDirection.BOTTOM) {
      return [sx, sy + height - theme.WINDOW_RESIZE_HANDLE_THICKNESS, width, theme.WINDOW_RESIZE_HANDLE_THICKNESS];
    } else if (direction == NodeSplitDirection.LEFT) {
      return [sx, sy, theme.WINDOW_RESIZE_HANDLE_THICKNESS, height];
    } else if (direction == NodeSplitDirection.RIGHT) {
      return [sx + width - theme.WINDOW_RESIZE_HANDLE_THICKNESS, sy, theme.WINDOW_RESIZE_HANDLE_THICKNESS, height];
    }

    throw "Invalid direction";
  }
}