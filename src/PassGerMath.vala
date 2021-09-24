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

public class PassGerMath {
    private static File? random_file;
    private static DataInputStream? reader;

    private static void init() {
        try {
            random_file = File.new_for_path("/dev/random");
            reader = new DataInputStream(random_file.read());
        } catch (Error e) {
            stderr.printf(_("Failed to open random file. exit."));
            Process.exit(127);
        }
    }
    
    public static char random_char() {
        try {
            if (reader == null) {
                init();
            }
            return (char) reader.read_byte();
        } catch (IOError e) {
            stderr.printf(_("IOError: random_byte was failed (%s))", e.message);
            Process.exit(127);
        }
    }
}
