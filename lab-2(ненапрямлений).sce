plot2d([0;100], [0;100], 0);

function[MATRIX] = createMatrix(n) 
rand('seed',9527);
T = rand(n, n)+rand(n, n);
A = floor((1.0 - 2*0.01 - 7*0.01 - 0.3) * T);
B = A';
C = bool2s(A + B);
MATRIX = C;
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
  x = radius * cos(%pi / extra);
  if corner < 180
    y = sqrt(radius^2 - x^2);
  else
    y = -sqrt(radius^2 - x^2);
  end
endfunction

function drawLoop(ip)
  [x, y] = find_X_Y(5, ip(i, 3));
  xarc(ip(i,1)+x-2,ip(i,2)+y+2, 4, 4, 0, 360*64);
endfunction

function drawLinesFromCenter(ip)
  [x, y] = find_X_Y(3, ip(j, 3));
  xsegs([ip(i,1)+x,ip(j,1)-x],[ip(i,2)+y,ip(j,2)-y], 6);
endfunction

function drawLinesToCenter(ip)
  [x, y] = find_X_Y(3, ip(i, 3));
  xsegs([ip(i,1)-x,ip(j,1)+x],[ip(i,2)-y,ip(j,2)+y], 6);  
endfunction

function drawLines(ip)
  [x1, y1] = find_X_Y(3, ip(i, 3));
  [x2, y2] = find_X_Y(3, ip(j, 3));
  xsegs([ip(i,1)-x1,ip(j,1)-x2],[ip(i,2)-y1,ip(j,2)-y2], 6);
endfunction


function buildLines(Matrix, n, ip)
  isolatedVertex = [];
  hangingVertex = [];
  degrees = [];
  count1 = 1;
  count2 = 1;
  for i = 1:n
    degrees(i, 1) = i;
    degr = 0;
    for j = 1:n
      if (Matrix(i, j) == 1)
        if (i == j)
          drawLoop(ip);
          degr = degr + 2;
        elseif (i == 1)
          drawLinesFromCenter(ip);
          degr = degr + 1;
        elseif (j == 1)
          drawLinesToCenter(ip);
          degr = degr + 1;
        else
          drawLines(ip);
          degr = degr + 1;
       end
      end
    end
    degrees(i ,2) = degr;
    if (degr == 0)
      isolatedVertex(count1, 1) = i;
      count1 = count1 + 1;
    end 
    if (degr == 1)
      hangingVertex(count2, 1) = i;
      count2 = count2 + 1;
    end
  end
  disp(degrees, 'Степені вершин ненапрямленого графа');
  disp(hangingVertex, 'Висячі вершини ненапрямленого графа');
  disp(isolatedVertex, 'Ізольовані вершини ненапрямленого графа');
endfunction


function main(n)
  Matrix = createMatrix(n);
  coordinates = findCoordinates(n);
  buildCircles(coordinates, n);
  buildLines(Matrix, n, coordinates);
endfunction;

main(12);
