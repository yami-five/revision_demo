import pygame

class point:
    def __init__(self, x, y,size,outline):
        self.x=x
        self.y=y
        self.size=size
        self.outlineSize=outline
        self.outline=outline*2+size
        self.isActive = False
        
    def move_point(self, pos):
        self.x, self.y = pos
        
    def get_pos(self):
        return (self.x, self.y)
    
    def get_x(self):
        return self.x
    
    def get_y(self):
        return self.y
    
    def out_of_screen(self):
        return (self.x<0 and self.y<0) or (self.x>=screen.get_width() and self.y>=screen.get_height())
    
    def is_clicked(self, mousePos):
        return (mousePos[0]>=self.x-self.outlineSize and mousePos[0]<self.x+self.outline) and (mousePos[1]>=self.y-self.outlineSize and mousePos[1]<self.y+self.outline)

class curve:
    def __init__(self):
        self.points=[
            point(-1,-1,4,3),
            point(-1,-1,4,3),
            point(-1,-1,4,3),
            point(-1,-1,4,3)            
        ]
        
    def add_curve_to_screen(self, mousePos):
        self.points[1].move_point(mousePos)
        self.points[0].move_point((mousePos[0]+20,mousePos[1]))
        self.points[2].move_point((mousePos[0],mousePos[1]+20))
        self.points[3].move_point((mousePos[0]+20,mousePos[1]+20))
        
    def out_of_screen(self):
        return self.points[1].out_of_screen()
    
    def get_points(self):
        return self.points
    
    def draw_lines(self, screen):
        pygame.draw.line(screen, grey,self.points[0].get_pos(),self.points[1].get_pos(),2)
        pygame.draw.line(screen, grey,self.points[1].get_pos(),self.points[2].get_pos(),2)
        pygame.draw.line(screen, grey,self.points[2].get_pos(),self.points[3].get_pos(),2)
        
    def draw_curve(self,screen):
        for i in range (0,100):
            t=i/100
            x,y=0,0
            x=self.points[0].get_x()*(1-t)*(1-t)*(1-t)
            x+=3*self.points[1].get_x()*t*(1-t)*(1-t)
            x+=3*self.points[2].get_x()*t*t*(1-t)
            x+=self.points[3].get_x()*t*t*t

            y=self.points[0].get_y()*(1-t)*(1-t)*(1-t)
            y+=3*self.points[1].get_y()*t*(1-t)*(1-t)
            y+=3*self.points[2].get_y()*t*t*(1-t)
            y+=self.points[3].get_y()*t*t*t
            screen.set_at((int(x),int(y)),white)
        
          

pygame.init()

rect=(128,128)
width, height = 800, 600
scale=3
screen=pygame.display.set_mode((width,height))

points=curve()

white = (255,255,255)
black = (0,0,0)
grey = (127,127,127)
red = (255,0,0)
green = (0,255,0)
blue = (0,0,255)

running=True
clicked=False
activePoint=0
while running:
    screen.fill(black)
    mousePos=pygame.mouse.get_pos()
    # pygame.draw.rect(screen,white,(width/2-(rect[0]/2)*scale,height/2-(rect[1]/2)*scale,rect[0]*scale,rect[1]*scale),1)
    # for x in range (0,rect[0]/8):
    #     pygame.draw.line(screen, grey, width/2-(rect[0]/2)*scale,width/2+(rect[0]/2)*scale)
    for event in pygame.event.get():
        if event.type==pygame.QUIT:
            running=False
    if pygame.mouse.get_pressed()[0] and clicked is False:
        if points.out_of_screen():
            points.add_curve_to_screen(mousePos)
            
    if points.out_of_screen() is False:
        points.draw_lines(screen)
        points.draw_curve(screen)
        for p in points.get_points():
            if p.isActive:
                pygame.draw.rect(screen,green,(p.x-3,p.y-3,p.outline,p.outline))
            else:
                pygame.draw.rect(screen,blue,(p.x-3,p.y-3,p.outline,p.outline))
            pygame.draw.rect(screen,white,(p.x,p.y,p.size,p.size))
            if p.is_clicked(mousePos) or p.isActive:
                if pygame.mouse.get_pressed()[0] and clicked is False:
                    p.isActive=True
                    clicked=True
                if pygame.mouse.get_pressed()[0] and clicked is True:
                    if p.isActive:
                        p.move_point(mousePos)
                if pygame.mouse.get_pressed()[0] is False and clicked is True:
                    clicked=False
                    p.isActive=False

    pygame.display.flip()

pygame.quit()