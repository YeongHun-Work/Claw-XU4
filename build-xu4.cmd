@echo off
setlocal

echo ======================================
echo  OpenClaw xu4 ARMv7 Cross-Build
echo ======================================
echo.

echo [1/4] Registering QEMU ARMv7 emulator...
docker run --privileged --rm tonistiigi/binfmt --install arm
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo [2/4] Setting up buildx builder...
docker buildx inspect xu4-builder >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    docker buildx create --name xu4-builder --use
) else (
    docker buildx use xu4-builder
)
docker buildx inspect --bootstrap
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo [3/4] Building ARMv7 image (may take 30-60 min)...
docker buildx build --platform linux/arm/v7 --load -t openclaw:xu4 -f Dockerfile .
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo [4/4] Saving image to tar...
docker save openclaw:xu4 -o openclaw-xu4.tar
if %ERRORLEVEL% NEQ 0 goto :error

echo.
echo ======================================
echo  Done! File: openclaw-xu4.tar
echo ======================================
pause
endlocal
exit /b 0

:error
echo.
echo [FAILED] Check error above.
pause
endlocal
exit /b 1
