function GenerateEIFigures()

    % Load your saved results file
    load('Results_EIBalanceSweep.mat');  % adjust filename if needed

    %% Clean up and extract values
    EIRatios_raw = [Results.EIRatio];
    nets_raw = {Results.Network};

    % Fix data types
    nets = unique(cellstr(nets_raw), 'stable');  % Ensure char array format
    EIRatios = unique(EIRatios_raw);
    heat = nan(length(nets), length(EIRatios));

    %% Create heatmap of correlations
    for i = 1:length(nets)
        for j = 1:length(EIRatios)
            idx = strcmp(cellstr({Results.Network}), nets{i}) & [Results.EIRatio] == EIRatios(j);
            vals = [Results(idx).CorrR];
            if ~isempty(vals)
                heat(i, j) = mean(vals);
            end
        end
    end

    figure;
    imagesc(heat);
    colormap(parula);
    colorbar;

    xticks(1:length(EIRatios));
    xticklabels(string(EIRatios));
    yticks(1:length(nets));
    yticklabels(nets);
    xlabel('Excitatory Node Ratio');
    ylabel('Network Type');
    title('Correlation between INT and Network Size');

    % Add numeric labels to heatmap cells
    for i = 1:size(heat, 1)
        for j = 1:size(heat, 2)
            val = heat(i, j);
            if ~isnan(val)
                text(j, i, sprintf('%.2f', val), ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', ...
                    'Color', 'w', 'FontWeight', 'bold');
            end
        end
    end

    saveas(gcf, 'Figure_EIBalance_Heatmap.png');

    %% Optional: Line plot version
    figure;
    hold on;
    colors = lines(length(nets));
    for i = 1:length(nets)
        r_vals = nan(size(EIRatios));
        for j = 1:length(EIRatios)
            idx = strcmp(cellstr({Results.Network}), nets{i}) & [Results.EIRatio] == EIRatios(j);
            vals = [Results(idx).CorrR];
            if ~isempty(vals)
                r_vals(j) = mean(vals);
            end
        end
        plot(EIRatios, r_vals, '-o', 'DisplayName', nets{i}, ...
             'LineWidth', 2, 'Color', colors(i,:));
    end
    xlabel('Excitatory Node Ratio');
    ylabel('Correlation (INT vs. Network Size)');
    title('Effect of E/I Balance on INT–Size Correlation');
    legend('Location', 'southwest');
    grid on;

    saveas(gcf, 'Figure_EIBalance_LinePlot.png');

end
