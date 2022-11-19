function[tp,tn,fp,fn]=prfmnc(tout,yout)
% tout=vec2ind(t)
% yout=vec2ind(y)
aa=0;ab=0;ba=0;bb=0;

for i=1:length(tout)
    if tout(i)==0 && yout(i)==0
        aa=aa+1;
    elseif tout(i)==0 && yout(i)==1
        ab=ab+1;
    elseif tout(i)==1 && yout(i)==0
        ba=ba+1;
    elseif tout(i)==1 && yout(i)==1
        bb=bb+1;
    end
end
tn=aa*100/length(tout);
tp=bb*100/length(tout);
fp=ab*100/length(tout);
fn=ba*100/length(tout);
end
    