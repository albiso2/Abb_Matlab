%% --- Seleziona cartella ---
clear all; clc; close all;
folderPath = uigetdir(pwd,'Seleziona la cartella con i dati');
if folderPath == 0
    error('Cartella non selezionata');
end

% Trova i file Excel
files = dir(fullfile(folderPath,'*.xlsx')); % o '*.xls'
if length(files) < 2
    error('Serve almeno 2 file Excel nella cartella');
end

% Prendi i due file (qui puoi filtrare per nome)
file1Path = fullfile(folderPath, files(1).name);
file2Path = fullfile(folderPath, files(2).name);

%% --- Leggi i file Excel ---

file1 = readmatrix(file1Path);
file2 = readmatrix(file2Path);


%% --- Estrazione tempo ---
tempo1 = file1(:,1);
tempo2 = file2(:,1);

%% --- Allineamento sui tempi comuni ---
[tempi_comuni, idx1, idx2] = intersect(tempo1, tempo2);
file1 = file1(idx1,:);
file2 = file2(idx2,:);
tempo = tempi_comuni;

%% --- Colonne da considerare (automatica) ---
colNames = {'Energia Totale','Potenza Motore','AL IRB4600_40', ...
            'MAL-IRB4600-40','AL IRB4600-20-IRB2600ID', ...
            'MAL TROB2'};

nTotalCols = length(colNames);

% Colonne da escludere (modificabile all'inizio dello script)
colsToExclude = [5 7];   % ad esempio escludi colonne 5 e 7

% Colonne da tenere
colsToKeep = setdiff(2:nTotalCols, colsToExclude);  % sempre tranne la colonna tempo (1)
colNamesData = colNames(colsToKeep-1);             % nomi delle colonne considerate
nCol = length(colsToKeep);

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
