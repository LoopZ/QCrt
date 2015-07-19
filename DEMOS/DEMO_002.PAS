{
     Copyright ¸ 2015 Jerome Shidel
     All rights reserved.
}

program Test;

uses QCrt;


	
var
	M, I, K : integer;
	S : String;	
begin
	S := 'Hello world'#0;
	DirectVideo := False;
	for K := 1 to 2 do
		for I := 0 to 10 do begin
			for M := 1 to I do begin
				Write('A');
			end;
			for M := 1 to K do
				Tab;
			WriteLn(':');
		end;
		
{	M := (Hi(WindMax) + 1) div 2;
	for I := 0 to M do begin
		TextBackground((I + 1) and $07);
		Window(1 + I, 1 + I, Lo(ScreenMax) + 1 - I, Hi(ScreenMax) + 1 - I);
		ClrScr;
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
	clrscr;
	WriteRawZStr(@S[1]); }
end.