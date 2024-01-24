# copyright
This repository contains scripts used for bulk copyright maintenance across multiple repositories.

## Notice
Copyright 2024 Open Networking Foundation (ONF) and the ONF Contributors
Copyright 2017-2024 Open Networking Foundation (ONF) and the ONF Contributors

Copyright 2024 Open Networking Foundation (ONF) and the ONF Contributors
   * format - CCYY (2024)  {century}-2_digits, {year}-2_digits
   * date_0 - Initial date work was created or introduced.
   * date_1 - Year sources were last modified, value cannot be open-ended.
   *        - Values such as -current or -present are invalid.
             
## Todo:
   * Update sources in all repositories to contain the correct copyright notice.
   * Provide samples of copyright notices used in the code base.
   * Write a traversal script to iterate over a repository checkout,
     search for copyright notices and validate syntax.

## Slide deck for copyright notice and licensing (circa: 2019).
https://docs.google.com/presentation/d/1Z0diSoTVpVb5EnjEt4UtGpPMIeQKx12G/edit#slide=id.p22

## Notice generation

```shell:
% ./gen-copyright.sh                         # span: *current_year*
% ./gen-copyright.sh --start 2019            # span: *2019-current_year*
% ./gen-copyright.sh --start 2019 --end 2023 # span: *2019-2023*

```