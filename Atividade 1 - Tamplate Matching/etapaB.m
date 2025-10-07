% ETAPA B - TEMPLATE MATCHING (FOLHAS)

% Configuração de ambiente
folder = "./folhas/";

capillipesFolder = folder + "Acer_Capillipes/";
monoFolder       = folder + "Acer_Mono/";
opalusFolder     = folder + "Acer_Opalus/";

% Listar arquivos JPG
capillipesFiles = {dir(capillipesFolder + "*.jpg").name};
monoFiles       = {dir(monoFolder + "*.jpg").name};
opalusFiles     = {dir(opalusFolder + "*.jpg").name};

% Definir semente
rng(3);

% Selecionar 4 imagens aleatórias de cada classe
randomCapillipes = capillipesFiles(randperm(numel(capillipesFiles), 4));
randomMono       = monoFiles(randperm(numel(monoFiles), 4));
randomOpalus     = opalusFiles(randperm(numel(opalusFiles), 4));

% Separar template (primeira imagem)
templateCap    = im2double(imread(capillipesFolder + randomCapillipes{1}));
templateMono   = im2double(imread(monoFolder + randomMono{1}));
templateOpalus = im2double(imread(opalusFolder + randomOpalus{1}));

% Carregar restantes
remainingCapImages    = cellfun(@(f) im2double(imread(capillipesFolder + f)), randomCapillipes(2:4), 'UniformOutput', false);
remainingMonoImages   = cellfun(@(f) im2double(imread(monoFolder + f)), randomMono(2:4), 'UniformOutput', false);
remainingOpalusImages = cellfun(@(f) im2double(imread(opalusFolder + f)), randomOpalus(2:4), 'UniformOutput', false);

% Padronizar tamanhos
function paddedImages = padImagesToMaxSize(varargin)
    allImages = {};
    for k = 1:numel(varargin)
        if iscell(varargin{k})
            allImages = [allImages, varargin{k}];
        else
            allImages{end+1} = varargin{k};
        end
    end
    maxHeight = 0; maxWidth = 0;
    for i = 1:numel(allImages)
        [h, w] = size(allImages{i});
        maxHeight = max(maxHeight, h);
        maxWidth  = max(maxWidth, w);
    end
    padImage = @(img) padarray(img, [maxHeight - size(img,1), maxWidth - size(img,2)], 0, 'post');
    paddedImages = cellfun(padImage, allImages, 'UniformOutput', false);
end

allPadded = padImagesToMaxSize(templateCap, remainingCapImages, templateMono, remainingMonoImages, templateOpalus, remainingOpalusImages);

templateCap          = allPadded{1};
remainingCapImages   = allPadded(2:4);
templateMono         = allPadded{5};
remainingMonoImages  = allPadded(6:8);
templateOpalus       = allPadded{9};
remainingOpalusImages = allPadded(10:12);

% Função para calcular Pearson e MSE
function stats = calcStats(template, imgs)
    stats = cell(1, numel(imgs));
    for i = 1:numel(imgs)
        r = corr2(template, imgs{i});
        e = immse(template, imgs{i});
        stats{i} = [r, e];
    end
end

% Função para comparar template com múltiplas classes
function stats = compareClasses(template, classesImgs)
    numClasses = numel(classesImgs);
    stats = cell(1, numClasses);
    for i = 1:numClasses
        stats{i} = calcStats(template, classesImgs{i});
    end
end

% Comparações
classesImgs = {remainingCapImages, remainingMonoImages, remainingOpalusImages};

capCompare   = compareClasses(templateCap, classesImgs);
monoCompare  = compareClasses(templateMono, classesImgs);
opalusCompare = compareClasses(templateOpalus, classesImgs);

classes = {capCompare, monoCompare, opalusCompare};
templateNames = {'Capillipes','Mono','Opalus'};
classNames    = {'Capillipes','Mono','Opalus'};

% Visualização
numTemplates = numel(classes);
numClasses   = numel(classesImgs);
numImages    = 3;

pearsonMat = zeros(numTemplates, numClasses*numImages);
mseMat     = zeros(numTemplates, numClasses*numImages);

for t = 1:numTemplates
    currentClass = classes{t};
    for c = 1:numClasses
        results = currentClass{c};
        vals = cell2mat(results');
        cols = (c-1)*numImages + (1:numImages);
        pearsonMat(t, cols) = vals(:,1)';
        mseMat(t, cols)     = vals(:,2)';
    end
end

% Exibir tabelas
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

% Heatmap gráfico
figure('Position',[100 100 1400 700]);

subplot(1,2,1);
pcolor([pearsonMat, pearsonMat(:,end); pearsonMat(end,:), pearsonMat(end,end)]);
shading flat;
colormap(jet); colorbar;
title('Pearson');
xticks(1:numClasses*numImages); xticklabels(colLabels); xtickangle(45);
yticks(1:numTemplates); yticklabels(templateNames);
set(gca,'YDir','normal'); axis equal tight;

subplot(1,2,2);
pcolor([mseMat, mseMat(:,end); mseMat(end,:), mseMat(end,end)]);
shading flat;
colormap(jet); colorbar;
title('MSE');
xticks(1:numClasses*numImages); xticklabels(colLabels); xtickangle(45);
yticks(1:numTemplates); yticklabels(templateNames);
set(gca,'YDir','normal'); axis equal tight;
