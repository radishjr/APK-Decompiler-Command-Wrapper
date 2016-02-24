@echo off
set 7zipPath="C:\Program Files (x86)\7-Zip\7z.exe"

cd %~dp0%

::Get user inputs
set /p ApkPath=Input your apk path: 
IF "%ApkPath%"=="quit" EXIT /B 1
IF NOT EXIST "%ApkPath%" (
    ECHO %~n0: file not found - %ApkPath% >&2
    set /p quit=Input anything to exit:
    EXIT /B 1
)
set /p OutputFolder=Input output folder path: 
IF "%OutputFolder%"=="quit" EXIT /B 1
IF NOT EXIST "%OutputFolder%" mkdir %OutputFolder%
IF NOT EXIST "%OutputFolder%" (
    ECHO %~n0: file not found - %OutputFolder% >&2
    set /p quit=Input anything to exit:
    EXIT /B 1
)

For %%A in ("%ApkPath%") do (
    set ApkNameWithoutExtension=%%~nA
    set ApkName=%%~nxA
)

set OutputFolderWithApkName=%OutputFolder%\%ApkNameWithoutExtension%
set ResourcesFolder=%OutputFolderWithApkName%\Resources
IF NOT EXIST "%ResourcesFolder%" (
	mkdir %ResourcesFolder%
)

::Extract resources
echo extract resources under: %ResourcesFolder% ...
java -jar apktool_2.0.3.jar d -f %ApkPath% -o %ResourcesFolder%

::Make a copy of the apk and unzip it.
set ZipFilePath=%OutputFolderWithApkName%\%ApkNameWithoutExtension%.zip
set DexFolder=%OutputFolderWithApkName%\Dex
IF NOT EXIST "%DexFolder%" (
	mkdir %DexFolder%
)

echo copy zip file...
copy /y %ApkPath% %ZipFilePath%
echo unzip file...
%7zipPath% e "%ZipFilePath%" -o"%DexFolder%" classes.dex

rm "%ZipFilePath%"

::Convert the dex file to jar
set dexPath=%DexFolder%\classes.dex
set jarPath=%OutputFolder%\%ApkNameWithoutExtension%.jar
cd dex2jar-2.0
CALL d2j-dex2jar "%dexPath%" -o "%jarPath%" --force

::Open jar with jd-gui
echo Open jar with jd-gui...
cd ..
jd-gui-windows-1.4.0\jd-gui.exe "%jarPath%"
EXIT /B 1
