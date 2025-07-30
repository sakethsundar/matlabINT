function Plot_INT_vs_EIRatio(targetNodeSize)
    % Load results
    load('Results_EIBalanceSweep.mat');

    % Validate structure
    if ~exist('Results', 'var')
        error('Results_EIBalanceSweep.mat does not contain variable ''Results''');
    end

    % Compute index for target node size
    idx = targetNodeSize - 89;  % Valid for node sizes 90 to 139
    if idx < 1 || idx > size(Results(1,1).MeanINT, 2)
        error('Target node size out of range. Must be between 90 and 139.');
    end

    % Get unique networks and E/I ratios
    nets = unique(string({Results(:,1).Network}), 'stable');
    EIRatios = [Results(1,:).EIRatio];

    figure;
    hold on;
    colors = lines(numel(nets));

    for i = 1:numel(nets)
        INTvals = nan(size(EIRatios));
        for j = 1:numel(EIRatios)
            result = Results(i, j);
            if numel(result.MeanINT) >= idx
                INTvals(j) = result.MeanINT(idx);
            end
        end
        plot(EIRatios, INTvals, '-o', 'DisplayName', nets(i), ...
             'LineWidth', 2, 'Color', colors(i,:));
    end

    xlabel('E/I Ratio (Fraction of Excitatory Neurons)');
    ylabel(sprintf('Mean INT at Network Size %d', targetNodeSize));
    title('INT vs. E/I Ratio');
    legend('Location', 'best');
    grid on;

    saveas(gcf, sprintf('INT_vs_EIRatio_Size%d.png', targetNodeSize));
end
