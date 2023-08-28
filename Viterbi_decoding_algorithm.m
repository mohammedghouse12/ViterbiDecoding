%Name : Shaik Mohammed Ghouse Basha
%Roll Number : 20EC10073


N = 256;
m = 3;
IT = 50;
data = randi([0 1], IT, N);
y = zeros([N 3]);
bte = zeros([IT 100]);

for j = 1:IT
    for i = 1:N
        if i == 1
            u = 0;
            v = 0;
            w = data(j,1);

        elseif i == 2
            u = 0;
            v = data(j,1);
            w = data(j,2);

        else
            u = data(j,i-2);
            v = data(j,i-1);
            w = data(j,i);
        end
        
        y(i,1) = xor(u,v);
        y(i,2) = xor(xor(u,v),w);
        y(i,3) = xor(u,w);
    end
    
    
    
    p = linspace(0,0.99,100);
    for l = 1:100
        pe = p(l);
        z = bsc(y, pe);
        
        hd = zeros([N 8]);
        for i = 1:N
            hd(i,1) = sum(xor(z(i,:),[0 0 0])); % 00 to 00 or state 0 to 0
            hd(i,2) = sum(xor(z(i,:),[0 0 1])); % 11 to 01 or state 3 to 1
            hd(i,3) = sum(xor(z(i,:),[0 1 0])); % 11 to 11 or state 3 to 3
            hd(i,4) = sum(xor(z(i,:),[0 1 1])); % 00 to 10 or state 0 to 2
            hd(i,5) = sum(xor(z(i,:),[1 0 0])); % 01 to 10 or state 1 to 2
            hd(i,6) = sum(xor(z(i,:),[1 0 1])); % 10 to 11 or state 2 to 3
            hd(i,7) = sum(xor(z(i,:),[1 1 0])); % 10 to 01 or state 2 to 1
            hd(i,8) = sum(xor(z(i,:),[1 1 1])); % 01 to 00 or state 1 to 0
        end
        
        dp = zeros([N 4]); %stores the states in each step
        h_err = zeros([N 4]); % their respective errors
        
        dp(1,:) = [0 inf 0 inf];
        dp(2,:) = [0 2 0 2];
        h_err(1,:) = [hd(1,1) inf hd(1,4) inf];
        h_err(2,:) = [hd(1,1)+hd(2,1) hd(1,4)+hd(2,7) hd(1,1)+hd(2,4) hd(1,4)+hd(2,6)];
        
        for i = 3:N
            h_err(i,1) = min(h_err(i-1,1) + hd(i,1), h_err(i-1,2) + hd(i,8));
            h_err(i,2) = min(h_err(i-1,3) + hd(i,7), h_err(i-1,4) + hd(i,2));
            h_err(i,3) = min(h_err(i-1,1) + hd(i,4), h_err(i-1,2) + hd(i,5));
            h_err(i,4) = min(h_err(i-1,3) + hd(i,6), h_err(i-1,4) + hd(i,3));
        
            if (h_err(i-1,1) + hd(i,1) < h_err(i-1,2) + hd(i,8))
                dp(i,1) = 0;
            else
                dp(i,1) = 1;
            end
        
            if (h_err(i-1,3) + hd(i,7) < h_err(i-1,4) + hd(i,2))
                dp(i,2) = 2;
            else
                dp(i,2) = 3;
            end
        
            if (h_err(i-1,1) + hd(i,4) < h_err(i-1,2) + hd(i,5))
                dp(i,3) = 0;
            else
                dp(i,3) = 1;
            end
        
            if (h_err(i-1,3) + hd(i,6) < h_err(i-1,4) + hd(i,3))
                dp(i,4) = 2;
            else
                dp(i,4) = 3;
            end
        end
        
        [D, I] = min(h_err(256,:));
        k = I-1;
        B = zeros([1 N]);
        
        for i = N:-1:1
            B(i) = k;
            k = dp(i,k+1);
        end
        
        C = zeros([1 N]);
        for i = 1:N
            if (B(i) == 0) || (B(i) == 1)
                C(i) = 0;
            elseif (B(i) == 2) || (B(i) == 3)
                C(i) = 1;
            end
        end
    
        [num, rat] = biterr(data(j,:), C);
        bte(j,l) = rat;
    end
end

mn = mean(bte);
figure
plot(p, mn);
xlabel('crossover probability (p)');
ylabel('Bit error rate (BER)');