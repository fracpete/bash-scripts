# bash-scripts
Collection of bash scripts:

* [check_git_repo.sh](check_git_repo.sh) - checks git repositories for
  their protocol and can switch from https to git
* [dockerauto.sh](dockerauto.sh) - performs login (and logout) of
  docker registries defined in `dockerauto.list` (uses insecure password storage!).
* [ffmpeg.md](ffmpeg.md) - example ffmpeg command-lines
* [option_parsing.sh](option_parsing.sh) - parses command-line options 
  provided by the user and offers a simple help screen.
* [simple_backup.sh](simple_backup.sh) - script that simplifies the use
  of or [rsync](https://rsync.samba.org/) for backing up directories.
  Each entry in the `simple_backup.list` file can have an associated 
  file with exclusions (`simple_backup.NAME.excl`).
* [update_repos.sh](update_repos.sh) - for updating local source code 
  repositories (git, svn, gdrive) using a text file specifying the 
  repositories.
