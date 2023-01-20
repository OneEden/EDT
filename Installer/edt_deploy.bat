@echo off

echo KKKKKKKK    KK       K        KKKKKKK
echo KK      KK  KK      KKK      KK      KK
echo KK      KK  KK     KK KK     KK            KKK
echo KK      KK  KK    KKKKKKK    KK    KKKK  KK
echo KK      KK  KK   KK     KK   KK      KK      KK
echo KKKKKKKK    KK  KK       KK    KKKKKK     KKK
echo ------------------------------------------------------------------------------------------------
echo Title: Deploy Tool for 6xx Code Test
echo Author: Yiting Wan
echo Version: 0.1
echo Desc: The tool should be used only for deployment of test code package for 6xx Diag software
echo ATTENTION(0): Put deployment packge 6xxDiags.zip at the same folder of this tool. 
echo ATTENTION(1): Close Diags SW first before deployment.
echo ------------------------------------------------------------------------------------------------
echo.

SET root=%~dp0
SET root=%root:~0,-1%
cd /d %root%

@REM Generate temp folder dir
:uniqLoop
SET "temp_dir=%tmp%\edt_deploy~%RANDOM%.tmp"
if exist "%temp_dir%" goto :uniqLoop

@REM Initialize constants
SET diags_folder_name=6xxDiags

SET timestamp=%date:~6,4%-%date:~0,2%-%date:~3,2%-%time:~0,2%-%time:~3,2%-%time:~6,2%
SET timestamp=%timestamp: =0%

SET job_name=EDT_Deploy_Job-%timestamp%


SET src_diags_package=%root%\%diags_folder_name%.zip
SET src_diags_temp=%temp_dir%\%diags_folder_name%
SET dst_diags=C:\%diags_folder_name%
SET output_package=%root%\%timestamp%.zip
SET output_dir=%root%\%timestamp%
SET temp_package_list=%temp_dir%\temp_package_list.txt
SET temp_backup=%temp_dir%\backup
SET temp_backup_info=%temp_backup%\info.txt
SET temp_backup_diags=%temp_backup%\%diags_folder_name%

@REM mkdir
mkdir %temp_dir%
mkdir %temp_backup%
mkdir %temp_backup_diags%

@REM Initialize flag
SET /p flag_scan=Deploy Diags software from %src_diags_package% to %dst_diags%?[Yes/No]
SET /A "flag = 0"
If %flag_scan%==yes SET /A "flag = %flag% | 1"
If %flag_scan%==Yes SET /A "flag = %flag% | 1"
If %flag_scan%==YES SET /A "flag = %flag% | 1"
If %flag_scan%==y SET /A "flag = %flag% | 1"
If %flag_scan%==Y SET /A "flag = %flag% | 1"
If %flag_scan%==no SET /A "flag = %flag% & 0"
If %flag_scan%==NO SET /A "flag = %flag% & 0"
If %flag_scan%==No SET /A "flag = %flag% & 0"
If %flag_scan%==N SET /A "flag = %flag% & 0"
If %flag_scan%==n SET /A "flag = %flag% & 0"

@REM Checking if the package is exist
IF %flag%==1 (
    echo.
    echo Job %job_name% start...
    echo [%job_name%]--Start>>edt_deploy.log
    TIMEOUT /T 1 /nobreak > NUL
    If exist %src_diags_package% (
        SET flag=1
        echo [%job_name%]--Check if deployment package 6xxDiags.zip exist...EXIST>>edt_deploy.log
        ) ELSE (
        SET flag=0
        echo %src_diags_package% not found. 
        echo [%job_name%]--Check if deployment package 6xxDiags.zip exist...NOT FOUND>>edt_deploy.log
        echo Fatal error. Deployment package not found. 
        echo Fatal error. Deployment package not found. >>edt_deploy.log
    )
) Else (
    echo User cancelled deployment.
    echo User cancelled deployment.>>edt_deploy.log
)

@REM Extract to temp
If %flag%==1 (
    If exist 7z.exe (
        echo [%job_name%]--Check if 7z.exe exis...EXIST>>edt_deploy.log
        echo ----------------EXTRACT INFO---------------- >>edt_deploy.log
        7z x %src_diags_package% -o%temp_dir%>>edt_deploy.log
        echo ----------------EXTRACT DONE---------------- >>edt_deploy.log
        If exist %src_diags_temp% (
            SET flag=1
            echo [%job_name%]--Check if %src_diags_temp% exist...EXIST>>edt_deploy.log
        ) Else (
            SET flag=0
            echo [%job_name%]--Check if %src_diags_temp% exist...NOT FOUND>>edt_deploy.log
        )
    ) Else (
        SET flag=0
        echo 7z.exe not found. 
        echo [%job_name%]--Check if 7z.exe exist...NOT FOUND>>edt_deploy.log
    )
    IF %flag%==0 (
        echo Fatal error. Deployment package extraction failed. 
        echo Fatal error. Deployment package extraction failed. >>edt_deploy.log
    )
)

@REM * https://blog.csdn.net/Dream_Weave/article/details/107310109?
@REM List Dir %src_diags_temp%
If %flag%==1 (
    echo Backup local 6xxDiags files...
    echo [%job_name%]--Backup local 6xxDiags files.>>edt_deploy.log
    echo ----------------BACKUP INFO---------------- >>edt_deploy.log
    for /f "usebackq delims=" %%f in (`dir /a:d/b/s/o:n %src_diags_temp%`) do echo %%f,Folder>>%temp_package_list%
    for /f "usebackq delims=" %%f in (`dir /a-d/b/s/o:n %src_diags_temp%`) do echo %%f,File>>%temp_package_list%
    for /f "usebackq tokens=1,2 delims=," %%a in (%temp_package_list%) do (
        setlocal enabledelayedexpansion
        SET _a=%%a
        SET _relative_dir=!_a:%src_diags_temp%=!
        SET _abosulte_dir=%dst_diags%!_relative_dir!
        If EXIST !_abosulte_dir! (
            echo OVERWRITE,!_relative_dir!,%%b>>%temp_backup_info%
            If %%b==File (
                xcopy /q/y "!_abosulte_dir!" "%temp_backup_diags%!_relative_dir!*" > nul
                echo !_abosulte_dir! >>edt_deploy.log
            ) Else (
                xcopy /q/y "!_abosulte_dir!" "%temp_backup_diags%!_relative_dir!\" > nul
                echo !_abosulte_dir! >>edt_deploy.log
            )
        ) Else (
            echo CREATE,!_relative_dir!,%%b>>%temp_backup_info%
        )
        endlocal
    )
    7z a %output_package% %temp_backup%\* >>edt_deploy.log
    echo ----------------BACKUP DONE---------------- >>edt_deploy.log
    echo [%job_name%]--Backup Done. Backup package is saved at %output_package%>>edt_deploy.log
    echo Backup Done. Backup package is saved at %output_package%. 
    echo Please check before deployment. 
    TIMEOUT /T 1 /nobreak > NUL
    @REM start %output_package%
    @REM Checking not implemented
) 
echo.
IF %flag%==1 (
echo ALERT! Deployment would overwrite codes of Diags.
SET /p flag_scan=Start deployment?[Yes/No]
SET /A "flag = 0"
If %flag_scan%==yes SET /A "flag = %flag% | 1"
If %flag_scan%==Yes SET /A "flag = %flag% | 1"
If %flag_scan%==YES SET /A "flag = %flag% | 1"
If %flag_scan%==y SET /A "flag = %flag% | 1"
If %flag_scan%==Y SET /A "flag = %flag% | 1"
If %flag_scan%==no SET /A "flag = %flag% & 0"
If %flag_scan%==NO SET /A "flag = %flag% & 0"
If %flag_scan%==No SET /A "flag = %flag% & 0"
If %flag_scan%==N SET /A "flag = %flag% & 0"
If %flag_scan%==n SET /A "flag = %flag% & 0"
)

IF %flag%==1 (
    echo.
    echo Deployment start...
    echo [%job_name%]--Deployment Start>>edt_deploy.log
    TIMEOUT /T 1 /nobreak > NUL
    echo ----------------DEPLOY INFO---------------- >>edt_deploy.log
    xcopy /i/y/e "%src_diags_temp%" "%dst_diags%">>edt_deploy.log
    echo ----------------DEPLOY DONE---------------- >>edt_deploy.log
    echo Deployment done. 
    @REM Checking not implemented
)

echo.
echo Job done.
echo [%job_name%]--Done.>>edt_deploy.log
echo.

pause