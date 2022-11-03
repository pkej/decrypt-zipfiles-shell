# decrypt-zipfiles-shell
Decrypt/unencrypt/unzip zipfiles by testing passwords from a list/dictionary you provide.

This script will only use the passwords provided on the command line. It will not try to brute force a decryption.

The script will create a folder named the same as the zip-file, minus '.zip' and move any files extracted to the root folder into it. Thus keeping your root clean from stray files from poorly made zip-files.

## Functionality
The file will scan a directory for zip-files. For each zip-file it will do an unzip test. If the file is password protected it will try all the passwords provided in a file. It will extract to one directory and keep it clean from stray files by moving them into a directory named the same as the zip-file. It will store which password worked on which zip-file in a separate file. It will store the names of successfully extracted zip-files in a file. The file is used to exclude the zip-file from extraction in future runs. It will move zip-files which can't be decrypted to a separate directory. It will store the names of unsuccessful files in a file for reference.

## Usage
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

## Why would you use it?
You download files from a lot of suppliers with different passwords for each file. You don't care to enter the password manually. You value your time and want to keep your download directory clean.

I tried finding something like this yesterday, and ended up creating it myself, as the few I found seem to use brute force based on dictionaries and took far too long to open one file. I know the passwords, I just don't care to assign them to specific files manually. This works fast and effective with the short list of passwords I use. I have not tested with larger sets of passwords.

## Some thoughts behind the implementation.
I'm using 'unzip -tP fail' to test if a file needs a password. It seems to be very fast. I also do the same with each password in the password-file, only if the test pass will I do a real unzip. This saves me from creating most empty directories. I choose force overwrite as I don't work with any incremental downloads.

## TODO
- [ ] Better handling of overwrites, let the user select the customary "all, none, skip" etc. choices.
- [ ] Delete flag.
- [ ] Help flag.
- [ ] select file for saving passwords
- [ ] make the password list cleaner, e.g. add tab between password and file name since spaces are confusing. Probably add some quotes around the password and file name
- [ ] check the actual directory the zipfile creates (if any) and move stray files into that instead of a new directory based just on the zip-file name.
