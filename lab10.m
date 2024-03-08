clc
close all
clear

nazwyPlikow=[];
nazwyPlikow=string(nazwyPlikow);

nazwyPlikow(1)="airplane";
nazwyPlikow(2)="baboonTMW";
nazwyPlikow(3)="balloon";
nazwyPlikow(4)="BARB";
nazwyPlikow(5)="BARB2";
nazwyPlikow(6)="camera256";
nazwyPlikow(7)="couple256";
nazwyPlikow(8)="GOLD";
nazwyPlikow(9)="lennagrey";
nazwyPlikow(10)="peppersTMW";

for i=1:length(nazwyPlikow)
    analiza(nazwyPlikow(i));
end

function[] = analiza(nazwa_obrazu)
    %% wczytanie obrazu %%
    obraz_oryginalny=imread(string("Image2/" + nazwa_obrazu), "bmp");
    obraz_oryginalny=double(obraz_oryginalny);
    
    %% zmienne wstepne %%
    [width,height]=size(obraz_oryginalny);  % szerokoœæ i wysokoœæ obrazu
    zakres_kolorow=256;
    
    %% obliczenie entropii %%
    n=zliczanie(obraz_oryginalny);
    p=wyliczPrawdopodobienstwa(n);
    entropia_oryginalnie=policzEntropie(p);
    
    %% wyswietlenie oryginalnego obrazu %%
    figure, imshow(obraz_oryginalny, []);
    
    %% psucie obrazu %%
    entropia_popsute=[];
    PNSR_zebrane=[];
    
    for ni=1:6
        %% zepsucie obrazu - zerowanie n najmlodszych bitow %%
        obraz_zepsuty=floor(obraz_oryginalny / 2^ni) * 2^ni;
        
        %% wyswietlanie popsutego obrazu %%
        figure, imshow(obraz_zepsuty, []);
        
        %% entropia zepsutego obrazu %%
        n=zliczanie(obraz_zepsuty);
        p=wyliczPrawdopodobienstwa(n);
        entropia=policzEntropie(p);
        entropia_popsute(ni)=entropia;
        
        %% wyliczenie PSNR %%
        licznik = width * height * 255^2;
        mianownik=0;
        for i=1:width
            wartosc=0;
            for j=1:height
                dzialanie=(obraz_oryginalny(i,j) - obraz_zepsuty(i,j))^2;
                wartosc=wartosc+dzialanie;
            end
            mianownik=mianownik+wartosc;
        end
        PNSR = 10 * log10(licznik / mianownik);  % jednostki dB
        PNSR_zebrane(ni)=PNSR;
    end
    
    %% wyswietlenie wynikow %%
    for ni=1:length(entropia_popsute)
        display(["Nazwa pliku: ", string(nazwa_obrazu + ".bmp");
            "Entropia oryginalnie: ", entropia_oryginalnie;
            "Ile najmlodszych bitow usunieto: ", ni;
            "Entropia popsuta: ", entropia_popsute(ni);
            "PNSR: ", PNSR_zebrane(ni)]);
        
    end
    
    %% zapis do pliku txt %%
    etykiety=["Entropia oryginalnie"; "Ile najmlodszych bitow usunieto"; 
        "Entropia popsuta"; "PNSR"];
    rozmiar=length(entropia_popsute);
    e0=zeros(rozmiar, 1);
    n1=zeros(rozmiar, 1);
    e1=zeros(rozmiar, 1);
    pnsr1=zeros(rozmiar, 1);
    for j=1:rozmiar
        e0(j,1)=entropia_oryginalnie;
        n1(j,1)=j;
        e1(j,1)=entropia_popsute(j);
        pnsr1(j,1)=PNSR_zebrane(j);
    end
    T=table(e0, n1, e1, pnsr1, 'VariableNames', etykiety); 
    nazwaPliku = string("PNSR_informacje\" + nazwa_obrazu + ".txt");
    writetable(T, nazwaPliku);
    
    %% funkcje wewnêtrzne pomocnicze %%
    function[n] = zliczanie(A)
        n=zeros(1,zakres_kolorow);
        for i=1:width
            for j=1:height
                index=A(i,j)+1;
                n(index)=n(index)+1;  % ile razy jaki kolor wystepuje w obrazku
            
            end
        end
        return;
    end

    function[p] = wyliczPrawdopodobienstwa(n)
       p=zeros(1,zakres_kolorow);
       for i=1:length(n)
           probka=n(i)/(width*(height-1));
           p(i)=probka;
       end 
       return;
    end
end

function[obliczenie] = policzEntropie(prob)
   obliczenie=0;
   for i=1:length(prob)
       dzialanie=0;  % zmienna lokalna do obliczeñ
       if ~(prob(i)==0)  % kiedy jest 0 to nie ma sensu wykonywaæ operacji poni¿ej
            dzialanie=prob(i)*log2(prob(i));
       end
       obliczenie=obliczenie+dzialanie;
   end
   obliczenie=-obliczenie;  % przekszta³cenie i wyœwietlenie wyniku
   return; 
end