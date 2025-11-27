function outlinedText(x,y,string,color)
    hold on;
    % contorno nero
    text(x+0.01, y, string, 'Color','k', 'FontSize',10, 'HorizontalAlignment','center');
    text(x-0.01, y, string, 'Color','k', 'FontSize',10, 'HorizontalAlignment','center');
    text(x, y+0.01, string, 'Color','k', 'FontSize',10, 'HorizontalAlignment','center');
    text(x, y-0.01, string, 'Color','k', 'FontSize',10, 'HorizontalAlignment','center');
    % testo principale
    text(x, y, string, 'Color',color, 'FontSize',10, ...
        'HorizontalAlignment','center', 'FontWeight','bold');
end