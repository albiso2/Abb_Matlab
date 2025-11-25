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

% Etichette y per ciascuna colonna
yLabels = {'[J]', '[W]', '[mm/s^2]', '[mm/s^2]'};

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

    xlabel('Tempo [s]');        % <-- etichetta aggiornata
    ylabel(yLabels{idx});       % <-- etichetta aggiornata
    legend('File1','File2','Location','best');
    title(colNamesData{idx});
    grid on;
end
sgtitle('Confronto colonne tra file1 e file2 (Tempo originale, valori estremi rimossi)');



%% ===================================================================
%% 2) BOXPLOT CON WHISKER AL MIN E MAX REALE (solo Energia e Potenza)
%% ===================================================================

figure('Name','Boxplot E & P','NumberTitle','off');

colsBox = [2 3]; % Energia e Potenza
yLabelsBox = {'[J]', '[W]'};

for idx = 1:length(colsBox)
    c = colsBox(idx);
    subplot(1,length(colsBox),idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % --- Filtra anomalie veramente estreme (percentili 0.5 e 99.5)
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

    % Calcolo statistiche e stampa su command window
    fprintf('Colonna: %s\n', colNamesData{c-1}); % colNamesData parte da colonna 2
    fprintf('  File1 -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati1_filt), prctile(dati1_filt,25), median(dati1_filt), prctile(dati1_filt,75), min(dati1_filt), max(dati1_filt));
    fprintf('  File2 -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati2_filt), prctile(dati2_filt,25), median(dati2_filt), prctile(dati2_filt,75), min(dati2_filt), max(dati2_filt));

    % Boxplot senza outlier, whisker al min/max filtrati
    boxplot(dati_comb, gruppi, 'whisker', Inf, 'Symbol','');

    title([ colNames{c}]);
    ylabel(yLabelsBox{idx});     % <-- etichetta y aggiornata
    xlabel('Tempo [s]');         % <-- etichetta x aggiornata
    grid on;
end

sgtitle('Boxplot E & P filtrati');


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