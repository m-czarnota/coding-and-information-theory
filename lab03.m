clc
close all
clear

ileElem=16;
sumyLewe=zeros(1,ileElem);
sumyPrawe=zeros(1,ileElem);
srednieDwoch=zeros(1,ileElem);
srednieWszystko=zeros(1,ileElem);
i=1;

[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\ATrain.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\BeautySlept.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\chanchan.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\death2.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\experiencia.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\female_speech.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\FloorEssence.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\ItCouldBeSweet.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\Layla.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\LifeShatters.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\macabre.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\male_speech.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\SinceAlways.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\thear1.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\TomsDiner.wav"); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\velvet.wav"); i=i+1;

for i=1:ileElem
   display(["Suma lewa: ", sumyLewe(i); "Suma prawa: ", sumyPrawe(i); 
       "Œrednie dwóch kolumn: ", srednieDwoch(i); 
       "Œrednie wszystkich kolumn: ", srednieWszystko(i)]);
       
end

function[sumaLewa, sumaPrawa, sredniaDwoch, sredniaWszystko] = entropia(nazwa_pliku)
    A=audioread(nazwa_pliku);
    A=double(A);
    ilosc=(2^15)+1;
    A=floor(A.*ilosc);
    [width,height]=size(A);  
    zakres=2*ilosc;

    n=zliczanie(1, height-1);
    p=wyliczProbki();
    sumaLewa=policzSume();
    
    n=zliczanie(1+1, height);
    p=wyliczProbki();
    sumaPrawa=policzSume();
    
    sredniaDwoch=(sumaLewa + sumaPrawa) / 2;
    sredniaWszystko=(sumaLewa + sumaPrawa + sredniaDwoch) / 3;
    
    return;
    
    %% funkcje wewnêtrzne pomocnicze %%
    function[n] = zliczanie(start, koniec)
        n=zeros(1,zakres);
        for i=1:width
            for j=start:koniec
                index=A(i,j)+1+(ilosc);
                n(index)=n(index)+1; % ile razy jaki kolor wystepuje w obrazku
            end
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

    function[obliczenie] = policzSume()
       obliczenie=0;
       for i=1:zakres
           dzialanie=0; % zmienna lokalna do obliczeñ
           if ~(p(i)==0) % kiedy jest 0 to nie ma sensu wykonywaæ operacji poni¿ej
                dzialanie=p(i)*log2(p(i));
           end
           obliczenie=obliczenie+dzialanie;
       end
       obliczenie=-obliczenie; % przekszta³cenie i wyœwietlenie wyniku
       return; 
    end
end


