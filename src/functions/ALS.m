function [corrected_baseline] = ALS(y,smoothness,asymmetry)
input_shape = size(y);
y = y(:);
len_signal  = length(y);

p      = asymmetry;  
Lambda =  smoothness;  

% second derivative calculation matrix iteration.
 len_signal = length(y);
 derivative = [1 -2 1];
 D = zeros(len_signal - 2 ,len_signal);

 for i = 1:len_signal-2
    count = 1;         
    for j = i:len_signal
        if count < 4
            D(i,j) = derivative(count);
            count = count + 1;
        else
            break       
        end
    end
end

penalty = D'*D;


w = ones(len_signal, 1);% weight initialization        
baseline = [];
for iter = 1:100 %iteration define
    W        = diag(w);                          
    baseline = (W + Lambda*penalty) \ (w .* y);  
    
    w        = p*(y > baseline) + (1-p)*(y <  baseline);  %weight update
                    
end

corrected_baseline = y - baseline;
corrected_baseline = reshape(corrected_baseline, input_shape); %restore t