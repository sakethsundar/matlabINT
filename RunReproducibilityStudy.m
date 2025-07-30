function RunReproducibilityStudy()

    % Settings
    NetworkTypes = ["BA", "ER", "WS"];
    AlphaList = 70:10:150;
    AddNodeSize = 50;     % test sizes (can increase later)
    NumExp = 10;          % experiments per config (for speed)

    % Prepare output
    Results = struct();

    % Loop through each configuration
    for iNet = 1:length(NetworkTypes)
        for iAlpha = 1:length(AlphaList)

            fprintf('Running %s network with Alpha = %d\n', NetworkTypes(iNet), AlphaList(iAlpha));

            [MeanINT, CorrR] = RunSimulation(NetworkTypes(iNet), AlphaList(iAlpha), AddNodeSize, NumExp);

            Results(iNet, iAlpha).Network = NetworkTypes(iNet);
            Results(iNet, iAlpha).Alpha = AlphaList(iAlpha);
            Results(iNet, iAlpha).MeanINT = MeanINT;
            Results(iNet, iAlpha).CorrR = CorrR;
        end
    end

    save Results_AlphaSweep70to150.mat Results

    fprintf('✅ Reproducibility study complete. Results saved.\n');

end
