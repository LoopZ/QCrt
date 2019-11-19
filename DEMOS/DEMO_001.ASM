; Copyright 2019 Jerome Shidel
; Released Under GPL v2.0 License.

use16

org 100h

%define TargetCPU 8086      ; default is 286+
%define BiosVideoOnly       ; default is Direct and Bios modes
%define DisableMouse        ; disable mouse support

%include "DEMO_001.INC"

HelloWorld:     DB "Hello,",9,"World! (Demo #1)",CRLF,0
