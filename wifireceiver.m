%txsignal = download('hello world', 4);
%[message,l,start] = wifireceiver(txsignal,4);
function [message,l,start] = wifireceiver(txsignal,level)
nfft = 64;
Trellis = poly2trellis(7,[133 171]); 
if level==1
    decoded = vitdec(txsignal(:,65:end),Trellis,35,'trunc','hard');
    colonm = length(decoded)/8;
    bits_new = reshape(decoded,8,colonm);

    str='';

    for i=1:colonm
        a = bits_new(:,i);
        b = 0;
        for j=1:8
            b = b+a(j,1)*2^(8-j);
        end
        if b~=0
            e = char(b);
            str = [str,e];
        end
    
    end
    message = str;
    l = length(message);
    start = 0;
    output = [message,l,start];
end


if level==2
    Interleave = reshape(reshape([1:64], 4, []).', [], 1);
    nsym = length(txsignal)/nfft;
        
    for jj = 1:nsym
        symbol = txsignal(((jj-1)*nfft+1:jj*nfft));
        for kk = 1:32780
            temp = symbol(Interleave);
            txsignal((jj-1)*nfft+1:jj*nfft) = temp;
            symbol = temp;
        end
    end
    level = 1;
    [message,l,start] = wifireceiver(txsignal,level);
end
if level==3
    txsignal = txsignal(:,65:end);
    txsignal = (txsignal+1)/2;
    level = 2;
    [message,l,start] = wifireceiver(txsignal,level);
end
if level==4
    nsym = length(txsignal)/nfft;
    for ii = 1:nsym
        symbol = txsignal((ii-1)*nfft+1:ii*nfft);
        txsignal((ii-1)*nfft+1:ii*nfft) = ifft(symbol);
    end
    
    for ii=1:length(txsignal)
        txsignal(1:ii) = int16(txsignal(1:ii));
    end

    level = 3;
    [message,l,start] = wifireceiver(txsignal,level);
end


end






