#!/usr/bin/awk -f
# File: audit-rules.awk
# Usage: awk -f audit-rules.awk /etc/audit/rules.d/*.rules
# Usage: awk -v A=TARGET1 [ -v B=TARGET2 ] [ -v C=TARGET3 ] \
#                -f audit-rules.awk /etc/audit/rules.d/*.rules

function print_help() {
    print "Usage: awk -v A=TARGET1 [ -v B=TARGET2 ] [ -v C=TARGET3 ]"
    print "    -f audit-rules.awk /etc/audit/rules.d/*.rules"
    print "Search for audit rules in the specified files with fields"
    print "matching targets A, and (optionally) B and (optionally) C."
}

BEGIN {
    num_targets = 0
    if ( A ) {
        if ( verbose ) printf "A = %s\n", A
        targets[num_targets++] = A
    }
    if ( B ) {
        if ( verbose ) printf "B = %s\n", B
        targets[num_targets++] = B
    }
    if ( C ) {
        if ( verbose ) printf "C = %s\n", C
        targets[num_targets++] = C
    }
    target_count = 0
    lines = 0
    rule_count = 0
    printf "--- Scanning auditd rules for:"
    for (idx in targets) {
        printf " %s", targets[idx]
    }
    printf "\n"
}

# Bail out if there are no search targets.
{
    if ( num_targets == 0 ) {
        print_help()
        exit(1)
    }
}

# Skip empty lines and comments
/^[[:space:]]*$/ || /^[[:space:]]*#/ {
    lines++
    next
}

{
    # Put the record's fields into an array, keyed with fields
    fields[none] = 0
    for (i = 0; i < NF; i++) {
        fields[$i] = 1
    }

    matches = 0
    for (ix in targets) {
        if (targets[ix] in fields) {
            matches++
        }
    }
    if ( matches == num_targets ) {
        target_count++
        printf "Match on line %d\n", lines
    }

    # Clean the 'fields' array at the end of processing this line
    delete fields
}

# Count other rules
{
    rule_count++
    lines++
}

END {
    printf "--- Rules monitoring %s: %d\n", targets[0], target_count
    printf "--- Processed %d rules in %d lines\n", rule_count, lines
    if ( target_count >= 1 )
        exit 0
    if ( target_count == 0 )
        exit 1
}
