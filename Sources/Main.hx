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

  public function new() {
    ui = new Kimgui({ font: Assets.fonts.OpenSansMedium });
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

    ui.setWindowSize(fb.width, fb.height);

		// Start drawing, and clear the framebuffer to `petrol`
		g2.begin(true, Color.fromBytes(0, 0, 0));
      // Do normal rendering here
    g2.end();

    // Render UI after other rendering finishes
    ui.begin(g2);
      ui.window(Id.handle(), "First Window", 30, 30, 300, 300, function () {
        ui.text("The contents of the first window");
      });

      ui.window(Id.handle(), "Second Window", 350, 30, 200, 300, function () {
        ui.text("The contents of the second window");
      });

      ui.window(Id.handle(), "Third Window", 670, 30, 300, 500, function () {
        ui.text("The contents of the third window");
      });
      
      ui.window(Id.handle(), "Fourth Window", 30, 350, 400, 400, function () {
        ui.text("The contents of the fourth window");
      });

      ui.window(Id.handle(), "Fifth Window", 450, 350, 300, 300, function () {
        ui.text("The contents of the fifth window");
      });

      ui.window(Id.handle(), "Sixth Window", 800, 350, 300, 300, function () {
        ui.text("The contents of the sixth window");
      });
    ui.end();
  }
}