{
     Copyright ¸ 2015 Jerome Shidel
     All rights reserved.
}

program Test;

uses QCrt;
	
var
	M, I : integer;
	S : String;	
begin
{	DirectVideo := True; }
	WriteLn('Hello, World! (Demo #2)');
	WriteLn('Press a key to continue.');
	while not Keypressed do;
	ReadKey;
		
	M := (Hi(WindMax) + 1) div 2;
	for I := 0 to M do begin
		TextBackground((I + 1) and $07);
		Window(1 + I, 1 + I, Lo(ScreenMax) + 1 - I, Hi(ScreenMax) + 1 - I);
		ClrScr;
		Write('Square #', I + 1);
		Sound(500 - (M - I + 1) * 32); 
		Delay(500 - (M - I + 1) * 32); 
	end;
	NoSound;
	Window(4, 4, Lo(ScreenMax) - 2, Hi(ScreenMax) - 2);
	TextAttr := $4F;
	for I := 1 to Hi(WindMax) - Hi(WindMin) do begin
		ScrollDown(1);
		ScrollRight(2);
		Delay(100);
	end;
	TextAttr := $07;
	Window(1, 1, Lo(ScreenMax) + 1, Hi(ScreenMax) + 1);	
	ClrScr;
end.