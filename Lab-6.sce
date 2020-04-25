blue = color(0,0,205);
green = color(0,205,0);
orange = color(255,140,0);
red = color(208,0,0);

// Створює матриці
function[MATRIX1, MATRIX2, MATRIX3] = createMatrix(n) 
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
  MATRIX3 = A;
endfunction
[usualMatrix, lengthMatrix, startMatrix] = createMatrix(12);
halt('press enter to see matrix');
disp(startMatrix, 'Матриця суміжності напрямленого графа');
disp(usualMatrix, 'Матриця суміжності ненапрямленого графа');
disp(lengthMatrix, 'Матриця ваг');

// знаходить координати центру вершин
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
function buildCircles(coordinates, n, reason, List)
  for count = 1:1:n
    x = coordinates(count, 1);
    y = coordinates(count, 2);
    xarc(x - 3,y + 3, 6, 6, 0, 360*64);
    if (reason == 'Roads')
      xColour = coordinates(count, 1);
      yColour = coordinates(count, 2)
      if (List(count,2) == 1)
        xfarc(xColour - 3, yColour + 3, 6, 6, 0, 360*64);
        gce().background = blue;
      elseif (List(count,2) == 0)
        xfarc(xColour - 3, yColour + 3, 6, 6, 0, 360*64);
        gce().background = red;
      end
    end
    xnumb(x - 2, y - 2, count);
  end
endfunction

// знаходить [х, у] вершини за вказаним радіусом
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

// Будує ваги ребер
function drawNumbers(x1, x2, y1, y2)
  xMid = (x1 + x2) / 2;
  yMid = (y1 + y2) / 2;
  xnumb(xMid, yMid, lengthMatrix(i ,j));
endfunction

// Будує ребра з центральної вершини до інших
function drawLinesFromCenter(ip, reason)
  [x, y] = find_X_Y(3, ip(j, 3));
  x1 = ip(i,1)+x;
  x2 = ip(j,1)-x;
  y1 = ip(i,2)+y;
  y2 = ip(j,2)-y;
  xsegs([x1,x2],[y1,y2], green);
  if (reason == 'Usual')
    drawNumbers(x1, x2 ,y1, y2);
  end
endfunction

// Будує ребра з вершин в центральну
function drawLinesToCenter(ip, reason)
  [x, y] = find_X_Y(3, ip(i, 3));
  x1 = ip(i,1)-x;
  x2 = ip(j,1)+x;
  y1 = ip(i,2)-y;
  y2 = ip(j,2)+y;
  xsegs([x1, x2],[y1, y2], green);
  if (reason == 'Usual')
    drawNumbers(x1, x2 ,y1, y2);
  end  
endfunction

// Будує всі ребра, окрім тих, що зв`язують центральну
function drawLines(ip, reason)
  [X1, Y1] = find_X_Y(3, ip(i, 3));
  [X2, Y2] = find_X_Y(3, ip(j, 3));
  x1 = ip(i,1)-X1;
  x2 = ip(j,1)-X2;
  y1 = ip(i,2)-Y1;
  y2 = ip(j,2)-Y2;
  xsegs([x1,x2],[y1,y2], green);
  if (reason == 'Usual')
    drawNumbers(x1, x2 ,y1, y2);
  end
endfunction

// Викликає попердні функції (будує всі ребра)
function buildLines(Matrix, n, ip, reason)
  for i = 1:n
    for j = 1:n
      if (Matrix(i, j) == 1)
        if (i == j)
          drawLoop(ip);
        elseif (i == 1)
          drawLinesFromCenter(ip, reason);
        elseif (j == 1)
          drawLinesToCenter(ip, reason);
        else
          drawLines(ip, reason);
        end
      end
    end
  end
endfunction

// Виводить пояснення щодо кольорів вершин
function buildInstruction()
  xfarc(5, 116, 6, 6, 0, 360*64);
  gce().background = blue;
  xstring(12, 110, ' ПОСТІЙНА ВЕРШИНА');
  xfarc(5, 106, 6, 6, 0, 360*64);
  gce().background = red;
  xstring(12, 100, ' ТИМЧАСОВА ВЕРШИНА');
endfunction

// Головна функція (запускає всі попердні)
function main(n, reason, List)
  plot2d([0;100], [0;100], 0);
  [Matrix, lengthMatrix, MatrixA] = createMatrix(n);
  coordinates = findCoordinates(n);
  buildCircles(coordinates, n, reason);
  buildLines(Matrix, n, coordinates, reason);
  if (reason == 'Roads') then
    buildInstruction()
  end
endfunction;

halt('press enter to watch initial graph');
main(12, 'Usual', []);

// Пошук найкоротших шляхів
function List = shortRoad(MatrixV, MatrixW, n)
  List = 0;
  activeV = 1;
  status = zeros(n, 3);
  status(1,1) = 0;
  status(1,2) = 1;
  status(1,3) = 0;
  for k = 2:n
    status(k,1) = %inf;
    status(k,2) = 0;
    status(k,3) = 0;
  end
  while (find(status(:,2) == 0) ~= [])
    smallWeight = [%inf, 0];
    for i = 1:n
        Length = status(activeV,1) + MatrixW(activeV,i);
      if (status(i,2) == 0 && MatrixV(activeV,i) == 1 && status(i,1) > Length)
          status(i,1) = Length;
          status(i,3) = activeV;
      end
    end
    for j = 1:n
      if (status(j,2) == 0 && status(j,1) <= smallWeight(1,1))
        smallWeight(1,1) = status(j,1);
        smallWeight(1,2) =  j;
      end
    end
    activeV = smallWeight(1,2);
    status(activeV,2) = 1;
    main(n, 'Roads', status);
    disp(status, 'Номер вершини = номер рядка. Орієнтуватись по 2 колонці: 1 - постійна, 0 - тимчасова');
    halt('press enter to continue');
  end
  List = status;
endfunction

halt('close graphic window and press enter to launch ""Пошук шляхів""');
List = shortRoad(usualMatrix, lengthMatrix, 12);
disp(List, 'Список: 1)довжина шляху 2)стан 3)попередник');

// Пошук списку шляхів
function [roads, Length] = createRoads(List, n)
  roads = list();
  Length = zeros(n,1);
  for k = 1:n
    tempNum = 1;
    tempArr = [];
    count = 2;
    point = k;
    tempArr(1,1) = k;  
    while (point ~= 1 && k ~= 1)
      point = List(point,3);
      tempArr(1,count) = point;
      count = count + 1;
    end
    Size = size(tempArr)(1, 2);
    newArr = zeros(1,Size);
    for q = 1:Size
      newArr(1,(q)) = tempArr(1,(Size - q + 1));
    roads(k) = newArr;
    end
    Length(k,1) = List(k,1);
  end
endfunction

halt('press enter to watch ""Перелік знайдених шляхів та їх довжин""');
[Roads, Length] = createRoads(List, 12);
disp(Roads, 'Список знайдених шляхів');
disp(Length, 'Список довжин шляхів');



