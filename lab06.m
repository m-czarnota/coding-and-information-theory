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
   [wartoscP(i), wartoscK(i), dlugoscPliku(i), efektywnosc(i), wektor] = koderRice(nazwyPlikow(i));
   [wartoscP(i), wartoscK(i), dlugoscPliku(i), efektywnosc(i)] = dekoderRice(wektor, wartoscK(i));
   display([ 
       "wartosc p=", wartoscP(i);
       "wartosc k=", wartoscK(i);
       "dlugosc pliku w bitach=", dlugoscPliku(i);
       "efektywnosc=", efektywnosc(i)
   ]);
end

function [p0, k, Lr, Er, wektor] = koderRice(filename)
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
          v_klejone=""; % dodadkowe v, ktore zawiera zera
          for j=length(v)+1:k
             v_klejone=strcat("0", v_klejone);
          end
          %display(["1)klejone_v=",v_klejone]);
          v=string(v); % aby moc skleic ze soba string i char, char zamienic na string
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
    %display(["wielkosc=", wielkosc]);

    return;  
end

function [p0, k, Lr, Er] = dekoderRice(wektor, k)
%% dekodowanie %%
    wektor2=[];
    wektor2=string(wektor2);
    for i=1:length(wektor)
       %% zliczanie zer %%
       ui=0;
       %display(["wektor(i)=",wektor(i)]);
       zmienna=string(wektor(i)); % dla pewnosci jeszcze raz na string
       zmienna=char(zmienna); % string mozna konwertowac na char
       %display(["zmienna=",zmienna]);
       %display(["length(zmienna)=",length(zmienna)]);
       for j=1:length(zmienna)
           liczba=zmienna(j); % pojedynczy znak
           %display(["liczba=",liczba]);
           liczba=str2num(liczba); % %konwersja znaku do liczby
           %display(["liczba+1=",liczba+1]);
           if(liczba~=0) % kiedy nie ma 0
               break; % koniec liczenia 
               %continue;
           end
           ui=ui+1; % jest 0, policz
       end
       %display(["ui=",ui]);
       
       %% wczytanie k bitow %%
       vi=0;
       if(k>0)
           ktorePrzejscie=ui+2; % ile zliczylo + jedynka na koncu + obecny stan
           %if(zmienna(ktorePrzejscie)!=1
           vi="";
           for j=1:k
               liczba=zmienna(ktorePrzejscie);
               vi=strcat(vi, liczba);
               ktorePrzejscie=ktorePrzejscie+1;
           end
           %display(["vi=",vi]);
           vi=bin2dec(vi); % wartosc binarna na decymalna (string jest widziany takze jako bin)
           %display(["convertion_vi=",vi]);
       end
       
       %% odtwarzanie wartoœci ni %%
       ni=ui * 2^k + vi;
       %display(["ni=",ni]);
       temp="";
       for j=1:ni % ciag ni zer
          temp=strcat("0", temp); 
       end
       temp=strcat(temp, "1"); % zakonczonych jedynka
       %display(["temp=",temp]);
       wektor2(i)=string(temp);
       %display(["wektor2(i)=",wektor2(i)]);
    end
    
    size=length(wektor2);
    %display(["size=",size]);
    iloscZer=0;
    ileBitow=0; % ile lacznie wszystkich bitow w pliku
    for i=1:size;
        %display(["wektor2(i)=", wektor2(i)]);
        zmienna=wektor2(i);
        zmienna=char(zmienna);
        %display(["length(zmienna)=",length(zmienna)]);
        for l=1:length(zmienna)
           temp=str2num(zmienna(l));
           ileBitow=ileBitow+1;
           if(temp==0)
              iloscZer=iloscZer+1; 
           end
        end
    end
    %display(["iloscZer=",iloscZer]);
    
    %% wartosci do zwrotu %%
    p0=iloscZer/ileBitow;
    k=ceil( log2( log2( (sqrt(5)-1)/2 ) / log2(p0) ) );
    Lr=(1 - p0) * ( k + ( 1 / ( 1 - ( p0 ^ (2^k) ) ) ) );
    Er=( -p0 * log2(p0) - (1 - p0) * log2(1 - p0) ) / Lr * 100;
    
    %return;
    
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