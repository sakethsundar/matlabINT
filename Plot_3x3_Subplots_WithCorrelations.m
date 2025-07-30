function Plot_3x3_Subplots_WithCorrelations()
    load('Results_EIBalanceSweep.mat');
    if ~exist('Results', 'var')
        error('Results_EIBalanceSweep.mat must contain variable ''Results''');
    end

    networkTypes = unique(string({Results(:,1).Network}));
    EIRatios = [Results(1,:).EIRatio];
    NodeSizes = 90:139;
    ei_idx = find(abs(EIRatios - 0.50) < 1e-3, 1);  % E/I=0.50
    size_idx = 109 - 89 + 1;  % Network size 109

    figure('Position', [100 100 1400 800]);
    
    for i = 1:numel(networkTypes)
        net = networkTypes(i);
        INT = nan(numel(EIRatios), numel(NodeSizes));
        for j = 1:numel(EIRatios)
            result = Results(i,j);
            if ~isempty(result.MeanINT)
                INT(j,:) = result.MeanINT;
            end
        end

        % Surface Plot
        subplot(3,3,(i-1)*3 + 1);
        surf(NodeSizes, EIRatios, INT, 'EdgeColor', 'none');
        view([45 25]);
        xlabel('Network Size (# nodes)');
        ylabel('E/I Ratio (Excitatory / Total)');
        zlabel('Mean INT');
        title(['Surface: ' net]);
        zlim([0.02 0.09]);
        xlim([90 140]);
        ylim([0 1]);
        colorbar;

        % INT vs Size at E/I = 0.5
        subplot(3,3,(i-1)*3 + 2);
        y1 = INT(ei_idx, :);
        r1 = corrcoef(NodeSizes', y1');
        plot(NodeSizes, y1, 'o-'); hold on;
        p1 = polyfit(NodeSizes, y1, 1);
        plot(NodeSizes, polyval(p1, NodeSizes), '--r');
        text(92, max(y1), sprintf('r = %.2f', r1(1,2)), 'FontSize', 10);
        xlabel('Network Size');
        ylabel('Mean INT');
        title(sprintf('%s: INT vs Size (E/I=0.50)', net));
        grid on;

        % INT vs E/I at fixed size
        subplot(3,3,(i-1)*3 + 3);
        y2 = INT(:, size_idx);
        r2 = corrcoef(EIRatios', y2);
        plot(EIRatios, y2, 'o-'); hold on;
        p2 = polyfit(EIRatios, y2', 1);
        plot(EIRatios, polyval(p2, EIRatios), '--r');
        text(0.05, max(y2), sprintf('r = %.2f', r2(1,2)), 'FontSize', 10);
        xlabel('E/I Ratio');
        ylabel('Mean INT');
        title(sprintf('%s: INT vs E/I (Size=109)', net));
        grid on;
    end

    sgtitle('INT Relationships Across Network Types (Surface + Slices)');
    saveas(gcf, 'INT_3x3_Surface_And_Slices.png');
end
