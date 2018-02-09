:: Clean obj directory
@del /S /Q obj\*

:: Setup build options for static or dynamic linking
@if %1 == static (
   set type=static
   goto build
)
@if %1 == dynamic (
   set type=relocatable
   goto build
)

@echo %1 is not supported
@goto eof

:: Start gprbuild with acquired parameter
:build
@gprbuild -Psnake_windows.gpr -XLIBRARY_TYPE=%type%

:eof
