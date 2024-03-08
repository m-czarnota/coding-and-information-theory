clc
close all
clear

sciezka="Audio\";

nazwyPlikow=[];
nazwyPlikow=string(nazwyPlikow);
nazwyPlikow(1)=sciezka+"ATrain.wav";
nazwyPlikow(2)=sciezka+"BeautySlept.wav";
nazwyPlikow(3)=sciezka+"chanchan.wav";
nazwyPlikow(4)=sciezka+"death2.wav";
nazwyPlikow(5)=sciezka+"experiencia.wav";
nazwyPlikow(6)=sciezka+"female_speech.wav";
nazwyPlikow(7)=sciezka+"FloorEssence.wav";
nazwyPlikow(8)=sciezka+"ItCouldBeSweet.wav";
nazwyPlikow(9)=sciezka+"Layla.wav";
nazwyPlikow(10)=sciezka+"LifeShatters.wav";
nazwyPlikow(11)=sciezka+ "macabre.wav";
nazwyPlikow(12)=sciezka+"male_speech.wav";
nazwyPlikow(13)=sciezka+"SinceAlways.wav";
nazwyPlikow(14)=sciezka+"thear1.wav";
nazwyPlikow(15)=sciezka+"TomsDiner.wav";
nazwyPlikow(16)=sciezka+"velvet.wav";

srednieBitowe=[];
efektywnosc=[];


for i=1:16
   [srednieBitowe(i), efektywnosc(i), wektor1, wektor2, k1, k2] = koderRice(nazwyPlikow(i));
   %A = dekoderRice(wektor1, wektor2, k1, k2);
   display([
       "Nazwa pliku: ", nazwyPlikow(i);
       "srednia bitowa=", srednieBitowe(i);
       "efektywnosc=", efektywnosc(i)
   ]);
end

function [Lsr_Laczne, Er_Lacznie, wektor1, wektor2, k1, k2] = koderRice(filename)
    %% wstepne odczytanie pliku %%
     
    A=audioread(filename);
    A=double(A);
    ilosc=2^16;
    A=floor(A.*2^15+0.5);
    [width,height]=size(A);  
    zakres=2*ilosc-1;
    
    A=kodownieRoznicowe(A);
    
    %% entropie kanalow %%
    n=zliczanie(1);
    p=wyliczProbki();
    sumaLewa=policzEntropie(p);
    
    n=zliczanie(2);
    p=wyliczProbki();
    sumaPrawa=policzEntropie(p);
    
    sredniaDwoch=(sumaLewa + sumaPrawa) / 2;
    
    %% algorytm nr 1 %%
    modyfikowane1=algoNr1(A, 1);
    modyfikowane2=algoNr1(A, 2);
    
    %% srednie arytmetyczne %%
    srednia1=mean(modyfikowane1);
    srednia2=mean(modyfikowane2);
    
    %% wyliczenie k %%
    p1=wyliczP(srednia1);
    p2=wyliczP(srednia2);
    
    k1=wyliczK(p1);
    k2=wyliczK(p2);
    
    %% kodowanie - bardzo dlugie liczenie %%
    [wektor1, iloscBitow1]=kodowanie(modyfikowane1, k1); % wektor stringow par liczb u i v
    [wektor2, iloscBitow2]=kodowanie(modyfikowane2, k2); % wektor stringow par liczb u i v
    
    %% ilosci bitow w kanalach po zakodowaniu %%
    wielkosc=iloscBitow1+iloscBitow2;
    %% srednia bitowa %%
    Lsr_Laczne=wielkosc/(2*size(modyfikowane1,2));
    
    %% efektywnosc procentowa %%
    Er_Lacznie=(sredniaDwoch/Lsr_Laczne)*100;
    
    return; 
    
    %% funkcje wewnêtrzne pomocnicze %%
    function[n] = zliczanie(j)
        n=zeros(1,zakres);
        for i=1:width
            index=A(i,j)+1+(ilosc);
            if(index<=0)
                display(i);
            end
            n(index)=n(index)+1; % ile razy jaki kolor wystepuje w obrazku
        end
        return;
    end

    function[p] = wyliczProbki()
       p=zeros(1,zakres);
       for i=1:length(n)
           probka=n(i)/(width*(height-1));
           p(i)=probka;
       end 
       return;
    end
end

function[A] = dekoderRice(wektor1, wektor2, k1, k2)
    % modyfikowane1: wektor stringow par liczb u i v 
    % modyfikowane2: wektor stringow par liczb u i v
    
    %% otrzymanie wartosci eDaszek(n) %%
    eDaszek1=dekodowanie(wektor1, k1);
    eDaszek2=dekodowanie(wektor2, k2);
    
    %% otrzymanie wartosci e(n) %%
    A=[[]];
    [oryginalne1, A] = algoNr1_reverse(eDaszek1, A, 1);
    [oryginalne2, A] = algoNr1_reverse(eDaszek2, A, 2);
    
    return;
end

%% funkcje pomocnicze %%
function [a] = optimalBinaryStr(y)
    x=dec2bin(y);
    x=reverse(x);
    a=[];
    a=char(a);
    index=1;
    for i=1:length(x)
        if(x(i)~=' ')
           a(index)=x(i);
           index=index+1;
        end
    end

    return;
end

function[obliczenie] = policzEntropie(prob)
   obliczenie=0;
   for i=1:length(prob)
       dzialanie=0; % zmienna lokalna do obliczeñ
       if ~(prob(i)==0) % kiedy jest 0 to nie ma sensu wykonywaæ operacji poni¿ej
            dzialanie=prob(i)*log2(prob(i));
       end
       obliczenie=obliczenie+dzialanie;
   end
   obliczenie=-obliczenie; % przekszta³cenie i wyœwietlenie wyniku
   return; 
end

function[p] = wyliczP(srednia)
    p=0;
    if(srednia>=2) 
        p=(srednia-1)/srednia; 
    else
        p=0.5;
    end
    return;
end

function[k] = wyliczK(p)
    k=ceil( log2( log2( (sqrt(5)-1)/2 ) / log2(p) ) );
    if(k>15)
        k=15;
    end
    return;
end

function[modyfikowane] = algoNr1(A, j)
    k=1;
    [width, height]=size(A);
    modyfikowane=[];
    for i=1:width
        if(A(i,j)>=0)
            modyfikowane(k)=2*A(i,j);
        else
            modyfikowane(k)=-2*A(i,j)-1;
        end
        k=k+1;
    end 
    return;
end

function[oryginalne, A] = algoNr1_reverse(modyfikowane, A, column)
    oryginalne=[];
    for i=1:length(modyfikowane)
       if(mod(modyfikowane, 2)==0)
           A(i, column)=modyfikowane(i) / 2;
       else
           A(i, column)=(modyfikowane(i)+1) / -2;
       end
    end
    
    return;
end

% function[dlugosc] = Lsr(p0, k)
%     dlugosc=(1 - p0) * ( k + ( 1 / ( 1 - ( p0 ^ (2^k) ) ) ) );
%     return;
% end
function[dlugosc] = Lsr(wielkosc, k)
    dlugosc=wielkosc/(2*k);
end

function[efektywnosc] = efekProc(p0, L_sr)
    efektywnosc=( -p0 * log2(p0) - (1 - p0) * log2(1 - p0) ) / L_sr * 100;
    return;
end

function[wektor, iloscBitow] = kodowanie(n, k)
    wektor=[];
    wektor=string(wektor);
    iloscBitow=0;
    
    %% k jako naglowek zakodowanego pliku %%
    k_binary=optimalBinaryStr(k);
    iloscBitow=iloscBitow+length(k_binary);
    k_binary=string(k_binary);
    wektor(1)=k_binary;
    
    for l=1:length(n)
       zmienna=n(l);
       ciagBitow="";

       %% obsluga kodu unarnego %%
       u=floor(zmienna/(2^k)); % ile ma byc zer w kodzie unarnym
       for j=1:u
          ciagBitow=ciagBitow+"0"; 
          iloscBitow=iloscBitow+1;
       end
       ciagBitow=ciagBitow+"1"; % kod unarny zawsze zakonczony jedynka
       iloscBitow=iloscBitow+1;

       %% obs³uga vi %%
       if(k>0)
          v=mod(zmienna, 2^k);
          v=optimalBinaryStr(v);
          iloscBitow=iloscBitow+length(v);
          v_klejone=""; % dodadkowe v, ktore zawiera zera
          for j=length(v)+1:k
             v_klejone=v_klejone+v_klejone;
             iloscBitow=iloscBitow+1;
          end
          v=string(v); % aby moc skleic ze soba string i char, char zamienic na string
          v_klejone=v_klejone+v;
          ciagBitow=ciagBitow+v_klejone;
       end

       %% zapisanie pary %%
       if (ciagBitow=="") 
           disp('blad')
       end
       wektor(l+1)=string(ciagBitow);
       wektor(l+1)=string(wektor(l+1));
    end 

    return;
end



function[B] = kodownieRoznicowe(A)
    [width, height]=size(A);
    B=zeros(width,height);
    for i=1:width
       for j=1:height
           if(i==1)
               B(i,j)=A(i,j);
           else
               B(i,j)=A(i,j) - A(i-1,j);
           end
       end
    end
end


