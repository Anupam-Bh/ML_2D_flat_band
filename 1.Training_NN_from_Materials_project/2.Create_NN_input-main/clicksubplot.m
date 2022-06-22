function [num] = clicksubplot
count=1;
num(count)=0;
while 1 == 1
    w = waitforbuttonpress;
      switch w 
          case 1 % keyboard 
              key = get(gcf,'currentcharacter'); 
%               if key==27 % (the Esc key) 
%                   try; delete(h); end
                  break
%               end
          case 0 % mouse click 
              mousept = get(gca,'currentPoint');
              x = mousept(1,1);
              y = mousept(1,2);
              try; delete(h); end
              h = text(x,y,get(gca,'tag'),'vert','middle','horiz','center'); 
              class(get(gca,'tag'));
              num(count)=str2num(get(gca,'tag'));
              count=count+1;
      end
  end