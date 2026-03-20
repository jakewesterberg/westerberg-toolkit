function h1 = draw_circle(x,y,r)
ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
h1 = plot(x+xp,y+yp);
end