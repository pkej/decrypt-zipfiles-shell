# decrypt-zipfiles-shell
Decrypt/unencrypt/unzip zipfiles by testing passwords from a list/dictionary you provide.

This script will only use the passwords provided on the command line. It will not try to brute force a decryption.

The script will create a folder named the same as the zip-file, minus '.zip' and move any files extracted to the root folder into it. Thus keeping your root clean from stray files from poorly made zip-files.

# Usage
```pre
-a autocleanup. If a file exists in the excludefile delete it
-b backup directory for files that can't be decrypted (missing password).
-d unimplemented. Delete zip-files after extraction.
-e directory to extract the files to. Automatic cleanup of stray files going into this root after each unzip.
-h unimplemented. Help.
-p passwordfile
-q quiet
-u file for storing the names of unsuccessfully extracted files.
-v verbose
-x file with list of files to exclude. When a file is succesfully extracted it will be stored in this file.
-z directory to glob (*.zip) for files to unzip.
```
