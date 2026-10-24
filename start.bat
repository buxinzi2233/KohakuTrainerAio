@echo off
setlocal DisableDelayedExpansion
rem Start the UI from source. No PowerShell, installation or Git operations.
set "AIO_ROOT=%~dp0"
set "UI_SRC=%AIO_ROOT%KohakuMoss-UI\src"
set "TRAINER_ROOT=%AIO_ROOT%KohakuMossTrainer"
set "TRAINER_PYTHON=%TRAINER_ROOT%\.venv\Scripts\python.exe"
set "SELECTED_PYTHON="
set "EXIT_CODE=1"

if not exist "%UI_SRC%\kohakumoss_ui\__main__.py" goto missing_ui
if not exist "%UI_SRC%\kohakumoss_ui\cli.py" goto missing_ui
if not exist "%TRAINER_ROOT%\scripts\train\moss.py" goto missing_trainer
if not exist "%TRAINER_ROOT%\configs\" goto missing_trainer

if defined AIO_PYTHON goto explicit_python
if exist "%TRAINER_ROOT%\.venv" goto trainer_python
if exist "%AIO_ROOT%KohakuMoss-UI\.venv" goto ui_python
call :try_system python3.exe
if defined SELECTED_PYTHON goto launch
call :try_system python.exe
if defined SELECTED_PYTHON goto launch
rem Resolve the Python launcher to a real executable, not a command string.
set "CANDIDATE="
for /f "delims=" %%P in ('py -3 -c "import sys; print(sys.executable)" 2^>nul') do set "CANDIDATE=%%P"
call :probe_python
if defined SELECTED_PYTHON goto launch
>&2 echo AIO: No working Python ^>=3.11 found. Install an environment or set AIO_PYTHON to its executable.
goto finish

:explicit_python
for %%P in ("%AIO_PYTHON%") do set "CANDIDATE=%%~fP"
call :probe_python
if defined SELECTED_PYTHON goto launch
>&2 echo AIO: AIO_PYTHON is not a working Python ^>=3.11 executable: "%AIO_PYTHON%"
goto finish

:trainer_python
set "CANDIDATE=%TRAINER_PYTHON%"
call :probe_python
if defined SELECTED_PYTHON goto launch
>&2 echo AIO: Trainer .venv is broken or needs Python ^>=3.11: "%CANDIDATE%"
>&2 echo Repair it or explicitly set AIO_PYTHON.
goto finish

:ui_python
set "CANDIDATE=%AIO_ROOT%KohakuMoss-UI\.venv\Scripts\python.exe"
call :probe_python
if defined SELECTED_PYTHON goto launch
>&2 echo AIO: UI .venv is broken or needs Python ^>=3.11: "%CANDIDATE%"
>&2 echo Repair it or explicitly set AIO_PYTHON.
goto finish

:launch
set "PYTHONPATH=%UI_SRC%;%PYTHONPATH%"
if exist "%TRAINER_ROOT%\.venv\Scripts\" set "PATH=%TRAINER_ROOT%\.venv\Scripts;%PATH%"
if defined KOHAKUMOSS_PYTHON goto run_ui
set "KOHAKUMOSS_PYTHON=%SELECTED_PYTHON%"
if exist "%TRAINER_PYTHON%" set "KOHAKUMOSS_PYTHON=%TRAINER_PYTHON%"
:run_ui
rem Do not CALL the command: double expansion would damage percent characters.
rem Keep caller cwd for relative arguments; a later --root overrides the default.
"%SELECTED_PYTHON%" -u -m kohakumoss_ui --root "%TRAINER_ROOT%" %*
set "EXIT_CODE=%ERRORLEVEL%"
goto finish

:missing_ui
>&2 echo AIO: UI source is missing. Initialize the KohakuMoss-UI submodule yourself; no Git commands were run.
goto finish

:missing_trainer
>&2 echo AIO: Trainer scripts/configs are missing. Initialize the KohakuMossTrainer submodule yourself; no Git commands were run.
goto finish

:try_system
set "CANDIDATE="
for %%P in (%1) do set "CANDIDATE=%%~$PATH:P"
call :probe_python
exit /b

:probe_python
if not defined CANDIDATE exit /b 1
if not exist "%CANDIDATE%" exit /b 1
"%CANDIDATE%" -I -c "import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)" >nul 2>&1
if not "%ERRORLEVEL%"=="0" exit /b 1
set "SELECTED_PYTHON=%CANDIDATE%"
exit /b 0

:finish
if "%EXIT_CODE%"=="0" goto return
if "%AIO_NO_PAUSE%"=="1" goto return
pause
:return
endlocal & exit /b %EXIT_CODE%
