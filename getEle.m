%% inner function
function A = getEle(B, element)

    try
        eval(strcat('A=B.', element, ';'));
    catch
        A = 0;
    end
end