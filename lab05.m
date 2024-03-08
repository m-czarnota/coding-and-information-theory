clc
close all
clear

sciezka="strumienie\";
nazwyPlikow=[];
nazwyPlikow=string(nazwyPlikow);
nazwyPlikow(1)=strcat(sciezka, "61");
nazwyPlikow(2)=strcat(sciezka, "75");
nazwyPlikow(3)=strcat(sciezka, "90");
nazwyPlikow(4)=strcat(sciezka, "915");
wartoscP=[];
wartoscK=[];
dlugoscPliku=[];
efektywnosc=[];

for i=1:length(nazwyPlikow)
   [wartoscP(i), wartoscK(i), dlugoscPliku(i), efektywnosc(i)] = Rice(nazwyPlikow(i));
   display([ 
       "wartosc p=", wartoscP(i);
       "wartosc k=", wartoscK(i);
       "dlugosc pliku w bitach=", dlugoscPliku(i);
       "efektywnosc=", efektywnosc(i)
   ]);
end

function [p0, k, Lr, Er] = Rice(filename)
    idFile=fopen(filename);
    plik=fread(idFile);
    plik=de2bi(plik);
    size=length(plik);
    display(["size=",size]);

    iloscZer=0;
    for i=1:size
        %display(plik(i));
        if(plik(i)==0)
            iloscZer=iloscZer+1;
        end
    end
    %% wartosci do zwrotu %%
    p0=iloscZer/size;
    k=ceil( log2( log2( (sqrt(5)-1)/2 ) / log2(p0) ) );
    Lr=(1 - p0) * ( k + ( 1 / ( 1 - ( p0 ^ (2^k) ) ) ) );
    Er=( -p0 * log2(p0) - (1 - p0) * log2(1 - p0) ) / Lr * 100;
    
    %% kodowanie %%
    n=[];
    size_n=1;
    ileZer=0;
    for i=1:size
        if(plik(i)==0)
            ileZer=ileZer+1;
        else
            n(size_n)=ileZer;
            size_n=size_n+1;
            ileZer=0;
        end
    end
    
    wektor=[];
    wektor=string(wektor);
    %display(["k=",k]);
    for l=1:length(n)
       %display(["n=",n(l)]);
       ciagBitow="";

       %% obsluga kodu unarnego %%
       u=floor(n(l)/(2^k)); % ile ma byc zer w kodzie unarnym
       %display(["u=",u]);
       for j=1:u
          ciagBitow=strcat(ciagBitow, "0"); 
       end
       ciagBitow=strcat(ciagBitow, "1"); % kod unarny zawsze zakonczony jedynka
       %display(["ciagBitow=",ciagBitow]);

       %% obs³uga vi %%
       if(k>0)
          v=mod(n(l), 2^k);
          %display(["v=",v]);
          v=optimalBinaryStr(v);
          %display(["binary_v=",v]);
          %display(["length(v)=",length(v)]);
          v_klejone="";
          for j=length(v)+1:k
             v_klejone=strcat("0", v_klejone);
          end
          %display(["1)klejone_v=",v_klejone]);
          v=string(v);
          v_klejone=strcat(v_klejone, v);
          %display(["klejone_v=",v_klejone]);
          %display(["przed sklejeniem ciagBitow=", ciagBitow]);
          ciagBitow=strcat(ciagBitow, v_klejone);
          %display(["po sklejeniu ciagBitow=", ciagBitow]);
       end
       
       %% zapisanie pary %%
       wektor(l)=string(ciagBitow);
       wektor(l)=string(wektor(l));
       %display(wektor(l));
    end

    %% zliczanie dlugosci zakodowanego pliku %%
    wielkosc=0;
    for i=1:length(wektor)
        temp=string(wektor(i));
        temp=char(temp);
        for j=1:length(temp)
           wielkosc=wielkosc+1; 
        end
    end
    display(["wielkosc=", wielkosc]);
    
    return;  
end

%% funkcje pomocnicze %%
function [a] = optimalBinaryStr(y)
    x=de2bi(y);
    x=num2str(x);
    x=reverse(x);
    x=char(x);

    a=[];
    a=char(a);
    index=1;
    for i=1:length(x)
        if(x(i)~=' ')
           a(index)=string(x(i));
           index=index+1;
        end
    end

    return;
end