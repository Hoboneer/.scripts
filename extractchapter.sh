#!/bin/sh
# DESCRIPTION: Extract a chapter from an audio or video file into a new file.
# DEPENDENCIES: ffmpeg ffprobe jq
# See https://stackoverflow.com/questions/30305953/is-there-an-elegant-way-to-split-a-file-by-chapter-using-ffmpeg
# TODO: should we be able to extract multiple chapters at once?  (into one file or split?)
# TODO: should the chapter argument(s) be regexes?  (so they can select multiple chapters at once?)
infile="$1"
outfile="$2"
chapter="$3"
json="$(ffprobe -i "$infile" -print_format json -show_chapters -loglevel error | jq --arg chapter "$chapter" '.chapters[] | select(.tags.title | contains($chapter))')"
# We don't copy over chapters since they would be meaningless in the output file
ffmpeg  -i "$infile" -acodec copy -vcodec copy -map_chapters -1 -ss $(echo "$json" | jq -r .start_time) -to $(echo "$json" | jq -r .end_time) "$outfile"
