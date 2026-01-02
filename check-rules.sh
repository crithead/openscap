#!/usr/bin/bash
# Check audit rules for a set of parameters.
if [ -z "$1" ]; then
    echo "Usage: ${0} TERMS"
    echo "  Where TERMS are a (semi-)colon-separated list of rule parameters to"
    echo "  search for in the system's audit rules."
    echo "  Example TERMS: arch=b64:-S:lsetxattr"
    echo "                 arch=b32:path=/usr/bin/sudo:always,exit"
    echo "                 -w:/usr/sbin/modprobe"
    exit 1
fi
[ $(id -u) -eq 0 ] || { echo "Must be root"; exit 1; }

IFS=':;' read -r -a terms <<< "${1}"
echo "${#terms[@]} terms: ${terms[@]}"

#readonly audit_dir=/etc/audit/rules.d
#readonly audit_file=/etc/audit/audit.rules
readonly audit_dir=${PWD}
readonly audit_file=

# scan_file FILENAME
# Where FILENAME is the file to check
# And the global 'terms' is an array of patterns to scan for
# Returns SUCCESS (0) if all terms are found in the same line,
# Otherwise returns FAILURE (1) or ERROR (2) as appropriate.
function scan_file
{
    local file_name=${1}

    if [ -z "$file_name" ]; then
        return 2
    fi


    # Read a line
    while IFS= read -r line; do
        if [[ $line =~ ^# ]] || [[ $line =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        # Split the line into an array of fields
        IFS=' ' read -r -a fields <<< "${line}"
        #echo "${#fields[@]} fields: ${fields[@]}"

        # Count the number of TERMS that match a FIELD in the line
        matches=0
        for term in ${terms[@]}; do
            for field in ${fields[@]}; do
                if [ "$field" == "$term" ]; then
                    (( matches++ ))
                fi
            done
        done
        # Return success as soon as all terms are matched in a line
        if [ "$matches" -eq "${#terms[@]}" ]; then
            return 0
        fi

    done < "${file_name}"

    # All terms not found in any line, return FAILURE
    return 1
}

# Check each audit rules file
exit_code=1
for file in ${audit_file} $(ls ${audit_dir}/*.rules); do
    if scan_file ${file}; then
        echo "+++ ${file}"
        exit_code=0
    else
        echo "--- ${file}"
    fi
done

exit "${exit_code}"

