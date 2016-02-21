
# Hello!
echo
echo "Extracting Libvirt XML files and OpenStack Heat Templates here: `pwd`"
echo

# Searches for the line number where finish the script and start the tar.gz.
SKIP=`awk '/^__TARFILE_FOLLOWS__/ { print NR + 1; exit 0; }' $0`

# Remember our file name.
THIS=`pwd`/$0

# Take the tarfile and pipe it into tar.
tail -n +$SKIP $THIS | tar -xv

# Any script here will happen after the tar file extract.
echo
echo "Finished"
exit 0

# NOTE: Don't place any newline characters after the last line below.
__TARFILE_FOLLOWS__
