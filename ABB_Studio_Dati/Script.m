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

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % --- Filtra valori anomali estremi per tutte le colonne (1°-99° percentile)
    lowerLim = prctile([dati1; dati2], 1);
    upperLim = prctile([dati1; dati2], 99);
    dati1(dati1 < lowerLim | dati1 > upperLim) = NaN;
    dati2(dati2 < lowerLim | dati2 > upperLim) = NaN;

    plot(tempo1, dati1, '-o', 'LineWidth', 1); hold on;
    plot(tempo2, dati2, '-x', 'LineWidth', 1);

    xlabel('Tempo'); ylabel('Valore');
    legend('File1','File2','Location','best');
    title(colNamesData{idx});
    grid on;
end
sgtitle('Confronto colonne tra file1 e file2 (Tempo originale, valori estremi rimossi)');
%% ===================================================================
%% BOXPLOT BASATI SU STATISTICHE CALCOLATE DAI DATI (PULITI) CON STAMPA
%% ===================================================================

figure('Name','Boxplot basati su statistiche','NumberTitle','off');

for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);

    % Dati originali
    dati1_plot = file1(:,c);
    dati2_plot = file2(:,c);

    % --- Filtra valori estremi per evitare picchi enormi
    allData = [dati1_plot; dati2_plot];
    lowerLim = prctile(allData, 1);
    upperLim = prctile(allData, 99);

    dati1_clean = dati1_plot(dati1_plot >= lowerLim & dati1_plot <= upperLim);
    dati2_clean = dati2_plot(dati2_plot >= lowerLim & dati2_plot <= upperLim);

    % --- Calcolo statistiche
    stats1.mean = mean(dati1_clean);
    stats1.q25  = prctile(dati1_clean, 25);
    stats1.q75  = prctile(dati1_clean, 75);
    stats1.min  = min(dati1_clean);
    stats1.max  = max(dati1_clean);

    stats2.mean = mean(dati2_clean);
    stats2.q25  = prctile(dati2_clean, 25);
    stats2.q75  = prctile(dati2_clean, 75);
    stats2.min  = min(dati2_clean);
    stats2.max  = max(dati2_clean);

    % --- Stampa su Command Window
    fprintf('Colonna: %s\n', colNamesData{idx});
    fprintf('  File1 -> Mean: %.3f, Q25: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
        stats1.mean, stats1.q25, stats1.q75, stats1.min, stats1.max);
    fprintf('  File2 -> Mean: %.3f, Q25: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n\n', ...
        stats2.mean, stats2.q25, stats2.q75, stats2.min, stats2.max);

    % --- Boxplot standard dai dati puliti
    dati_box = [dati1_clean; dati2_clean];
    gruppi = [repmat({'File1'}, length(dati1_clean),1);
              repmat({'File2'}, length(dati2_clean),1)];
    boxplot(dati_box, gruppi, 'whisker',1.5, 'Symbol','');
    hold on;

    % Sovrapponiamo le medie come linea rossa
    plot([1 1], [stats1.mean stats1.mean], 'r', 'LineWidth', 2);
    plot([2 2], [stats2.mean stats2.mean], 'r', 'LineWidth', 2);

    title(['Boxplot - ' colNamesData{idx}]);
    ylabel('Valori');
    grid on;
end

sgtitle('Boxplot basati su statistiche (quartili e media, valori estremi filtrati)');
