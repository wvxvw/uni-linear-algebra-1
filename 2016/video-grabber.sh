#!/bin/bash
# curl 'http://p2-vd-se01.se.openuvd01.vds-is.bynetcdn.com/vod/mp4:vod/openu/PRV/5v0tqWY3iD/App/5v0tqWY3iD_2.mp4/media_b1200000_9.ts' -H 'Host: p2-vd-se01.se.openuvd01.vds-is.bynetcdn.com' -H 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate' -H 'Referer: http://opal.openu.ac.il/local/ouil_video/theoplayer.php?&width=640&height=480&method=VOD&in=0&out=0&vtt=c20407_16b_784_81_9&clipurl=http%3A%2F%2Fapi.bynetcdn.com%2FRedirector%2Fopenu%2Fmanifest%2Fc20407_16b_784_81_9_mp4%2FHLS%2Fplaylist.m3u8&protocol=hls' -H 'Origin: http://opal.openu.ac.il' -H 'Connection: keep-alive'

i=238
mkdir -p /tmp/vod
rm -rf /tmp/vod/*
while [ $i -lt 1200 ]; do
    file="media_b1200000_$i.ts"
    echo "saving to: <$file>"
    curl "http://p2-vd-se01.se.openuvd01.vds-is.bynetcdn.com/vod/mp4:vod/openu/PRV/5v0tqWY3iD/App/5v0tqWY3iD_2.mp4/$file" \
         -H 'Host: openuvd01.vds-is.bynetcdn.com' \
         -H 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.0' \
         -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
         -H 'Accept-Language: en-US,en;q=0.5' \
         --compressed \
         -H 'Referer: http://opal.openu.ac.il/local/ouil_video/theoplayer.php?&width=640&height=480&method=VOD&in=0&out=0&vtt=c20407_16b_784_81_9&clipurl=http%3A%2F%2Fapi.bynetcdn.com%2FRedirector%2Fopenu%2Fmanifest%2Fc20407_16b_784_81_9_mp4%2FHLS%2Fplaylist.m3u8&protocol=hls' \
         -H 'Origin: http://opal.openu.ac.il' \
         -H 'Connection: keep-alive' > /tmp/vod/"$file"
    i=$((i+1))
    ffmpeg -i /tmp/vod/"$file" -strict -2 -bsf:a aac_adtstoasc -vcodec copy /tmp/vod/"$file".mp4
    echo "file /tmp/vod/$file".mp4 >> /tmp/vod/playlist.txt
done
ffmpeg -f concat -i /tmp/vod/playlist.txt -vcodec copy -acodec copy /tmp/vod/combined.mp4
