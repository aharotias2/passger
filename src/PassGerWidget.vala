/*
 *  Copyright 2021 Tanaka Takayuki (田中喬之)
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

using Gtk;

public class PassGerWidget : Box {
    private enum Column {
        INDEX = 0,
        ENABLE_UPPER,
        ENABLE_LOWER,
        ENABLE_DIGIT,
        ENABLE_PUNCT,
        NUM_COLUMNS
    }

    public signal void require_alert(string message);
    public signal PassGerConfig require_other_settings();
    public signal void require_open_setting();
    public signal void require_close_setting();
    public signal void require_resize_window();
    public signal void require_clipboard_copy(string text);
    
    private const uint DEFAULT_PASSWORD_LENGTH = 8;
    
    public Gtk.ListStore model { get; set; }

    private Entry password_entry;
    private SpinButton password_length_setter;
    private TreeView list_view;
    private Button generate_button;
    private bool pan_button_clicked;

    public PassGerWidget() {
        Object(
            orientation: Orientation.VERTICAL,
            spacing: 4
        );
    }
    
    construct {
        pan_button_clicked = false;
        model = create_model();

        var top_button_box = new Box(HORIZONTAL, 0);
        {
            var pan_button = new Button.from_icon_name("pan-end-symbolic");
            pan_button.clicked.connect(() => {
                if (!pan_button_clicked) {
                    pan_button_clicked = true;
                    (pan_button.image as Image).icon_name = "pan-start-symbolic";
                    require_open_setting();
                } else {
                    pan_button_clicked = false;
                    (pan_button.image as Image).icon_name = "pan-end-symbolic";
                    require_close_setting();
                }
            });
            
            top_button_box.pack_start(pan_button, false, false);
            top_button_box.halign = END;
        }

        var entry_box = new Box(HORIZONTAL, 0);
        {
            password_entry = new Entry() {
                primary_icon_name = "dialog-password-symbolic",
                secondary_icon_name = "edit-copy-symbolic"
            };
            password_entry.icon_press.connect((pos, ev) => {
                if (pos == PRIMARY) {
                    generate_password();
                } else {
                    require_clipboard_copy(password_entry.text);
                }
            });
            
            entry_box.pack_start(password_entry, true, true);
        }
        
        var password_length_box = new Box(HORIZONTAL, 0);
        {
            var password_length_label = new Label(_("Length: "));
            password_length_setter = new SpinButton.with_range(/*min*/ 1.0, /*max*/ 1024.0, /*step*/ 1.0) {
                value = DEFAULT_PASSWORD_LENGTH
            };
            password_length_setter.value_changed.connect(() => {
                change_length();
            });
            var button_help1 = new Button.from_icon_name("help-faq-symbolic");
            {
                var pop_help1 = new Popover(button_help1);
                {
                    var label_help1 = new Label(
                            _("You can specify the password length using the \n"
                            + "spin box on the left.\n"
                            + "You can also specify the type of characters \n"
                            + "used for each character in the password using \n"
                            + "the table below.\n"
                            + "You can select the type of characters from \n"
                            + "uppercase letters, lowercase letters, numbers, \n"
                            + "and punctuation characters.\n"
                            + "You can select or deselect all character types \n"
                            + "for that column by clicking the column header.\n"
                            + "Specify at least one type for each row."));
                    
                    pop_help1.add(label_help1);
                    pop_help1.border_width = 10;
                    label_help1.show();
                }
                
                button_help1.get_style_context().add_class("flat");
                button_help1.clicked.connect(() => {
                    pop_help1.popup();
                });
            }
            password_length_box.pack_start(password_length_label, false, false);
            password_length_box.pack_start(password_length_setter, false, false);
            password_length_box.pack_start(button_help1, false, false);
        }
        
        list_view = new TreeView.with_model(model);
        {
            CellRendererText text_renderer = new CellRendererText();
            text_renderer.alignment = RIGHT;
            TreeViewColumn col1 = new TreeViewColumn.with_attributes("#", text_renderer, "text", Column.INDEX);
            list_view.append_column(col1);
            
            CellRendererToggle toggle_renderer_upper = new CellRendererToggle();
            toggle_renderer_upper.toggled.connect((path_str) => {
                toggle(new TreePath.from_string(path_str), Column.ENABLE_UPPER);
            });
            TreeViewColumn col2 = new TreeViewColumn.with_attributes("ABC", toggle_renderer_upper, "active", Column.ENABLE_UPPER);
            col2.clicked.connect(() => {
                toggle_all(Column.ENABLE_UPPER);
            });
            list_view.append_column(col2);
            
            CellRendererToggle toggle_renderer_lower = new CellRendererToggle();
            toggle_renderer_lower.toggled.connect((path_str) => {
                toggle(new TreePath.from_string(path_str), Column.ENABLE_LOWER);
            });
            TreeViewColumn col3 = new TreeViewColumn.with_attributes("abc", toggle_renderer_lower, "active", Column.ENABLE_LOWER);
            col3.clicked.connect(() => {
                toggle_all(Column.ENABLE_LOWER);
            });
            list_view.append_column(col3);

            CellRendererToggle toggle_renderer_digit = new CellRendererToggle();
            toggle_renderer_digit.toggled.connect((path_str) => {
                toggle(new TreePath.from_string(path_str), Column.ENABLE_DIGIT);
            });
            TreeViewColumn col4 = new TreeViewColumn.with_attributes("123", toggle_renderer_digit, "active", Column.ENABLE_DIGIT);
            col4.clicked.connect(() => {
                toggle_all(Column.ENABLE_DIGIT);
            });
            list_view.append_column(col4);

            CellRendererToggle toggle_renderer_punct = new CellRendererToggle();
            toggle_renderer_punct.toggled.connect((path_str) => {
                toggle(new TreePath.from_string(path_str), Column.ENABLE_PUNCT);
            });
            TreeViewColumn col5 = new TreeViewColumn.with_attributes("$%&", toggle_renderer_punct, "active", Column.ENABLE_PUNCT);
            col5.clicked.connect(() => {
                toggle_all(Column.ENABLE_PUNCT);
            });
            list_view.append_column(col5);
            
            list_view.headers_clickable = true;
            list_view.activate_on_single_click = true;
            list_view.row_activated((path, column) => {
                TreeIter iter;
                model.get_iter(out iter, path);
                model.set
        }
        
        generate_button = new Button.with_label(_("Generate!"));
        {
            generate_button.clicked.connect(() => {
                generate_password();
            });
        }
        
        pack_start(top_button_box, false, false);
        pack_start(entry_box, false, false);
        pack_start(password_length_box, false, false);
        pack_start(list_view, true, true);
        pack_start(generate_button, false, false);
    }
    
    private Gtk.ListStore create_model() {
        Gtk.ListStore model = new Gtk.ListStore(Column.NUM_COLUMNS,
                typeof(int), typeof(bool), typeof(bool), typeof(bool), typeof(bool));
        
        TreeIter iter;
        
        for (int i = 0; i < DEFAULT_PASSWORD_LENGTH; i++) {
            model.append(out iter);
            model.set(iter,
                    Column.INDEX, i + 1, Column.ENABLE_UPPER, true, Column.ENABLE_LOWER, true,
                    Column.ENABLE_DIGIT, true, Column.ENABLE_PUNCT, true);
        }
        
        return model;
    }
    
    private void change_length() {
        int new_length = (int) password_length_setter.value;
        int current_length = model.iter_n_children(null);
        TreeIter iter;
        if (current_length < new_length) {
            while (model.iter_n_children(null) < new_length) {
                current_length++;
                model.append(out iter);
                model.set(iter, Column.INDEX, current_length, Column.ENABLE_UPPER, true, Column.ENABLE_LOWER, true,
                        Column.ENABLE_DIGIT, true, Column.ENABLE_PUNCT, true);
            }
            require_resize_window();
        } else if (new_length < current_length) {
            while (model.iter_n_children(null) > new_length) {
                model.iter_nth_child(out iter, null, new_length);
                model.remove(ref iter);
            }
            require_resize_window();
        }
    }
    
    struct CharTypeStruct {
        public bool enable_upper;
        public bool enable_lower;
        public bool enable_digit;
        public bool enable_punct;
    }

    private void generate_password() {
        PassGerConfig other_settings = require_other_settings();
        CharType[] settings = new CharType[model.iter_n_children(null)];
        TreeIter iter;
        bool is_set = model.get_iter_first(out iter);
        if (!is_set) {
            return;
        }
        int i = 0;
        do {
            CharTypeStruct setting = { false, false, false, false };
            model.get(iter, Column.ENABLE_UPPER, out setting.enable_upper);
            model.get(iter, Column.ENABLE_LOWER, out setting.enable_lower);
            model.get(iter, Column.ENABLE_DIGIT, out setting.enable_digit);
            model.get(iter, Column.ENABLE_PUNCT, out setting.enable_punct);
            settings[i] = (
                (setting.enable_upper ? CharType.UPPER : 0) |
                (setting.enable_lower ? CharType.LOWER : 0) |
                (setting.enable_digit ? CharType.DIGIT : 0) |
                (setting.enable_punct ? CharType.PUNCT : 0)
            );
            i++;
        } while (model.iter_next(ref iter));
        if (!is_all_zeros(settings)) {
            string? new_password = PassGerUtils.generate(settings, other_settings);
            if (new_password != null) {
                if (new_password.length < settings.length) {
                    Idle.add(() => {
                        require_alert(_("There is not enough characters available.\n"
                                + "Please add available characters on the right panel.\n"
                                + "Or uncheck the “Do not use duplicated characters” checkbox."));
                        return false;
                    });
                }
                password_entry.text = new_password;
            } else {
                require_alert(_("Setting is invalid. At least 1 Character should be selected on each type (upper, lower, digit, punct)"));
            }
        } else {
            require_alert(_("At least 1 check should be checked on each rows."));
        }
    }
    
    private void toggle(TreePath path, Column column) {
        TreeIter iter;
        bool state;
        model.get_iter(out iter, path);
        model.get(iter, (int) column, out state);
        model.set(iter, (int) column, !state);
    }
    
    private void toggle_all(Column column) {
        TreeIter iter;
        model.get_iter_first(out iter);
        bool is_all_selected = true;
        do {
            bool is_selected;
            model.get(iter, (int) column, out is_selected);
            if (!is_selected) {
                is_all_selected = false;
                break;
            }
        } while (model.iter_next(ref iter));
        model.get_iter_first(out iter);
        do {
            model.set(iter, column, !is_all_selected);
        } while (model.iter_next(ref iter));
    }
    
    private bool is_all_zeros(CharType[] setting) {
        for (int i = 0; i < setting.length; i++) {
            if (setting[i] == 0) {
                return true;
            }
        }
        return false;
    }
}
