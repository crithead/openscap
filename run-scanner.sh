#!/usr/bin/bash
[ $(id -u) -eq 0 ] || { echo "Must be root"; exit 1; }

readonly output_dir="${PWD}/output"
[ -d "${output_dir}" ] || { echo "Directory not found: ${output_dir}"; exit 1; }

# Run 'oscap info ssg-cs10-ds.xml' to get a list of profiles
readonly profile="xccdf_org.ssgproject.content_profile_stig"
#readonly profile="xccdf_org.ssgproject.content_profile_stig_gui"

readonly ds_dir=/usr/share/xml/scap/ssg/content
timestamp="$(date +%Y%m%d%H%M%S)"
readonly date

echo -e "\nStart Scan - ${timestamp}\n"

/usr/bin/oscap xccdf eval \
  --profile "${profile}" \
  --results "${output_dir}/ssg-cs10-results-${timestamp}.xml" \
  "${ds_dir}/ssg-cs10-ds.xml"

echo -e "\nGenerate Report - ${timestamp}\n"

/usr/bin/oscap xccdf generate report \
  --output "${output_dir}/ssg-cs10-report-${timestamp}.html" \
  "${output_dir}/ssg-cs10-results-${timestamp}.xml"

echo -e "\nDone - ${timestamp}\n"
#ls -l "${output_dir}/*${timestamp}*"

exit 0

