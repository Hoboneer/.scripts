#!/bin/sh
# Toggle input method engine
ENGINE_EN=xkb:us::eng
ENGINE_JP=mozc-jp

get_engine ()
{
	case "$1" in
		"$ENGINE_EN"|en) echo "$ENGINE_JP" ;;
		"$ENGINE_JP"|jp) echo "$ENGINE_EN" ;;
		*) return 1 ;;
	esac
	return 0
}

engine="$(get_engine "$1")" || engine="$(get_engine "$(ibus engine)")" || { notify-send -t 1000 'Could not next engine for some reason'; exit 1; }

notify-send -t 500 "Switching to $engine"
exec ibus engine "$engine"
