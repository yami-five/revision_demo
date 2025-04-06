import pygame
from enum import Enum

class modes(Enum):
    MODIFY = 1
    ADD = 2
    CHOOSE = 3
    REMOVE = 4

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
            
    def get_point_by_pos(self,pos):
        for p in self.points:
            if p.is_clicked(pos):
                return p

class workspacePoint:
    def __init__(self, x, y):
        self.x=x
        self.y=y
        
    def get_pos(self):
        return (self.x, self.y)
    
    def get_x(self):
        return self.x
    
    def get_y(self):
        return self.y
        
class workspace:
    def __init__(self, width, height, scale, screen):
        self.width=width
        self.height=height
        x=screen.get_width()/2-(width/2)*scale
        y=screen.get_height()/2-(height/2)*scale 
        self.a=workspacePoint(x,y)
        self.b=workspacePoint(x+width*scale,y+height*scale)
        self.scale=scale
        
    def get_size(self):
        return (width,height)   
    
    def get_width(self):
        return self.width
    
    def get_height(self):
        return self.height
    
    def get_scale(self):
        return self.scale
    
    def get_a(self):
        return self.a
    
    def get_b(self):
        return self.b
    
    def draw_workspace(self,screen):
        width=self.width*self.scale
        height=self.height*self.scale
        pygame.draw.rect(screen,white,(self.a.get_x()-1,self.a.get_y()-1,width+2,height+2),1)
        pygame.draw.rect(screen,teal,(self.a.get_x(),self.a.get_y(),width,height))
        x=self.get_a().get_x()
        y=self.get_a().get_y()
        width=self.get_width()
        height=self.get_height()
        for i in range(0,width//8):
            pygame.draw.line(screen, midnight_blue, (x+i*8*self.get_scale(),y),(x+i*8*self.get_scale(),y+height*self.scale-1),1)
        for i in range(0,self.height//8):
            pygame.draw.line(screen, midnight_blue, (x,y+i*8*self.get_scale()),(x+width*self.scale-1,y+i*8*self.get_scale()),1)  
    
    def out_of_workspace(self,pos):
        return (pos[0]<self.a.get_x() and pos[1]<self.a.get_y()) or (pos[0]>=self.b.get_x() and pos[1]>=self.b.get_y())

def save_curves_to_file(curves,targetScreen):
    result=""
    with open('curve.txt', 'w') as file:
        for c in curves:
            for p in c.get_points():
                x=int((p.get_x()-targetScreen.get_a().get_x())//targetScreen.get_scale())
                y=int((p.get_y()-targetScreen.get_a().get_y())//targetScreen.get_scale())
                result+=f'{x},{y},'
        file.write(result[:-1])
        

pygame.init()

delay=100
currentMode=modes.MODIFY
activeCurve=-1
lastActiveCurve=-1
width, height = 800, 600
scale=3
screen=pygame.display.set_mode((width,height))
targetScreen=workspace(128,128,scale,screen)
pygame.display.set_caption("curve editor")

white = (255,255,255)
black = (0,0,0)
grey = (127,127,127)
red = (255,0,0)
green = (0,255,0)
blue = (0,0,255)
teal = (0,128,128)
midnight_blue = (25,25,112)

font = pygame.font.SysFont(None, 24)
text_surface = font.render("ctrl + S - save to file    lmb + a - choose active curve    lmb + c - add curve    lmb + r - remove curve", True, green)

curves=[]

running=True
clicked=False

while running:
    screen.fill(black)    
    mousePos=pygame.mouse.get_pos()
    targetScreen.draw_workspace(screen)
    for event in pygame.event.get():
        if event.type==pygame.QUIT:
            running=False
        if event.type==pygame.KEYDOWN:
            keys = pygame.key.get_mods()
            if keys & pygame.KMOD_CTRL:
                if event.key == pygame.K_s:
                    print("save")
                    save_curves_to_file(curves, targetScreen)
            if  event.key == pygame.K_a:
                print("choose")
                currentMode=modes.CHOOSE    
            if  event.key == pygame.K_c:
                print("add")
                currentMode=modes.ADD
            if  event.key == pygame.K_r:
                print("remove")
                currentMode=modes.REMOVE
        if event.type == pygame.KEYUP:
            currentMode=modes.MODIFY
        
    if pygame.mouse.get_pressed()[0] and clicked is False and currentMode==modes.ADD and delay==100:
        curves.append(curve())
        curves[len(curves)-1].add_curve_to_screen(mousePos)
        delay=0
        
    if pygame.mouse.get_pressed()[0] and clicked is False and currentMode==modes.CHOOSE:
        for i in range(0,len(curves)):
            p=curves[i].get_point_by_pos(mousePos)
            if p is not None:
                lastActiveCurve=activeCurve
                activeCurve=i
                break
            
    if pygame.mouse.get_pressed()[0] and clicked is False and currentMode==modes.REMOVE:
        curveToRemove=-1
        for i in range(0,len(curves)):
            p=curves[i].get_point_by_pos(mousePos)
            if p is not None:
                curveToRemove=i
                break
        if curveToRemove>=0:
            del curves[curveToRemove]
            if activeCurve==curveToRemove:
                activeCurve=-1
                lastActiveCurve=-1
            if activeCurve>curveToRemove:
                activeCurve-=1
            if lastActiveCurve>curveToRemove:
                lastActiveCurve-=1
                      
    for i in range(0,len(curves)):
        curves[i].draw_lines(screen)
        curves[i].draw_curve(screen)
        for p in curves[i].get_points():
            if i==activeCurve:
                if p.isActive:
                    pygame.draw.rect(screen,green,(p.x-3,p.y-3,p.outline,p.outline))
                else:
                    pygame.draw.rect(screen,blue,(p.x-3,p.y-3,p.outline,p.outline))
            else:
                pygame.draw.rect(screen,red,(p.x-3,p.y-3,p.outline,p.outline))
            pygame.draw.rect(screen,white,(p.x,p.y,p.size,p.size))
    
    if(activeCurve>=0):
        for p in curves[activeCurve].get_points():
            if (p.is_clicked(mousePos) or p.isActive) and targetScreen.out_of_workspace(mousePos) is False:
                if pygame.mouse.get_pressed()[0] and clicked is False:
                    p.isActive=True
                    clicked=True
                if pygame.mouse.get_pressed()[0] and clicked is True:
                    if p.isActive:
                        p.move_point(mousePos)
                if pygame.mouse.get_pressed()[0] is False and clicked is True:
                    clicked=False
                    p.isActive=False
                if p.isActive is False:
                    p.move_point(((p.get_x()//targetScreen.get_scale())*targetScreen.get_scale(),(p.get_y()//targetScreen.get_scale())*targetScreen.get_scale()))

    screen.blit(text_surface, (20, height-100))
    if delay<100:
        delay+=1
    
    pygame.display.flip()

pygame.quit()