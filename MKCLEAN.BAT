@echo off

rem Make and Clean bin directory
if exist BIN del BIN\*.*
if exist BIN rmdir BIN

rem Clean up previous builds if needed.
if exist PASCAL\QCRT.OBJ del PASCAL\*.OBJ
if exist PASCAL\QCRT.TPU del PASCAL\*.TPU
rem if exist DEMOS\QCRT.TPU del PASCAL\*.TPU
