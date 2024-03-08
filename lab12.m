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
    p=wyliczPrawdopodobienstwa(n, obraz_oryginalny);
    entropia_oryginalnie=policzEntropie(p);
    
    %% wyswietlenie oryginalnego obrazu %%
    % figure, imshow(obraz_oryginalny, []);
    
    %% psucie obrazu %%
    obraz_popsuty = [[]];
    
    ktory_wiersz=1;
    for i=1:width
        ktora_kolumna=1;
        if(mod(i, 2)~=0)  % jak wiersz nieparzysty to moze dzialac
            for j=1:height
                if(mod(j, 2)~=0)  % jak kolumna nieparzysta to moze dzialac
                    obraz_popsuty(ktory_wiersz, ktora_kolumna)=obraz_oryginalny(i,j);
                    ktora_kolumna=ktora_kolumna+1;
                end
            end
            ktory_wiersz=ktory_wiersz+1;
        end
    end
    [popsute_width, popsute_height] = size(obraz_popsuty);
    
 
    %% pierwszy krok %%
    odtwarzane_width = popsute_width*2;
    odtwarzane_height = popsute_height*2;
    obraz_odtwarzany=[[]];
    
    ktory_wiersz=1;
    for i=1:odtwarzane_width
        ktora_kolumna=1;
        for j=1:odtwarzane_height
            if(mod(i, 2)==0 || mod(j, 2)==0)  % tych wartosci brakuje
                % wybieram sobie jakas wartosc, ktora nie jest w przedziale
                % kolorow RGB, czyli 0-255 (w przypadku matlaba 1-256)
                obraz_odtwarzany(i,j) = -1;  % ta wartosc sam sobie ustalilem
            else
                obraz_odtwarzany(i,j) = obraz_popsuty(ktory_wiersz,ktora_kolumna);  % przepisuje wartosci
                ktora_kolumna=ktora_kolumna+1;
            end
        end
        
        if(mod(i, 2)==0)
            ktory_wiersz=ktory_wiersz+1;
        end
    end
    
    %% obliczenie wspoczynnikow q1 i q2 %%
    m12=0; m21=0; m11=0; m22=0; p1=0; p2=0;
    for i=1:width/2-1
        for j=1:height/2-1
            m12=m12 + obraz_oryginalny(2*i-1, 2*j-1)*obraz_oryginalny(2*i-1, 2*j+1);
            m21=m12;
            m11=m11 + obraz_oryginalny(2*i-1, 2*j-1)^2;
            m22=m22 + obraz_oryginalny(2*i-1, 2*j+1)^2;
            p1=p1 + obraz_oryginalny(2*i-1, 2*j-1)*obraz_oryginalny(2*i-1, 2*j);
            p2=p2 + obraz_oryginalny(2*i-1, 2*j+1)*obraz_oryginalny(2*i-1, 2*j);
        end
    end
    macierzM = [m11, m12; m21, m22];
    wektorP=[p1; p2];
    wektorQ = macierzM^-1 * wektorP;
    q1=wektorQ(1); q2=wektorQ(2);
    
    %% obliczenie wspoczynnikow y1 i y2 %%
    m12=0; m21=0; m11=0; m22=0; p1=0; p2=0;
    for i=1:width/2-1
        for j=1:height/2-1
            m12=m12 + obraz_oryginalny(2*i-1, 2*j-1)*obraz_oryginalny(2*i+1, 2*j-1);
            m21=m12;
            m11=m11 + obraz_oryginalny(2*i-1, 2*j-1)^2;
            m22=m22 + obraz_oryginalny(2*i+1, 2*j-1)^2;
            p1=p1 + obraz_oryginalny(2*i-1, 2*j-1)*obraz_oryginalny(2*i, 2*j-1);
            p2=p2 + obraz_oryginalny(2*i+1, 2*j-1)*obraz_oryginalny(2*i, 2*j-1);
        end
    end
    macierzM = [m11, m12; m21, m22];
    wektorP=[p1; p2];
    wektorY = macierzM^-1 * wektorP;
    y1=wektorY(1); y2=wektorY(2);
    
    %% drugi i trzci krok %%
    z=0.25;
    for i=1:odtwarzane_width
        for j=1:odtwarzane_height
            % jeszcze zabezpieczenia !!
            if(i==odtwarzane_width)  % ostatni wiersz kopiowany z przedostatniego
                obraz_odtwarzany(i,j)=obraz_odtwarzany(i-1,j);
            elseif(j==odtwarzane_height)  % ostatnia kolumna kopiowana z przedostatniej
                obraz_odtwarzany(i,j)=obraz_odtwarzany(i,j-1);
                
            elseif(mod(i, 2)~=0 && mod(j, 2)==0)  % byly wiersze, nie ma kolumn
                obraz_odtwarzany(i,j)=floor(obraz_odtwarzany(i,j-1)*q1 + obraz_odtwarzany(i,j+1)*q2 + 0.5);
            elseif(mod(i, 2)==0 && mod(j, 2)~=0)  % nie bylo wiersza, nieparzyste kolumny
                obraz_odtwarzany(i,j)=floor(obraz_odtwarzany(i-1,j)*y1 + obraz_odtwarzany(i+1,j)*y2 + 0.5);
                
            elseif(mod(i, 2)==0 && mod(j, 2)==0)  % nie bylo wiersza, parzyste kolumny
                obraz_odtwarzany(i,j)=floor(obraz_odtwarzany(i-1,j-1)*z ...  % A z pdf
                + obraz_odtwarzany(i-1,j+1)*z ...  % C z pdf
                + obraz_odtwarzany(i+1,j-1)*z ...  % G z pdf
                + obraz_odtwarzany(i+1,j+1)*z + 0.5);  % I z pdf
            end
        end
    end
    
    
    %% wyliczenie entropii %%
    n=zliczanie(obraz_odtwarzany);
    p=wyliczPrawdopodobienstwa(n, obraz_odtwarzany);
    entropia_popsute=policzEntropie(p);
    
    %% wyliczenie PSNR %%
    licznik = width * height * 255^2;
    mianownik=0;
    for i=1:width
        wartosc=0;
        for j=1:height
            dzialanie=(obraz_oryginalny(i,j) - obraz_odtwarzany(i,j))^2;
            wartosc=wartosc+dzialanie;
        end
        mianownik=mianownik+wartosc;
    end
    PNSR = 10 * log10(licznik / mianownik);  % jednostki dB
    
    %% wyswietlenie wynikow %%
    for ni=1:length(entropia_popsute)
        display(["Nazwa pliku: ", string(nazwa_obrazu + ".bmp");
            "Entropia oryginalnie: ", entropia_oryginalnie;
            "Entropia popsuta: ", entropia_popsute;
            "PNSR: ", PNSR;
            "q1: ", q1;
            "q2: ", q2;
            "y1: ", y1;
            "y2: ", y2]);
        
    end
    
    %% funkcje wewnêtrzne pomocnicze %%
    function[n] = zliczanie(A)
        [width1,height1]=size(A);
        n=zeros(1,zakres_kolorow);
        for i=1:width1
            for j=1:height1
                index=A(i,j)+1;
                n(index)=n(index)+1;  % ile razy jaki kolor wystepuje w obrazku
            
            end
        end
        return;
    end

    function[p] = wyliczPrawdopodobienstwa(n, A)
       [width1,height1]=size(A);
       p=zeros(1,zakres_kolorow);
       for i=1:length(n)
           probka=n(i)/(width1*(height1-1));
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