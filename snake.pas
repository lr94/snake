    program snake;
          uses crt;
          const compiler='fpc'; (* 'fpc' or 'turbo' *)
                s_width=80;
                s_heigth=24;
                time=100;
                start_length=10;
                version='1.6';
                cibo_buono_cicli=50;
          var serpente:array[0..s_width*s_heigth,0..1] of integer;
              table:array[1..s_width,2..s_heigth] of integer;
              len,punti,cibo_x,cibo_y,cibo_buono_c,cibo_buono_x,cibo_buono_y:integer;
              cibo_buono,cibo_buono_lampeggio_on:boolean;
              direzione,key:char;
              exit_s,punti_s:string;

       procedure sleep(t:integer);
       begin
          if compiler='fpc' then delay(t);
          if compiler='turbo' then delay(t*100);
       end;
       procedure locate(x:integer;y:integer;c:char);
       begin
          gotoxy(x,y);
          write(c);
          gotoxy(1,1);
       end;
       procedure cwrite(cmd:string);
          var j,cn,lnd:integer;
              ch:char;
              buf:string;
       begin
          buf:='';
          cn:=1;
          lnd:=0;
          for j:=1 to length(cmd) do begin
             ch:=cmd[j];
             if ch='\' then begin
                cn:=cn+1;
             end;
          end;
          for j:=1 to length(cmd) do begin
             ch:=cmd[j];
             if ch='\' then begin
                gotoxy(trunc((s_width-length(buf))/2),trunc((s_heigth-cn)/2)+lnd);
                write(buf);
                buf:='';
                lnd:=lnd+1;
             end
             else buf:=concat(buf,ch);

          end;
          gotoxy(1,1);
          
       end;

       function adatta(n:integer;t:char):integer;
       begin
          if t='x' then begin
             if n=(s_width+1) then n:=1;
             if n=0 then n:=s_width;
          end;
          if t='y' then begin
             if n=s_heigth+1 then n:=2;
             if n=1 then n:=s_heigth;
          end;
          adatta:=n;
       end;

       procedure prepara;
          var i,j:integer;
       begin
          cibo_buono:=false;
          randomize;
          punti:=0;
          len:=0;
          for i:=1 to s_width do
             for j:=2 to s_heigth do table[i,j]:=0;
       end;
       procedure gameover;
       begin
          gotoxy(trunc((s_width-11)/2),1);
          write('-GAME OVER-');
          gotoxy(1,1);
          sleep(1500);
          exit_s:='gameover';
          key:='q';
       end;

       procedure crea_serpente;
          var i,te:integer;
       begin
          te:=start_length+1;
          for i:=0 to start_length do begin
             serpente[i,0]:=te-i;
             serpente[i,1]:=trunc(s_heigth/2);
             table[te-i,trunc(s_heigth/2)]:=-1;
             len:=i;
          end;
       end;
       procedure aggiungi_pezzo_serpente;
       begin
          len:=len+1;
          serpente[len,0]:=2*serpente[len-1,0]-serpente[len-2,0];
          serpente[len,1]:=2*serpente[len-1,1]-serpente[len-2,1];
          table[serpente[len,0],serpente[len,1]]:=-1;
       end;
       procedure disegna_serpente;
          var i:integer;
       begin
          clrscr;
          for i:=0 to len do begin
             if i=0 then begin
                if direzione='H' then locate(serpente[i,0],serpente[i,1],'A');
                if direzione='P' then locate(serpente[i,0],serpente[i,1],'V');
                if direzione='M' then locate(serpente[i,0],serpente[i,1],'>');
                if direzione='K' then locate(serpente[i,0],serpente[i,1],'<');
             end;
             if i=len then begin
                if serpente[i,0]=serpente[i-1,0] then locate(serpente[i,0],serpente[i,1],'|');
                if serpente[i,1]=serpente[i-1,1] then locate(serpente[i,0],serpente[i,1],'-');
             end;
             if (i>0) and (i<len) then begin
                if serpente[i+1,0]=serpente[i-1,0] then locate(serpente[i,0],serpente[i,1],'|');
                if serpente[i+1,1]=serpente[i-1,1] then locate(serpente[i,0],serpente[i,1],'-');
                if (serpente[i+1,0]<>serpente[i-1,0]) and (serpente[i+1,1]<>serpente[i-1,1]) then
                   locate(serpente[i,0],serpente[i,1],'-');
             end;
          end;
       end;
       procedure crea_cibo_buono;
          var cb_x,cb_y:integer;
       begin
          repeat
             cb_x:=abs(random(s_width-6))+3;
             cb_y:=abs(random(s_heigth-6))+3;
          until table[cb_x,cb_y]=0;
          table[cb_x,cb_y]:=2;
          cibo_buono:=true;
          cibo_buono_lampeggio_on:=true;
          cibo_buono_c:=cibo_buono_cicli; (* cicli rimanenti per mangiare il cibo buono *)
          cibo_buono_x:=cb_x;
          cibo_buono_y:=cb_y;
       end;
       procedure crea_cibo;
       begin
          repeat
             cibo_x:=abs(random(s_width-6))+3;
             cibo_y:=abs(random(s_heigth-6))+3;
          until table[cibo_x,cibo_y]<>-1;
          table[cibo_x,cibo_y]:=1;
          if (trunc(punti/9) mod 5=0) and (punti<>0) then begin (* se dobbiamo creare il cibo buono *)
             crea_cibo_buono;
          end;
       end;
       procedure disegna_cibo; (* disegno anche il cibo buono *)
       begin
          locate(cibo_x,cibo_y,'*');
          if cibo_buono and cibo_buono_lampeggio_on then begin
             locate(cibo_buono_x,cibo_buono_y,'@');
          end;
       end;

       procedure slitta_array_serpente(new_x:integer;new_y:integer);
          var i:integer;
          var temp:array[0..s_width*s_heigth,0..1] of integer;
       begin
          for i:=1 to len do begin
             temp[i,0]:=serpente[i-1,0];
             temp[i,1]:=serpente[i-1,1];
          end;
          for i:=1 to len do begin
             serpente[i,0]:=temp[i,0];
             serpente[i,1]:=temp[i,1];
          end;
          serpente[0,0]:=new_x;
          serpente[0,1]:=new_y;
       end;
       procedure sposta_serpente(dir:char);
          var cx,cy,ox,oy:integer;
       begin
          ox:=serpente[len,0];
          oy:=serpente[len,1];
                    cx:=0;
                    cy:=0;
          if dir='H' then cy:=-1;
          if dir='P' then cy:=1;
          if dir='M' then cx:=1;
          if dir='K' then cx:=-1;
          cx:=cx+serpente[0,0];
          cy:=cy+serpente[0,1];
          cx:=adatta(cx,'x');
          cy:=adatta(cy,'y');
          if table[cx,cy]<>-1 then begin
             slitta_array_serpente(cx,cy);
             table[cx,cy]:=-1;
             table[ox,oy]:=0;
             (* col cibo è inutile eliminare il pezzo dalla table dato che ci pensa il serpente spostandosi *)
             if (cibo_x=cx) and (cibo_y=cy) then begin
                aggiungi_pezzo_serpente;
                punti:=punti+9; (* Aumento di 9 punti *)
                crea_cibo;
             end;
             if (cibo_buono_x=cx) and (cibo_buono_y=cy) then begin
                punti:=punti+trunc(400/cibo_buono_cicli*cibo_buono_c); (* Aumento di 400 punti in prop *)
                cibo_buono_x:=-1;
                cibo_buono_y:=-1;
                cibo_buono:=false;   
             end;
          end
          else gameover;
       end;
       procedure scrivi_dati;
       begin
          gotoxy(2,1);
          write('Score: ');
          gotoxy(9,1);
          write(punti);
          gotoxy(1,1);
       end;



       procedure gioco;
       begin
          prepara;

          crea_serpente;
          crea_cibo;

          disegna_serpente;
          disegna_cibo;

          direzione:='M';

          repeat
             if keypressed then begin
                key:=readkey;
                if (key in ['H','P']) and (direzione in ['H','P']) then key:=direzione;(*antiinversione*)
                if (key in ['M','K']) and (direzione in ['M','K']) then key:=direzione;(*di marcia     *)
                if key in ['H','P','M','K'] then direzione:=key;
                if key='p' then begin
                   key:='-';
                   gotoxy(trunc((s_width-7)/2),1);
                   write('-PAUSE-');
                   gotoxy(1,1);
                   repeat
                      if keypressed then key:=readkey
                   until key in ['p','q']
                end;
             end;
             sposta_serpente(direzione);
             if cibo_buono then begin (* trattiamo il cibo buono *)
                cibo_buono_c:=cibo_buono_c-1;
                if cibo_buono_c=0 then begin
                   cibo_buono:=false;
                   table[cibo_buono_x,cibo_buono_y]:=0;
                   cibo_buono_x:=-1;
                   cibo_buono_y:=-1;
                end;
                if (cibo_buono_c>0) and (cibo_buono_c<=15) then begin
                   cibo_buono_lampeggio_on:=not cibo_buono_lampeggio_on;
                end;
             end;
             disegna_serpente;
             disegna_cibo;
             scrivi_dati;
             sleep(time);
          until key='q';
       end;

       procedure info;
          var i:string;
       begin
          i:='';
          clrscr;
          
          i:=concat(i,'SNAKE\');
          i:=concat(i,'Version ',version,'\');
          i:=concat(i,'(February 2010)\');
          i:=concat(i,'Created by Luca Robbiano\');
          i:=concat(i,'(2^B 2009-2010     G.D.Cassini)\');
          i:=concat(i,'\');
          i:=concat(i,'This software is distribuited under\');
          i:=concat(i,'MIT License\');
          i:=concat(i,'\Press any key to exit\');
          
          cwrite(i);
          repeat until keypressed;
       end;
       
       begin
          clrscr;
          cwrite(concat('Snake ',version,'\By Luca Robbiano\(press any key to start, Q to exit, I for info)\'));

          repeat until keypressed;
          key:=readkey;

          if not (key in ['q','i']) then gioco;

          if exit_s='gameover' then begin
             clrscr;
             str(punti,punti_s);
             cwrite(concat('GAME OVER\Score: ',punti_s,'\Press any key to exit\'));
             repeat until keypressed;
          end;
          
          if key='i' then info;

          clrscr;
       end.
