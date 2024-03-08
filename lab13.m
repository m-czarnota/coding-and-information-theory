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
    zakres_kolorow=511;
    
    %% obliczenie entropii %%
    n=zliczanie(obraz_oryginalny);
    p=wyliczPrawdopodobienstwa(n, obraz_oryginalny);
    entropia_oryginalnie=policzEntropie(p);
    
    %% wyswietlenie oryginalnego obrazu %%
    % figure, imshow(obraz_oryginalny, []);
    
    %% dwukrotne zmniejszenie obrazu %%
    obraz_zmniejszony = [[]];
    
    ktory_wiersz=1;
    for i=1:width
        ktora_kolumna=1;
        if(mod(i, 2)~=0)  % jak wiersz nieparzysty to moze dzialac
            for j=1:height
                if(mod(j, 2)~=0)  % jak kolumna nieparzysta to moze dzialac
                    obraz_zmniejszony(ktory_wiersz, ktora_kolumna)=obraz_oryginalny(i,j);
                    ktora_kolumna=ktora_kolumna+1;
                end
            end
            ktory_wiersz=ktory_wiersz+1;
        end
    end
    [zmniejszone_width, zmniejszone_height] = size(obraz_zmniejszony);
    
    %% usuniecie 2 najmlodszych bitow %%
    obraz_zmniejszony=floor(obraz_zmniejszony / 2^2);
    
    %% kodowanie roznicowe %%
    obraz_zakodowany = [[]];
    for i=1:zmniejszone_width
        for j=1:zmniejszone_height
            if(i==1 && j==1)  % pierwszy piksel przepisany bez zmian
               obraz_zakodowany(i,j)=obraz_zmniejszony(i,j);
            elseif(j==1)  % pierwsza kolumna wykorzystuje wartosc wyzej
                obraz_zakodowany(i,j)=obraz_zmniejszony(i,j)-obraz_zmniejszony(i-1,j);
            elseif(i==1)  % pierwszy wiersz wykorzystuje wartoœæ z lewej
                obraz_zakodowany(i,j)=obraz_zmniejszony(i,j)-obraz_zmniejszony(i,j-1);
            else
                p1 = obraz_zmniejszony(i, j-1);
                p2 = obraz_zmniejszony(i-1, j);
                p3 = obraz_zmniejszony(i-1, j-1);
                xMed = min([p1,p2,p3]) + max([p1,p2,p3]) - p3;
                obraz_zakodowany(i,j)=obraz_zmniejszony(i,j)-floor(xMed);
            end
        end
    end
    
    %% wyliczenie entropii obrazu zakodowanego %%
    n=zliczanie(obraz_zakodowany);
    p=wyliczPrawdopodobienstwa(n, obraz_zakodowany);
    entropia_zmniejszone=policzEntropie(p);
    
    %% wyliczenie stopnia kompresji %%
    stopien_kompresji = 8*4 / entropia_zmniejszone;
    
    %% dekodowanie roznicowe - takie jak w lab2 %%
    obraz_zdekodowany = [[]];
    for i=1:zmniejszone_width
       for j=1:zmniejszone_height
           if(i==1 && j==1)
               obraz_zdekodowany(i,j)=obraz_zakodowany(i,j);
           elseif(j==1)
               obraz_zdekodowany(i,j)=obraz_zakodowany(i,j)+obraz_zdekodowany(i-1,j);
           else
               obraz_zdekodowany(i,j)=obraz_zakodowany(i,j)+obraz_zdekodowany(i,j-1);
           end
       end
    end
    
    %% przywrocenie zakresu bitowego %%
    obraz_zdekodowany = floor(obraz_zdekodowany * 2^2 + 2);
    
    %% przywrocenie pierwotnej rozdzielczosci zmniejszonego obrazu %%
    odtwarzane_width = zmniejszone_width*2;
    odtwarzane_height = zmniejszone_height*2;
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
                obraz_odtwarzany(i,j) = obraz_zdekodowany(ktory_wiersz,ktora_kolumna);  % przepisuje wartosci
                ktora_kolumna=ktora_kolumna+1;
            end
        end
        
        if(mod(i, 2)==0)
            ktory_wiersz=ktory_wiersz+1;
        end
    end
    
    %% drugi i trzci krok %%
    q=0.5; y=0.5; z=0.25;
    for i=1:odtwarzane_width
        for j=1:odtwarzane_height
            % jeszcze zabezpieczenia !!
            if(i==odtwarzane_width)  % ostatni wiersz kopiowany z przedostatniego
                obraz_odtwarzany(i,j)=obraz_odtwarzany(i-1,j);
            elseif(j==odtwarzane_height)  % ostatnia kolumna kopiowana z przedostatniej
                obraz_odtwarzany(i,j)=obraz_odtwarzany(i,j-1);
            elseif(mod(i, 2)~=0 && mod(j, 2)==0)  % byly wiersze, nie ma kolumn
                obraz_odtwarzany(i,j)=floor(obraz_odtwarzany(i,j-1)*q + obraz_odtwarzany(i,j+1)*q + 0.5);
            elseif(mod(i, 2)==0 && mod(j, 2)~=0)  % nie bylo wiersza, nieparzyste kolumny
                obraz_odtwarzany(i,j)=floor(obraz_odtwarzany(i-1,j)*y + obraz_odtwarzany(i+1,j)*y + 0.5);
            elseif(mod(i, 2)==0 && mod(j, 2)==0)  % nie bylo wiersza, parzyste kolumny
                obraz_odtwarzany(i,j)=floor(obraz_odtwarzany(i-1,j-1)*z ...  % A z pdf
                + obraz_odtwarzany(i-1,j+1)*z ...  % C z pdf
                + obraz_odtwarzany(i+1,j-1)*z ...  % G z pdf
                + obraz_odtwarzany(i+1,j+1)*z + 0.5);  % I z pdf
            end
            
            if(obraz_odtwarzany(i,j)>255)
                obraz_odtwarzany(i,j)=255;
            end
            if(obraz_odtwarzany(i,j)<1)
                obraz_odtwarzany(i,j)=0;
            end
        end
    end
    
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
    PSNR = 10 * log10(licznik / mianownik);  % jednostki dB
    
    %% wyswietlenie wynikow %%
    display(["Nazwa pliku: ", string(nazwa_obrazu + ".bmp");
        "Entropia oryginalnie: ", entropia_oryginalnie;
        "Entropia zmniejszone: ", entropia_zmniejszone;
        "Stopien kompresji: ", stopien_kompresji;
        "PSNR: ", PSNR]);
    
    %% funkcje wewnêtrzne pomocnicze %%
    function[n] = zliczanie(A)
        [width1,height1]=size(A);
        n=zeros(1,zakres_kolorow);
        for i=1:width1
            for j=1:height1
                if(A(i,j)>255)  % sprawdzenie
                    display(["i: ", i; "j: ", j; "A(i,j): ", A(i,j)]);
                end
                
                index=A(i,j)+1 + 255;
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