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

%% --- Allineamento sui tempi comuni ---
[tempi_comuni, idx1, idx2] = intersect(tempo1, tempo2);
file1 = file1(idx1,:);
file2 = file2(idx2,:);
tempo = tempi_comuni;

%% --- Colonne da considerare ---
colNames = {'Energia Totale','Potenza Motore','AL IRB4600_40', ...
            'MAL-IRB4600-40','AL IRB4600-20-IRB2600ID', ...
            'MAL TROB2'};

nTotalCols = length(colNames);

colsToExclude = [5 7]; 
colsToKeep = setdiff(2:nTotalCols, colsToExclude);
colNamesData = colNames(colsToKeep - 1);
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
    col1 = file1(:,c);
    col2 = file2(:,c);
    
    mediaFile1(idx) = mean(col1,'omitnan');
    mediaFile2(idx) = mean(col2,'omitnan');
    maxFile1(idx)   = max(col1,[],'omitnan');
    maxFile2(idx)   = max(col2,[],'omitnan');
end

%% --- Grafici barre valori medi e massimi ---
colorFile1 = [0 0.4470 0.7410];
colorFile2 = [0.8500 0.3250 0.0980];

energyIdx = 1;
accIdx = 2:nCol;

figure('Name','Energia: Media e Massimo','NumberTitle','off');

subplot(2,1,1); hold on;
plot(1, mediaFile1(energyIdx), 'o','MarkerFaceColor',colorFile1,'MarkerEdgeColor',colorFile1,'MarkerSize',10);
plot(2, mediaFile2(energyIdx), 'o','MarkerFaceColor',colorFile2,'MarkerEdgeColor',colorFile2,'MarkerSize',10);
xlim([0 3]); set(gca,'XTick',[1 2],'XTickLabel',{'File1','File2'});
ylabel('Valore medio'); title('Energia Totale - Media'); grid on;

subplot(2,1,2); hold on;
plot(1, maxFile1(energyIdx), 'o','MarkerFaceColor',colorFile1,'MarkerEdgeColor',colorFile1,'MarkerSize',10);
plot(2, maxFile2(energyIdx), 'o','MarkerFaceColor',colorFile2,'MarkerEdgeColor',colorFile2,'MarkerSize',10);
xlim([0 3]); set(gca,'XTick',[1 2],'XTickLabel',{'File1','File2'});
ylabel('Valore massimo'); title('Energia Totale - Massimo'); grid on;

%% --- Accelerazioni ---
figure('Name','Accelerazioni: Media e Massimo','NumberTitle','off');

subplot(2,1,1); hold on;
for i = 1:length(accIdx)
    plot(2*i-1, mediaFile1(accIdx(i)), 'o','MarkerFaceColor',colorFile1,'MarkerEdgeColor',colorFile1,'MarkerSize',8);
    plot(2*i,   mediaFile2(accIdx(i)), 'o','MarkerFaceColor',colorFile2,'MarkerEdgeColor',colorFile2,'MarkerSize',8);
end
xlim([0 2*length(accIdx)+1]);
xticks(1:2:2*length(accIdx));
xticklabels(colNamesData(accIdx));
xtickangle(45); ylabel('Valore medio'); title('Medie'); grid on;

subplot(2,1,2); hold on;
for i = 1:length(accIdx)
    plot(2*i-1, maxFile1(accIdx(i)), 'o','MarkerFaceColor',colorFile1,'MarkerEdgeColor',colorFile1,'MarkerSize',8);
    plot(2*i,   maxFile2(accIdx(i)), 'o','MarkerFaceColor',colorFile2,'MarkerEdgeColor',colorFile2,'MarkerSize',8);
end
xlim([0 2*length(accIdx)+1]);
xticks(1:2:2*length(accIdx));
xticklabels(colNamesData(accIdx));
xtickangle(45); ylabel('Valore massimo'); title('Massimi'); grid on;

%% --- Picchi e correlazioni ---
fprintf('\n--- Correlazioni File1 vs File2 ---\n');
figure('Name','Picchi Massimi','NumberTitle','off');

for idx = 1:nCol
    c = colsToKeep(idx);
    col1 = file1(:,c); col2 = file2(:,c);

    thresh1 = mean(col1,'omitnan') + std(col1,'omitnan');
    thresh2 = mean(col2,'omitnan') + std(col2,'omitnan');

    if any(col1 > thresh1), [pks1, locs1] = findpeaks(col1,'MinPeakHeight',thresh1); else pks1=[]; locs1=[]; end
    if any(col2 > thresh2), [pks2, locs2] = findpeaks(col2,'MinPeakHeight',thresh2); else pks2=[]; locs2=[]; end

    subplot(ceil(nCol/2),2,idx); hold on;
    plot(tempo,col1,'-b'); if ~isempty(pks1), plot(tempo(locs1),pks1,'ob','MarkerFaceColor','b'); end
    plot(tempo,col2,'-r'); if ~isempty(pks2), plot(tempo(locs2),pks2,'or','MarkerFaceColor','r'); end
    title(colNamesData{idx}); grid on;

    R = corr(col1,col2,'Rows','complete'); if isempty(R) || isnan(R), R=0; end
    fprintf('%s: Corr = %.3f\n', colNamesData{idx}, R);
end
sgtitle('Picchi Massimi per ciascuna colonna');

%% --- FFT su POTENZA MOTORE (File1 e File2) ---
idxPower = find(strcmp(colNamesData,'Potenza Motore'));

if ~isempty(idxPower)
    colPow = colsToKeep(idxPower);

    % Estrai dati e rimuovi offset
    p1 = detrend(file1(:,colPow));
    p2 = detrend(file2(:,colPow));

    % Lunghezza e frequenze
    L = length(p1);
    Fs = 1/mean(diff(tempo));
    f = (0:floor(L/2))*(Fs/L);

    % FFT
    Yp1 = fft(p1);
    Yp2 = fft(p2);

    Yp1_mag = abs(Yp1(1:length(f)));
    Yp2_mag = abs(Yp2(1:length(f)));

    % Plot
    figure('Name','FFT Potenza Motore','NumberTitle','off');
    plot(f, Yp1_mag,'b','LineWidth',1.2); hold on;
    plot(f, Yp2_mag,'r','LineWidth',1.2);
    grid on;
    xlabel('Frequenza [Hz]');
    ylabel('Ampiezza');
    title('FFT Potenza Motore');
    legend('File1','File2');
end

%% --- BLOCCO FINALE: Dashboard + Statistiche per Command Window ---
figure('Name','Dashboard Completa','NumberTitle','off','Units','normalized','Position',[0 0 1 1]);
tiled = tiledlayout(4,2,'TileSpacing','compact','Padding','compact');
title(tiled,'Dashboard completa dell’analisi');

% --- Serie temporali ---
for idx=1:nCol
    nexttile; 
    plot(tempo,file1(:,colsToKeep(idx)),'-o'); hold on; 
    plot(tempo,file2(:,colsToKeep(idx)),'-x'); 
    title(['Serie: ' colNamesData{idx}]); grid on;
    legend('File1','File2');
end

% --- Medie (pallini) ---
nexttile; hold on;
for i = 1:nCol
    plot(i-0.2, mediaFile1(i), 'o', 'MarkerFaceColor', colorFile1, 'MarkerEdgeColor', colorFile1, 'MarkerSize', 8);
    plot(i+0.2, mediaFile2(i), 'o', 'MarkerFaceColor', colorFile2, 'MarkerEdgeColor', colorFile2, 'MarkerSize', 8);
end
xlim([0 nCol+1]);
xticks(1:nCol); xticklabels(colNamesData);
xtickangle(45); ylabel('Valore medio'); title('Medie'); grid on;

% --- Massimi (pallini) ---
nexttile; hold on;
for i = 1:nCol
    plot(i-0.2, maxFile1(i), 'o', 'MarkerFaceColor', colorFile1, 'MarkerEdgeColor', colorFile1, 'MarkerSize', 8);
    plot(i+0.2, maxFile2(i), 'o', 'MarkerFaceColor', colorFile2, 'MarkerEdgeColor', colorFile2, 'MarkerSize', 8);
end
xlim([0 nCol+1]);
xticks(1:nCol); xticklabels(colNamesData);
xtickangle(45); ylabel('Valore massimo'); title('Massimi'); grid on;

% --- FFT Potenza Motore ---
if ~isempty(idxPower)
    nexttile([1 2]); % occupa due colonne
    plot(f,Yp1_mag,'b','LineWidth',1.2); hold on; 
    plot(f,Yp2_mag,'r','LineWidth',1.2);
    grid on; xlabel('Frequenza [Hz]'); ylabel('Ampiezza'); 
    title('FFT Potenza Motore'); legend('File1','File2');
end

%% --- Statistiche dettagliate in Command Window ---
disp('--- Statistiche dettagliate per ciascuna colonna ---');
for idx = 1:nCol
    c = colsToKeep(idx);
    col1 = file1(:,c);
    col2 = file2(:,c);

    fprintf('\nColonna: %s\n', colNamesData{idx});
    fprintf('File1: Media=%.3f, Max=%.3f, Min=%.3f, Std=%.3f\n', ...
        mean(col1,'omitnan'), max(col1,[],'omitnan'), min(col1), std(col1,'omitnan'));
    fprintf('File2: Media=%.3f, Max=%.3f, Min=%.3f, Std=%.3f\n', ...
        mean(col2,'omitnan'), max(col2,[],'omitnan'), min(col2), std(col2,'omitnan'));
end

%% --- Tabella riepilogativa delle statistiche e correlazioni ---
statTable = table();

for idx = 1:nCol
    c = colsToKeep(idx);
    col1 = file1(:,c);
    col2 = file2(:,c);

    % Calcolo statistiche
    media1 = mean(col1,'omitnan');  media2 = mean(col2,'omitnan');
    max1   = max(col1,[],'omitnan'); max2   = max(col2,[],'omitnan');
    min1   = min(col1);              min2   = min(col2);
    std1   = std(col1,'omitnan');    std2   = std(col2,'omitnan');

    % Correlazione
    R = corr(col1,col2,'Rows','complete'); 
    if isempty(R) || isnan(R), R = 0; end

    % Aggiungi riga alla tabella
    statTable = [statTable; table({colNamesData{idx}}, media1, media2, max1, max2, min1, min2, std1, std2, R, ...
        'VariableNames', {'Colonna','Media_File1','Media_File2','Max_File1','Max_File2','Min_File1','Min_File2','Std_File1','Std_File2','Correlazione'})];
end

% Mostra la tabella in una finestra interattiva
fStats = uifigure('Name','Statistiche e Correlazioni','Position',[200 200 900 400]);
uit = uitable(fStats,'Data',statTable,'Position',[10 10 880 380]);
