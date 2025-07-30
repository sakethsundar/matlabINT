function Plot_3DSurface_INT(targetNet)
    % Load results file
    load('Results_EIBalanceSweep.mat');

    % Make sure network name is valid
    targetNet = string(targetNet);
    allNets = unique(string({Results(:,1).Network}));
    if ~ismember(targetNet, allNets)
        error('Network type "%s" not found in results.', targetNet);
    end

    % Get E/I ratios and node sizes
    EIRatios = [Results(1,:).EIRatio];
    NodeSizes = 90:139;  % 50 sizes

    % Initialize Z (mean INTs)
    Z = nan(length(NodeSizes), length(EIRatios));

    for j = 1:length(EIRatios)
        for i = 1:length(NodeSizes)
            res = Results(:, j);
            idx = find(string({res.Network}) == targetNet);
            if isempty(idx)
                continue;
            end
            val = res(idx).MeanINT;
            if numel(val) >= i
                Z(i, j) = val(i);  % Row = size, Col = ratio
            end
        end
    end

    %% 3D Surface Plot
    figure;
    surf(EIRatios, NodeSizes, Z, 'EdgeColor', 'none');
    view(45, 30);
    set(gca, 'XDir', 'normal');
    xlabel('E/I Ratio (Excitatory / Total)');
    ylabel('Network Size (# nodes)');
    zlabel('Mean INT');
    title(sprintf('3D Surface: INT vs. E/I Ratio and Network Size (%s)', targetNet));
    colorbar;
    set(gca, 'XDir', 'normal', 'YDir', 'normal');

    %% 2D Slice: INT vs. Network Size at fixed E/I Ratio
    targetRatio = 0.5;  % Adjust this
    [~, j] = min(abs(EIRatios - targetRatio));
    INT_vs_Size = Z(:, j);

    figure;
    plot(NodeSizes, INT_vs_Size, '-o', 'LineWidth', 2, 'DisplayName', 'INT values');
    hold on;

    % Fit and plot regression line
    coeffs = polyfit(NodeSizes, INT_vs_Size, 1);
    fitLine = polyval(coeffs, NodeSizes);
    plot(NodeSizes, fitLine, '--r', 'LineWidth', 1.5, 'DisplayName', 'Linear fit');

    % Compute and annotate correlation
    valid = ~isnan(INT_vs_Size);
    r1 = corrcoef(NodeSizes(valid), INT_vs_Size(valid));
    r1 = r1(1,2);
    legend('Location', 'northwest');
    title(sprintf('INT vs. Network Size at E/I Ratio = %.2f (%s)\nCorr = %.2f', ...
        EIRatios(j), targetNet, r1));
    xlabel('Network Size (# nodes)');
    ylabel('Mean INT');
    grid on;

    %% 2D Slice: INT vs. E/I Ratio at fixed Network Size
    targetSize = 120;  % Adjust this
    [~, i] = min(abs(NodeSizes - targetSize));
    INT_vs_EI = Z(i, :);

    figure;
    plot(EIRatios, INT_vs_EI, '-o', 'LineWidth', 2, 'DisplayName', 'INT values');
    hold on;

    % Fit and plot regression line
    coeffs = polyfit(EIRatios, INT_vs_EI, 1);
    fitLine = polyval(coeffs, EIRatios);
    plot(EIRatios, fitLine, '--r', 'LineWidth', 1.5, 'DisplayName', 'Linear fit');

    % Compute and annotate correlation
    valid = ~isnan(INT_vs_EI);
    r2 = corrcoef(EIRatios(valid), INT_vs_EI(valid));
    r2 = r2(1,2);

    legend('Location', 'northwest');
    title(sprintf('INT vs. E/I Ratio at Network Size = %d (%s)\nCorr = %.2f', ...
        NodeSizes(i), targetNet, r2));
    xlabel('E/I Ratio (Excitatory / Total)');
    ylabel('Mean INT');
    grid on;
end
