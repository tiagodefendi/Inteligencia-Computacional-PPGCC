% ETAPA C - FEATURE MATCHING (FORMAS + FOLHAS)

% Função para extrair features 3x3 (soma de pixels)
function features = extractFeatures3x3Sum(img)
    [h, w] = size(img);
    h_step = floor(h/3); w_step = floor(w/3);
    features = zeros(1,9);
    for i = 1:3
        for j = 1:3
            r_start = (i-1)*h_step + 1;
            c_start = (j-1)*w_step + 1;
            if i==3, r_end = h; else, r_end = i*h_step; end
            if j==3, c_end = w; else, c_end = j*w_step; end
            block = img(r_start:r_end, c_start:c_end);
            features((i-1)*3+j) = sum(block(:));
        end
    end
end

% Função para calcular Pearson e MSE entre vetor de features
function stats = calcStatsFeature(template, imgs)
    stats = cell(1,numel(imgs));
    templateFeat = extractFeatures3x3Sum(template);
    for i = 1:numel(imgs)
        feat = extractFeatures3x3Sum(imgs{i});
        r = corr(templateFeat', feat');  % Pearson
        e = immse(templateFeat, feat);   % MSE
        stats{i} = [r, e];
    end
end

% Função para comparar template com várias classes
function stats = compareClassesFeature(template, classesImgs)
    stats = cell(1,numel(classesImgs));
    for i = 1:numel(classesImgs)
        stats{i} = calcStatsFeature(template, classesImgs{i});
    end
end

% EXEMPLO 1: FORMAS

% Mesma lógica para Shapes
folder = "./fourShapes/";
classesFolders = {folder+"circle/", folder+"square/", folder+"star/", folder+"triangle/"};
classNames = {'Circle','Square','Star','Triangle'};
rng(3);

classesFiles = cellfun(@(f) {dir(f+"*.png").name}, classesFolders, 'UniformOutput', false);
randomFiles = cellfun(@(f) f(randperm(numel(f),4)), classesFiles, 'UniformOutput', false);

templates = cell(1,4); imgsClasses = cell(1,4);
for k=1:4
    templates{k} = im2double(imread(classesFolders{k} + randomFiles{k}{1}));
    remaining = randomFiles{k}(2:4);
    imgsClasses{k} = cellfun(@(f) im2double(imread(classesFolders{k}+f)), remaining, 'UniformOutput', false);
end

classesStats = cell(1,4);
for k=1:4
    classesStats{k} = compareClassesFeature(templates{k}, imgsClasses);
end

numTemplates = numel(classesStats);
numClasses   = numel(imgsClasses);
numImages    = 3;

pearsonMat = zeros(numTemplates,numClasses*numImages);
mseMat     = zeros(numTemplates,numClasses*numImages);

for t=1:numTemplates
    currentClass = classesStats{t};
    for c=1:numClasses
        vals = cell2mat(currentClass{c}');
        cols = (c-1)*numImages + (1:numImages);
        pearsonMat(t,cols) = vals(:,1)';
        mseMat(t,cols)     = vals(:,2)';
    end
end

colLabels = {};
for c=1:numClasses
    for i=1:numImages
        colLabels{end+1} = sprintf('%s%d', classNames{c}, i);
    end
end

pearsonTable = array2table(pearsonMat,'VariableNames',colLabels,'RowNames',classNames);
mseTable     = array2table(mseMat,'VariableNames',colLabels,'RowNames',classNames);

disp('Tabela Pearson (Formas)'); disp(pearsonTable);
disp('Tabela MSE (Formas)'); disp(mseTable);

figure('Position',[100 100 1400 700]);
subplot(1,2,1);
pcolor([pearsonMat, pearsonMat(:,end); pearsonMat(end,:), pearsonMat(end,end)]);
shading flat; colormap(jet); colorbar;
title('Pearson Feature Matching (Formas)');
xticks(1:numClasses*numImages); xticklabels(colLabels); xtickangle(45);
yticks(1:numTemplates); yticklabels(classNames);
set(gca,'YDir','normal'); axis equal tight;

subplot(1,2,2);
pcolor([mseMat, mseMat(:,end); mseMat(end,:), mseMat(end,end)]);
shading flat; colormap(jet); colorbar;
title('MSE Feature Matching (Formas)');
xticks(1:numClasses*numImages); xticklabels(colLabels); xtickangle(45);
yticks(1:numTemplates); yticklabels(classNames);
set(gca,'YDir','normal'); axis equal tight;


% EXEMPLO 2: FOLHAS

% Configuração
folder = "./folhas/";
classesFolders = {folder+"Acer_Capillipes/", folder+"Acer_Mono/", folder+"Acer_Opalus/"};
classNames = {'Capillipes','Mono','Opalus'};
rng(5);

% Seleciona 4 imagens aleatórias e carrega
classesFiles = cellfun(@(f) {dir(f+"*.jpg").name}, classesFolders, 'UniformOutput', false);
randomFiles = cellfun(@(f) f(randperm(numel(f),4)), classesFiles, 'UniformOutput', false);

templates = cell(1,3); imgsClasses = cell(1,3);
for k=1:3
    templates{k} = im2double(imread(classesFolders{k} + randomFiles{k}{1}));
    remaining = randomFiles{k}(2:4);
    imgsClasses{k} = cellfun(@(f) im2double(imread(classesFolders{k}+f)), remaining, 'UniformOutput', false);
end

% Calcula intra e inter-classe
classesStats = cell(1,3);
for k=1:3
    classesStats{k} = compareClassesFeature(templates{k}, imgsClasses);
end

% Montar matrizes para heatmap
numTemplates = numel(classesStats);
numClasses   = numel(imgsClasses);
numImages    = 3;

pearsonMat = zeros(numTemplates,numClasses*numImages);
mseMat     = zeros(numTemplates,numClasses*numImages);

for t=1:numTemplates
    currentClass = classesStats{t};
    for c=1:numClasses
        vals = cell2mat(currentClass{c}');
        cols = (c-1)*numImages + (1:numImages);
        pearsonMat(t,cols) = vals(:,1)';
        mseMat(t,cols)     = vals(:,2)';
    end
end

colLabels = {};
for c=1:numClasses
    for i=1:numImages
        colLabels{end+1} = sprintf('%s%d', classNames{c}, i);
    end
end

% Mostrar tabelas
pearsonTable = array2table(pearsonMat,'VariableNames',colLabels,'RowNames',classNames);
mseTable     = array2table(mseMat,'VariableNames',colLabels,'RowNames',classNames);

disp('Tabela Pearson (Folhas)'); disp(pearsonTable);
disp('Tabela MSE (Folhas)'); disp(mseTable);

% Heatmaps
figure('Position',[100 100 1400 700]);
subplot(1,2,1);
pcolor([pearsonMat, pearsonMat(:,end); pearsonMat(end,:), pearsonMat(end,end)]);
shading flat; colormap(jet); colorbar;
title('Pearson Feature Matching (Folhas)');
xticks(1:numClasses*numImages); xticklabels(colLabels); xtickangle(45);
yticks(1:numTemplates); yticklabels(classNames);
set(gca,'YDir','normal'); axis equal tight;

subplot(1,2,2);
pcolor([mseMat, mseMat(:,end); mseMat(end,:), mseMat(end,end)]);
shading flat; colormap(jet); colorbar;
title('MSE Feature Matching (Folhas)');
xticks(1:numClasses*numImages); xticklabels(colLabels); xtickangle(45);
yticks(1:numTemplates); yticklabels(classNames);
set(gca,'YDir','normal'); axis equal tight;