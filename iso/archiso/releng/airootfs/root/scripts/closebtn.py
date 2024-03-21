import subprocess
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk
import sys

program = sys.argv[1]
class HelloWorld(Gtk.EventBox):
    def __init__(self):
        Gtk.EventBox.__init__(self)
        self.set_size_request(65, 30)
        label = Gtk.Label()
        label.set_text("Zavřít")
        label.set_margin_top(3)
        label.set_margin_start(5)
        self.add(label)
        self.override_background_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(1, 1, 1, 0.5))

def on_window_clicked(widget, event):
    command = "pkill -f " + program
    subprocess.call(command, shell=True)
    sys.exit()

if __name__ == "__main__":
    Gtk.init()
    hello_world = HelloWorld()
    fixed = Gtk.Fixed()
    fixed.put(hello_world, 0, 0)
    window = Gtk.Window()
    window.set_decorated(False)
    window.set_type_hint(Gdk.WindowTypeHint.DOCK)
    window.set_keep_below(True)
    window.set_resizable(False)
    window.set_skip_taskbar_hint(True)
    window.add(fixed)
    window.connect("button-press-event", on_window_clicked)
    window.show_all()
    print("Close button showed.")
    Gtk.main()
