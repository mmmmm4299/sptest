@echo off
setlocal enabledelayedexpansion

:MENU
cls
echo Vyber si test rychlosti:
echo.
echo 1. Ultra Quick Test (1000)
echo 2. Quick Test (5000)
echo 3. Fast Test (10000)
echo 4. Normal Test (25000)
echo 5. Slow Test (50000)
echo 6. Ultra Slow Test (250000)
echo 7. Vlastni test
echo 8. Konec
echo.
set /p choice=Zadej cislo (1-7): 

if "%choice%"=="1" set MAXNUMBER=1000 & goto RUN
if "%choice%"=="2" set MAXNUMBER=5000 & goto RUN
if "%choice%"=="3" set MAXNUMBER=10000 & goto RUN
if "%choice%"=="4" set MAXNUMBER=25000 & goto RUN
if "%choice%"=="5" set MAXNUMBER=50000 & goto RUN
if "%choice%"=="6" set MAXNUMBER=250000 & goto RUN
if "%choice%"=="7" goto CUSTOM
if "%choice%"=="8" goto END

echo Neplatna volba, zkus to znovu.
pause
goto MENU

:CUSTOM
cls
set /p MAXNUMBER=Zadej pocet vypoctu (cele cislo vetsi nez 0): 
REM Ověření jestli je to číslo a větší než 0
for /f "delims=0123456789" %%A in ("!MAXNUMBER!") do (
    echo Chyba: Zadej prosim jen cislo!
    pause
    goto CUSTOM
)
if "!MAXNUMBER!"=="0" (
    echo Cislo musi byt vetsi nez 0!
    pause
    goto CUSTOM
)
goto RUN

:RUN
cls
echo Spoustim test s %MAXNUMBER% vypocty...
echo.

REM Vypis mod - budeme jen nulový (bez výpisu)
set OUTPUTMODE=None

REM Spusti powershell a uloz vysledek do promenne
for /f "usebackq delims=" %%a in (`powershell -ExecutionPolicy Bypass -File speedtest.ps1 %MAXNUMBER% %OUTPUTMODE%`) do set elapsed=%%a

echo Cas vypoctu: %elapsed% sekund

if "%choice%"=="6" (
    echo Zadany pocet vypoctu: %MAXNUMBER%
)

pause
goto END

:END
endlocal
exit
