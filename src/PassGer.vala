/*
 *  Copyright 2019-2021 Tanaka Takayuki (田中喬之)
 *
 *  This file is part of PassGer.
 *
 *  PassGer is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  PassGer is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with PassGer.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Tanaka Takayuki <aharotias2@gmail.com>
 */

int main(string[] args) {
    var app = new Gtk.Application("com.github.aharotias2.passger", FLAGS_NONE);
    app.activate.connect(() => {
        var window = new Gtk.ApplicationWindow(app);
        Gtk.Clipboard clipboard = Gtk.Clipboard.get_default(window.get_display());
        var top_box = new Gtk.Box(HORIZONTAL, 4);
        {
            PassGerConfigWidget widget2 = new PassGerConfigWidget();
            Idle.add(() => {
                top_box.pack_start(widget2, false, false);
                window.show_all();
                widget2.visible = false;
                window.resize(1, 1);
                return false;
            });
            
            PassGerWidget widget1 = new PassGerWidget();
            widget1.require_other_settings.connect(() => {
                return widget2.get_config();
            });
            widget1.require_open_setting.connect(() => {
                widget2.visible = true;
                window.resize(1, 1);
            });
            widget1.require_close_setting.connect(() => {
                widget2.visible = false;
                window.resize(1, 1);
            });
            widget1.require_resize_window.connect(() => {
                window.resize(1, 1);
            });
            widget1.require_clipboard_copy.connect((password) => {
                clipboard.set_text(password, password.length);
            });
            widget1.require_alert.connect((message) => {
                var alert = new Gtk.MessageDialog(window, MODAL, ERROR, OK, message);
                alert.run();
                alert.close();
            });

            top_box.pack_start(widget1, false, false);
            top_box.margin = 4;
        }
        window.add(top_box);
        window.show_all();
        window.title = _("PassGer - A simple password generator");
    });
    return app.run(args);
}
