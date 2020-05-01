//Ця функція створює початкову матрицю 
function[MATRIX] = createMatrix(n) 
rand('seed',9527);
T = rand(n, n)+rand(n, n);
A = floor((1.0 - 2*0.01 - 7*0.005 - 0.15) * T);
MATRIX = A;
endfunction

Matrix = createMatrix(12); // Створення початкової матриці

// Ця функція шукає координати центру вершин
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

// Ця функція знаходить координати (х, у)кола відносно заданих радіусу і куту 
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

// Функція, яка будує вершини для звичайного графа
function buildUsualCircles(coor, n)
  for count = 1:1:n
    x = coor(count, 1);
    y = coor(count, 2);
    xarc(x - 3,y + 3, 6, 6, 0, 360*64);
    xnumb(x - 2, y - 2, count);
  end
endfunction

// Ця функція будує вершини для функції "halt" (будує прості і розфарбовані вершини)
function buildCirclesForHalt(n, activeV, visitV,closeV)
  coor = findCoordinates(n)
  for count = 1:1:n
    x = coor(count, 1);
    y = coor(count, 2);
    if (visitV(1, count) > 0)
      xfarc(x - 3, y + 3, 6, 6, 0, 360*64);
      gce().background = 3;
    elseif (activeV(1, count) > 0)
      xfarc(x - 3, y + 3, 6, 6, 0, 360*64);
      gce().background = 2;
    elseif (closeV(1, count) > 0)
      xfarc(x - 3, y + 3, 6, 6, 0, 360*64);
      gce().background = 5;
    else
    xarc(x - 3,y + 3, 6, 6, 0, 360*64);
    end
    xnumb(x - 2, y - 2, count);
  end
endfunction

// Ця функція будує вершини для дерева обходу
function buildCirclesForTree(coor, n)
  for count = 1:1:n
    x = coor(count, 1);
    y = coor(count, 2);
    xarc(x - 3,y + 3, 6, 6, 0, 360*64);
    xnumb(x - 2, y - 2, count);
    [x1, y1] = find_X_Y(5, coor(count, 3));
    xnumb(x + x1 - 2, y + y1 - 2, listBFS(1,count));
  end
endfunction

// Функція, яка будує петлі
function drawLoop(ip)
  [x, y] = find_X_Y(5, ip(i, 3));
  [x1, y1] = find_X_Y(3.1, ip(i, 3));
  [x2, y2] = find_X_Y(3, ip(i, 3));
  xarc(ip(i,1)+x-2,ip(i,2)+y+2, 4, 4, 0, 360*64);
  xarrows([ip(i,1)+x1,ip(i,1)+x2],[ip(i,2)+y1,ip(i,2)+y2],25,6);
endfunction

// Функція будує звязки від центральної до інших вершин
function drawLinesFromCenter(ip)
  [x, y] = find_X_Y(3, ip(j, 3));
  xarrows([ip(i,1)+x,ip(j,1)-x],[ip(i,2)+y,ip(j,2)-y],25, 6);
endfunction

// Функція будує звязки від вершин до центральної
function drawLinesToCenter(ip)
  [x, y] = find_X_Y(3, ip(i, 3));
  xarrows([ip(i,1)-x,ip(j,1)+x],[ip(i,2)-y,ip(j,2)+y],25, 6);
endfunction


// Ця функція будує звязки між вершинами (окрім петель та звязків ценральної вершини)
function drawLines(ip, Output, Input)
  [x1, y1] = find_X_Y(3, Output);
  [x2, y2] = find_X_Y(3, Input);
  xarrows([ip(i,1)+x1,ip(j,1)+x2],[ip(i,2)+y1,ip(j,2)+y2],25, 6);
endfunction

// Загальня функція звязків, викликає попередні функції, для побудови усіх звязків
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

// Функція, яка створює в графічному вікні пояснення кольорів вершин(для нової, відвіданої, активної, закритої)
function buildInstruction()
  xfarc(5, 116, 6, 6, 0, 360*64);
  gce().background = 2;
  xstring(12, 110, '- АКТИВНА');
  xarc(5,106, 6, 6, 0, 360*64);
  xstring(12, 100, '- НОВА');
  xfarc(50, 116, 6, 6, 0, 360*64);
  gce().background = 5;
  xstring(57, 110, '- ЗАКРИТА');
  xfarc(50, 106, 6, 6, 0, 360*64);
  gce().background = 3;
  xstring(57, 100, '- ВІДВІДАНА');  
endfunction

// Функція, яка будує граф в графічному вікні
function main(n, Matrix, Reason)
  plot2d([0;100], [0;100], 0);
  coordinates = findCoordinates(n);
  if (Reason == 'Tree') then
    buildCirclesForTree(coordinates, n);
  elseif (Reason == 'Usual')
    buildUsualCircles(coordinates, n);
  elseif (Reason == 'For Halt')
    buildInstruction();
  end    
  buildLines(Matrix, n, coordinates);
endfunction

// ОСНОВНА ФУНКЦІЯ ДАНОЇ ЛАБОРАТОРНОЇ
function [ListBFS,matrixTree] = BFS(Graph, startVert, n)
  activeV = zeros(1, n);
  visitV = zeros(1, n);
  closeV = zeros(1, n);
  matrixTree = zeros(n, n);
  matrixBFS = zeros(1,n);
  matrixBFS(1, startVert) = 1;
  activeV(1,startVert) = startVert;
  main(12, Matrix, 'For Halt');
  buildCirclesForHalt(n, activeV, visitV, closeV);
  halt('Press enter to continue');
  queue = [startVert];
  indexQueue = 1;
  k = 1;
  while (queue(1,1) ~= 0); 
    v = queue(1, 1);
    activeV(1, v) = v;
    visitV(1, v) = 0;
    if (closeV(1 ,v) == v)
      close(1, v) = 0; 
    end
    for u = 1:n
      if (Graph(v, u) == 1 && matrixBFS(1,u) == 0 && v~=u)
        k = k + 1;
        matrixBFS(1, u) = k;
        visitV(1, u) = u;
        main(12, Matrix, 'For Halt');
        buildCirclesForHalt(n, activeV, visitV, closeV);
        halt('Press enter to continue');
        indexQueue = indexQueue + 1;
        queue(1, indexQueue) = u;
        matrixTree(v, u) = 1; 
      end
      if (u == n)
        copyQueue = queue;
        numEnd = size(queue)(1, 2) - 1;
        for count = 1:numEnd
          queue(1, count) = copyQueue(1, (count + 1))
        end
        queue(1, (numEnd + 1)) = 0;
        indexQueue = indexQueue - 1;
        activeV(1, v) = 0;
        closeV(1, v) = v;
      end    
    end
    if (queue(1,1) == 0)
      for num = 1:n
        if (matrixBFS(1,num) == 0)
          k = k + 1;
          matrixBFS(1, num) = k;
          activeV(1, num) = num
          queue = [num];
          indexQueue = 1;
          main(12, Matrix, 'For Halt');
          buildCirclesForHalt(n, activeV, visitV, closeV);
          halt('Press enter to continue');
          break;
        end 
      end
    end
  end
  disp(matrixBFS);
  ListBFS = matrixBFS;
endfunction

disp(Matrix, 'Початкова матриця'); // Вивожу в консоль початкову матрицю
main(12, Matrix, 'Usual'); // Будую початковий граф
xstring(10, 90, 'Початковий граф'); 

halt('close graphic window and press enter to lauch function BFS');
// виклик функції BFS і одержання матриці дерева обходу та списку нової номерації вершин
[listBFS, matrixTree] = BFS(Matrix, 1, 12);

// функція для створення матриці відповідності вершин
function Matrix = createMatchingMatrix(finiteM, n);
    Matrix = [];
    for i = 1:n
      Matrix(i,finiteM(1,i)) = 1;
    end
endfunction

MatchingMatrix = createMatchingMatrix(listBFS, 12);

halt('press enter to watch (матриця відповідності вершин і одержаної нумерації) ');
disp(MatchingMatrix); // Матриця відповідності вершин 

halt('press enter to watch tree matrix');
disp(matrixTree);   // Матриця дерева обходу

halt('close graphic window and press enter to watch the tree');
main(12, matrixTree, 'Tree');  // Побудова дерева обходу


