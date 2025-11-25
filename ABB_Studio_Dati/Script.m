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

%% ===================================================================
%% 1) SERIE TEMPORALI SU TEMPI ORIGINALI (NESSUNA INTERSEZIONE)
%% ===================================================================

figure('Name','Confronto Serie Temporali','NumberTitle','off');

for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);

    plot(tempo1, file1(:,c), '-o', 'LineWidth', 1); hold on;
    plot(tempo2, file2(:,c), '-x', 'LineWidth', 1);

    xlabel('Tempo'); ylabel('Valore');
    legend('File1','File2','Location','best');
    title(colNamesData{idx});
    grid on;
end
sgtitle('Confronto colonne tra file1 e file2 (Tempo originale)');


%% ===================================================================
%% 2) BOXPLOT SENZA OUTLIER (WHISKERS STANDARD IQR)
%% ===================================================================

figure('Name','Boxplot Senza Outlier - Confronto File1 vs File2','NumberTitle','off');

for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % --- Rimozione outlier tramite IQR ---
    Q1_1 = prctile(dati1,25);
    Q3_1 = prctile(dati1,75);
    IQR1 = Q3_1 - Q1_1;
    lower1 = Q1_1 - 1.5*IQR1;
    upper1 = Q3_1 + 1.5*IQR1;
    dati1_clean = dati1(dati1 >= lower1 & dati1 <= upper1);

    Q1_2 = prctile(dati2,25);
    Q3_2 = prctile(dati2,75);
    IQR2 = Q3_2 - Q1_2;
    lower2 = Q1_2 - 1.5*IQR2;
    upper2 = Q3_2 + 1.5*IQR2;
    dati2_clean = dati2(dati2 >= lower2 & dati2 <= upper2);

    % --- Prepara dati per boxplot ---
    dati_comb = [dati1_clean; dati2_clean];
    gruppi = [repmat({'File1'}, length(dati1_clean),1); 
              repmat({'File2'}, length(dati2_clean),1)];

    % --- Boxplot senza simboli dei outlier (perché già rimossi) ---
    boxplot(dati_comb, gruppi, 'whisker',1.5, 'Symbol','');
    title(['Boxplot - ' colNamesData{idx}]);
    ylabel('Valori');
    grid on;
end

sgtitle('Boxplot senza outlier (Whiskers IQR)');
