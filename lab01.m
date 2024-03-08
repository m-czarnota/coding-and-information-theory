clc
close all
clear

% plot(x,y, '-')
% hold on
% grid on;
% plot(-0.271286,0,'rs','MarkerSize',5,'MarkerFaceColor',[1,0,0]);
% plot(-1.22871,0,'rs','MarkerSize',5,'MarkerFaceColor',[1,0,0]);
% xlabel("t");
% ylabel("s(t)");

sum=zeros(1,10);
sum(1)=wyliczenie("Image2\airplane");
sum(2)=wyliczenie("Image2\baboonTMW");
sum(3)=wyliczenie("Image2\balloon");
sum(4)=wyliczenie("Image2\BARB");
sum(5)=wyliczenie("Image2\BARB2");
sum(6)=wyliczenie("Image2\camera256");
sum(7)=wyliczenie("Image2\couple256");
sum(8)=wyliczenie("Image2\GOLD");
sum(9)=wyliczenie("Image2\lennagrey");
sum(10)=wyliczenie("Image2\peppersTMW");

function[suma] = wyliczenie(nazwa_obrazu)
    A=imread(nazwa_obrazu, "bmp");
    A=double(A);
    [width,height]=size(A); % szerokoœæ i wysokoœæ obrazu
    suma=0;
    zakres_kolorow=256;

    p=zeros(1,zakres_kolorow); %wstêpne wype³nienie zerami wektora
    n=zeros(1,zakres_kolorow);
    for i=1:width
        for j=1:height
            n(A(i,j)+1)=n(A(i,j)+1)+1; % ile razy jaki kolor wystepuje w obrazku
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