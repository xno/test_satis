###############################################################################
#
# PHP Syntax Check for Git pre-commit hook for Windows PowerShell
#
# Author: Vojtech Kusy <wojtha@gmail.com>
# Author: Chuck "MANCHUCK" Reeves <chuck@manchuck.com>
#
###############################################################################

### INSTRUCTIONS ###

# Place the code to file "pre-commit" (no extension) and add it to the one of 
# the following locations:
# 1) Repository hooks folder - C:\Path\To\Repository\.git\hooks
# 2) User profile template   - C:\Users\<USER>\.git\templates\hooks 
# 3) Global shared templates - C:\Program Files (x86)\Git\share\git-core\templates\hooks
# 
# The hooks from user profile or from shared templates are copied from there
# each time you create or clone new repository.

### SETTINGS ###

# Path to the php.exe
$php_exe = "C:\xampp\php\php.exe";


# Flag, if set to 1 require test file to exist, set to 0 to disable
$requireTest = 1;

# Extensions of the PHP files 
$php_ext = "php|phtml"

# Flag, if set to 1 git will unstage all files with errors, set to 0 to disable
$unstage_on_error = 0;

### FUNCTIONS ###

function php_syntax_check {
    param([string]$php_bin, [string]$extensions, [int]$reset) 

    $err_counter = 0;

    write-host "Pre-commit PHP syntax check:" -foregroundcolor "white" -backgroundcolor "black"

    git diff-index --name-only --cached HEAD -- | foreach {             
        if ($_ -match ".*\.($extensions)$") {
            $file = $matches[0];
            $errors = & $php_bin -l $file   
            $testFileExists = (Test-Path $file -PathType Leaf)
            write-host $file ": "  -foregroundcolor "gray"  -backgroundcolor "black" -NoNewline
            if ($testFileExists) {
                if ($errors -match "No syntax errors detected in $file") {
                    write-host "OK!" -foregroundcolor "green" -backgroundcolor "black"
                }
                else {              
                    write-host "ERROR! " $errors -foregroundcolor "red" -backgroundcolor "black"
                    if ($reset) {
                        git reset -q HEAD $file
                        write-host "Unstaging ..." -foregroundcolor "magenta" -backgroundcolor "black"
                    }
                    $err_counter++
                }
            } else {
                write-host "OK! (file deleted)" -foregroundcolor "green" -backgroundcolor "black"
            }
        }
    }

    if ($err_counter -gt 0) {
        write-host "Some File(s) have syntax errors. Please fix then commit" -foregroundcolor "red" -backgroundcolor "black"
        exit 1
    }    
}

### MAIN ###

php_syntax_check $php_exe "php|phtml" $unstage_on_error
write-host
