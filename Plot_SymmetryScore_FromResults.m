function Plot_SymmetryScore_FromResults()

    % Load results (this must contain your networks or regenerate a subset)
    load('Results_EIBalanceSweep.mat');

    % Parameters
    EIRatios = [Results(1,:).EIRatio];
    NetworkTypes = string({Results(:,1).Network});
    uniqueTypes = unique(NetworkTypes, 'stable');

    symmetry_scores = nan(length(uniqueTypes), length(EIRatios));

    for iNet = 1:length(uniqueTypes)
        for j = 1:length(EIRatios)
            % Reconstruct the same network (same size as in results)
            N0 = 10;
            NumAddNode = 89 + 25;  % Middle of sweep (adjust as needed)
            M = 10;
            NumNode = N0 + NumAddNode;

            switch uniqueTypes(iNet)
                case "BA"
                    A = BAmodel(N0, NumAddNode, M);
                case "ER"
                    p = 2*M / NumNode;
                    A = ERmodel(NumNode, p);
                case "WS"
                    k = 2*M; beta = 0.1;
                    A = WSmodel(NumNode, k, beta);
            end

            % Apply Dale's Law-based E/I balance
            A_signed = AddEIBalanceByNode(A, EIRatios(j));

            % Symmetry score: 1 = fully symmetric, 0 = fully asymmetric
            diffMat = abs(A_signed - A_signed');
            symmetry_scores(iNet, j) = 1 - sum(diffMat(:)) / sum(abs(A_signed(:)));
        end
    end

    % Plot
    figure;
    hold on;
    colors = lines(length(uniqueTypes));
    for i = 1:length(uniqueTypes)
        plot(EIRatios, symmetry_scores(i,:), '-o', 'LineWidth', 2, ...
             'DisplayName', uniqueTypes(i), 'Color', colors(i,:));
    end

    xlabel('E/I Ratio (Fraction of Excitatory Neurons)');
    ylabel('Symmetry Score');
    title('Network Symmetry vs. E/I Ratio');
    legend('Location', 'southwest');
    grid on;

    saveas(gcf, 'Symmetry_vs_EIRatio_FromResults.png');
end
