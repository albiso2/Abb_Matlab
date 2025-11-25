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

%% ===================================================================
%% 2) BOXPLOT CON WHISKER AL MIN E MAX REALE (Dati filtrati per anomalie)
%% ===================================================================

figure('Name','Boxplot corretto con whisker al min/max','NumberTitle','off');

for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % --- Filtra anomalie veramente estreme per tutte le colonne ---
    % Definiamo come valori estremi quelli oltre i percentili 0.5 e 99.5
    p_lower = prctile([dati1; dati2],0.5);
    p_upper = prctile([dati1; dati2],99.5);
    dati1_filt = dati1;
    dati2_filt = dati2;
    dati1_filt(dati1 < p_lower | dati1 > p_upper) = NaN;
    dati2_filt(dati2 < p_lower | dati2 > p_upper) = NaN;

    % Rimuove eventuali NaN dopo filtraggio
    dati1_filt = dati1_filt(~isnan(dati1_filt));
    dati2_filt = dati2_filt(~isnan(dati2_filt));

    % Concatenazione dati e definizione gruppi
    dati_comb = [dati1_filt; dati2_filt];
    gruppi = [repmat({'File1'}, length(dati1_filt),1); repmat({'File2'}, length(dati2_filt),1)];

    % Calcolo statistiche
    Q1 = prctile(dati_comb,25);
    med = median(dati_comb);
    Q3 = prctile(dati_comb,75);
    min_val = min(dati_comb);
    max_val = max(dati_comb);

    fprintf('Colonna: %s\n', colNamesData{idx});
    fprintf('  File1 -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati1_filt), prctile(dati1_filt,25), median(dati1_filt), prctile(dati1_filt,75), min(dati1_filt), max(dati1_filt));
    fprintf('  File2 -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati2_filt), prctile(dati2_filt,25), median(dati2_filt), prctile(dati2_filt,75), min(dati2_filt), max(dati2_filt));

    % Boxplot senza outlier, whisker al min/max filtrati
    boxplot(dati_comb, gruppi, 'whisker', Inf, 'Symbol','');

    title(['Boxplot - ' colNamesData{idx}]);
    ylabel('Valori');
    grid on;
end

sgtitle('Boxplot con whisker al min/max filtrati per anomalie estreme');
%% ===================================================================
%% ZONE DI VARIAZIONE RAPIDA DELLE ACCELERAZIONI (WINDOW ~60s)
%% ===================================================================

accCols = nCol-1:nCol;  % ultime 2 colonne
accNames = colNamesData(accCols);
window_size = 1948;  % circa 60 secondi

figure('Name','Zone di accelerazione rapida','NumberTitle','off');

for k = 1:length(accCols)
    c = accCols(k);
    subplot(length(accCols),1,k);

    % --- Dati filtrati (tolgo valori estremi 1-99 percentile)
    dati1 = file1(:,c); dati2 = file2(:,c);
    datiAll = [dati1; dati2];
    lowerLim = prctile(datiAll,1);
    upperLim = prctile(datiAll,99);
    dati1(dati1 < lowerLim | dati1 > upperLim) = NaN;
    dati2(dati2 < lowerLim | dati2 > upperLim) = NaN;

    % --- Calcolo derivata media in finestra mobile
    deriv1 = movmean([0; diff(dati1)], window_size,'omitnan');  
    deriv2 = movmean([0; diff(dati2)], window_size,'omitnan');  

    % --- Soglia rispetto alla media
    thresh1 = 3*nanstd(deriv1); % picchi > 3 deviazioni standard
    thresh2 = 3*nanstd(deriv2);

    fast1 = abs(deriv1) > thresh1;
    fast2 = abs(deriv2) > thresh2;

    % --- Plot dei dati principali
    t1_valid = tempo1; t2_valid = tempo2;
    hold on;
    h1 = plot(t1_valid, dati1, 'b', 'LineWidth', 1.2); 
    h2 = plot(t2_valid, dati2, 'r', 'LineWidth', 1.2);

    % --- Evidenzia i picchi con bande più visibili
    ylimVals = ylim;
    for i=1:length(fast1)
        if fast1(i)
            patch([t1_valid(i) t1_valid(i) t1_valid(i+1) t1_valid(i+1)],...
                  [ylimVals(1) ylimVals(2) ylimVals(2) ylimVals(1)],...
                  'c','FaceAlpha',0.6,'EdgeColor','c');
        end
    end
    for i=1:length(fast2)
        if fast2(i)
            patch([t2_valid(i) t2_valid(i) t2_valid(i+1) t2_valid(i+1)],...
                  [ylimVals(1) ylimVals(2) ylimVals(2) ylimVals(1)],...
                  'm','FaceAlpha',0.6,'EdgeColor','m');
        end
    end

    xlabel('Tempo [s]'); ylabel('Accelerazione');

    % --- Legenda aggiornata
    legend([h1 h2], {'File1','File2'}, 'Location','best');

    title(['Accelerazione rapida - ' accNames{k}]);
    grid on;
end

sgtitle('Zone di accelerazione rapida (finestra ~60s, soglia 3 std)');