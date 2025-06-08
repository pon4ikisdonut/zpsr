@echo off
chcp 1251 >nul
setlocal

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Этот установщик должен быть запущен с правами администратора!
    echo Запусти файл ПРАВОЙ кнопкой мыши -> "Запуск от имени администратора"
    pause
    exit /b
)

set "ZPSR_DIR=%USERPROFILE%\zpsr-lang"
set "SCRIPT_DIR=%~dp0"

where python >nul 2>nul
if errorlevel 1 (
    echo [!] Python не найден. Скачиваю Python 3.13.3...

    set "PYTHON_VERSION=3.13.3"
    set "PYTHON_INSTALLER=python-%PYTHON_VERSION%-amd64.exe"
    set "PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/%PYTHON_INSTALLER%"

    curl -O %PYTHON_URL%
    echo Устанавливаю Python...
    %PYTHON_INSTALLER% /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    if errorlevel 1 (
        echo [!] Ошибка установки Python!
        pause
        exit /b
    )
    echo Python установлен.
) else (
    echo Python уже установлен.
)

python --version >nul 2>nul
if errorlevel 1 (
    echo [!] Python не найден после установки. Проверь PATH.
    pause
    exit /b
)

if not exist "%ZPSR_DIR%" (
    mkdir "%ZPSR_DIR%"
    echo Создана папка установки: %ZPSR_DIR%
)

copy /Y "%SCRIPT_DIR%zpsr.py" "%ZPSR_DIR%\zpsr.py"
if errorlevel 1 echo [!] Не удалось скопировать zpsr.py
copy /Y "%SCRIPT_DIR%zpsr-build.py" "%ZPSR_DIR%\zpsr-build.py"
if errorlevel 1 echo [!] Не удалось скопировать zpsr-build.py

(
echo @echo off
echo python "%%~dp0zpsr.py" %%*
) > "%ZPSR_DIR%\zpsr.cmd"

(
echo @echo off
echo python "%%~dp0zpsr-build.py" %%*
) > "%ZPSR_DIR%\zpsr-build.cmd"

for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path') do set "OLDPATH=%%B"

echo %OLDPATH% | find /I "%ZPSR_DIR%" >nul
if %errorlevel%==0 (
    echo Путь %ZPSR_DIR% уже добавлен в системный PATH.
) else (
    echo Добавляем %ZPSR_DIR% в системный PATH...
    setx /M PATH "%OLDPATH%;%ZPSR_DIR%"
    echo Путь добавлен. Перезапусти компьютер или терминал, чтобы изменения вступили в силу.
)

:: Установка зависимостей
if exist "%SCRIPT_DIR%requirements.txt" (
    echo Устанавливаю зависимости...
    python -m pip install --upgrade pip
    pip install -r "%SCRIPT_DIR%requirements.txt"
) else (
    echo [!] Файл requirements.txt не найден. Пропускаю установку зависимостей.
)

echo.
echo [?] Установка завершена.
pause
