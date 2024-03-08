clc
close all
clear

ileElem=16;
sumyLewe=zeros(1,ileElem);
sumyPrawe=zeros(1,ileElem);
srednieDwoch=zeros(1,ileElem);
srednieWszystko=zeros(1,ileElem);
opcja=1;
i=1;

[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\ATrain.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\BeautySlept.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\chanchan.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\death2.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\experiencia.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\female_speech.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\FloorEssence.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\ItCouldBeSweet.wav", opcja); i=i+1;
%[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\Layla.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\LifeShatters.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\macabre.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\male_speech.wav", opcja); i=i+1;
%[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\SinceAlways.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\thear1.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\TomsDiner.wav", opcja); i=i+1;
[sumyLewe(i), sumyPrawe(i), srednieDwoch(i), srednieWszystko(i)]=entropia("Audio\velvet.wav", opcja); i=i+1;

for i=1:ileElem
   display(["Suma lewa: ", sumyLewe(i); "Suma prawa: ", sumyPrawe(i); 
       "Œrednie dwóch kolumn: ", srednieDwoch(i); 
       "Œrednie wszystkich kolumn: ", srednieWszystko(i)]);
       
end

function[sumaLewa, sumaPrawa, sredniaDwoch, sredniaWszystko] = entropia(nazwa_pliku, opcja)
    A=audioread(nazwa_pliku);
    A=double(A);
    ilosc=2^16;
    A=floor(A.*ilosc+0.5);
    [width,height]=size(A);  
    zakres=2*ilosc-1;
    
    display("start");
    B=zeros(width,height);
    B=double(B);
    for i=1:width
       for j=1:height
           %display(length(B(i)));
           if(i==1)
               B(i,j)=A(i,j);
           else
               B(i,j)=A(i,j) - A(i-1,j);
               if(B(i,j)>ilosc)
                   display(["B(i,j)=",B(i,j); "A(i,j)=",A(i,j); "A(i,j-1)=",A(i,j-1)]);
               end
           end
       end
    end
    display("koniec");
    
    if(opcja==0)
        C=zeros(width,height);
        C=double(C);
        for i=1:width
           for j=1:height
               %display(length(B(i)));
               if(i==1)
                   C(i,j)=B(i,j);
               else
                   C(i,j)=B(i,j) + (C(i-1,j));
                   if(C(i,j)>ilosc)
                       display(["C(i,j)=",C(i,j); "B(i,j)=",B(i,j); "B(i,j-1)=",B(i,j-1)]);
                   end
               end
           end
        end
        B=C;
    end
    
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
                index=B(i,j)+1+(ilosc);
                if(index<=0)
                    display(i);
                end
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


