clc;
close all;
clear all;
Directory=input('Please input the file directory','s');
%File 1
%First column of the excel file: Bus number
%Second column of the excel file: Bus number
%Transmission lines are connected between two buses
%Third column of the excel file:Line Resistance (pu)
%Fourth column of the excel file: Line Inductance (pu)
File1=input('Please input the file1','s');
%File 2
%Bus_1 is the slack bus (Reference bus)
%First column of the excel file: Bus number
%Second column of the excel file: Bus voltage (abs) in pu
%Third column of the excel file: Bus voltage angle (radian)
%Fourth column of the excel file: P_generated (pu)
%Fifth column of the excel file: Q_generated (pu)
%Sixth column of the excel file: P_load (pu)
%Seventh column of the excel file: Q_load (pu)
File2=input('Please input the file2','s');
cd(Directory)
A=xlsread(File1)
B=xlsread(File2)
 Length=size(A,1);
 NB=max(max(A));
 tol=0.00000000001;
 itr=0;
 for i=1:Length
     z(A(i,1),A(i,2))=A(i,3)+1j*A(i,4);
     z(A(i,2),A(i,1))=z(A(i,1),A(i,2));
 end
 for i=1:NB
     for j=1:NB
         if z(i,j)==0
             z(i,j)=inf;
         end
     end
 end
 for i=1:NB
     for j=1:NB
         y(i,j)=1./z(i,j);
     end
 end
 for i=1:NB
     for j=1:NB
         if i==j
             Y(i,j)=sum(y(i,:));
         else
             Y(i,j)=-y(i,j);
         end
     end
 end
 Y_Bus=[Y]
 Vabs=B(:,2);
 Vang=B(:,3);
 Pt=B(:,4)-B(:,6);
 Qt=B(:,5)-B(:,7);
 Vcom=B(:,2).*exp(1j*B(:,3));
 for k=1:100
     for i=2:NB
         Vprev(i)=Vcom(i);
         SPV=0;
         if Pt(i)>0
             for j=1:NB
             SPV=SPV+Vcom(j)*Y(i,j);
             I(i)=SPV;
             end
             S(i)=Vcom(i)*conj(I(i));
             Q(i)=imag(S(i));
             S(i)=Pt(i)+1j*Q(i);
         else
             S(i)=Pt(i)+1j*Qt(i);
         end
         SBYV=0;
         for j=1:NB
             SBYV=SBYV+Vcom(j)*Y(i,j);
             VY(i)=SBYV;
         end
         VY(i)=VY(i)-Vcom(i)*Y(i,i);
         if Pt(i)>0
             Vcom(i)=(1/Y(i,i))*((conj(S(i))/(conj(Vcom(i))))-VY(i));
             Vimag(i)=imag(Vcom(i));
             Vreal(i)=sqrt(((Vabs(i))^2)-(Vimag(i))^2);
             Vcom(i)=Vreal(i)+1j*Vcom(i);
         else
             Vcom(i)=(1/Y(i,i))*((conj(S(i))/(conj(Vcom(i))))-VY(i));
         end
     end
     for i=1:NB
         Vabs(i)=abs(Vcom(i));
         Vang(i)=angle(Vcom(i));
         Vangd(i)=rad2deg(Vang((i)));
     end
     term=1;
     for i=2:NB
         if (Vprev(i)-Vcom(i))<tol
             term=1*term;
         else
             term=0;
         end
     end
     itr=itr+1;
     if term==1
         break;
     end
 end
for k=1:NB
fprintf('Bus %i Voltage (Angle in Radian): %4f<%4f\n',k,Vabs(k),Vang(k));
end
for k=1:NB
fprintf('Bus %i Voltage (Angle in Degree): %4f<%4f\n',k,Vabs(k),Vangd(k));
end
