int main(string[] args) {
    var app = new Gtk.Application("com.github.aharotias2.pass-gener", FLAGS_NONE);
    app.activate.connect(() => {
        PassGerWidget widget1 = new PassGerWidget();
        PassGerConfigWidget widget2 = new PassGerConfigWidget();
        var window = new Gtk.ApplicationWindow(app);
        Gtk.Clipboard clipboard = Gtk.Clipboard.get_default(window.get_display());
        var top_box = new Gtk.Box(HORIZONTAL, 4);
        {
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
            top_box.pack_start(widget2, false, false);
        }
        window.add(top_box);
        window.title = "PassGer - A simple password generator";
        window.show_all();
        widget2.visible = false;
        window.resize(1, 1);
    });
    return app.run(args);
}
