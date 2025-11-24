%% --- Seleziona cartella ---
clear all; clc; close all;
folderPath = uigetdir(pwd,'Seleziona la cartella con i dati');
if folderPath == 0
    error('Cartella non selezionata');
end

% Trova i file Excel
files = dir(fullfile(folderPath,'*.xlsx'));
if length(files) < 2
    error('Serve almeno 2 file Excel nella cartella');
end

% Prendi i primi due file
file1Path = fullfile(folderPath, files(1).name);
file2Path = fullfile(folderPath, files(2).name);

%% --- Leggi i file Excel ---
file1 = readmatrix(file1Path);
file2 = readmatrix(file2Path);

%% --- Estrazione tempo ---
tempo1 = file1(:,1);
tempo2 = file2(:,1);

%% --- Colonne da considerare ---
colNames = {'Tempo','Energia','Potenza Motore','AL IRB4600_40','AL IRBDiverso'};
colsToKeep = 2:size(file1,2);
nCol = length(colsToKeep);
colNamesData = colNames(colsToKeep);

%% --- Allineamento sui tempi comuni per tutte le colonne ---
[tempi_comuni, idx1, idx2] = intersect(tempo1, tempo2);
file1_common = file1(idx1,:);
file2_common = file2(idx2,:);
tempo_common = tempi_comuni;

%% --- Plot serie temporali ---
figure('Name','Confronto Serie Temporali','NumberTitle','off');
for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);

    % Tutte le colonne: plot sui tempi comuni
    plot(tempo_common, file1_common(:,c), '-o','LineWidth',1); hold on;
    plot(tempo_common, file2_common(:,c), '-x','LineWidth',1);

    xlabel('Tempo'); ylabel('Valore');
    legend('File1','File2','Location','best');
    title(colNamesData{idx});
    grid on;
end
sgtitle('Confronto colonne tra file1 e file2');

%% --- Boxplot puliti (percentili 5-95 per tutte le colonne) ---
figure('Name','Boxplot Puliti Confronto File1 vs File2','NumberTitle','off');
lowerPerc = 5;
upperPerc = 95;

for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % Filtra percentili 5-95 per tutte le colonne, nessuna eccezione
    perc1 = prctile(dati1, [lowerPerc upperPerc]);
    perc2 = prctile(dati2, [lowerPerc upperPerc]);

    dati1f = dati1(dati1 >= perc1(1) & dati1 <= perc1(2));
    dati2f = dati2(dati2 >= perc2(1) & dati2 <= perc2(2));

    if isempty(dati1f), dati1f = dati1; end
    if isempty(dati2f), dati2f = dati2; end

    dati_comb = [dati1f; dati2f];
    gruppi = [repmat({'File1'}, length(dati1f),1); repmat({'File2'}, length(dati2f),1)];

    boxplot(dati_comb, gruppi, 'whisker',1.5,'Symbol','');
    title(['Boxplot - ' colNamesData{idx}]);
    ylabel('Valori');
    grid on;
end
sgtitle(['Boxplot Puliti (' num2str(lowerPerc) '-' num2str(upperPerc) ' percentile)']);
