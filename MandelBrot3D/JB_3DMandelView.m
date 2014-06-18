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

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		indexCnt = 0;
		for(int i=0; i<800; i++)for(int j=0; j<600; j++)
		{
			Index[indexCnt++] = (i)*601+(j);
			Index[indexCnt++] = (i+1)*601+(j);
			Index[indexCnt++] = (i+1)*601+(j+1);
			Index[indexCnt++] = (i)*601+(j);
			Index[indexCnt++] = (i+1)*601+(j+1);
			Index[indexCnt++] = (i)*601+(j+1);
		}
	}
	return self;
}

- (void)viewDidMoveToWindow
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized:) name:NSWindowDidResizeNotification object:[self window]];
}

-(void)awakeFromNib
{
	[self.window makeFirstResponder:self];
	
	[self ResetSetting];
	
	ArcBall = [[JB_ArcBall alloc] initWithWidth:self.frame.size.width Height:self.frame.size.height];
	
}

- (void)windowResized:(NSNotification *)notification;
{
	[ArcBall setBounds:self.frame.size.width :self.frame.size.height];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
	
	glClearColor(0, 0, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	
	if(ShowLine) glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
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
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, ver);
	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(3, GL_FLOAT, 0, col);
	glEnableClientState(GL_NORMAL_ARRAY);
	glNormalPointer(GL_FLOAT, 0, nor);
	
	int ind = 0;
	
	float *H = [Data getHArray];
	int *I = [Data getIterArray];
	for(int i=0; i<801; i++)for(int j=0; j<601; j++)
	{
		
		ver[ind*3] = i - 400;
		ver[ind*3+1] = j - 300;
		if(I[ind] == -1) ver[ind*3+2] = H[ind]*HeightRatio;
		else if(ShowCurveOnDiv) ver[ind*3+2] = H[ind]*HeightRatio*0.15;
		else ver[ind*3+2] = 0;
		
		if(ShowColor)
		{
			RGBA t = [Data getColor:i :j];
			col[ind*3] = t.r;
			col[ind*3+1] = t.g;
			col[ind*3+2] = t.b;
		}
		else if(I[ind] == -1)
		{
			col[ind*3] =
			col[ind*3+1] =
			col[ind*3+2] = 0.7;
		}
		else
		{
			col[ind*3] =
			col[ind*3+1] =
			col[ind*3+2] = 1;
		}
		
		nor[ind*3] = nor[ind*3+1] = nor[ind*3+2] = 0;
		
		ind ++;
	}
	
	for(int i=0; i<800; i++)for(int j=0; j<600; j++)
	{
		int x1, y1, x2, y2, x3, y3;
		float z1, z2, z3, dx1, dx2, dy1, dy2, dz1, dz2, x, y, z;
		
		x1 = i; y1 = j; z1 = ver[(x1*601+y1)*3+2];
		x2 = i+1; y2 = j; z2 = ver[(x2*601+y2)*3+2];
		x3 = i+1; y3 = j+1; z3 = ver[(x3*601+y3)*3+2];
		
		dx1 = x2 - x1;
		dy1 = y2 - y1;
		dz1 = z2 - z1;
		
		dx2 = x3 - x1;
		dy2 = y3 - y1;
		dz2 = z3 - z1;
		
		x = - dy1*dz2 + dz1*dy2;
		y = - dz1*dx2 + dx1*dz2;
		z = - dx1*dy2 + dy1*dx2;
		
		nor[(x1*601+y1)*3] += x;
		nor[(x2*601+y2)*3] += x;
		nor[(x3*601+y3)*3] += x;
		nor[(x1*601+y1)*3+1] += y;
		nor[(x2*601+y2)*3+1] += y;
		nor[(x3*601+y3)*3+1] += y;
		nor[(x1*601+y1)*3+2] += z;
		nor[(x2*601+y2)*3+2] += z;
		nor[(x3*601+y3)*3+2] += z;
		
		x1 = i; y1 = j; z1 = ver[(x1*601+y1)*3+2];
		x2 = i+1; y2 = j+1; z2 = ver[(x1*601+y2)*3+2];
		x3 = i; y3 = j+1; z3 = ver[(x3*601+y3)*3+2];
		
		dx1 = x2 - x1;
		dy1 = y2 - y1;
		dz1 = z2 - z1;
		
		dx2 = x3 - x1;
		dy2 = y3 - y1;
		dz2 = z3 - z1;
		
		x = - dy1*dz2 + dz1*dy2;
		y = - dz1*dx2 + dx1*dz2;
		z = - dx1*dy2 + dy1*dx2;
		
		nor[(x1*601+y1)*3] += x;
		nor[(x2*601+y2)*3] += x;
		nor[(x3*601+y3)*3] += x;
		nor[(x1*601+y1)*3+1] += y;
		nor[(x2*601+y2)*3+1] += y;
		nor[(x3*601+y3)*3+1] += y;
		nor[(x1*601+y1)*3+2] += z;
		nor[(x2*601+y2)*3+2] += z;
		nor[(x3*601+y3)*3+2] += z;
		
	}
	
	ind = 0;
	for(int i=0; i<801; i++)for(int j=0; j<601; j++)
	{
		float x = nor[ind*3];
		float y = nor[ind*3+1];
		float z = nor[ind*3+2];
		
		float len = sqrt(x*x+y*y+z*z);
		
		nor[ind*3] /= len;
		nor[ind*3+1] /= len;
		nor[ind*3+2] /= len;
		
		ind ++;
	}
	
	glDrawElements(GL_TRIANGLES, indexCnt, GL_UNSIGNED_INT, Index);
	
	glPopMatrix();
	
	glFlush();
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
			ShowLine = !ShowLine;
			[LineCheckBox setIntValue:ShowLine];
			break;
		case 8: // 'c'
			ShowColor = !ShowColor;
			[ColorCheckBox setIntValue:ShowColor];
			break;
		case 2: // 'd'
			ShowCurveOnDiv = !ShowCurveOnDiv;
			[DivCheckBox setIntValue:ShowCurveOnDiv];
			break;
		case 15: // 'R'
			[self ResetView:self];
			break;
	}
	[self setNeedsDisplay:true];
}

-(void)prepareOpenGL
{
	glEnable(GL_DEPTH_TEST);
	glClearColor(1, 1, 1, 1);
	glFrustum(-600, 600, -450, 450,1000,2000);
}

-(IBAction)ColorCheckBoxChanged:(id)sender {ShowColor = !ShowColor;[self setNeedsDisplay:true];}

-(IBAction)LineCheckBoxChanged:(id)sender {ShowLine = !ShowLine;[self setNeedsDisplay:true];}

-(IBAction)CurveCheckBoxChanged:(id)sender {ShowCurveOnDiv = !ShowCurveOnDiv;[self setNeedsDisplay:true];}

-(IBAction)ResetView:(id)sender {[self ResetSetting];[self setNeedsDisplay:true];}

-(void)ResetSetting
{
	
	magni = 1;
	Tx = Ty = 0;
	Tz = -1500;
	xRotAng = yRotAng = zRotAng = 0;
	HeightRatio = 300;
	
	ShowLine = false;
	ShowColor = true;
	ShowCurveOnDiv = true;
	
	[LineCheckBox setIntValue:ShowLine];
	[ColorCheckBox setIntValue:ShowColor];
	[DivCheckBox setIntValue:ShowCurveOnDiv];
	
	Matrix3fSetIdentity(&LastRot);
	Matrix3fSetIdentity(&ThisRot);
	for(int i=0; i<16; i++)Transform.M[i] = 0;
	Transform.s.M00 = Transform.s.M11 = Transform.s.M22 = Transform.s.M33 = 1;
	
}

-(void)scrollWheel:(NSEvent *)theEvent
{
	magni *= [theEvent deltaY]*0.01 + 1;
	[self setNeedsDisplay:true];
}

-(NSPoint)getRealPoint :(NSEvent*)event
{
	NSPoint r = [event locationInWindow];
	r.x -= self.frame.origin.x;
	r.y -= self.frame.origin.y;
	return r;
}

-(void)mouseDown:(NSEvent *)theEvent
{
	pMouseClicked = [self getRealPoint:theEvent];
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
	Pt.s.X = [self getRealPoint:theEvent].x;
	Pt.s.Y = self.frame.size.height-[self getRealPoint:theEvent].y;
	
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
	Pt.s.X = [self getRealPoint:theEvent].x;
	Pt.s.Y = self.frame.size.height-[self getRealPoint:theEvent].y;
	[ArcBall drag:&Pt :&ThisQuat];
	Matrix3fSetRotationFromQuat4f(&ThisRot, &ThisQuat);
	Matrix3fMulMatrix3f(&ThisRot, &LastRot);
	Matrix4fSetRotationFromMatrix3f(&Transform, &ThisRot);
	[self setNeedsDisplay:true];
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
	pCMouseClicked = [self getRealPoint:theEvent];
}

-(void)rightMouseDragged:(NSEvent *)theEvent
{
	NSPoint tmp = [self getRealPoint:theEvent];
	double dx = tmp.x - pCMouseClicked.x;
	double dy = tmp.y - pCMouseClicked.y;
	Tx += (dx*800/self.frame.size.width)*2.26/magni;
	Ty += (dy*600/self.frame.size.height)*2.26/magni;
	pCMouseClicked = tmp;
	[self setNeedsDisplay:true];
}

-(void)rightMouseUp:(NSEvent *)theEvent
{
	NSPoint tmp = [self getRealPoint:theEvent];
	double dx = tmp.x - pCMouseClicked.x;
	double dy = tmp.y - pCMouseClicked.y;
	Tx += (dx*400/self.frame.size.width)*3/magni;
	Ty += (dy*300/self.frame.size.height)*3/magni;
	[self setNeedsDisplay:true];
}

@end
