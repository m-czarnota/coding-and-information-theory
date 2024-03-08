clc
close all
clear

sciezka="Audio\";

nazwyPlikow=[];
nazwyPlikow=string(nazwyPlikow);
nazwyPlikow(1)="ATrain.wav";
nazwyPlikow(2)="BeautySlept.wav";
nazwyPlikow(3)="chanchan.wav";
nazwyPlikow(4)="death2.wav";
nazwyPlikow(5)="experiencia.wav";
nazwyPlikow(6)="female_speech.wav";
nazwyPlikow(7)="FloorEssence.wav";
nazwyPlikow(8)="ItCouldBeSweet.wav";
nazwyPlikow(9)="Layla.wav";
nazwyPlikow(10)="LifeShatters.wav";
nazwyPlikow(11)= "macabre.wav";
nazwyPlikow(12)="male_speech.wav";
nazwyPlikow(13)="SinceAlways.wav";
nazwyPlikow(14)="thear1.wav";
nazwyPlikow(15)="TomsDiner.wav";
nazwyPlikow(16)="velvet.wav";

best_q=0;
for i=1:16
    %% wstepne dane %%
   q=5:14;
   Lsr=[];
   efektywnosc=[];
   wykres=false;
   
   %% petla %%
   for j=1:length(q)
       [Lsr(j), efektywnosc(j), plik_zakodowany] = koderGolumba(string(sciezka+nazwyPlikow(i)), q(j));
       % dekoderGolumba(plik_zakodowany, q);
       display([
           "Nazwa pliku: ", nazwyPlikow(i);
           "Wartosc q: ", q(j);
           "srednia bitowa=", Lsr(j);
           "efektywnosc=", efektywnosc(j)
       ]);
   end

    %% zapis do pliku csv %%
    etykiety=["Wartosc q"; "Srednia bitowa"; "Efektywnosc"];
    q1=zeros(length(q), 1);
    Lsr1=zeros(length(q), 1);
    efektywnosc1=zeros(length(q), 1);
    for j=1:length(q)
        q1(j,1)=q(j);
        Lsr1(j,1)=Lsr(j);
        efektywnosc1(j,1)=efektywnosc(j);
    end
    T=table(q1, Lsr1, efektywnosc1, 'VariableNames', etykiety); 
    nazwaPliku = string("golomb_bloki_wykresy\" +nazwyPlikow(i) + ".txt");
    writetable(T, nazwaPliku);
end

function [Lsr_Laczne, Er_Lacznie, plik_wynikowy] = koderGolumba(filename, q)
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
    
    %% podzial na ramki %%
    dlugoscRamek=2^q;
    wielkoscPliku=width;
    ileRamek=wielkoscPliku/dlugoscRamek;
    
    plik_wynikowy=[];
    plik_wynikowy=string(plik_wynikowy);
    wielkosc=0;
    
    %% zapis liczby N jako uint32 %%
    iloscProbek=optimalBinaryStr(width);
    wielkosc=wielkosc+length(iloscProbek);
    ciagBitow="";
    for i=length(iloscProbek)+1:32
        ciagBitow=ciagBitow+"0";
    end
    ciagBitow=ciagBitow+string(iloscProbek);
    plik_wynikowy(1)=ciagBitow;
    
    ktoreOdczytac=1;
    for i=1:ileRamek
        B=[[]];
        for j=1:dlugoscRamek
           B(j,:)=A(ktoreOdczytac,:);
           ktoreOdczytac=ktoreOdczytac+1;
           
           if(ktoreOdczytac==wielkoscPliku)  % zatrzymanie czytania na koncu pliku
               break;
           end
        end
            
        %% algorytm nr 1 %%
        modyfikowane1=algoNr1(B, 1);
        modyfikowane2=algoNr1(B, 2);

        %% srednie arytmetyczne %%
        srednia1=mean(modyfikowane1);
        srednia2=mean(modyfikowane2);

        %% wyliczenie k %%
        p1=wyliczP(srednia1);
        p2=wyliczP(srednia2);

        m1=wyliczM(p1);
        m2=wyliczM(p2);

        %% kodowanie - bardzo dlugie liczenie %%
        [wektor1, iloscBitow1]=kodowanie(modyfikowane1, m1); % wektor stringow par liczb u i v
        [wektor2, iloscBitow2]=kodowanie(modyfikowane2, m2); % wektor stringow par liczb u i v

        %% ilosci bitow w kanalach po zakodowaniu %%
        wielkosc_lokalna=iloscBitow1+iloscBitow2;
        wielkosc=wielkosc+wielkosc_lokalna;

        %% przekopiowanie danych z ramki do pliku wynikowego %%
        gdzieZapisac=length(plik_wynikowy)+1;
        for j=1:length(wektor1)  % przepisanie kanalu lewego
           plik_wynikowy(gdzieZapisac)=wektor1(j); 
           gdzieZapisac=gdzieZapisac+1;
        end
        
        for j=1:length(wektor2)
           plik_wynikowy(gdzieZapisac)=wektor2(j); 
           gdzieZapisac=gdzieZapisac+1;
        end
    end
    
    %% srednia bitowa %%
    Lsr_Laczne=wielkosc/(2*width);

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

function[] = dekoderGolumba(plik_zakodowany, q)
    %% dekodowanie %%
    [zdekodowane, iloscProbek]=dekodowanie(plik_zakodowany, q);
    
    %% odtworzenie macierzy %%
    A=[[]];
    A=algoNr1_reverse(zdekodowane, A, iloscProbek);
    
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

function[A] = algoNr1_reverse(modyfikowane, A, iloscProbek)
    ktoreOdczytac=1;
    for i=1:iloscProbek
        for j=1:2
           if(mod(modyfikowane(ktoreOdczytac), 2)==0)
               A(i, j)=modyfikowane(ktoreOdczytac) / 2;
           else
               A(i, j)=(modyfikowane(ktoreOdczytac)+1) / (-2);
           end
           ktoreOdczytac=ktoreOdczytac+1;
        end
    end
    
    return;
end

function[wektor, iloscBitow] = kodowanie(n, m)
    wektor=[];
    wektor=string(wektor);
    iloscBitow=0;
    
    %% m jako naglowek zakodowanego pliku %%
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

function[zdekodowane, N] = dekodowanie(wektor)
    %% odczytanie liczby probek w kanalach %%
    N=wektor(1);
    N=char(N);
    pierwsza1=false;
    ciagBitow="";
    for i=1:length(N)
        %% pominiecie zer z przodu %%
        wartosc=str2num(N(i));
        if(wartosc==0 && pierwsza1==false)
            continue;
        else
            pierwsza1=true;
        end
        
        %% odczytywanie kolejnych bitow %%
        ciagBitow=ciagBitow+string(wartosc);
    end
    ciagBitow=char(ciagBitow);
    N=bin2dec(ciagBitow);  % liczba probek w kanale
    
    %% obliczanie ilosci ramek %%
    dlugoscRamek=2^q;
    wielkoscPliku=N;
    ileRamek=wielkoscPliku/dlugoscRamek;
    
    zdekodowane=[];
    ktoryElementOdczytac=2;
    gdzieZapisac=1;
    for i=1:ileRamek
        for j=1:2  % dwa kanaly, tyle samo elementow
            %% obsluzenie liczby m w danym kanale %%
            m=wektor(ktoryElementOdczytac);
            ktoryElementOdczytac=ktoryElementOdczytac+1;
            ciagBitow="";
            pierwsza1=false;
            for t=1:length(m)
                wartosc=str2num(m(t));
                if(wartosc==0 && pierwsza1==false)
                    continue;
                else
                    pierwsza1=true;
                end

                %% odczytywanie kolejnych bitow %%
                ciagBitow=ciagBitow+string(wartosc);
            end
            
            ciagBitow=char(ciagBitow);
            m=bin2dec(ciagBitow);  % liczba m w kanale
            m=m+1;
            
            for r=1:dlugoscRamek
                %% zabezpieczenie %%
                if(r>length(wektor))
                    break;
                end
                
                zmienna=wektor(ktoryElementOdczytac); % string
                zmienna=char(zmienna); % char, tablica znaków
                ktoryElementOdczytac=ktoryElementOdczytac+1;
                
                %% obsluzenie kodu liczby uG %%
                ileZer=0;
                ktorePrzejscie=1;
                for t=1:length(zmienna)
                   liczba=str2num(zmienna(t));
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
                for t=1:k-1
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
                zdekodowane(gdzieZapisac)=vG+ileZer*14;
                gdzieZapisac=gdzieZapisac+1;
            end
        end
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
           if(i==1)
               B(i,j)=A(i,j);
           else
               B(i,j)=A(i,j) + (B(i-1,j));
           end
       end
    end
    
    return;
end
