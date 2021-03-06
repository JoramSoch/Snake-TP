program snake;
{written by Joram Soch <JoramSoch@web.de>,
 coded on 11/02/2016, uploaded on 01/02/2018}

uses
  crt, dos;

var
  i, j, n, d, l, t               : integer;
  h1, m1, s1, h2, m2, s2, s100   : word;
  xmin, ymin, xmax, ymax         : byte;
  xf, yf, xl, yl, xn, yn, xs, ys : byte;
  x, y                           : array[1..256] of byte;
  name, lvl, pts, sec            : string[30];
  ss                             : char;


{FUNCTIONS AND PROCEDURES}

function InKey : integer;
var
  c : char;
begin
  if KeyPressed then
  begin
    c := ReadKey;
    if c = #0 then	{control keys}
      InKey := 1000 + ord(ReadKey)
    else		{ASCII table}
      InKey := ord(c);
  end
  else			{no key pressed}
    InKey := 0;
end;

procedure write_pos(x1,y1 : byte; str : string);
begin
  gotoxy(x1,y1);
  write(str);
end;

procedure draw_box(x1,y1,x2,y2 : byte; tl,tr,br,bl : char; t,r,b,l : char; title : string);
var
  xt : byte;
begin
  {corners}
  write_pos(x1,y1,tl);
  write_pos(x2,y1,tr);
  write_pos(x2,y2,br);
  write_pos(x1,y2,bl);
  {top and bottom}
  if (x2-x1) > 1 then
  begin
    for i := (x1+1) to (x2-1) do
    begin
      write_pos(i,y1,t);
      write_pos(i,y2,b);
    end;
  end;
  {left and right}
  if (y2-y1) > 1 then
  begin
    for i := (y1+1) to (y2-1) do
    begin
      write_pos(x1,i,l);
      write_pos(x2,i,r);
    end;
  end;
  {title}
  if (length(title)+4) < (x2-x1) then
  begin
    xt := (x1+1) + (((x2-x1-1)-(length(title)+2)) div 2);
    write_pos(xt,y1,' '+title+' ');
  end;
  gotoxy(x1+1,y1+1);
end;

function point_on_snake(x,y : array of byte; x1,y1 : byte; n : integer) : boolean;
begin
  point_on_snake := false;
  for i := 1 to n do
  begin
    if (x1 = x[i]) AND (y1 = y[i]) then
      point_on_snake := true;
  end;
end;

function snake_in_wall(x1,y1,x2,y2 : byte; xf,yf : byte) : boolean;
begin
  snake_in_wall := false;
  if xf < x1 then snake_in_wall := true;
  if xf > x2 then snake_in_wall := true;
  if yf < y1 then snake_in_wall := true;
  if yf > y2 then snake_in_wall := true;
end;


{MAIN PROGRAM}

begin

  {0. Parameter Definition}
  Randomize;
  n := 10;			{length of the snake}
  d := 4;			{direction of the snake}
  xmin :=  3; ymin :=  3;	{top left corner}
  xmax := 78; ymax := 48;	{bottom right corner}
  {coordinates of the snake}
  x[1] := (xmin+xmax) div 2;	{horizontal center}
  y[1] := (ymin+ymax) div 2;	{vertical center}
  for i := 2 to n do
  begin
    x[i] := x[1]+(i-1);
    y[i] := y[1];
  end;
  {position of the target}
  ss := 'O';			{circle symbol}
  repeat
    xs := random(xmax-xmin+1)+xmin;
    ys := random(ymax-ymin+1)+ymin;
  until point_on_snake(x,y,xs,ys,n) = false;


  {1. Start Screen}
  textmode(CO80);
  TextColor(15);
  clrscr;
  writeln;
  write('>> Name of the Player  : '); readln(name);
  write('>> Starting Level (0-9): '); readln(l);
  writeln;


  {2. Game Screen}
  textmode(CO80+font8x8);
  TextColor(15);
  clrscr;
  draw_box(xmin-1,ymin-1,xmax+1,ymax+1,'�','�','�','�','�','�','�','�','SNAKE for DOS');
  draw_box(x[1],y[1],x[n-1],y[n-1],'�','�','�','�','�','�','�','�','SNAKE for DOS');
  write_pos(xs,ys,ss);


  {3. Main Loop}
  if l < 0 then l := 0;		{minimal level 0}
  if l > 9 then l := 9;		{maximal level 9}
  t := 120 - l*10;		{interval time [ms]}

  {get start time}
  gettime(h1,m1,s1,s100);

  repeat

    {check whether a key was pressed}
    case InKey of
      1072 : begin		{move up}
               if d <> 3 then d := 1;
             end;
      1077 : begin		{move right}
               if d <> 4 then d := 2;
             end;
      1080 : begin		{move down}
               if d <> 1 then d := 3;
             end;
      1075 : begin		{move left}
               if d <> 2 then d := 4;
             end;
        27 : begin d := 0; end;	{Escape}
         0 : begin end;		{no key}
    end;

    {determine next position of snake}
    xf := x[1]; yf := y[1];
    xl := x[n]; yl := y[n];
    case d of
      1 : begin xn := xf;   yn := yf-1; end;
      2 : begin xn := xf+1; yn := yf;   end;
      3 : begin xn := xf;   yn := yf+1; end;
      4 : begin xn := xf-1; yn := yf;   end;
    end;

    {check whether game is over}
    if point_on_snake(x,y,xn,yn,n-1) then
      d := -1;
    if snake_in_wall(xmin,ymin,xmax,ymax,xn,yn) then
      d := -2;

    {if snake reaches a target}
    if (xn = xs) AND (yn = ys) then
    begin
      n := n + 1;
      if (n < 101) AND (n mod 10 = 0) then
      begin
        if (n div 10 - 1 > l) then
        begin
          {adapt level and interval}
          l := n div 10 - 1;
          t := 120 - l*10;
        end;
      end;
      xs := 0;
      ys := 0;
    end;

    {move snake forward by one point}
    for i := n downto 2 do
    begin
      x[i] := x[i-1];
      y[i] := y[i-1];
    end;
    x[1] := xn;
    y[1] := yn;

    {if game was not aborted}
    if d <> 0 then
    begin
      write_pos(x[1],y[1],'�');
      if d < 0 then
      begin
        TextColor(LightRed);
        write_pos(x[1],y[1],'�');
	TextColor(15);
      end;
      if (xs <> 0) AND (d <> -1) then
      begin             
	write_pos(xl,yl,' ');
      end;
    end;

    {if snake has reached a target}
    if xs = 0 then
    begin
      repeat
        xs := random(xmax-xmin+1)+xmin;
        ys := random(ymax-ymin+1)+ymin;
      until point_on_snake(x,y,xs,ys,n) = false;
      write_pos(xs,ys,ss);
    end;

    {show game status at the bottom}
    str(l,lvl);
    str(n,pts);
    if d <> -2 then
    begin
      write_pos(xmin+1,ymax+1,' Player: '+name+' � Level: '+lvl+' � Points: '+pts+' ');
    end;
    delay(t);

  until (d < 1) OR (n = 256);

  {get end time}
  gettime(h2,m2,s2,s100);
  if (h2 <> h1) AND (h2 = 0) then h2 := 24;
  str((h2*3600+m2*60+s2)-(h1*3600+m1*60+s1),sec);

  {case 1: maximum points reached}
  if d > 0 then
  begin
    TextColor(LightGreen);
    write_pos(xmax-26,ymax+1,' MAXIMUM NUMBER OF POINTS ');
  end;
  {case 2: game ended on purpose}
  if d = 0 then
  begin
    TextColor(LightGreen);
    write_pos(xmax-20,ymax+1,' TERMINATED BY USER ');
  end;
  {case 3: snake bites its tail}
  if d = -1 then
  begin
    TextColor(LightRed);
    write_pos(xmax-20,ymax+1,' SNAKE BITES ITSELF ');
  end;
  {case 4: snake moves into wall}
  if d = -2 then
  begin
    TextColor(LightRed);
    write_pos(xmax-20,ymax+1,' SNAKE CRASHES WALL ');
  end;
  readln;


  {4. End Screen}
  textmode(CO80);
  TextColor(15);
  clrscr;
  writeln;
  writeln('>> Congratulations, ',name,'!');
  writeln('>> You were playing on level ',lvl,'.');
  writeln('>> You reached ',pts,' points in total.');
  writeln('>> Your game lasted ',sec,' seconds.');
  readln;

end.																																																	