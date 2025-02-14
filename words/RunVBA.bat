@echo off
setlocal

:: Define the path to the Word macro script
set "VBA_SCRIPT=C:\Path\To\ReplaceHyperlinks.bas"
set "WORD_DOCS_FOLDER=C:\Path\To\Your\Folder"

:: Start Word and execute the VBA macro
echo Running VBA macro on Word documents...
start /wait winword /mProcessWordFiles /q

echo Done!
exit
