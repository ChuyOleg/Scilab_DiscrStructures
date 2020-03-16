plot2d([0;100], [0;100], 0);

function[MATRIX] = createMatrix(n) 
rand('seed',9527);
T = rand(n, n)+rand(n, n);
//A = floor((1.0 - 2*0.02 - 7*0.005 - 0.25)*T);
A = floor((1.0 - 2*0.01 - 7*0.01 - 0.3) * T);
B = A';
C = bool2s(A + B);
MATRIX = A;
endfunction


function[Coordinates] =  findCoordinates(n)
  Coordinates = [50, 50];
  counter = 2;
  step = 360 / (n - 1);
  for corner = 0:step:360
  extra = 180 / corner;
  x = 30 * cos(%pi / extra);
  if (corner < 180)
    y = sqrt(900 - x^2);
  else
    y = -sqrt(900 - x^2);
  end   
  Coordinates(counter, 1) = x + 50;
  Coordinates(counter, 2) = y + 50;
  Coordinates(counter, 3) = corner;
  counter = counter + 1;
  end
endfunction 


function buildCircles(matrix, n)
  for count = 1:1:n
    x = matrix(count, 1);
    y = matrix(count, 2);
    xarc(x - 3,y + 3, 6, 6, 0, 360*64);
    xnumb(x - 2, y - 2, count);
  end
endfunction


function [x, y] = find_X_Y(radius, corner)
  extra = 180 / corner;
  angle = %pi / extra;
  x = radius * cos(angle);
  if (angle > 0 && angle < %pi);
    y = sqrt(radius^2 - x^2);
  else
    y = -sqrt(radius^2 - x^2);
  end
endfunction

function drawLoop(ip)
  [x, y] = find_X_Y(5, ip(i, 3));
  [x1, y1] = find_X_Y(3.1, ip(i, 3));
  [x2, y2] = find_X_Y(3, ip(i, 3));
  xarc(ip(i,1)+x-2,ip(i,2)+y+2, 4, 4, 0, 360*64);
  xarrows([ip(i,1)+x1,ip(i,1)+x2],[ip(i,2)+y1,ip(i,2)+y2],25,6);
endfunction

function drawLinesFromCenter(ip)
  [x, y] = find_X_Y(3, ip(j, 3));
  xarrows([ip(i,1)+x,ip(j,1)-x],[ip(i,2)+y,ip(j,2)-y],25, 6);
endfunction

function drawLinesToCenter(ip)
  [x, y] = find_X_Y(3, ip(i, 3));
  xarrows([ip(i,1)-x,ip(j,1)+x],[ip(i,2)-y,ip(j,2)+y],25, 6);
endfunction

function drawLines(ip, Output, Input)
  [x1, y1] = find_X_Y(3, Output);
  [x2, y2] = find_X_Y(3, Input);
  xarrows([ip(i,1)+x1,ip(j,1)+x2],[ip(i,2)+y1,ip(j,2)+y2],25, 6);
endfunction

function buildLines(Matrix, n, ip)
  mainExtraCorner = 180 / (n - 3); 
  extraCorner1 = 0;
  extraCorner2 = 0;
  for i = 1:n
    cornerOutput = 90 + extraCorner1 - 2*mainExtraCorner - 14
    cornerInput = -90 + extraCorner1 - 2*mainExtraCorner - 14
    cornerOutput2 = -90 + extraCorner2 + mainExtraCorner;
    cornerInput2 = 90 + extraCorner2 - mainExtraCorner - 10;
    for j = 1:n
      if (Matrix(i, j) == 1)
        if (i == j)
          drawLoop(ip);  
        elseif (i == 1)
          drawLinesFromCenter(ip);
        elseif (j == 1)
          drawLinesToCenter(ip);
        elseif (j > i)
          drawLines(ip, cornerOutput, cornerInput);
        elseif (i > j);
          drawLines(ip, cornerOutput2, cornerInput2);
        end
      end
      cornerOutput = cornerOutput + mainExtraCorner;
      cornerInput = cornerInput + mainExtraCorner;
      cornerOutput2 = cornerOutput2 + mainExtraCorner;
      cornerInput2 = cornerInput2 + mainExtraCorner;
    end
    extraCorner1 = extraCorner1 + 10;
    extraCorner2 =  extraCorner2 + 10;
  end
endfunction


function main(n)
  Matrix = createMatrix(n);
  coordinates = findCoordinates(n);
  buildCircles(coordinates, n);
  buildLines(Matrix, n, coordinates);
endfunction

main(12);
