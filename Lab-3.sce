plot2d([0;100], [0;100], 0);

function[MATRIX] = createMatrix(n) 
rand('seed',9527);
T = rand(n, n)+rand(n, n);
A = floor((1.0 - 2*0.005 - 7*0.005 - 0.27) * T);
//B = A';
//C = bool2s(A + B);
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
  degrees = zeros(n, 3);
  count1 = 1;
  count2 = 1;
  for i = 1:n
    cornerOutput = 90 + extraCorner1 - 2*mainExtraCorner - 14
    cornerInput = -90 + extraCorner1 - 2*mainExtraCorner - 14
    cornerOutput2 = -90 + extraCorner2 + mainExtraCorner;
    cornerInput2 = 90 + extraCorner2 - mainExtraCorner - 10;
    degrees(i, 1) = i;
    degr1 = 0;
    for j = 1:n
      degr2 = 0;
      if (Matrix(i, j) == 1)
        degr1 = degr1 + 1;
        degr2 = degr2 - 1;
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
      degrees(j, 3) = degrees(j, 3) + degr2;
    end
    extraCorner1 = extraCorner1 + 10;
    extraCorner2 =  extraCorner2 + 10;
    degrees(i, 2) = degrees(i, 2) + degr1;
  end
  disp(degrees, 'Напівстепені вершин напрямленого графа');
endfunction


//  ФУНКЦІЯ, ДЛЯ СТВОРЕННЯ МАТРИЦІ ПЕВНОГО СТЕПЕНЯ
function Matrix = degreeMatrix(n, Degree)
  m = createMatrix(n);
  Matrix = m^Degree;
endfunction;

// ПОШУК УСІХ ШЛЯХІВ ДОВЖИНОЮ 2
function roads = findRoadsLength2(n)
    A = degreeMatrix(n, 1);
    B = degreeMatrix(n, 2);
    roads = [];
    count = 1;
    for i = 1:n
      for j= 1:n
        if (B(i,j) > 0)
          for k = 1:n
            if (A(k,j) == 1 && A(i,k) == 1)
              if (i == j && i == k && j == k)
                continue
              end    
              roads(count,1) = i;
              roads(count,2) = k;
              roads(count,3) = j;
              count = count + 1;
            end         
          end
        end
      end 
    end
    disp(roads);
endfunction

// ПОШУК УСІХ ШЛЯХІВ ДОВЖИНОЮ 3
function roads = findRoadsLength3(n)
    A = degreeMatrix(n, 1);
    B = degreeMatrix(n, 2);
    C = degreeMatrix(n, 3);
    roads = [];
    count = 1;
    for i = 1:n
      for j= 1:n
        if (C(i,j) > 0)
          for k = 1:n
            if (A(k,j) > 0 && B(i,k) > 0)
              for q = 1:n
                if (A(q,k) == 1 && A(i,q) == 1)
                  if (((i == q || j == q) && (i == k || j ==                   k) && q == k) || (i == k && q == j));
                    continue   
                  end
                  roads(count,1) = i;
                  roads(count,2) = q;
                  roads(count,3) = k;
                  roads(count,4) = j;
                  count = count + 1;
                end              
              end
            end         
          end
        end
      end 
    end
    disp(roads);
endfunction

// СТВОРЕННЯ МАТРИЦІ ДОСЯЖНОСТІ
function Matrix = reachAbilityMatrix(n)
  res = eye(n, n);
  for x = 1:n-1;
    extra = degreeMatrix(n, x);
    res = res + extra;
  end
  for i = 1:n
    for j = 1:n
      if (res(i,j) > 1)
        res(i,j) = 1
      end
    end
  end
  Matrix = res;
endfunction

//  СТВОРЕННЯ МАТРИЦІ СИЛЬНОЇ ЗВЯЗНОСТІ
function Matrix = strongLinkMatrix(n)
  matr = reachAbilityMatrix(n);
  matr2 = matr';
  Matrix = matr .* matr2;
endfunction


// ПОШУК КОМПОНЕНТІВ СИЛЬНОЇ ЗВЯЗНОСТІ
function components = findStrongComponents(n)
  components = list();
  rubbish = [];
  num = 1;
  count = 1;
  matr = strongLinkMatrix(n);
  for q = 1:n
    vect = [];
    point = 3;
    row1 = matr(q,:);
    for i = (q+1):n
      row2 = matr(i,:);
      if (row1 == row2 && (find(rubbish==i) == []))
        if (vect == [])
          vect(1,:) = [q,i]
          rubbish(1,num) = q;
          rubbish(1,(num + 1)) = i;
        else
          vect(1,point) = i;
          point = point + 1;
          rubbish(1,num) = i;
          num = num + 1;
        end
      end    
    end
    if (vect(1,1) >= 1)
      components(count) = vect;
      count = count + 1;
    elseif (find(rubbish==q) == [])
      components(count) = q;
      count = count + 1;
      rubbish(1,num) = q;
      num = num + 1;
    end
  end
endfunction


// Допоміжна функція, шукає до якої компоненти належить задане число, ця функція використовується в findMatrixCondensat   
function number = findNumInComponent(component, num)
    number = 100;
    for i = 1:size(component)
      if (find(component(i)==num))
      number = i;
      end
    end
endfunction    
    

function matrixCondensat = findMatrixCondensat(n)
  basicM = createMatrix(n)
  components = findStrongComponents(n);
  sizeCondensat = size(components);
  matrixCondensat = zeros(sizeCondensat,sizeCondensat);
  for i = 1:sizeCondensat
    for j = 1:n
        parts = components(i);
        sizeParts = size(parts)(2);
        while(sizeParts > 0)
          if (basicM(parts(sizeParts),j) == 1 )
            newNumForPoint=findNumInComponent(components, j);
            if (i ~= newNumForPoint)
            matrixCondensat(i,newNumForPoint) = 1;
            end
          end
          sizeParts = sizeParts - 1;
        end  
      end    
    end    
endfunction

    
function main(n)
  Matrix = createMatrix(n);
  coordinates = findCoordinates(n);
  buildCircles(coordinates, n);
  buildLines(Matrix, n, coordinates);
endfunction


//main(12);
disp(createMatrix(12))
components = findStrongComponents(12);

matrixCondensat = findMatrixCondensat(12);
disp(matrixCondensat);
coordinates = findCoordinates(10);
buildCircles(coordinates,10);
buildLines(matrixCondensat, 10, coordinates);


disp(components, 'Компоненти сильної звязності');
disp(strongLinkMatrix(12), 'Матриця сильної звязності');
disp(reachAbilityMatrix(12), 'Матриця досяжності');
findRoadsLength2(12);
findRoadsLength3(12);


