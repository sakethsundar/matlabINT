function A_signed = AddEIBalanceByNode(A, EIRatio)
    % Assigns each node as excitatory (+1) or inhibitory (-1)
    % All outgoing edges from a node get the same sign

    N = size(A, 1);
    numExc = round(EIRatio * N);

    neuron_types = -ones(N, 1);             % Default: inhibitory
    perm = randperm(N);
    neuron_types(perm(1:numExc)) = 1;       % Random excitatory neurons

    % Multiply each row by the neuron's type
    A_signed = A .* neuron_types;
end
