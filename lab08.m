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
   [srednieBitowe(i), efektywnosc(i), wektor1, wektor2] = koderGolumba(nazwyPlikow(i));
   % dekoderGolumba(wektor1, wektor2);
   display([
       "Nazwa pliku: ", nazwyPlikow(i);
       "srednia bitowa=", srednieBitowe(i);
       "efektywnosc=", efektywnosc(i)
   ]);
end

function [Lsr_Laczne, Er_Lacznie, wektor1, wektor2] = koderGolumba(filename)
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
    
    m1=wyliczM(p1);
    m2=wyliczM(p2);
    
    %% testy %%
%     test=0:1:31;
%     m=14;
%     [wektor1, iloscBitow]=kodowanie(test, m);
%     display(length(wektor1));
%     for i=1:length(wektor1)
%        display([string(i-2) + string(": "), wektor1(i)]); 
%     end
    
    %% kodowanie - bardzo dlugie liczenie %%
    [wektor1, iloscBitow1]=kodowanie(modyfikowane1, m1); % wektor stringow par liczb u i v
    [wektor2, iloscBitow2]=kodowanie(modyfikowane2, m2); % wektor stringow par liczb u i v
    
    %% ilosci bitow w kanalach po zakodowaniu %%
    wielkosc=iloscBitow1+iloscBitow2;
    
    %% srednia bitowa %%
    Lsr_Laczne=wielkosc/(2*length(modyfikowane1));
    
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

function[] = dekoderGolumba(wektor1, wektor2)
    %% dekodowanie %%
    modyfikowane1=dekodowanie(wektor1);
    modyfikowane2=dekodowanie(wektor2);
    
    %% odtworzenie macierzy %%
    A=[[]];
    A=algoNr1_reverse(modyfikowane1, A, 1);
    A=algoNr1_reverse(modyfikowane2, A, 2);
    
    A=dekodowanieRoznicowe(A);
end

%% funkcje pomocnicze %%
function [a] = optimalBinaryStr(y)
    x=dec2bin(y);
    % x=reverse(x); % a tutaj dobrze jest zamieniana liczba binarnie
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

function[m] = wyliczM(p)
    m=ceil( -(log10(1+p) / log10(p)) );
    if(m>2^14)
        m=2^14;
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

function[A] = algoNr1_reverse(modyfikowane, A, column)
    for i=1:length(modyfikowane)
       if(mod(modyfikowane(i), 2)==0)
           A(i, column)=modyfikowane(i) / 2;
       else
           A(i, column)=(modyfikowane(i)+1) / (-2);
       end
    end
    
    return;
end

function[wektor, iloscBitow] = kodowanie(n, m)
    wektor=[];
    wektor=string(wektor);
    iloscBitow=0;
    
    %% k jako naglowek zakodowanego pliku %%
    m_binary=optimalBinaryStr(m-1);
    m_binary_length=length(m_binary); % zapamietanie ilosci bitow binarnego m
    iloscBitow=iloscBitow+m_binary_length; % nabicie obecnych bitow
    m_binary=string(m_binary); % zmiana binarnego m na string
    
    if(m_binary_length<14) % m da sie zapisac na 14 bitach, jak nie ma 14 to dodawaj 0 na poczatek
       for i=m_binary_length+1:14
          m_binary="0"+m_binary;
          iloscBitow=iloscBitow+1;
       end
    end
    wektor(1)=m_binary; % parametr m zapisany na 14 bitach
    
    for i=1:length(n)
       zmienna=n(i);
       ciagBitow="";

       %% obsluga kodu unarnego %%
       uG=floor(zmienna/m); % ile ma byc zer w kodzie unarnym
       for j=1:uG
          ciagBitow=ciagBitow+"0"; 
          iloscBitow=iloscBitow+1;
       end
       ciagBitow=ciagBitow+"1"; % kod unarny zawsze zakonczony jedynka
       iloscBitow=iloscBitow+1;

       %% obs³uga vG %%
       if(m>0)
          vG=zmienna - uG * m;
          k=ceil(log2(m)); % pomocniczy parametr k
          l=2^k - m; % ile pierwszych wartosci kodowanych jest za pomoca k-1 bitow
          v_klejone="";
          if(vG<l) % gdy v mniejsze od l
%               if(vG>1) % moze tu byc potencjalny problem
%                   display(["vG wieksze od 1: ", vG]);
%               end
              
              vG_binary=optimalBinaryStr(vG);
              iloscBitow=iloscBitow+length(vG_binary);
              v_klejone=v_klejone+string(vG_binary);
              
              for j=length(vG_binary)+1:k-1 
                 v_klejone="0"+v_klejone;
                 iloscBitow=iloscBitow+1;
              end
          else
              vG=vG+l; % dodanie do vG wartosci l
              
              vG_binary=optimalBinaryStr(vG); % vG do postaci binarnej
              v_klejone=v_klejone+string(vG_binary); % bity vG doklejone do stringa
              iloscBitow=iloscBitow+length(vG_binary); % dodanie liczby bitow, ktore ma binarnie vG
              
              for j=length(vG_binary)+1:k % jak liczba bitow mniejsza niz k
                  v_klejone="0"+v_klejone; % to uzupelnienie az do k bitami zerowymi
                  iloscBitow=iloscBitow+1; % dodanie kolejnej ilosci bitow
              end
          end
          
          ciagBitow=ciagBitow+v_klejone;
       end

       %% zapisanie pary %%
       wektor(i+1)=string(ciagBitow);
       wektor(i+1)=string(wektor(i+1));
    end 

    return;
end

function[modyfikowane] = dekodowanie(wektor)
    %% odczytanie wartosci m %%
    m=string(wektor(1));
    m=char(m);
    m_klejone="";
    ileZer=0;
    pierwsza1=false;
    for i=1:length(m)
        zmienna=str2num(m(i));
        if(zmienna==0 && pierwsza1==false)
            ileZer=ileZer+1;
        else
            pierwsza1=true;
        end
        
        if(pierwsza1==true)
           m_klejone=m_klejone+m(i);
        end
    end
    
    m_klejone=char(m_klejone);
    m=bin2dec(m_klejone) + 1;
    
    modyfikowane=[];
    for i=2:length(wektor)
        zmienna=wektor(i); % string
        zmienna=char(zmienna); % char, tablica znaków
        
        %% obsluzenie kodu liczby uG %%
        ileZer=0;
        ktorePrzejscie=1;
        for j=1:length(zmienna)
           liczba=str2num(zmienna(j));
           if(liczba==0)
               ktorePrzejscie=ktorePrzejscie+1;
               ileZer=ileZer+1;
               continue;
           else
               break; 
           end
        end
        ktorePrzejscie=ktorePrzejscie+1;
        
        %% odtworzenie liczby vG %%
        k=ceil(log2(m));
        l=2^k - m;
        vG_klejone="";
        for j=1:k-1
            vG_klejone=vG_klejone+zmienna(ktorePrzejscie);
            ktorePrzejscie=ktorePrzejscie+1;
        end
        
        v=char(vG_klejone);
        v=bin2dec(v);
        vG=0;
        if(v<l)
            vG=v;
        else
            q=zmienna(ktorePrzejscie);
            q=str2num(q);
            vG = 2 * v + q - l;
        end
        
        %% zapamietanie odwtorzonej wartosci %%
        modyfikowane(i-1)=vG+ileZer*14;
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

function[B] = dekodowanieRoznicowe(A)
    [width, height]=size(A);
    B=zeros(width,height);
    B=double(B);
    for i=1:width
       for j=1:height
           %display(length(B(i)));
           if(i==1)
               B(i,j)=A(i,j);
           else
               B(i,j)=A(i,j) + (B(i-1,j));
%                if(B(i,j)>ilosc)
%                    display(["B(i,j)=",B(i,j); "A(i,j)=",A(i,j); "A(i,j-1)=",A(i,j-1)]);
%                end
           end
       end
    end
    
    return;
end
