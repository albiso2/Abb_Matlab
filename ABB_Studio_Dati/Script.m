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


%% --- BOXPLOT PULITI: togli outlier oltre i percentili ---
figure('Name','Boxplot Puliti Confronto File1 vs File2','NumberTitle','off');

lowerPerc = 5;   % percentile minimo
upperPerc = 95;  % percentile massimo

for idx = 1:nCol
    c = colsToKeep(idx);

    subplot(ceil(nCol/2),2,idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % Percentili normali
    lowerP = 5; upperP = 95;

    % Se colonna accelerazione IRB4600-20 → prendi tutto
    if strcmp(colNamesData{idx}, 'AL IRB4600-20-IRB2600ID')
        lowerP = 0;
        upperP = 100;
    end

    % Calcolo percentili
    perc1 = prctile(dati1, [lowerP upperP]);
    perc2 = prctile(dati2, [lowerP upperP]);

    % Filtra dati entro percentili
    dati1f = dati1(dati1 >= perc1(1) & dati1 <= perc1(2));
    dati2f = dati2(dati2 >= perc2(1) & dati2 <= perc2(2));

    % Se quasi piatti, prendi tutti i dati
    if isempty(dati1f), dati1f = dati1; end
    if isempty(dati2f), dati2f = dati2; end

    % Concatenazione verticale e gruppi
    dati_comb = [dati1f; dati2f];
    gruppi = [repmat({'File1'}, length(dati1f),1); repmat({'File2'}, length(dati2f),1)];

    % Boxplot
    boxplot(dati_comb, gruppi, 'whisker',1.5,'Symbol','');

    title(['Boxplot - ' colNamesData{idx}]);
    ylabel('Valori');
    grid on;
end


sgtitle(['Boxplot Puliti (' num2str(lowerPerc) '-' num2str(upperPerc) ' percentile)']);
