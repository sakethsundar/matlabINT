function dxdt = SinOscillatorWithNoise01(x, A, epsilon, ~, Omega, Noise)
    dxdt = Omega + epsilon * (cos(x) .* (A * sin(x)) - sin(x) .* (A * cos(x))) + Noise;
end
