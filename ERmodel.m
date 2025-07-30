function A = ERmodel(n, p)
    A = rand(n) < p;
    A = triu(A,1);
    A = A + A';
    A = double(A > 0);
end
