%% --- SCRIPT DI CONFRONTO COLONNE CON TEMPO INGRESSO ---
clear all;
load('dati.mat');  % ricarica Data1 e Data2

% --- Inizio script ---
file1 = CellaAP10001000; % sostituire con il nome reale
file2 = CellaR10001500;

% Conversione in array numerici
file1 = convertArrayToNumeric(file1);
file2 = convertArrayToNumeric(file2);

% Estrazione tempo (colonna 1)
tempo1 = file1(:,1);
tempo2 = file2(:,1);

%% -------------------------------------------------------
% --- Allineamento senza modificare i dati ---
% Trova i tempi presenti in entrambi i file
[tempi_comuni, idx1, idx2] = intersect(tempo1, tempo2);

% Riduci i dataset solo ai tempi comuni
file1 = file1(idx1, :);
file2 = file2(idx2, :);

% Aggiorna tempo1 e tempo2
tempo1 = tempi_comuni;
tempo2 = tempi_comuni;

%% Escludiamo colonne da scartare (qui solo colonna 7 se esiste)
colNames = {'Energia Totale','Potenza Motore','Acc Lineare IRB4600_40','Massima Accelerazione Lineare IRB4600_40','Acc Lineare TROB2', 'Massima Acc Lineare TROB2'};

colsToKeep = 2:size(file1,2);   % tutte le colonne tranne il tempo
colsToKeep(colsToKeep==7) = []; % escludi colonna 7 se presente

% map per nomi
colNamesData = colNames(colsToKeep-1); % -1 perché colNames non ha colonna tempo
nCol = length(colNamesData);

%% --- Plot serie temporali ---
figure('Name','Confronto Serie Temporali','NumberTitle','off');
for idx = 1:nCol
    c = colsToKeep(idx);  % colonna reale in file1/file2
    subplot(ceil(nCol/2),2,idx);
    plot(tempo1, file1(:,c), '-o'); hold on;
    plot(tempo2, file2(:,c), '-x');
    xlabel('Tempo'); ylabel('Valore');
    legend('File1','File2');
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
    c = colsToKeep(idx);   % colonna reale in file1/file2
    col1 = file1(:,c);
    col2 = file2(:,c);
    
    % Calcolo medie ignorando eventuali NaN
    mediaFile1(idx) = mean(col1,'omitnan');
    mediaFile2(idx) = mean(col2,'omitnan');
    
    % Massimi rimangono invariati
    maxFile1(idx) = max(col1);
    maxFile2(idx) = max(col2);
end

%% --- Grafico barre medie e massimi corretto ---
figure('Name','Statistiche Medie e Massimi','NumberTitle','off');


% Matrice barre: ogni riga = file, ogni colonna = colonna dati
barDataMedia = [mediaFile1; mediaFile2];  % 2 x nCol
barDataMax   = [maxFile1; maxFile2];

% --- Media ---
subplot(2,1,1);
bar(barDataMedia');   % trasponi in modo che ogni gruppo di barre sia una colonna dei dati
set(gca,'XTickLabel', colNamesData);
ylabel('Valore medio');
legend('File1','File2');
title('Confronto valori medi');
grid on;

% --- Massimo ---
subplot(2,1,2);
bar(barDataMax');
set(gca,'XTickLabel', colNamesData);
ylabel('Valore massimo');
legend('File1','File2');
title('Confronto valori massimi');
grid on;