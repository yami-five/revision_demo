pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
t=0
light="50,50,50"
calc_light=false
zBuffer={}
tex='677765677656777677776566665677777777655ee55677777776555ee55567776665555ee55556665555555665555555665555677655556676eee6e77e6eee6776eee6eeee6eee676655556ee655556655555556655555556665555ee55556667776555ee55567777777655ee556777777776566665677776777656776567776'
cameraMatrix="0,0,5,0,0,0,0,1,0,0,0,0,0,0,0"
-- 1-3 position
-- 4-6 target
-- 7-9 up vector
-- 10-12 right vector
-- 13-15 forward vector
viewMatrix="0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
perspectiveMatrix="0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"

function _init()
    cameraMatrix=split(cameraMatrix)
    viewMatrix=split(viewMatrix)
    perspectiveMatrix=split(perspectiveMatrix)
    -- forward vector
    cameraMatrix[13]=cameraMatrix[1]-cameraMatrix[4]
    cameraMatrix[14]=cameraMatrix[2]-cameraMatrix[5]
    cameraMatrix[15]=cameraMatrix[3]-cameraMatrix[6]
    cameraMatrix[13],cameraMatrix[14],cameraMatrix[15]=normalizeVec(cameraMatrix[13],cameraMatrix[14],cameraMatrix[15])
    -- right vector
    cameraMatrix[10]=cameraMatrix[8]*cameraMatrix[15]+cameraMatrix[9]*cameraMatrix[14]
    cameraMatrix[11]=cameraMatrix[9]*cameraMatrix[13]+cameraMatrix[7]*cameraMatrix[15]
    cameraMatrix[12]=cameraMatrix[7]*cameraMatrix[14]+cameraMatrix[8]*cameraMatrix[13]
    cameraMatrix[10],cameraMatrix[11],cameraMatrix[12]=normalizeVec(cameraMatrix[10],cameraMatrix[11],cameraMatrix[12])
    -- up vector
    cameraMatrix[7]=cameraMatrix[14]*cameraMatrix[12]+cameraMatrix[15]*cameraMatrix[11]
    cameraMatrix[8]=cameraMatrix[15]*cameraMatrix[10]+cameraMatrix[13]*cameraMatrix[12]
    cameraMatrix[9]=cameraMatrix[13]*cameraMatrix[11]+cameraMatrix[14]*cameraMatrix[10]
    cameraMatrix[7],cameraMatrix[8],cameraMatrix[9]=normalizeVec(cameraMatrix[7],cameraMatrix[8],cameraMatrix[9])
    --view matrix
    viewMatrix[1]=cameraMatrix[10]
    viewMatrix[2]=cameraMatrix[11]
    viewMatrix[3]=cameraMatrix[12]
    viewMatrix[4]=-(cameraMatrix[10]*cameraMatrix[1]+cameraMatrix[11]*cameraMatrix[2]+cameraMatrix[12]*cameraMatrix[3])
    viewMatrix[5]=cameraMatrix[7]
    viewMatrix[6]=cameraMatrix[8]
    viewMatrix[7]=cameraMatrix[9]
    viewMatrix[8]=-(cameraMatrix[7]*cameraMatrix[1]+cameraMatrix[8]*cameraMatrix[2]+cameraMatrix[9]*cameraMatrix[3])
    viewMatrix[9]=cameraMatrix[13]
    viewMatrix[10]=cameraMatrix[14]
    viewMatrix[11]=cameraMatrix[15]
    viewMatrix[12]=-(cameraMatrix[13]*cameraMatrix[1]+cameraMatrix[14]*cameraMatrix[2]+cameraMatrix[15]*cameraMatrix[3])
    viewMatrix[16]=1
    --perspective matrix
    perspectiveMatrix[1]=1/1.619775 --1/(tan(fov/2)*aspect ratio)
    perspectiveMatrix[6]=1/1.619775
    perspectiveMatrix[11]=-((100+1)/(100-1)) -- -((zfar+znear)/(zfar-znear))
    perspectiveMatrix[12]=-((2*100*1)/(100-1)) -- -(2*zfar*znear/(zfar-znear))
    perspectiveMatrix[15]=-1
    -- music(0)
    printh("pos "..cameraMatrix[1]..","..cameraMatrix[2]..","..cameraMatrix[3],"log.txt")
    printh("target "..cameraMatrix[4]..","..cameraMatrix[5]..","..cameraMatrix[6],"log.txt")
    printh("up "..cameraMatrix[7]..","..cameraMatrix[8]..","..cameraMatrix[9],"log.txt")
    printh("right "..cameraMatrix[10]..","..cameraMatrix[11]..","..cameraMatrix[12],"log.txt")
    printh("forward "..cameraMatrix[13]..","..cameraMatrix[14]..","..cameraMatrix[15],"log.txt")
    printh("view","log.txt")
    printh(viewMatrix[1]..","..viewMatrix[2]..","..viewMatrix[3]..","..viewMatrix[4],"log.txt")
    printh(viewMatrix[5]..","..viewMatrix[6]..","..viewMatrix[7]..","..viewMatrix[8],"log.txt")
    printh(viewMatrix[9]..","..viewMatrix[10]..","..viewMatrix[11]..","..viewMatrix[12],"log.txt")
    printh(viewMatrix[13]..","..viewMatrix[14]..","..viewMatrix[15]..","..viewMatrix[16],"log.txt")
    printh("perspective","log.txt")
    printh(perspectiveMatrix[1]..","..perspectiveMatrix[2]..","..perspectiveMatrix[3]..","..perspectiveMatrix[4],"log.txt")
    printh(perspectiveMatrix[5]..","..perspectiveMatrix[6]..","..perspectiveMatrix[7]..","..perspectiveMatrix[8],"log.txt")
    printh(perspectiveMatrix[9]..","..perspectiveMatrix[10]..","..perspectiveMatrix[11]..","..perspectiveMatrix[12],"log.txt")
    printh(perspectiveMatrix[13]..","..perspectiveMatrix[14]..","..perspectiveMatrix[15]..","..perspectiveMatrix[16],"log.txt")
    for i=1,128*128 do
        add(zBuffer,0)
    end
    light=split(light)
end

function clearZBuffer()
    for i=1,128*128 do
        add(zBuffer,0)
    end    
end

function mulMatrixVector(x,y,z,w,matrix)
    resultX,resultY,resultZ,resultW=0,0,0,0
    resultX+=x*matrix[1]+y*matrix[2]+z*matrix[3]+w*matrix[4]
    resultY+=x*matrix[5]+y*matrix[6]+z*matrix[7]+w*matrix[8]
    resultZ+=x*matrix[9]+y*matrix[10]+z*matrix[11]+w*matrix[12]
    resultW+=x*matrix[13]+y*matrix[14]+z*matrix[15]+w*matrix[16]
    return resultX,resultY,resultZ,resultW
end

function v3_len(vec)
    return sqrt(vec[1]*vec[1]+vec[2]*vec[2]+vec[3]*vec[3])        
end


function normalizeVec(x, y, z)
    local len = sqrt(x * x + y * y + z * z)
    x/=len
    y/=len
    z/=len
    return x, y, z
end

function checkIfTriVisible(a,b,c,d,e,f)
    local e1x,e1y,e2x,e2y=c-a,d-b,e-a,f-b;
    return (e1x*e2y-e1y*e2x)>=0
end    

function inf(t,x,y)
	x+=2*(cos(t))
	y+=2*cos(t)*sin(t)
    return x,y
end
    
function rotate(x,y,a)
    local c,s=cos(a),sin(a)
    return c*x-s*y, s*x+c*y
end

function translation(x,y,z,xT,yT,zT)
    return x+xT,y+yT,z+zT
end

function baricentricCoords(x,yp2y,inv,p0,p1,p2,fac)
    local Ba,Bb=((p1[2]-p2[2])*(x*2+fac-p2[1])+(p2[1]-p1[1])*yp2y)*inv,((p2[2]-p0[2])*(x*2+fac-p2[1])+(p0[1]-p2[1])*yp2y)*inv
    local Bc=1-Ba-Bb 
    return Ba, Bb, Bc
end

function texturing(Ba,Bb,Bc,uv0,uv1,uv2,tex_size,texture,tsts)
    local uv_x,uv_y=Ba*uv0[1]+Bb*uv1[1]+Bc*uv2[1],Ba*uv0[2]+Bb*uv1[2]+Bc*uv2[2]
    uv_x = max(0, min(1, uv_x))
    uv_x=flr(uv_x*tex_size)+1
    uv_y = max(0, min(1, uv_y))
    uv_y=flr(uv_y*tex_size)+1
    return texture[max(0, min(tsts, flr(uv_y *tex_size + uv_x)))]
end

function checkDepth(Ba, Bb, Bc, z0, z1, z2, x, y)
    z = 1/((Ba*1/z0)+(Bb*1/z1)+(Bc*1/z2))
    addr=x*128+y
    if(z>zBuffer[addr]) then
        zBuffer[addr]=z
        return 1
    else
        return 0
    end
end

function rasterize(y, x0, x1, uv0, uv1, uv2, inv,p0,p1,p2,l_int,tex_size,texture,fast,tsts)
    if (y<0 or y>127) return
    local q,n
    local yp2y=y-p2[2]
    n=(flr(y)%2+0.5)*0.5
    x0+=n;
    x1+=n;
    if (x1<x0) q=x0 x0=x1 x1=q
    if (x1<0 or x0>127) return
    y=flr(y+0.5);
    if (x0<0) x0=0
    if (x1>123) x1=123
    x0,x1=flr(x0/2+0.5),flr(x1/2+0.5)
    for x = x0, x1, 1 do
        local color="0x11"
        local Ba,Bb,Bc=baricentricCoords(x,yp2y,inv,p0,p1,p2,0)
        if(checkDepth(Ba, Bb, Bc, p0[3], p1[3], p2[3], x, y)) then
            if(l_int>0.3)then
                local texture_color1 = texturing(Ba,Bb,Bc,uv0,uv1,uv2,tex_size,texture,tsts)
                if(l_int>0.97)then color="0xa"..texture_color1
                elseif(l_int<=0.97 and l_int>0.5)then
                    color="0x"..texture_color1..texture_color1
                elseif(l_int<=0.5)then color="0x1"..texture_color1
                end
            end
            poke(0x6000 + y * 0x40 + x, color)
        end
    end
end

function tri(x0,y0,z0,x1,y1,z1,x2,y2,z2,uv0,uv1,uv2,l_int,tex_size,texture,fast,tsts)
    local x,xx,y,q,q2,uv;
    if (y0>y1) y=y0;y0=y1;y1=y;x=x0;x0=x1;x1=x;uv=uv0;uv0=uv1;uv1=uv;z=z0;z0=z1;z1=z;
    if (y0>y2) y=y0;y0=y2;y2=y;x=x0;x0=x2;x2=x;uv=uv0;uv0=uv2;uv2=uv;z=z0;z0=z2;z2=z;
    if (y1>y2) y=y1;y1=y2;y2=y;x=x1;x1=x2;x2=x;uv=uv1;uv1=uv2;uv2=uv;z=z2;z2=z1;z1=z;
    local dx01,dy01,dx02,dy02;
    local xd,xxd;
    if (y2<0 or y0>127) return
    y,x,xx=y0,x0,x0;
    dx01,dy01,dy02,dx02,dx12,dy12,q2,xxd=x1-x0,y1-y0,y2-y0,x2-x0,x2-x1,y2-y1,0,1;
    if(x2<x0) xxd=-1
    inv=1/((y1-y2)*(x0-x2)+(x2-x1)*(y0-y2))
    if flr(y0)<flr(y1) then
        q,xd=0,1;
        if(x1<x0) xd=-1
        while y<=y1 do
            rasterize(y,x,xx,uv0,uv1,uv2,inv,{x0,y0,z0},{x1,y1,z1},{x2,y2,z2},l_int,tex_size,texture,fast,tsts);
            y+=1;
            q+=dx01;
            q2+=dx02;
            while xd*q>=dy01 do
                q-=xd*dy01
                x+=xd
            end
            while xxd*q2>=dy02 do
                q2-=xxd*dy02
                xx+=xxd
            end
        end
    end
    
    if flr(y1)<flr(y2) then
        q,x,xd=0,x1,1;
        if (x2<x1) xd=-1
        while y<=y2 and y<128 do
            rasterize(y,x,xx,uv0,uv1,uv2,inv,{x0,y0,z0},{x1,y1,z1},{x2,y2,z2},l_int,tex_size,texture,fast,tsts);
            y+=1;
            q+=dx12;
            q2+=dx02;
            while xd*q>dy12 do
                q-=xd*dy12
                x+=xd
            end
            while xxd*q2>dy02 do
                q2-=xxd*dy02
                xx+=xxd
            end
        end
    end
end

function draw_model(p,qt,vertices,vt,vm,faces,f,tc,uv,textures,calc_light,tex_size,fast,tsts)
    for i=1,3*faces,3 do
        local a,b,c,xab,yab,zab,xac,yac,zac,nv,l_dir,l_cos,l_int;
        a,b,c,l_int=f[i],f[i+1],f[i+2],0.9;
        if(checkIfTriVisible(vt[a*3+1],vt[a*3+2],vt[b*3+1],vt[b*3+2],vt[c*3+1],vt[c*3+2])==true) then
            if(calc_light==true) then
                -- flat shading
                -- normal vector
                xab,yab,zab,xac,yac,zac=vm[b*3+1]-vm[a*3+1],vm[b*3+2]-vm[a*3+2],vm[b*3+3]-vm[a*3+3],vm[c*3+1]-vm[a*3+1],vm[c*3+2]-vm[a*3+2],vm[c*3+3]-vm[a*3+3]
                nv={yab*zac-zab*yac,zab*xac-xab*zac,xab*yac-yab*xac}
                vec_len=v3_len({nv[1],nv[2],nv[3]})
                nv[1],nv[2],nv[3]=nv[1]/vec_len,nv[2]/vec_len,nv[3]/vec_len
                nv_len=v3_len(nv)
                -- light direction
                local tx,ty,tz=(vm[a*3+1]+vm[b*3+1]+vm[c*3+1])/3,(vm[a*3+2]+vm[b*3+2]+vm[c*3+2])/3,(vm[a*3+3]+vm[b*3+3]+vm[c*3+3])/3
                l_dir={light[1]-tx,light[1]-ty,light[3]-tz}
                l_len=v3_len(l_dir)
                -- cos
                l_dir_nv=v3_len({l_dir[1]-nv[1],l_dir[2]-nv[2],l_dir[3]-nv[3]})
                x=nv_len*nv_len+l_len*l_len-l_dir_nv*l_dir_nv
                y=l_len*nv_len*2
                l_cos=x/y
                l_int=max(0.1,l_cos)
            end
            local tex_i=1
            if #textures==6 then tex_i=flr(i/3)%6+1 end
            tri(
                vt[a*3+1],
                vt[a*3+2],
                vt[a*3+3],
                vt[b*3+1],
                vt[b*3+2],
                vt[b*3+3],
                vt[c*3+1],
                vt[c*3+2],
                vt[c*3+3],
                {tc[uv[i]*2+1],tc[uv[i]*2+2]},{tc[uv[i+1]*2+1],tc[uv[i+1]*2+2]},{tc[uv[i+2]*2+1],tc[uv[i+2]*2+2]},l_int,tex_size,textures[tex_i],fast,tsts)
        end
    end
end

function draw_cube(p)
	local qt,vertices,faces,vt,vm=t*0.01,8,12,{},{}
	local v=split("1.3,1.3,-1.3,1.3,-1.3,-1.3,1.3,1.3,1.3,1.3,-1.3,1.3,-1.3,1.3,-1.3,-1.3,-1.3,-1.3,-1.3,1.3,1.3,-1.3,-1.3,1.3")
	local f=split("4, 2, 0, 2, 7, 3, 6, 5, 7, 1, 7, 5, 0, 3, 1, 4, 1, 5, 4, 6, 2, 2, 6, 7, 6, 4, 5, 1, 3, 7, 0, 2, 3, 4, 0, 1")
    local tc=split("1.0,0.0,0.0,1.0,0.0,0.0,1.0,1.0")
    local uv=split("0, 1, 2, 0, 1, 2, 2, 3, 1, 3, 2, 0, 0, 1, 2, 2, 3, 1, 0, 3, 1, 0, 3, 1, 2, 0, 3, 3, 1, 2, 0, 3, 1, 2, 0, 3")
    for j=1,vertices*3,3 do
        local x,y,z=v[j],v[j+1],v[j+2];
        y,z=rotate(y,z,qt);
        x,z=rotate(x,z,qt*1.5);
        x,y=inf(qt+p,x,y)
        -- y-=1
        z+=5
        add(vm,x);
        add(vm,y);
        add(vm,z);
        z-=5
        w=1
        x,y,z,w=mulMatrixVector(x,y,z,w,viewMatrix)
        x,y,z,w=mulMatrixVector(x,y,z,w,perspectiveMatrix)
        x=x/w*64 + 64
        y=y/w*64 + 64
        -- x=x*96/z+64;
        -- y=y*96/z+64;
        vt[j],vt[j+1],vt[j+2]=flr(x),flr(y),flr(z);
    end
    draw_model(p,qt,vertices,vt,vm,faces,f,tc,uv,{tex},true,16,false,256)
end

function _update()
   t+=1 
end

function _draw()
    cls();
    draw_cube(0);
    clearZBuffer();
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010400000055000550005400054000530005300052000525015500155001550015500154001540015400154001530015300153001530015200152001520015250355003550035400354003530035300352003525
010800000355003540035300352503550035500354003540035300353003520035251155011540115301152511550115401153011525035500354003530035250155001540015300152500550005400053000525
010800000a5500a5400a5300a5250a5500a5500a5400a5400a5300a5300a5200a5250055000540005300052500550005400053000525085500854008530085250755007540075300752505550055400553005525
010800000155001540015300152500550005400053000525015500154001530015250355003540035300352503550035500354003540035300353003520035250055000550005400054000530005300052000525
01080000085500854008530085250a5500a5500a5400a5400a5300a5300a5200a5250855008540085300852507550075500754007540075300753007520075251f5501f545225502254518550185452955029545
01080000115501155011550115501154011540115401154011530115301153011530115201152011520115251155011550115501154011540115401153011530115301152011520115250a5500a5400a5300a525
010800000055000550005400054000520005250a5500a545085500854008530085250755007540075300752505550055500554005540055300553005520055250055000540005300052501550015400055000545
__music__
00 00424344
00 01424344
00 02424344
00 03424344
00 04424344
00 05424344
02 06424344

