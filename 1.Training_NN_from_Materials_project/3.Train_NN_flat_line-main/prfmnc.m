function[tp,tn,fp,fn]=prfmnc(t,y)
tout=vec2ind(t);
yout=vec2ind(y);
aa=0;ab=0;ba=0;bb=0;
for i=1:length(tout)
    if tout(i)==1 && yout(i)==1
        aa=aa+1;
    elseif tout(i)==1 && yout(i)==2
        ab=ab+1;
    elseif tout(i)==2 && yout(i)==1
        ba=ba+1;
    elseif tout(i)==2 && yout(i)==2
        bb=bb+1;
    end
end
tp=aa*100/length(tout);
tn=bb*100/length(tout);
fp=ab*100/length(tout);
fn=ba*100/length(tout);
end
    