//
//  JB_3DMandelView.m
//  MandelBrot3D
//
//  Created by 이재범 on 2014. 6. 3..
//  Copyright (c) 2014년 jb. All rights reserved.
//

#import "JB_3DMandelView.h"
#import "JB_MandelModelController.h"

@implementation JB_3DMandelView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {		
    }
    return self;
}

-(void)awakeFromNib
{
	[self.window makeFirstResponder:self];
	magni = 1;
	Tx = Ty = 0;
	Tz = -1500;
	xRotAng = yRotAng = zRotAng = 0;
	HeightRatio = 10;
	DrawLine = false;
	
	ArcBall = [[JB_ArcBall alloc] initWithWidth:self.frame.size.width Height:self.frame.size.height];
	
	Matrix3fSetIdentity(&LastRot);
	Matrix3fSetIdentity(&ThisRot);
	Transform.s.M00 = Transform.s.M11 = Transform.s.M22 = Transform.s.M33 = 1;
}

-(void)keyDown:(NSEvent *)theEvent
{
	int t = [theEvent keyCode];
	//printf("%d", t);
	switch(t)
	{
		case 126: //key UP
			Ty-=2;
			break;
		case 124: //key Right
			Tx-=2;
			break;
		case 125 : //key Down
			Ty+=2;
			break;
		case 123 : //key Left
			Tx+=2;
			break;
		case 69: // '+'
			HeightRatio*=1.1;
			break;
		case 78: // '-'
			HeightRatio/=1.1;
			break;
		case 37: // 'l'
			DrawLine = !DrawLine;
	}
	[self setNeedsDisplay:true];
}

-(void)scrollWheel:(NSEvent *)theEvent
{
	magni *= [theEvent deltaY]*0.01 + 1;
	[self setNeedsDisplay:true];
}

-(void)mouseDown:(NSEvent *)theEvent
{
	pMouseClicked = [theEvent locationInWindow];
	LastRot = ThisRot;
	Point2fT Pt;
	Pt.s.X = [theEvent locationInWindow].x;
	Pt.s.Y = self.frame.size.height-[theEvent locationInWindow].y;
	[ArcBall click:&Pt];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	Quat4fT     ThisQuat;
	
	Point2fT Pt;
	Pt.s.X = [theEvent locationInWindow].x;
	Pt.s.Y = self.frame.size.height-[theEvent locationInWindow].y;
	
	[ArcBall drag:&Pt :&ThisQuat];
	Matrix3fSetRotationFromQuat4f(&ThisRot, &ThisQuat);
	Matrix3fMulMatrix3f(&ThisRot, &LastRot);
	Matrix4fSetRotationFromMatrix3f(&Transform, &ThisRot);
	
	LastRot = ThisRot;
	[ArcBall click:&Pt];
	[self setNeedsDisplay:true];
}

-(void)mouseUp:(NSEvent *)theEvent
{
	Quat4fT     ThisQuat;
	Point2fT Pt;
	Pt.s.X = [theEvent locationInWindow].x;
	Pt.s.Y = self.frame.size.height-[theEvent locationInWindow].y;
	[ArcBall drag:&Pt :&ThisQuat];
	Matrix3fSetRotationFromQuat4f(&ThisRot, &ThisQuat);
	Matrix3fMulMatrix3f(&ThisRot, &LastRot);
	Matrix4fSetRotationFromMatrix3f(&Transform, &ThisRot);
	[self setNeedsDisplay:true];
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
	pCMouseClicked = [theEvent locationInWindow];
}

-(void)rightMouseDragged:(NSEvent *)theEvent
{
	NSPoint tmp = [theEvent locationInWindow];
	double dx = tmp.x - pCMouseClicked.x;
	double dy = tmp.y - pCMouseClicked.y;
	Tx += (dx*800/self.frame.size.width)*2.26/magni;
	Ty += (dy*600/self.frame.size.height)*2.26/magni;
	pCMouseClicked = tmp;
	[self setNeedsDisplay:true];
}

-(void)rightMouseUp:(NSEvent *)theEvent
{
	NSPoint tmp = [theEvent locationInWindow];
	double dx = tmp.x - pCMouseClicked.x;
	double dy = tmp.y - pCMouseClicked.y;
	Tx += (dx*400/self.frame.size.width)*3/magni;
	Ty += (dy*300/self.frame.size.height)*3/magni;
	[self setNeedsDisplay:true];
}

-(void)prepareOpenGL
{
	glEnable(GL_DEPTH_TEST);
	glClearColor(1, 1, 1, 1);
	glFrustum(-600, 600, -450, 450,1000,2000);
}

-(double)getZ:(double)x :(double)y
{
	if([Data getNum:x :y] == -1)
		return [Data getH:x :y]*HeightRatio;
	else
		return [Data getH:x :y]*HeightRatio*0.15*0;
}

-(void)drawDot:(double)x :(double)y :(double)z
{
	RGBA t = [Data getColor:x :y];
	glColor3d(t.r, t.g, t.b);
	glVertex3d(x-400,	y-300,z);
}

-(void)drawTri:(double)x1 :(double)y1 :(double)x2 :(double)y2 :(double)x3 :(double)y3
{
	CGFloat z1, z2, z3;
	CGFloat dx1, dy1, dz1, dx2, dy2, dz2;
	CGFloat x, y, z;
	CGFloat len;
	
	z1 = [self getZ:x1 :y1];
	z2 = [self getZ:x2 :y2];
	z3 = [self getZ:x3 :y3];
	
	dx1 = x2 - x1;
	dy1 = y2 - y1;
	dz1 = z2 - z1;
	
	dx2 = x3 - x1;
	dy2 = y3 - y1;
	dz2 = z3 - z1;
	
	x = - dy1*dz2 + dz1*dy2;
	y = - dz1*dx2 + dx1*dz2;
	z = - dx1*dy2 + dy1*dx2;
	
	len = sqrt(x*x+y*y+z*z);
	
	glNormal3f(x/len, y/len, z/len);
	
	[self drawDot:x1 :y1 :z1];
	[self drawDot:x2 :y2 :z2];
	[self drawDot:x3 :y3 :z3];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
	glClearColor(0, 0, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_CULL_FACE);
	
	if(DrawLine) glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	else glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	
	/// 위치
	GLfloat lightPos[] = {0, 0, 1000, 1};
	glLightfv(GL_LIGHT0, GL_POSITION, lightPos);

	///	방향
	GLfloat lightDir[] = {0, 0, 1, 0};
	glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, lightDir);

	/// 주변광 색
	GLfloat ambient[4]={0.5,0.5,0.5,1};
	glLightfv(GL_LIGHT0,GL_AMBIENT,ambient);
	
	/// 분산 색
	GLfloat Diff[4]={1,1,1,1};
	glLightfv(GL_LIGHT0,GL_DIFFUSE,Diff);
	

	///	광역 주변광
//	GLfloat ambient2[4]={0.1,0.1,0.1,1};
//	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient2);
	
	///재질
	glEnable(GL_COLOR_MATERIAL);
	
	glShadeModel(GL_SMOOTH);
	
	glPushMatrix();
	
	glViewport(0, 0, self.frame.size.width, self.frame.size.height);
	
	glScaled(magni, magni, 1);
	glTranslated(Tx, Ty, Tz);
	
	glMultMatrixf(Transform.M);
	
	for(int i=0; i<400; i++)for(int j=0; j<300; j++)
	{
		glBegin(GL_TRIANGLES);
		
		
		[self drawTri:i*2+1 :j*2+1 :i*2+0 :j*2+0 :i*2+2 :j*2+0];
		
		[self drawTri:i*2+1 :j*2+1 :i*2+0 :j*2+2 :i*2+0 :j*2+0];
		
		[self drawTri:i*2+1 :j*2+1 :i*2+2 :j*2+0 :i*2+2 :j*2+2];
		
		[self drawTri:i*2+1 :j*2+1 :i*2+2 :j*2+2 :i*2+0 :j*2+2];
	
		glEnd();
	}
	
	glPopMatrix();
	
	glFlush();
}

@end
