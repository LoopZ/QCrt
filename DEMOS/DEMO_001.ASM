; Copyright ¸ 2015 Jerome Shidel
; All rights reserved.

use16

org 100h

%define TargetCPU 8086		; default is 286+
%define BiosVideoOnly		; default is Direct and Bios modes

%include "DEMO_001.INC"

HelloWorld: 	DB "Hello,",9,"World! (Demo #1)",CRLF,0
