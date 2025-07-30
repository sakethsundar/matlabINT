function Plot_3x3_SurfaceAndSlices()
    load('Results_EIBalanceSweep.mat');
    
    NetTypes = ["BA", "ER", "WS"];
    EIRatios = [Results(1,:).EIRatio];
    NodeSizes = 90:139;

    fixed_EI_idx = 10;  % E.g., E/I ratio index = 10 (~0.55)
    fixed_Node_idx = 20; % Node size index = 20 (~109)

    figure('Position', [100 100 1600 900]);

    for i = 1:3
        net = NetTypes(i);
        Z = nan(length(NodeSizes), length(EIRatios));
        
        for j = 1:length(EIRatios)
            for k = 1:length(NodeSizes)
                data = Results(i,j).MeanINT;
                if length(data) >= k
                    Z(k,j) = data(k);
                end
            end
        end

        % Surface plot (column 1)
        subplot(3,3,(i-1)*3 + 1);
        surf(EIRatios, NodeSizes, Z, 'EdgeColor', 'none');
        view(45, 30);
        xlabel('E/I Ratio');
        ylabel('Network Size');
        zlabel('Mean INT');
        title(['Surface: ' net]);
        colorbar;

        % 2D INT vs Node Size at fixed E/I ratio (column 2)
        subplot(3,3,(i-1)*3 + 2);
        plot(NodeSizes, Z(:,fixed_EI_idx), '-o');
        xlabel('Network Size');
        ylabel('Mean INT');
        title(sprintf('%s: INT vs Size (E/I=%.2f)', net, EIRatios(fixed_EI_idx)));
        grid on;

        % Correlation
        y = Z(:,fixed_EI_idx);
        valid = ~isnan(y);
        r = corrcoef(NodeSizes(valid), y(valid));
        r = r(1,2);
        text(0.0sen

        % 2D INT vs E/I Ratio at fixed network size (column 3)
        subplot(3,3,(i-1)*3 + 3);
        plot(EIRatios, Z(fixed_Node_idx,:), '-o');
        xlabel('E/I Ratio');
        ylabel('Mean INT');
        title(sprintf('%s: INT vs E/I (Size=%d)', net, NodeSizes(fixed_Node_idx)));
        grid on;

        % Correlation
        y2 = Z(fixed_Node_idx,:);
        valid = ~isnan(y2);
        r2 = corrcoef(EIRatios(valid), y2(valid));
        r2 = r2(1,2);
        text(0.05, 0.9, sprintf('r = %.2f', r2), 'Units','normalized');
    end

    sgtitle('INT Relationships Across Network Types (Surface + Slices)');
    saveas(gcf, 'INT_3x3_Overview.png');
end
