#!/bin/sh

PROGRAM_NAME='atlint'

# Warn about files
warn_file ()
{
	printf "%s: %s\n" "$1" "$2"
}

warn_general ()
{
	printf "%s: %s\n" "$PROGRAM_NAME" "$1"
}

# Replace last segment of grep output, adding a newline.
# Assumes grep output is in the form: filename:col:match
replace_grep_message ()
{
	match_prefix="$1"
	#match_prefix="$(echo "$1" | cut -f 1,2 -d :)"
	new_message="$2"
	printf "%s: %s\n" "$match_prefix" "$new_message"
}

# Project-wide checks
if [ -f configure.in ] && [ ! -f configure.ac ]; then
	warn_general "Files named 'configure.in' are deprecated. Consider renaming to 'configure.ac'"
	configure_file=configure.in
elif [ -f configure.ac ]; then
	configure_file=configure.ac
else
	warn_general "Cannot find 'configure.ac' or 'configure.in'"
	# TODO: Use proper exit code.
	exit 1
fi

GREP_FLAGS='-HnE'
VALID_MACRO_NAME='[A-Z_]+'
temp="$(mktemp)"
# Autoconf checks

# Shorthand for checking the configure script
# Return code matches that of the underlying call to `grep`.
grep_configure ()
{
	grep "$GREP_FLAGS" "$1" "$configure_file" > "$temp" && return 0 || return 1
}

# Use `grep_configure` in a pipe.
grep_configure_pipe ()
{
	grep_configure "$1" && cat "$temp" || return 1
}

print_matches_with_message ()
{
	while read -r match; do
		replace_grep_message "$match" "$1"
	done < "$temp"
}

# Macro calls in the form: SOME_MACRO (...)
if grep_configure "${VALID_MACRO_NAME}\s+\("; then
	print_matches_with_message "Macros must be called without whitespace preceding the opening parenthesis"
fi

# Plain shell if-statements
if grep_configure '^if '; then
	print_matches_with_message "Use of (possibly unportable) if statement. Consider using 'AS_IF' instead"
fi

# Plain shell case-statements
if grep_configure '^case '; then
	print_matches_with_message "Use of (possibly unportable) case statement. Consider using 'AS_CASE' instead"
fi

# Uninitialised automake when its macros are used
if ! grep_configure '^AM_INIT_AUTOMAKE' && test "$(grep_configure_pipe '^AM_' | wc -l)" -ge 1; then
	warn_file "$configure_file" "Use of automake macros while uninitialised. Call 'AM_INIT_AUTOMAKE' at the start of '$configure_file'"
fi

# Lines after 'AC_OUTPUT'
if [ "$(sed '1,/AC_OUTPUT/ d' "$configure_file" | grep -Ev '^\s*(#|dnl)' | wc -l)" -gt 0 ]; then
	ac_output_match="$(grep "$GREP_FLAGS" '^AC_OUTPUT' "$configure_file" | head -n 1)"
	replace_grep_message "$ac_output_match" "Lines occur after 'AC_OUTPUT'. Consider if this is an error"
fi

rm -f "$temp"
