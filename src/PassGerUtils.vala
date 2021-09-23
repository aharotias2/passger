public class PassGerUtils {
    private PassGerUtils() {
        // Don't create instances.
    }
    
    private static bool is_char_acceptable(char c, CharType acceptable_type, PassGerConfig config) {
        if (UPPER in acceptable_type && c.isupper() && config.upper_set[c]) {
            config.upper_set[c] = config.use_duplicated_chars;
            return true;
        } else if (LOWER in acceptable_type && c.islower() && config.lower_set[c]) {
            config.lower_set[c] = config.use_duplicated_chars;
            return true;
        } else if (DIGIT in acceptable_type && c.isdigit() && config.digit_set[c]) {
            config.digit_set[c] = config.use_duplicated_chars;
            return true;
        } else if (PUNCT in acceptable_type && c.ispunct() && config.punct_set[c]) {
            config.punct_set[c] = config.use_duplicated_chars;
            return true;
        } else {
            return false;
        }
    }

    private static int calc_sum(bool[] char_set) {
        int count = 0;
        for (int i = 0; i < char_set.length; i++) {
            if (char_set[i]) {
                count++;
            }
        }
        return count;
    }

    private static bool is_not_enough_chars(CharType type, PassGerConfig config) {
        int count = 0;
        if (UPPER in type) {
            count += calc_sum(config.upper_set);
        }
        if (LOWER in type) {
            count += calc_sum(config.lower_set);
        }
        if (DIGIT in type) {
            count += calc_sum(config.digit_set);
        }
        if (PUNCT in type) {
            count += calc_sum(config.punct_set);
        }
        return count == 0;
    }
    
    public static string? generate(CharType[] flags, PassGerConfig config) {
        try {
            int length = flags.length;
            uint8[] buffer = new uint8[length];
            int count = 0;
            File random_file = File.new_for_path("/dev/random");
            DataInputStream reader = new DataInputStream(random_file.read());
            while (count < length) {
                char c = (char) reader.read_byte();
                CharType type = flags[count];
                if (is_char_acceptable(c, type, config)) {
                    buffer[count] = (uint8) c;
                    if (is_not_enough_chars(type, config)) {
                        return (string) buffer;
                    }
                    count++;
                }
            }
            return (string) buffer;
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
            return null;
        }
    }
}
