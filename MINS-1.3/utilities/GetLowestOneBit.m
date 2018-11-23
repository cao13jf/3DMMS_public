function b = GetLowestOneBit(n)

s = dec2bin(n);
for k = length(s):-1:1
    if s(k) == '1'
        b = length(s) - k;
        return ;
    end
end

