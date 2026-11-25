

function [corrected_baseline] = airPLS(y,smoothness)

%for change the shape of Y to column matrix 
input_shape = size(y);
y = y(:);
len_signal  = length(y);

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

 w = ones(len_signal, 1);% weight initialization to zero
    
imax = 150; % max no of iteration

% min error stopping criterion % changed from ALS algorithm
i = 1;
error = 1;
while true

    W        = diag(w);                          
    % baseline = (W + Lambda*penalty) \ (w .* y);  
    baseline = (W + Lambda*penalty + 1e-8*eye(len_signal)) \ (w .* y);

                        %weight update
   
    diff        = y-baseline;
    diff_neg    = diff(diff<0);

    error = sum(abs(diff_neg)); % sum of squared error used 
    w = zeros(len_signal, 1);% weight initialization to zero 
    w(diff < 0) = exp((i * diff_neg) / error);
    
     

    if error < 0.001*sum(abs(diff_neg)) 
        break 
    elseif i >= imax 
            break 
    end
    i = i+1; % for iteration only

end

corrected_baseline = y - baseline;
corrected_baseline = reshape(corrected_baseline, input_shape); %restore t

fprintf(" Max no of iteration reached %d",i )


end

%search of airPLS baseline to be 