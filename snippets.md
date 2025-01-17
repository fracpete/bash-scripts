# Find directories containing certain files recursively 

The following snippet searches a directory (`top_level`) recursively for specific files (`file-to-look-for`)
and stores the directory names in a text file (`dir_list`). As second step, it iterates over the directories
from the text file to perform some operation on it:

```bash
#!/bin/bash
top_level = "/some/dir"
dir_list = "/tmp/list.txt"
find "$top_level" -type f -iname "file-to-look-for" -print0 | xargs -0 --no-run-if-empty dirname | sort -u > $dir_list
while read d; do
  echo "--> $d"
  # do something
done < $dir_list
```
