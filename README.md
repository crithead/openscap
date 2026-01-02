# OpenSCAP

Scripts for SCE to fix OpenSCAP checks.

If you customize your system, the default checks in the OpenSCAP scanner may
not find what its looking for even though the rule is there. Here are some
script experiments to find another way of verifying the system is configured
IAW the STIG.

Though the SCE runs shell scripts, it seems like AWK is the perfect tool for
scanning configuration files.  (More than awk '{print $1}' or the like.) There
are AWK programs here too.

## References

- [github.com/openscap](https://github.com/openscap)
- [www.open-scap.org](https://www.open-scap.org/)

