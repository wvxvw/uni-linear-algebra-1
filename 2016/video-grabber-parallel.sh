#!/bin/bash
target=/tmp/vod
workers=()
referer='Referer: http://opal.openu.ac.il/local/ouil_video/theoplayer.php?&width=640&height=480&method=VOD&in=0&out=0&vtt=c20407_16b_784_81_7&clipurl=http%3A%2F%2Fapi.bynetcdn.com%2FRedirector%2Fopenu%2Fmanifest%2Fc20407_16b_784_81_7_mp4%2FHLS%2Fplaylist.m3u8&protocol=hls'
playlist='http://p2-vd-se01.se.openuvd01.vds-is.bynetcdn.com/vod/mp4:vod/openu/PRV1/aMJe6xhpwr/App/aMJe6xhpwr_2.mp4/chunklist_b1200000.m3u8'
cdn='http://p2-vd-se01.se.openuvd01.vds-is.bynetcdn.com/vod/mp4:vod/openu/PRV1/aMJe6xhpwr/App/aMJe6xhpwr_2.mp4/'

load_playlist() {
    curl "$playlist" \
         -H 'Host: p1-vd-se01.se.openuvd01.vds-is.bynetcdn.com' \
         -H 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.0' \
         -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
         -H 'Accept-Language: en-US,en;q=0.5' \
         -H 'Accept-Encoding: gzip, deflate' \
         -H "$referer" \
         -H 'Origin: null' \
         -H 'Connection: keep-alive'
}

load_ts() {
    file="$1"
    echo "saving to: <$target/$file>"
    curl "$cdn/$file" \
         -H 'Host: openuvd01.vds-is.bynetcdn.com' \
         -H 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.0' \
         -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
         -H 'Accept-Language: en-US,en;q=0.5' \
         --compressed \
         -H "$referer" \
         -H 'Origin: http://opal.openu.ac.il' \
         -H 'Connection: keep-alive' > /tmp/vod/"$file"
    ffmpeg -i "$target/$file" -strict -2 -bsf:a aac_adtstoasc -vcodec copy "$target/$file".mp4
}

convert() {
    mkdir -p "$target"
    rm -rf "$target/*"
    load_playlist | grep '^[^#]'  | while read line ; do
        free=${#workers[@]}
        if [ $free -le 10 ]; then
            load_ts $line & pid=$!
            workers+=($pid)
        else
            removed=false
            for pid in ${workers[@]}; do
                if ! kill -0 $pid 2> /dev/null ; then
                    removed=true
                    rem=($pid)
                    workers=(${workers[@]/$rem})
                fi
            done
            if ! $removed ; then
                sleep 1
            fi
        fi
    done
    find "$target" -name '*.mp4' -exec echo "file {}" \; | \
        sort -k3,3g -t_ > "$target/playlist.txt"
    ffmpeg -f concat -i "$target/playlist.txt" -vcodec copy -acodec copy "$target/combined.mp4"
}

convert
