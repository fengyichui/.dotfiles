alias x=extract

extract() {

    if (( $# == 0 )); then
		cat <<-'EOF' >&2
			Usage: extract [-option] [file ...]
			Default: Extract archive file
			Options:
			    -r, --remove    Remove archive after unpacking.
			    -l, --list      List archive files' name.
			    -c, --compress  Compress files/directories to archive file
			                    extract -c <archive-name> <files>
		EOF
    fi

    if [[ "$1" == "-c" ]] || [[ "$1" == "--compress" ]]; then
        shift

        # compress
        case "$1" in
            (*.zip) zip -r "$@" ;;
            (*.7z) 7za a "$@" ;;
            (*.rar) ;;
            (*) tar cavf "$@" ;;
        esac

    else

        local remove_archive
        local list_archive
        local success
        local extract_dir

        remove_archive=1
        if [[ "$1" == "-r" ]] || [[ "$1" == "--remove" ]]; then
            remove_archive=0
            shift
        fi

        list_archive=0
        if [[ "$1" == "-l" ]] || [[ "$1" == "--list" ]]; then
            list_archive=1
            shift
        fi

        while (( $# > 0 )); do
            if [[ ! -f "$1" ]]; then
                echo "extract: '$1' is not a valid file" >&2
                shift
                continue
            fi

            if [[ "$list_archive" == "1" ]]; then
                # list
                case "$1" in
                    (*.zip|*.war|*.jar|*.ipsw|*.xpi|*.apk) unzip -l "$1" | less ;;
                    (*.rar) unrar l "$1" | less ;;
                    (*.7z) 7za l "$1" | less ;;
                    (*) tar tavf "$1" | less ;;
                esac
            else
                # extract
                success=0
                case "$1" in
                    (*.tar.gz|*.tar.bz2|*.tar.xz|*.tar.zma) extract_dir="${1:t:r:r}" ;;
                    (*) extract_dir="${1:t:r}" ;;
                esac
                mkdir $extract_dir 2>/dev/null
                case "$1" in
                    (*.tar.gz|*.tgz) tar zxvf "$1" -C $extract_dir ;;
                    (*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$1" -C $extract_dir ;;
                    (*.tar.xz|*.txz) tar --xz -xvf "$1" -C $extract_dir ;;
                    (*.tar.zma|*.tlz) tar --lzma -xvf "$1" -C $extract_dir ;;
                    (*.tar) tar xvf "$1" -C $extract_dir ;;
                    (*.gz) gunzip "$1" ;;
                    (*.bz2) bunzip2 "$1" ;;
                    (*.xz) unxz "$1" ;;
                    (*.lzma) unlzma "$1" ;;
                    (*.Z) uncompress "$1" ;;
                    (*.zip|*.war|*.jar|*.sublime-package|*.ipsw|*.xpi|*.apk) unzip "$1" -d $extract_dir ;;
                    (*.rar) unrar x -ad "$1" ;;
                    (*.7z) 7za x "$1" ;;
                    (*.deb)
                        mkdir -p "$extract_dir/control"
                        mkdir -p "$extract_dir/data"
                        cd "$extract_dir"; ar vx "../${1}" > /dev/null
                        cd control; tar xzvf ../control.tar.gz
                        cd ../data; extract ../data.tar.*
                        cd ..; rm *.tar.* debian-binary
                        cd ..
                    ;;
                    (*)
                        echo "extract: '$1' cannot be extracted" >&2
                        success=1
                    ;;
                esac
                rmdir --ignore-fail-on-non-empty "$extract_dir"

                # remove double dir
                extract_sub_dir=$(ls $extract_dir)
                if [[ "$extract_sub_dir" == "$extract_dir" ]]; then
                    mv "$extract_dir/$extract_sub_dir" "${extract_dir}.tmp"
                    rmdir --ignore-fail-on-non-empty $extract_dir
                    mv "${extract_dir}.tmp" $extract_dir
                fi

                (( success = $success > 0 ? $success : $? ))
                (( $success == 0 )) && (( $remove_archive == 0 )) && rm "$1"
            fi

            shift
        done
    fi
}

