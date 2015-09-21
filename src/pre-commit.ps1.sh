#!/bin/sh

echo 
exec powershell.exe -ExecutionPolicy RemoteSigned -File '.\.git\hooks\pre-commit-hook.ps1'


exit