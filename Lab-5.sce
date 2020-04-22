
blue = color(0,0,205);
green = color(0,205,0);
orange = color(255,140,0);
red = color(208,0,0);

// Створення матриці суміжності ненапрямленого графа і матриці ваг
function[MATRIX1, MATRIX2] = createMatrix(n) 
  rand('seed',9527);
  T = rand(n, n)+rand(n, n);
  A = floor((1.0 - 2*0.01 - 7*0.005 - 0.05) * T);
  B = A';
  C = bool2s(A + B);
  W1 = round(rand(n,n)*100 .* A);
  B = W1 & ones(n, n);
  W1 = (bool2s(B&~B')+bool2s(B&B').*tril(ones(n,n),-1)).*W1;
  W = W1 + W1';
  MATRIX1 = C;
  MATRIX2 = W;
endfunction
[usualMatrix, lengthMatrix] = createMatrix(12);
halt('press enter to see matrix');
disp(usualMatrix, 'Матриця суміжності ненапрямленого графа');
disp(lengthMatrix, 'Матриця ваг');

// Пошук координат
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

// Будує вершини
function buildCircles(coordinates, n, reason, ListVert)
  for count = 1:1:n
    x = coordinates(count, 1);
    y = coordinates(count, 2);
    xarc(x - 3,y + 3, 6, 6, 0, 360*64);
    if (reason == 'Sceleton' && count < n && ListVert(count,1) > 0)
      xColour1 = coordinates(ListVert(count,1),1);
      yColour1 = coordinates(ListVert(count,1),2);
      xColour2 = coordinates(ListVert(count,2),1);
      yColour2 = coordinates(ListVert(count,2),2);
      xfarc(xColour1 - 3, yColour1 + 3, 6, 6, 0, 360*64);
      gce().background = blue;
      xfarc(xColour2 - 3, yColour2 + 3, 6, 6, 0, 360*64);
      gce().background = blue;
      xnumb(xColour1 - 2, yColour1 - 2, ListVert(count,1));
      xnumb(xColour2 - 2, yColour2 - 2, ListVert(count,2));
    end
    xnumb(x - 2, y - 2, count);
  end
endfunction

// Шукає координати х,у за заданим кутом
function [x, y] = find_X_Y(radius, corner)
  extra = 180 / corner;
  x = radius * cos(%pi / extra);
  if corner < 180
    y = sqrt(radius^2 - x^2);
  else
    y = -sqrt(radius^2 - x^2);
  end
endfunction

// Будує петлі
function drawLoop(ip)
  [x, y] = find_X_Y(5, ip(i, 3));
  xarc(ip(i,1)+x-2,ip(i,2)+y+2, 4, 4, 0, 360*64);
endfunction

// Малює ваги ребер
function drawNumbers(x1, x2, y1, y2)
  xMid = (x1 + x2) / 2;
  yMid = (y1 + y2) / 2;
  xnumb(xMid, yMid, lengthMatrix(i ,j));
endfunction

// Будує ребра з центральної вершини
function drawLinesFromCenter(ip, n, reason, ListVert)
  [x, y] = find_X_Y(3, ip(j, 3));
    x1 = ip(i,1)+x;
    x2 = ip(j,1)-x;
    y1 = ip(i,2)+y;
    y2 = ip(j,2)-y;
    position = find(ListVert(:, 2) == j);
    position2 = find(ListVert(:, 2) == i);
  if (find(ListVert == j) == []) then  
    if (find(ListVert == i) == [])
      xsegs([x1,x2],[y1,y2], green);
      if (reason == 'Tree')
        drawNumbers(x1, x2, y1, y2);
      end
    else
      xsegs([x1,x2],[y1,y2], orange);
      drawNumbers(x1, x2, y1, y2);
    end 
  elseif (ListVert(position, 1) == 1); 
    xsegs([x1,x2],[y1,y2], blue);
  elseif (find(ListVert == i) == [])
    xsegs([x1,x2],[y1,y2], orange);
    drawNumbers(x1, x2, y1, y2);
  elseif (ListVert(position2, 1) ~= j);
    xsegs([x1,x2],[y1,y2], green);
  end
endfunction

// Будує ребра до центральної вершини
function drawLinesToCenter(ip, n, reason, ListVert)
  [x, y] = find_X_Y(3, ip(i, 3));
  x1 = ip(i,1)-x;
  x2 = ip(j,1)+x;
  y1 = ip(i,2)-y;
  y2 = ip(j,2)+y;
  position = find(ListVert(:, 2) == j);
  position2 = find(ListVert(:, 2) == i);
  if (find(ListVert == i) == []) then
    if (find(ListVert == j) == [])
      xsegs([x1, x2],[y1, y2], green);
      if (reason == 'Tree')
        drawNumbers(x1, x2, y1, y2);
      end
    else
      xsegs([x1, x2],[y1, y2], orange);
      drawNumbers(x1, x2, y1, y2);
    end
  elseif (ListVert(position,1) == i)
    xsegs([x1, x2],[y1, y2], blue);
  elseif (find(ListVert == j) == [])
    xsegs([x1, x2],[y1, y2], orange);
    drawNumbers(x1, x2, y1, y2);
  elseif (ListVert(position2,1) ~= j)
    xsegs([x1, x2],[y1, y2], green);
  end
endfunction

// Будує ребра (окрім ребер, які стосуються центральної вершини)
function drawLines(ip, n, reason, ListVert)
  [X1, Y1] = find_X_Y(3, ip(i, 3));
  [X2, Y2] = find_X_Y(3, ip(j, 3));
  x1 = ip(i,1)-X1;
  x2 = ip(j,1)-X2;
  y1 = ip(i,2)-Y1;
  y2 = ip(j,2)-Y2;
  position = find(ListVert(:, 2) == j);
  position2 = find(ListVert(:, 2) == i);
  if (find(ListVert == j) == []) then
    if (find(ListVert == i) == [])
      xsegs([x1,x2],[y1,y2], green);
      if (reason == 'Tree')
        drawNumbers(x1, x2, y1, y2);
      end
    else
      xsegs([x1,x2],[y1,y2], orange);
      drawNumbers(x1, x2, y1, y2);
    end
  elseif (ListVert(position, 1) == i); 
    xsegs([x1,x2],[y1,y2], blue);
  elseif (find(ListVert == i) == [])
    xsegs([x1,x2],[y1,y2], orange);
    drawNumbers(x1, x2, y1, y2);
  elseif (ListVert(position2, 1) ~= j)
    xsegs([x1,x2],[y1,y2], green);
  end
endfunction

// Запускає попередні функції для побудови ребер
function buildLines(Matrix, n, ip, reason, ListVert)
  for i = 1:n
    for j = 1:n
      if (Matrix(i, j) == 1)
        if (i == j)
          drawLoop(ip);
        elseif (i == 1)
          drawLinesFromCenter(ip, n, reason, ListVert);
        elseif (j == 1)
          drawLinesToCenter(ip, n, reason, ListVert);
        else
          drawLines(ip, n, reason, ListVert);
        end
      end
    end
  end
endfunction

// Будує інструкцію в графічному вікні
function buildInstruction()
  xfarc(5, 116, 6, 6, 0, 360*64);
  gce().background = blue;
  xstring(12, 110, ' ВЕРШИНА КІСТЯКА');
  xsegs([5,20],[106,106], green);
  xstring(22, 104, ' ЗВИЧАЙНЕ РЕБРО ГРАФА');
  xsegs([5,20],[98,98], orange);
  xstring(22, 96, ' РЕБРО КАНДИДАТ');
  xsegs([5,20],[90,90], blue);
  xstring(22, 87, ' РЕБРО, ЯКЕ ВХОДИТЬ ДО КІСТЯКА'); 
endfunction

// Будує граф (кістяк або звичайний)
function main(n, reason)
  plot2d([0;100], [0;100], 0);
  if (reason == 'Tree') then
    Matrix = createTreeMatrix(ListForMatrixTree, 12);
    xstring(45, 90, 'КІСТЯК');
  elseif (reason == 'Usual')
    [Matrix, LengthMatrix] = createMatrix(n);  
  end
  coordinates = findCoordinates(n);
  if (reason == 'Tree') then
  buildCircles(coordinates, n, 'Tree', []);
  buildLines(Matrix, n, coordinates, 'Tree', []);
  elseif (reason == 'Usual')
  buildCircles(coordinates, n, 'Usual', []);
  buildLines(Matrix, n, coordinates, 'Usual', []);
  xstring(40, 90, 'ПОЧАТКОВИЙ ГРАФ');
  end
endfunction;

// Будує граф (під час знаходження кістяка)
function mainForSceleton(n, ListVert)
  plot2d([0;100], [0;100], 0);
  buildInstruction();
  [Matrix, LengthMatrix] = createMatrix(n);
  coordinates = findCoordinates(n);
  buildCircles(coordinates,n,'Sceleton',ListVert);
  buildLines(Matrix, n, coordinates, 'Sceleton', ListVert);
endfunction

// Пошку кістяка
function ListVert = Sceleton(mGraph,mWeight, startVert,n)
  ListVert = zeros((n - 1), 2);
  point = 1;
  setVertex = [startVert];
  totalWeight = 0;
  count = 2;
  while (size(setVertex)(1,2) < n)
    sizeOfSetV = size(setVertex)(1, 2);
    minValue = [1000, 1, 1];
    for i = 1:sizeOfSetV;
      for j = 1:n
        cond1 = mGraph(setVertex(1,i),j);
        cond2 = mWeight(setVertex(1,i),j);
        if ((find(setVertex == j) == []) && (cond1 == 1) && (cond2 < minValue(1,1)));
          minValue = [cond2, setVertex(1,i), j];
        end
      end
    end
    if (find(setVertex == minValue(1,3)) == [])
      setVertex(1,count) = minValue(1,3);
      count = count + 1;
      ListVert(point, 1) = minValue(1,2);
      ListVert(point, 2) = minValue(1,3);
      point = point + 1;
      totalWeight = totalWeight + minValue(1,1);
      mainForSceleton(12, ListVert);
      disp(ListVert, 'Список');
      halt('close graphic window and press enter to continue');
    else
      for k = 1:n
        if (find(setVertex == k) == [])
          setVertex(1,count) = k;
          count = count + 1;
          ListVert(point, 1) = minValue(1,2);
          ListVert(point, 2) = minValue(1,3);
          point = point + 1;
        end
      end    
    end
  end
  disp(totalWeight, 'Total weight is');
endfunction

// Створення матриці кістяка
function MATRIX = createTreeMatrix(ListForSceleton, n)
  MATRIX = zeros(n, n);
  for i = 1:(n - 1)
    vert1 = ListForSceleton(i, 1);
    vert2 = ListForSceleton(i, 2);
    MATRIX(vert1, vert2) = 1;
  end
endfunction

halt('press enter to watch initial graph');
main(12, 'Usual');

halt('press enter to launch : пошук кістяка');
ListForMatrixTree = Sceleton(usualMatrix, lengthMatrix, 1, 12);
disp(ListForMatrixTree);

halt('press enter to watch tree matrix');
TreeMatrix = createTreeMatrix(ListForMatrixTree, 12);
disp(TreeMatrix, 'Матриця кістяка графу');

halt('press enter to watch tree');
main(12, 'Tree');




