clc
close all
clear

sum=zeros(1,10);
[sum(1), B1]=wyliczenie1("Image2\airplane");
[sum(2), B2]=wyliczenie1("Image2\baboonTMW");
[sum(3), B3]=wyliczenie1("Image2\balloon");
[sum(4), B4]=wyliczenie1("Image2\BARB");
[sum(5), B5]=wyliczenie1("Image2\BARB2");
[sum(6), B6]=wyliczenie1("Image2\camera256");
[sum(7), B7]=wyliczenie1("Image2\couple256");
[sum(8), B8]=wyliczenie1("Image2\GOLD");
[sum(9), B9]=wyliczenie1("Image2\lennagrey");
[sum(10), B10]=wyliczenie1("Image2\peppersTMW");

sum2=zeros(1,10);
sum2(1)=wyliczenie2(B1);
sum2(2)=wyliczenie2(B2);
sum2(3)=wyliczenie2(B3);
sum2(4)=wyliczenie2(B4);
sum2(5)=wyliczenie2(B5);
sum2(6)=wyliczenie2(B6);
sum2(7)=wyliczenie2(B7);
sum2(8)=wyliczenie2(B8);
sum2(9)=wyliczenie2(B9);
sum2(10)=wyliczenie2(B10);

function[suma, B] = wyliczenie1(nazwa_obrazu) %transformacja
    A=imread(nazwa_obrazu, "bmp");
    A=double(A);
    [width,height]=size(A); % szerokoœæ i wysokoœæ obrazu
    suma=0;
    zakres_kolorow=511;
    
    B=zeros(width,height);
    B=double(B);
    for i=1:width
       for j=1:height
           if(i==1 && j==1)
               B(i,j)=A(i,j);
           elseif(j==1)
               B(i,j)=A(i,j)-A(i-1,j);
           else
               B(i,j)=A(i,j)-A(i,j-1);
           end
       end
    end

    p=zeros(1,zakres_kolorow); %wstêpne wype³nienie zerami wektora
    n=zeros(1,zakres_kolorow);
    for i=1:width
        for j=1:height
            index=B(i,j)+1+255;
            n(index)=n(index)+1; % ile razy jaki kolor wystepuje w obrazku
        end
    end

    for i=1:length(n)
       probka=n(i)/(width*height);
       p(i)=probka;
    end

    for i=1:zakres_kolorow
       dzialanie=0; % zmienna lokalna do obliczeñ
       if ~(p(i)==0) % kiedy jest 0 to nie ma sensu wykonywaæ operacji poni¿ej
            dzialanie=p(i)*log2(p(i));
       end
       suma=suma+dzialanie;
    end
    suma=-suma; % przekszta³cenie i wyœwietlenie wyniku
    return;
end

function[suma] = wyliczenie2(B) %transformacja
    [width,height]=size(B); % szerokoœæ i wysokoœæ obrazu
    suma=0;
    zakres_kolorow=511;
    
    C=zeros(width,height);
    C=double(C);
    for i=1:width
       for j=1:height
           if(i==1 && j==1)
               C(i,j)=B(i,j);
           elseif(j==1)
               C(i,j)=B(i,j)+C(i-1,j);
           else
               C(i,j)=B(i,j)+C(i,j-1);
           end
       end
    end

    p=zeros(1,zakres_kolorow); %wstêpne wype³nienie zerami wektora
    n=zeros(1,zakres_kolorow);
    for i=1:width
        for j=1:height
            index=C(i,j)+1+255;
            n(index)=n(index)+1; % ile razy jaki kolor wystepuje w obrazku
        end
    end

    for i=1:length(n)
       probka=n(i)/(width*height);
       p(i)=probka;
    end

    for i=1:zakres_kolorow
       dzialanie=0; % zmienna lokalna do obliczeñ
       if ~(p(i)==0) % kiedy jest 0 to nie ma sensu wykonywaæ operacji poni¿ej
            dzialanie=p(i)*log2(p(i));
       end
       suma=suma+dzialanie;
    end
    suma=-suma; % przekszta³cenie i wyœwietlenie wyniku
    return;
end