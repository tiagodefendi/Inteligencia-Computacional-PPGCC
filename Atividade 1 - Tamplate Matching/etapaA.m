% ETAPA A - TEMPLATE MATCHING (FORMAS)

% configuração de ambiente

folder = "./fourShapes/";

circleFolder = folder + "circle/";
squareFolder = folder + "square/";
starFolder = folder + "star/";
triangleFolder = folder + "triangle/";

circleFiles = {dir(circleFolder + "*.png").name};
squareFiles = {dir(squareFolder + "*.png").name};
starFiles   = {dir(starFolder   + "*.png").name};
triangleFiles = {dir(triangleFolder + "*.png").name};

% Definir a semente para reprodutibilidade
rng(3); % Define a seed

% Selecionar 4 imagens aleatórias de cada pasta
randomCircleFiles = circleFiles(randperm(numel(circleFiles), 4));
randomSquareFiles = squareFiles(randperm(numel(squareFiles), 4));
randomStarFiles = starFiles(randperm(numel(starFiles), 4));
randomTriangleFiles = triangleFiles(randperm(numel(triangleFiles), 4));

% Separa a primeira imagem de cada lista como template
templateCircle = im2double(imread(circleFolder + randomCircleFiles{1}));
templateSquare = im2double(imread(squareFolder + randomSquareFiles{1}));
templateStar = im2double(imread(starFolder + randomStarFiles{1}));
templateTriangle = im2double(imread(triangleFolder + randomTriangleFiles{1}));

% Carregar as imagens restantes de cada pasta
circleRemainingFiles = randomCircleFiles(2:4);
squareRemainingFiles = randomSquareFiles(2:4);
starRemainingFiles = randomStarFiles(2:4);
triangleRemainingFiles = randomTriangleFiles(2:4);

remainingCircleImages = cellfun(@(f) im2double(imread(circleFolder + f)), circleRemainingFiles, 'UniformOutput', false);
remainingSquareImages = cellfun(@(f) im2double(imread(squareFolder + f)), squareRemainingFiles, 'UniformOutput', false);
remainingStarImages = cellfun(@(f) im2double(imread(starFolder + f)), starRemainingFiles, 'UniformOutput', false);
remainingTriangleImages = cellfun(@(f) im2double(imread(triangleFolder + f)), triangleRemainingFiles, 'UniformOutput', false);

% Calcule Pearson e Erro Quadrárico Médio entre elas

function stats = calcStats(template, imgs)
    stats = cell(1, numel(imgs));
    for i = 1:numel(imgs)
        r = corr2(template, imgs{i});
        e = immse(template, imgs{i});
        stats{i} = [r, e];
    end
end

fprintf('\n\n===================================================\n');

circleStats = calcStats(templateCircle, remainingCircleImages);
squareStats = calcStats(templateSquare, remainingSquareImages);
starStats = calcStats(templateStar, remainingStarImages);
triangleStats = calcStats(templateTriangle, remainingTriangleImages);

fprintf('\nCircle ->\n'); cellfun(@(s,i) fprintf('Img %d: Pearson=%.4f | MSE=%.4f\n', i, s(1), s(2)), circleStats, num2cell(1:3));
fprintf('\nSquare ->\n'); cellfun(@(s,i) fprintf('Img %d: Pearson=%.4f | MSE=%.4f\n', i, s(1), s(2)), squareStats, num2cell(1:3));
fprintf('\nStar ->\n'); cellfun(@(s,i) fprintf('Img %d: Pearson=%.4f | MSE=%.4f\n', i, s(1), s(2)), starStats, num2cell(1:3));
fprintf('\nTriangle ->\n'); cellfun(@(s,i) fprintf('Img %d: Pearson=%.4f | MSE=%.4f\n', i, s(1), s(2)), triangleStats, num2cell(1:3));

% Utilizando o mesmo "template", selecione três imagens de cada uma das 
% outras três classes. Repita o processo calculando o coeficiente de 
% Pearson e Erro Quadrárico Médio entre elas

function stats = compareClasses(template, classesImgs)
    numClasses = numel(classesImgs);
    stats = cell(1, numClasses);
    for i = 1:numClasses
        stats{i} = calcStats(template, classesImgs{i});
    end
end

classesImgs = {remainingCircleImages, remainingSquareImages, remainingStarImages, remainingTriangleImages};

circleCompare = compareClasses(templateCircle, classesImgs);
squareCompare = compareClasses(templateSquare, classesImgs);
starCompare = compareClasses(templateStar, classesImgs);
triangleCompare = compareClasses(templateTriangle, classesImgs);


fprintf('\n\n===================================================\n');

classes = {circleCompare, squareCompare, starCompare, triangleCompare};
templateNames = {'Circle', 'Square', 'Star', 'Triangle'};

for t = 1:numel(classes)
    fprintf('\nComparação usando Template: %s ->\n', templateNames{t});

    currentClass = classes{t};

    for c = 1:numel(currentClass)
        fprintf('\nClasse %s:\n', templateNames{c});
        results = currentClass{c};

        for img = 1:numel(results)
            s = results{img};
            fprintf('Img %d -> Pearson: %.4f | MSE: %.4f\n', img, s(1), s(2));
        end
    end
end


% Visualizar dados ================

% Matriz
fprintf("\n\n\n==============================================\n");

numTemplates = numel(classes);
numClasses   = numel(classesImgs);
numImages    = 3; % 3 imagens por classe

% Inicializa matrizes para armazenar valores
pearsonMat = zeros(numTemplates, numClasses*numImages);
mseMat     = zeros(numTemplates, numClasses*numImages);

% Preenche as matrizes
for t = 1:numTemplates
    currentClass = classes{t}; % resultados do template t comparado com todas as classes
    for c = 1:numClasses
        results = currentClass{c};       % cell array de vetores [Pearson, MSE]
        vals = cell2mat(results');        % converte para matriz 3x2
        cols = (c-1)*numImages + (1:numImages);
        pearsonMat(t, cols) = vals(:,1)'; % Pearson
        mseMat(t, cols)     = vals(:,2)'; % MSE
    end
end

% Exibir as matrizes numéricas
fprintf('Matriz Pearson (linhas = templates, colunas = imagens de cada classe):\n');
disp(pearsonMat);

fprintf('Matriz MSE (linhas = templates, colunas = imagens de cada classe):\n');
disp(mseMat);

% Opcional: mostrar de forma mais clara com tabela
templateNames = {'Circle','Square','Star','Triangle'};
classNames    = {'Circle','Square','Star','Triangle'};
colLabels = {};
for c = 1:numClasses
    for i = 1:numImages
        colLabels{end+1} = sprintf('%s%d', classNames{c}, i);
    end
end

pearsonTable = array2table(pearsonMat, 'VariableNames', colLabels, 'RowNames', templateNames);
mseTable     = array2table(mseMat, 'VariableNames', colLabels, 'RowNames', templateNames);

disp('Tabela Pearson:');
disp(pearsonTable);

disp('Tabela MSE:');
disp(mseTable);

% HEATMAP
figure('Position',[100 100 1400 700]); % figura maior

% Pearson
subplot(1,2,1);
pcolor([pearsonMat, pearsonMat(:,end); pearsonMat(end,:), pearsonMat(end,end)]); % "preenche" última linha/coluna
shading flat;
colormap(jet);
colorbar;
title('Pearson');
xlabel('Imagens por classe');
ylabel('Templates');

xticks(1:numClasses*numImages);
xticklabels(colLabels);
xtickangle(45);

yticks(1:numTemplates);
yticklabels(templateNames);

set(gca,'YDir','normal'); % corrige a ordem das linhas
axis equal tight;

% MSE
subplot(1,2,2);
pcolor([mseMat, mseMat(:,end); mseMat(end,:), mseMat(end,end)]); % mesma correção
shading flat;
colormap(jet);
colorbar;
title('MSE');
xlabel('Imagens por classe');
ylabel('Templates');

xticks(1:numClasses*numImages);
xticklabels(colLabels);
xtickangle(45);

yticks(1:numTemplates);
yticklabels(templateNames);

set(gca,'YDir','normal'); % corrige a ordem das linhas
axis equal tight;
