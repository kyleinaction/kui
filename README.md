# Kimgui

## About
Kimgui (Kha Immediate Mode Graphical User Interface) is an immediate mode graphical user interface for Kha written in Haxe. Inspired by Zui from Armory, and Dear ImGui. The primary goals for Kimgui are:

- Minimal UI state storage - application state should have one source of truth.
- No callbacks - draw and accept user input inline.
- Layout system that supports window docking.
- Easy to theme.
- Easy to extend and add new elements.

## Examples

```haxe
class Application {
  public var ui:Kimgui;

  public function new() {
    ui = new Kimgui({ font: Assets.fonts.OpenSansMedium });
  }

  public function render(framebuffers: Array<Framebuffer>):Void {
    final fb = framebuffers[0];
    final g2 = fb.g2;

    ui.setScreenSize(fb.width, fb.height);

    g2.begin(true, Color.fromBytes(0, 0, 0));
    // Do normal rendering here
    g2.end();

    // Render UI after other rendering finishes
    ui.begin(g2);
      // Create a window
      if (ui.window(Id.handle(), "First Window", 30, 30, 300, 300)) {
        ui.text("Hello World!");
        ui.text("This is window 1");

        if (ui.button("Click Me")) {
          trace("First Window Button Clicked");
        }
      }

      // Create a second window
      if (ui.window(Id.handle(), "Second Window", 350, 30, 200, 300)) {
        ui.text("Another window!");
        if (ui.button("Click Me Too")) {
          trace("Second Window Button Clicked");
        }
      }
    ui.end();
  }
}
```

### Node Splitting
![Example of window splitting](support/images/splitResizeZOrdering.gif)

### Node Merging
![Example of window merging](support/images/mergeResizeZOrdering.gif)

## TODO

- [x] Ability to create Windows.
- [x] Ability to drag Nodes/Windows
- [x] Dragging Nodes over another Node reveals the hovered-nodes split placements
- [x] Dropping a dragged node onto a split-placement causes the root node to split
- [x] Resizing Nodes/Windows.
- [x] Sorting nodes/windows.
- [ ] Detach nodes from their parent.
- [x] Preventing event propagation.
- [ ] Window scrolling.
- [x] Text/Labels.
- [x] Buttons.
- [ ] Radio buttons.
- [ ] Check-boxes.
- [ ] Combo-boxes.
- [ ] Panels.
- [ ] Text inputs.
- [ ] Images.
- [ ] Ability to create rows.
- [ ] Ability to indent/unindent.