@ECHO OFF

rem Applied Fluids Lab, 2023
rem Appalachian State University
rem Tess Mickey and Chris Thaxton

rem *** This is for NAM12km data only - 4 day backtrajectories (-96) only

rem *** NOTE: This version works on Chris Thaxton's computer
rem *** Make sure to change the directories below to match yours but keep the syntax

rem *** Changed the code to copy met files from USB for use then deletes the local copy
rem *** ...did this to save local file space on c:\

rem set the location of met data
SET NAM12km_DIR=C:\_METDATA\NAM12km\

rem set the working directory
SET WORK_DIR=.\

rem set the tdumps directory
SET RESULTS_DIR=.\results\NAM12km-96hr\%6\

rem set executable directory
SET EXEC_DIR=C:\HYSPLIT\exec\

IF NOT EXIST %RESULTS_DIR% mkdir %RESULTS_DIR%

rem *******************************************
rem   STRUCTURE OF RUN, SET BAT FILES
rem *******************************************
rem parameter #1: start year (UTC)
rem parameter #2: start month (UTC)
rem parameter #3: start day (UTC)
rem parameter #4: start hour (UTC)
rem parameter #5: start minute (UTC)
rem parameter #6: height (500, 1500, 3500)
rem parameter #7: site code (corresponds to location)
rem parameter #8: run name
rem parameter #9: metfile1 (edas!!)
rem parameter #10: metfile2 (edas!!)

rem *******************************************
rem BUILD THE CONTROL FILE
rem *******************************************

rem *** date and time inputs
ECHO %1 %2 %3 %4 %5 >control.txt

rem number of starting locations
ECHO 1 >>control.txt

rem *** location inputs
rem if %7==APP        goto site_APP
rem add other sites if desired

rem :site_APP
ECHO 36.2 -81.7 %6 >>control.txt
rem goto site_end
rem :site_end

rem *** back trajectory time
ECHO -96 >>control.txt

rem *** vertical motion option
ECHO 0 >>control.txt

rem *** top of model domain
ECHO 10000.0 >>control.txt

rem *** number of input data grids (we will likely only have 1)
ECHO 5 >>control.txt

ECHO %NAM12km_DIR% >>control.txt
ECHO %9 >>control.txt

rem ***
COPY E:\NAM12km\%9 %NAM12km_DIR%

shift
ECHO %NAM12km_DIR% >>control.txt
ECHO %9 >>control.txt
COPY E:\NAM12km\%9 %NAM12km_DIR%

shift
ECHO %NAM12km_DIR% >>control.txt
ECHO %9 >>control.txt
COPY E:\NAM12km\%9 %NAM12km_DIR%

shift
ECHO %NAM12km_DIR% >>control.txt
ECHO %9 >>control.txt
COPY E:\NAM12km\%9 %NAM12km_DIR%

shift
ECHO %NAM12km_DIR% >>control.txt
ECHO %9 >>control.txt
COPY E:\NAM12km\%9 %NAM12km_DIR%
rem ***


rem ECHO %RESULTS_DIR% >>control.txt
ECHO %WORK_DIR% >>control.txt
SET outfile=tdump.txt
ECHO %outfile% >>control.txt

IF EXIST CONTROL. DEL CONTROL.
copy control.txt CONTROL

IF EXIST SETUP.CFG DEL SETUP.CFG
rem copy setup_cfg_frac_pbl.txt SETUP.CFG

IF EXIST setup.txt del setup.txt

rem now figured out how to ECHO an ampersand -- have to have a ^ in front!
ECHO  ^&setup > setup.txt
ECHO TRATIO = 0.75, >>setup.txt
ECHO MGMIN = 10, >> setup.txt
ECHO KHMAX = 9999, >> setup.txt
ECHO KMIXD = 0, >> setup.txt
ECHO KMSL = 0, >> setup.txt
ECHO NSTR = 0, >> setup.txt
ECHO MHRS = 9999, >> setup.txt
ECHO NVER = 0, >> setup.txt
ECHO TOUT = 60, >> setup.txt
ECHO TM_TPOT = 1, >> setup.txt
ECHO TM_TAMB = 1, >> setup.txt
ECHO TM_RAIN = 1, >> setup.txt
ECHO TM_MIXD = 1, >> setup.txt
ECHO TM_RELH = 1, >> setup.txt
ECHO TM_SPHU = 1, >> setup.txt
ECHO TM_MIXR = 1, >> setup.txt
ECHO TM_DSWF = 1, >> setup.txt
ECHO TM_TERR = 1, >> setup.txt
ECHO DXF = 1.0, >> setup.txt
ECHO DYF = 1.0, >> setup.txt
ECHO DZF = 0.01, >> setup.txt
ECHO WVERT = .TRUE. >> setup.txt
ECHO  /   >>setup.txt

copy setup.txt SETUP.CFG
IF EXIST tdump.txt DEL tdump.txt
REM *****************************************************************************************
%EXEC_DIR%hyts_std.exe

rem ***
DEL %NAM12km_DIR%\%5
DEL %NAM12km_DIR%\%6
DEL %NAM12km_DIR%\%7
DEL %NAM12km_DIR%\%8
DEL %NAM12km_DIR%\%9
ECHO %1
ECHO %2
ECHO %3
ECHO %4
ECHO %5
ECHO %6
rem ***

SET DATASOURCE="NAM12km"

IF EXIST tdump.txt COPY tdump.txt tdump_%4_%DATASOURCE%.tdp
IF EXIST CONTROL COPY CONTROL CONTROL_%4_%DATASOURCE%.ctl

rem IF NOT EXIST %RESULTS_DIR%\%2\ mkdir %RESULTS_DIR%\%2\

IF NOT EXIST %RESULTS_DIR%\tdp\ mkdir %RESULTS_DIR%\tdp\
IF NOT EXIST %RESULTS_DIR%\ctl\ mkdir %RESULTS_DIR%\ctl\

IF EXIST tdump_%4_%DATASOURCE%.tdp MOVE tdump_%4_%DATASOURCE%.tdp %RESULTS_DIR%\tdp\
IF EXIST CONTROL_%4_%DATASOURCE%.ctl MOVE CONTROL_%4_%DATASOURCE%.ctl %RESULTS_DIR%\ctl\





