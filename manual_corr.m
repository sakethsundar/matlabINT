function r = manual_corr(x, y)
    x = x(:);
    y = y(:);
    x = x - mean(x);
    y = y - mean(y);
    r = sum(x .* y) / sqrt(sum(x.^2) * sum(y.^2));
end
