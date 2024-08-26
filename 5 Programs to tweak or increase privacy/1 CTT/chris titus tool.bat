@echo off
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo run as admin
    pause
    exit /b
)

powershell -Command "iwr -useb https://christitus.com/win | iex"
