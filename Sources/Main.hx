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
    ui = new Kimgui();
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
      g2.color = 0xFFFF0000;
      g2.fillRect(0, 0, fb.width, fb.height);
    g2.end();

    ui.begin(g2);
      ui.window(Id.handle());
      ui.endWindow();
    ui.end();
  }
}