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

public class PassGerConfigWidget : Box {
    public const char[] UPPER_SET = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
        'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    };
    
    public const char[] LOWER_SET = {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
    };

    public const char[] DIGIT_SET = {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    };
    
    public const char[] PUNCT_SET = {
        '!', '\"', '#', '$', '%', '&', 0x27 /*single quote*/, '(', ')', '*', '+',
        ',', '-', '.', '/', ':', ';', '<', '=', '>', '?', '@', '[', '\\', ']', '^',
        '_', '`'
    };
    
    public Entry keyword_entry;
    private GLib.ListStore list_upper;
    private GLib.ListStore list_lower;
    private GLib.ListStore list_digit;
    private GLib.ListStore list_punct;
    private Gtk.CheckButton toggle_use_duplicated_chars;
    
    public PassGerConfigWidget() {
        Object(
            orientation: Orientation.VERTICAL,
            spacing: 5,
            margin: 4
        );
    }
    
    construct {
        list_upper = create_list(UPPER_SET);
        list_lower = create_list(LOWER_SET);
        list_digit = create_list(DIGIT_SET);
        list_punct = create_list(PUNCT_SET);
        
        var box_label1 = new Box(HORIZONTAL, 5);
        {
            var charset_label = new Label(_("Character Setting")) {
                halign = START
            };
            
            var button_help1 = new Button.from_icon_name("help-faq-symbolic");
            {
                var pop_help1 = new Popover(button_help1);
                {
                    var label_help1 = new Label(
                        _("Here you can specify the characters used to generate the password.\n"
                        + "The pressed characters are used to generate the password.\n"
                        + "On the contrary, the characters that are not pressed are not used for \n"
                        + "password generation.\n"
                        + "At least one character should be pressed on each category.")
                    );
                    
                    pop_help1.add(label_help1);
                    pop_help1.border_width = 10;
                    label_help1.show();
                }
                
                button_help1.get_style_context().add_class("flat");
                button_help1.clicked.connect(() => {
                    pop_help1.popup();
                });
            }

            box_label1.pack_start(charset_label, false, false);
            box_label1.pack_start(button_help1, false, false);
        }
        
        var frame_upper = new Frame(_("Uppercase Letters"));
        {
            var box_upper = new FlowBox() {
                min_children_per_line = 10,
                selection_mode = NONE
            };
            box_upper.bind_model(list_upper, create_character_button);
            frame_upper.add(box_upper);
        }

        var frame_lower = new Frame(_("Lowercase Letters"));
        {
            var box_lower = new FlowBox() {
                selection_mode = NONE
            };
            box_lower.bind_model(list_lower, create_character_button);
            frame_lower.add(box_lower);
        }

        var frame_digit = new Frame(_("Digital characters"));
        {
            var box_digit = new FlowBox() {
                selection_mode = NONE
            };
            box_digit.bind_model(list_digit, create_character_button);
            frame_digit.add(box_digit);
        }

        var frame_punct = new Frame(_("Punctuation Characters"));
        {
            var box_punct = new FlowBox() {
                selection_mode = NONE
            };
            box_punct.bind_model(list_punct, create_character_button);
            frame_punct.add(box_punct);
        }
        
        var frame_other = new Frame(_("Other Settings"));
        {
            var box_other = new Box(VERTICAL, 5);
            {
                toggle_use_duplicated_chars = new CheckButton.with_label(_("Do not use duplicated characters")) {
                    active = false
                };

                box_other.pack_start(toggle_use_duplicated_chars, false, false);
            }
            
            frame_other.add(box_other);
        }
        
        pack_start(box_label1, true, false);
        pack_start(frame_upper, true, false);
        pack_start(frame_lower, true, false);
        pack_start(frame_digit, true, false);
        pack_start(frame_punct, true, false);
        pack_start(frame_other, true, false);
    }

    private class CharacterSetting : Object {
        public unowned GLib.ListStore list;
        public char character;
        public bool active;
    }
    
    private Widget create_character_button(Object item) {
        CharacterSetting? character_setting = item as CharacterSetting;
        var toggle = new CheckButton.with_label(character_setting.character.to_string()) {
            active = true
        };
        toggle.toggled.connect(() => {
            if (!toggle.active && count_activated(character_setting.list) == 1) {
                toggle.active = true;
            } else {
                character_setting.active = toggle.active;
            }
        });
        toggle.active = character_setting.active;
        return toggle;
    }

    private int count_activated(GLib.ListStore list) {
        int count = 0;
        for (uint i = 0; i < list.get_n_items(); i++) {
            CharacterSetting? character_setting = list.get_item(i) as CharacterSetting;
            if (character_setting.active) {
                count++;
            }
        }
        return count;
    }
    
    private GLib.ListStore create_list(char[] char_set) {
        var model = new GLib.ListStore(typeof(CharacterSetting));
        for (int i = 0; i < char_set.length; i++) {
            var character_setting = new CharacterSetting();
            character_setting.list = model;
            character_setting.character = char_set[i];
            character_setting.active = true;
            model.append(character_setting);
        }
        return model;
    }
    
    public PassGerConfig get_config() {
        var config = new PassGerConfig();
        config.upper_set = create_charset(list_upper);
        config.lower_set = create_charset(list_lower);
        config.digit_set = create_charset(list_digit);
        config.punct_set = create_charset(list_punct);
        config.use_duplicated_chars = !toggle_use_duplicated_chars.active;
        return config;
    }
    
    private bool[] create_charset(ListModel list) {
        uint length = list.get_n_items();
        bool[] result = new bool[256];
        for (int i = 0; i < length; i++) {
            CharacterSetting item = list.get_item(i) as CharacterSetting;
            result[(int) item.character] = item.active;
        }
        return result;
    }
}

