package;

import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import kimgui.Kimgui;
import kimgui.Id;

class Main {

  static function update(): Void {
  }

  public static function main() {
    System.start({title: "Project", width: 1024, height: 768}, function (_) {
      // Just loading everything is ok for small projects
      Assets.loadEverything(function () {
        final app = new Application();
        app.run();
      });
    });
  }
}


class Application {
  public var ui:Kimgui;

  var clicks: Array<Int>;

  public function new() {
    ui = new Kimgui({ font: Assets.fonts.OpenSansMedium });
    clicks = [0, 0, 0];
  }

  public function run():Void {
    // Start Loop
    Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
    System.notifyOnFrames(function (frames) { render(frames); });
  }

  public function update():Void {

  }

  public function render(framebuffers: Array<Framebuffer>):Void {
    // As we are using only 1 window, grab the first framebuffer
    final fb = framebuffers[0];
    // Now get the `g2` graphics object so we can draw
    final g2 = fb.g2;

    ui.setScreenSize(fb.width, fb.height);

    // Start drawing, and clear the framebuffer to `petrol`
    g2.begin(true, Color.fromBytes(0, 0, 0));
      // Do normal rendering here
    g2.end();

    // Render UI after other rendering finishes
    ui.begin(g2);
      if (ui.window(Id.handle(), "First Window", 30, 30, 300, 300)) {
        ui.text("This is window 1");
        ui.text("Click count: " + clicks[0]);

        if (ui.button("Click Me")) {
          clicks[0]++;
        }

        ui.text("Lorem ipsum dolor sit amet,");
        ui.text("consectetur adipiscing elit.");
        ui.text("Integer sed nisi in orci posuere venenatis.");
        ui.text("Integer sollicitudin purus nec tortor");
        ui.text("congue consequat. Proin varius luctus aliquam.");
      }
      
      if (ui.window(Id.handle(), "Second Window", 350, 30, 200, 300)) {
        ui.text("Another window!");
        ui.text("Click count: " + clicks[1]);

        if (ui.button("Click Me Too")) {
          clicks[1]++;
        }

        ui.text("Lorem ipsum dolor sit amet,");
        ui.text("consectetur adipiscing elit.");
        ui.text("Integer sed nisi in orci posuere venenatis.");
        ui.text("Integer sollicitudin purus nec tortor");
        ui.text("congue consequat. Proin varius luctus aliquam.");
      }

      if (ui.window(Id.handle(), "Third Window", 600, 30, 200, 300)) {
        ui.text("Three window?! Wow!");
        ui.text("Click count: " + clicks[2]);
        if (ui.button("Third Button")) {
          clicks[2]++;
        }

        ui.text("Lorem ipsum dolor sit amet,");
        ui.text("consectetur adipiscing elit.");
        ui.text("Integer sed nisi in orci posuere venenatis.");
        ui.text("Integer sollicitudin purus nec tortor");
        ui.text("congue consequat. Proin varius luctus aliquam.");
      }
    ui.end();
  }
}