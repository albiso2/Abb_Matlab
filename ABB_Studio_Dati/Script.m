% --- SCRIPT DI CONFRONTO COLONNE CON TEMPO INGRESSO ---
clear all; clc;

%% --- Caricamento dati ---
load('dati.mat');  % contiene CellaAP10001000 e CellaR10001500

file1 = CellaAP10001000;
file2 = CellaR10001500;

%prova git

%% --- Conversione robusta table/cell -> numeric ---
file1_num = zeros(size(file1));
file2_num = zeros(size(file2));

for c = 1:size(file1,2)
    % --- File1 ---
    if istable(file1)
        col = file1{:,c};  % usa {} per estrarre contenuto numerico/cella
    else
        col = file1(:,c);
    end
    
    if iscell(col)
        colNum = nan(size(col));
        for k = 1:numel(col)
            val = col{k};
            if isnumeric(val)
                colNum(k) = val;
            elseif ischar(val) || isstring(val)
                colNum(k) = str2double(val);
            end
        end
    else
        colNum = double(col);
    end
    file1_num(:,c) = colNum;
    
    % --- File2 ---
    if istable(file2)
        col = file2{:,c};
    else
        col = file2(:,c);
    end
    
    if iscell(col)
        colNum = nan(size(col));
        for k = 1:numel(col)
            val = col{k};
            if isnumeric(val)
                colNum(k) = val;
            elseif ischar(val) || isstring(val)
                colNum(k) = str2double(val);
            end
        end
    else
        colNum = double(col);
    end
    file2_num(:,c) = colNum;
end

% Sostituisci file1 e file2 con array numerici
file1 = file1_num;
file2 = file2_num;

%% --- Estrazione tempo ---
tempo1 = file1(:,1);
tempo2 = file2(:,1);

%% --- Allineamento sui tempi comuni ---
[tempi_comuni, idx1, idx2] = intersect(tempo1, tempo2);
file1 = file1(idx1,:);
file2 = file2(idx2,:);
tempo = tempi_comuni;

%% --- Colonne da considerare ---
colNames = {'Energia Totale','Potenza Motore','Acc Lineare IRB4600_40',...
            'Massima Accelerazione Lineare IRB4600_40','Acc Lineare TROB2',...
            'Massima Acc Lineare TROB2'};

colsToKeep = 2:size(file1,2);   % tutte tranne tempo
colsToKeep(colsToKeep==7) = []; % escludi eventuale colonna 7
colNamesData = colNames(colsToKeep-1);
nCol = length(colNamesData);

%% --- Plot serie temporali ---
figure('Name','Confronto Serie Temporali','NumberTitle','off');
for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);
    plot(tempo, file1(:,c), '-o'); hold on;
    plot(tempo, file2(:,c), '-x');
    xlabel('Tempo'); ylabel('Valore');
    legend('File1','File2','Location','best');
    title(colNamesData{idx});
    grid on;
end
sgtitle('Confronto colonne tra file1 e file2');

%% --- Calcolo medie e massimi ---
mediaFile1 = zeros(1,nCol);
mediaFile2 = zeros(1,nCol);
maxFile1   = zeros(1,nCol);
maxFile2   = zeros(1,nCol);

for idx = 1:nCol
    c = colsToKeep(idx);
    col1 = file1(:,c); col2 = file2(:,c);
    col1 = col1(:); col2 = col2(:);
    
    mediaFile1(idx) = mean(col1,'omitnan');
    mediaFile2(idx) = mean(col2,'omitnan');
    
    maxFile1(idx) = max(col1,[],'omitnan');
    maxFile2(idx) = max(col2,[],'omitnan');
end
%% --- Grafici barre valori medi e massimi con coppie di colori fisse ---

% Definiamo colori fissi per File1 e File2
colorFile1 = [0 0.4470 0.7410];      % blu
colorFile2 = [0.8500 0.3250 0.0980]; % arancio

% Indici
energyIdx = 1;           % Energia Totale
accIdx = 2:nCol;         % tutte le altre colonne (Accelerazioni)

%% --- Energia: Media e Massimo ---
figure('Name','Energia: Media e Massimo','NumberTitle','off');

colorFile1 = [0 0.4470 0.7410];   % blu
colorFile2 = [0.8500 0.3250 0.0980]; % arancio

% Media
subplot(2,1,1); hold on;
plot(1, mediaFile1(energyIdx), 'o', 'MarkerFaceColor', colorFile1, 'MarkerEdgeColor', colorFile1, 'MarkerSize', 10);
plot(2, mediaFile2(energyIdx), 'o', 'MarkerFaceColor', colorFile2, 'MarkerEdgeColor', colorFile2, 'MarkerSize', 10);
xlim([0 3]);
set(gca,'XTick',[1 2],'XTickLabel',{'File1','File2'});
ylabel('Valore medio'); title('Energia Totale - Media'); grid on;

% Massimo
subplot(2,1,2); hold on;
plot(1, maxFile1(energyIdx), 'o', 'MarkerFaceColor', colorFile1, 'MarkerEdgeColor', colorFile1, 'MarkerSize', 10);
plot(2, maxFile2(energyIdx), 'o', 'MarkerFaceColor', colorFile2, 'MarkerEdgeColor', colorFile2, 'MarkerSize', 10);
xlim([0 3]);
set(gca,'XTick',[1 2],'XTickLabel',{'File1','File2'});
ylabel('Valore massimo'); title('Energia Totale - Massimo'); grid on;


%% --- Accelerazioni: Media e Massimo ---
figure('Name','Accelerazioni: Media e Massimo','NumberTitle','off');

% Media
subplot(2,1,1); hold on;
for i = 1:length(accIdx)
    plot(2*i-1, mediaFile1(accIdx(i)), 'o', 'MarkerFaceColor', colorFile1, 'MarkerEdgeColor', colorFile1, 'MarkerSize', 8);
    plot(2*i,   mediaFile2(accIdx(i)), 'o', 'MarkerFaceColor', colorFile2, 'MarkerEdgeColor', colorFile2, 'MarkerSize', 8);
end
xlim([0 2*length(accIdx)+1]);
xticks(1:2:2*length(accIdx));
xticklabels(colNamesData(accIdx));
xtickangle(45);
ylabel('Valore medio'); title('Medie'); grid on;

% Massimo
subplot(2,1,2); hold on;
for i = 1:length(accIdx)
    plot(2*i-1, maxFile1(accIdx(i)), 'o', 'MarkerFaceColor', colorFile1, 'MarkerEdgeColor', colorFile1, 'MarkerSize', 8);
    plot(2*i,   maxFile2(accIdx(i)), 'o', 'MarkerFaceColor', colorFile2, 'MarkerEdgeColor', colorFile2, 'MarkerSize', 8);
end
xlim([0 2*length(accIdx)+1]);
xticks(1:2:2*length(accIdx));
xticklabels(colNamesData(accIdx));
xtickangle(45);
ylabel('Valore massimo'); title('Massimi'); grid on;
