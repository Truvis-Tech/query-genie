@echo off
setlocal enabledelayedexpansion

:: === Prompt for Branches ===
set /p FRONTEND_BRANCH=Enter the frontend branch to clone (default is "main"): 
if "%FRONTEND_BRANCH%"=="" set FRONTEND_BRANCH=main

set /p BACKEND_BRANCH=Enter the backend branch to clone (default is "main"): 
if "%BACKEND_BRANCH%"=="" set BACKEND_BRANCH=main

:: === Configuration ===
set "TRULENS_DIR=%cd%\trulens"
set "FRONTEND_REPO=https://<username>:<access-token>@192.168.1.10:8888/truvis/demo-trulens-ui.git"
set "BACKEND_REPO=https://<username>:<access-token>@192.168.1.10:8888/truvis/trulens.git"
set "RUN_COMMAND=query-genie-api"

:: === Create Output Directory ===
if not exist "%TRULENS_DIR%" mkdir "%TRULENS_DIR%"

:: === Clone Frontend ===
echo [INFO] Cloning frontend repository (branch: %FRONTEND_BRANCH%)...
if exist "demo-trulens-ui" rmdir /s /q "demo-trulens-ui"
git clone -b %FRONTEND_BRANCH% "%FRONTEND_REPO%" demo-trulens-ui
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Frontend clone failed!
    pause
    exit /b 1
)

:: === Build Frontend ===
cd demo-trulens-ui
echo [INFO] Installing frontend dependencies...
call npm install
if %ERRORLEVEL% neq 0 (
    echo [ERROR] npm install failed!
    pause
    exit /b 1
)

echo [INFO] Building frontend...
call npm run build
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Frontend build failed!
    pause
    exit /b 1
)

echo [INFO] Copying build to output directory...
xcopy /E /I /Y dist "%TRULENS_DIR%\dist" >nul
cd ..
rmdir /s /q demo-trulens-ui

:: === Clone Backend ===
echo [INFO] Cloning backend repository (branch: %BACKEND_BRANCH%)...
if exist "trulens-backend" rmdir /s /q "trulens-backend"
git clone -b %BACKEND_BRANCH% "%BACKEND_REPO%" trulens-backend
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Backend clone failed!
    pause
    exit /b 1
)

:: === Build Backend ===
cd trulens-backend
echo [INFO] Building Python wheel...
call python -m pip install --upgrade pip >nul
call pip install wheel >nul
call python setup.py bdist_wheel
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Backend wheel build failed!
    pause
    exit /b 1
)

echo [INFO] Copying backend files...
copy dist\*.whl "%TRULENS_DIR%" >nul
xcopy /E /I /Y main "%TRULENS_DIR%\main" >nul
xcopy /E /I /Y config "%TRULENS_DIR%\config" >nul
cd ..
rmdir /s /q trulens-backend

:: === Setup Python venv and run backend ===
cd "%TRULENS_DIR%"
echo [INFO] Creating Python virtual environment...
python -m venv venv
call venv\Scripts\activate

echo [INFO] Installing backend wheel...
for %%f in (*.whl) do (
    pip install "%%f"
)

echo [INFO] Starting backend server in detached mode: %RUN_COMMAND%
start "Backend" /min cmd /c "venv\Scripts\activate && %RUN_COMMAND%"

:: === Serve frontend ===
echo [INFO] Checking for 'serve' installation...
where serve >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [INFO] 'serve' not found. Installing globally...
    npm install -g serve
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Failed to install 'serve'. Please check npm permissions.
        pause
        exit /b 1
    )
) else (
    echo [INFO] 'serve' is already installed.
)

echo [INFO] Starting frontend server (detached) on port 5173...
cd /d "%TRULENS_DIR%"
if not exist "dist" (
    echo [ERROR] Frontend build output 'dist' not found in %TRULENS_DIR%
    pause
    exit /b 1
)

start "Frontend" /min cmd /k "cd /d %TRULENS_DIR% && serve -s dist -l 5173"


:: === Get local IP address for LAN access ===
for /f "tokens=14" %%f in ('ipconfig ^| findstr "IPv4"') do set LOCAL_IP=%%f

cls
echo.
echo ✅ Frontend and Backend setup complete and running.
echo 📁 Output saved to: %TRULENS_DIR%
echo.
echo ============================
echo 🌐 Access URLs:
echo ----------------------------
echo 🔹 Frontend:
echo    http://localhost:5173
echo    http://%LOCAL_IP%:5173
echo.
echo 🔹 Backend:
echo    http://localhost:8000
echo    http://%LOCAL_IP%:8000
echo ============================
echo.
pause

