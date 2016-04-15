function xy = makeLines(numLines,angularNoise,averageAngle,maxLength,screenX,screenY)
% numLines is the number of lines to draw
% angluarNoise is the possible range of angles in radians
% averageAngle is the average angle
% line lengths are distributed randomly from 0 to maxLength
% screenX and screenY are vectors of box to draw the lines in.


dX = screenX(2)-screenX(1);
dY = screenY(2)-screenY(1);

x1 = screenX(1) + round(rand(numLines, 1).*(dX));
y1 = screenY(1) + round(rand(numLines, 1).*(dY));

angles = (2*rand(numLines, 1)-1).*angularNoise/2+averageAngle;
flipVec = (rand(numLines,1)<0.5).*pi;
angles = angles+flipVec;

lengths = rand(numLines, 1).*maxLength;

x2 = x1 + lengths.*cos(angles);
y2 = y1 + lengths.*sin(angles);

for i = 1:length(x1)
    
    if x1(i)<screenX(1)
        y1(i)=y1(i)+(screenX(1)-x1(i))*tan(angles(i));  
        x1(i)=screenX(1);
    end
    
    if x1(i)>screenX(2)
        y1(i)=y1(i)+(screenX(2)-x1(i))*tan(angles(i));  
        x1(i)=screenX(2);
    end
    
    if x2(i)<screenX(1)
        y2(i)=y2(i)+(screenX(1)-x2(i))*tan(angles(i));  
        x2(i)=screenX(1);
    end
    
    if x2(i)>screenX(2)
        y2(i)=y2(i)+(screenX(2)-x2(i))*tan(angles(i));  
        x2(i)=screenX(2);
    end
    
    if y1(i)<screenY(1)
        x1(i)=x1(i)+(screenY(1)-y1(i))/tan(angles(i));  
        y1(i)=screenY(1);
    end
    
    if y2(i)<screenY(1)
       x2(i)=x2(i)+(screenY(1)-y2(i))/tan(angles(i));  
       y2(i)=screenY(1);
    end
    
    if y1(i)>screenY(2)
        x1(i)=x1(i)+(screenY(2)-y1(i))/tan(angles(i));  
        y1(i)=screenY(2);
    end
    
   if y2(i)>screenY(2)
        x2(i)=x2(i)+(screenY(2)-y2(i))/tan(angles(i));  
        y2(i)=screenY(2);
    end
    
end




xrow(1:2:numLines*2) = x1;
xrow(2:2:numLines*2) = x2;
yrow(1:2:numLines*2) = y1;
yrow(2:2:numLines*2) = y2;

% xrow(xrow<screenX(1))=screenX(1);
% xrow(xrow>screenX(2))=screenX(2);
% yrow(yrow<screenY(1))=screenY(1);
% yrow(yrow>screenY(2))=screenY(2);


xy = [xrow;yrow];


end
