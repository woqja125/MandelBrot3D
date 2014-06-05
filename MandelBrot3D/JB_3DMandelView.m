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
	Tz = -300;
	xRotAng = yRotAng = 0;
	HeightRatio = 1;
}

-(void)keyDown:(NSEvent *)theEvent
{
	int t = [theEvent keyCode];
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
		case 69:
			HeightRatio*=1.1;
			break;
		case 78:
			HeightRatio/=1.1;
			break;
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
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint tmp = [theEvent locationInWindow];
	double dx = tmp.x - pMouseClicked.x;
	double dy = tmp.y - pMouseClicked.y;
	xRotAng += dx/(self.frame.size.width)*60;
	yRotAng -= dy/(self.frame.size.height)*60;
	pMouseClicked = tmp;
	[self setNeedsDisplay:true];
}

-(void)prepareOpenGL
{
	glEnable(GL_DEPTH_TEST);
//	GLKMatrix4MakePerspective();
//	gluPerspective(45, 4/3, 1, 10);
	glFrustum(-200, 200, -150, 150,100,500);
}

-(void)drawDot:(double)x :(double)y
{
	RGBA t = [Data getColor:x*2 :y*2];
	glColor3d(t.r, t.g, t.b);
	int it = [Data getNum:2*x :2*y];
	if(it == -1)
	{
		glVertex3d(x-200,	y-150, 0);
	}
	else
		glVertex3d(x-200,	y-150,	log([Data getV:2*x :2*y])*HeightRatio);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
	glClearColor(1, 1, 1, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glPushMatrix();
	
	glViewport(0, 0, self.frame.size.width, self.frame.size.height);
	
	glScaled(magni, magni, 1);
	glTranslated(Tx, Ty, Tz);
	
	glRotated(xRotAng, 0, 1, 0);
	glRotated(yRotAng, 1, 0, 0);
	
	for(int i=0; i<400; i++)for(int j=0; j<300; j++)
	{
		glBegin(GL_TRIANGLE_FAN);
		[self drawDot:i+0.5 :j+0.5];
		
		[self drawDot:i :j];
		[self drawDot:i+1 :j];
		
		[self drawDot:i :j];
		[self drawDot:i :j+1];
		
		[self drawDot:i+1 :j];
		[self drawDot:i+1 :j+1];
		
		[self drawDot:i :j+1];
		[self drawDot:i+1 :j+1];
		glEnd();
	}
	
	glPopMatrix();
	
	glFlush();
}

@end
