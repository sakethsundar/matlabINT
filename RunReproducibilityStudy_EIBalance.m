function RunReproducibilityStudy_EIBalance()
    %% Settings
    NetworkTypes = ["BA", "ER", "WS"];
    EIRatioList = 0.05:0.05:0.95;       % Sweep excitatory ratio from 5% to 95%
    Alpha = 100;                     % Fixed noise level
    AddNodeSize = 50;                % Range of network sizes
    NumExp = 10;                     

    Results = struct();             

    for iNet = 1:length(NetworkTypes)
        for iRatio = 1:length(EIRatioList)
            networkType = NetworkTypes(iNet);
            eiRatio = EIRatioList(iRatio);

            fprintf('[%s] Running %s network with E/I ratio %.2f\n', ...
                datestr(now, 'HH:MM:SS'), networkType, eiRatio);

            [MeanINT, CorrR] = RunSimulation(networkType, Alpha, AddNodeSize, NumExp, eiRatio);

            % Save into array
            Results(iNet, iRatio).Network = networkType;
            Results(iNet, iRatio).Alpha = Alpha;
            Results(iNet, iRatio).EIRatio = eiRatio;
            Results(iNet, iRatio).MeanINT = MeanINT;
            Results(iNet, iRatio).CorrR = CorrR;
        end
    end

    save('Results_EIBalanceSweep.mat', 'Results');
    fprintf('\nResults saved to Results_EIBalanceSweep.mat\n');
end
