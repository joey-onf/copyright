# copyright
This repository contains scripts used for bulk copyright maintenance across multiple repositories.

## Notice
Copyright 2024 Open Networking Foundation Contributors
Copyright 2017-2024 Open Networking Foundation Contributors

Copyright 2024 Open Networking Foundation Contributors
   * format - CCYY (2024)  {century}-2_digits, {year}-2_digits
   * date_0 - Initial date work was created or introduced.
   * date_1 - Year sources were last modified, value cannot be open-ended.
   *        - Values such as -current or -present are invalid.

## Notice generation

```shell:
% ./gen-copyright.sh                         # span: *current_year*
% ./gen-copyright.sh --start 2019            # span: *2019-current_year*
% ./gen-copyright.sh --start 2019 --end 2023 # span: *2019-2023*

```

## Bulk copyright notice updates

```shell:

% git clone git@github.com:joey-onf/copyright.git
% git clone myrepo

% cd myrepo
% ../copyright/gather-and-update
% git diff --color=always | less -R
% git add --all
% git commit -F ../commit_message_file

```

## See Also
- https://www.linuxfoundation.org/blog/blog/copyright-notices-in-open-source-software-projects