function load_env --description 'Export variables from dotenv-style files (KEY=VALUE)'
    for file in $argv
        test -r $file; or continue
        while read -l line
            # skip blank lines and comments
            string match -qr '^\s*(#|$)' -- $line; and continue
            set line (string replace -r '^\s*export\s+' '' -- $line)
            set -l kv (string split -m 1 = -- $line)
            test (count $kv) -eq 2; or continue
            set -l key (string trim -- $kv[1])
            # strip surrounding quotes from the value
            set -l value (string trim -- $kv[2] | string replace -r '^([\'"])(.*)\1$' '$2')
            set -gx $key $value
        end <$file
    end
end
