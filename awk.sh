#!/usr/bin/bash -v
# The goal of this little experiement is to figure out how to launch an inline
# awk program from within a bash script.

# Note: Quoting the here-doc delimiter prevents parameter expansion, command
# substitution, and arithemtic expansion.

## Option #1 -- Put the AWK program in a shell variable
P=$(cat <<'EOF'
BEGIN {printf "Name\n-----\n"}
{print $3, $2}
END {printf "-----\n"}
EOF
)
/usr/bin/awk "$P" guys.txt

# Option #2 -- Put the AWK program in a temporary file
T=$(mktemp XXXXXXXX.awk)
cat > "$T" <<'AWK'
BEGIN{printf "Name\n-----\n"}
{print $1, $4}
END{printf "-----\n"}
AWK

/usr/bin/awk -f "$T" guys.txt
/usr/bin/rm -f "$T"
exit 0

