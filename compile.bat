@echo off
tasm %1
tlink /t /x %1
%1