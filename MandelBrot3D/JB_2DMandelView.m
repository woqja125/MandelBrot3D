//
//  JB_2DMandelView.m
//  MandelBrot3D
//
//  Created by 이재범 on 2014. 6. 3..
//  Copyright (c) 2014년 jb. All rights reserved.
//

#import "JB_2DMandelView.h"
#import "JB_MandelModelController.h"

@implementation JB_2DMandelView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		//
	}
	return self;
}

-(void)prepareOpenGL
{
	glOrtho(0, 400, 0, 300, -1, 1);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
	glClear(GL_COLOR_BUFFER_BIT);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBegin(GL_POINTS);
	{
		for(int i=0; i<400; i++)for(int j=0; j<300; j++)
		{
			int d = [Data getNum:i*2:j*2];
			if(d==-1) continue;
			else
			{
				RGBA t = [Data getColor:i*2 :j*2];
				glColor3d(t.r, t.g, t.b);
				glVertex2d(i, j);
			}
		}
	}
	glEnd();
	
	NSPoint MO, ME;
	int dx = MouseEnd.x - MouseStart.x;
	dx /= 4;
	int dy = MouseEnd.y - MouseStart.y;
	dy /= 3;
	int g; if(abs(dx)>abs(dy))g = abs(dy);else g = abs(dx);
	if(dx>0) MouseEnd.x = MouseStart.x + g*4;
	else MouseEnd.x = MouseStart.x - g*4;
	if(dy>0) MouseEnd.y = MouseStart.y + g*3;
	else MouseEnd.y = MouseStart.y - g*3;
	if(MouseStart.x < MouseEnd.x)
	{
		MO.x = MouseStart.x;
		ME.x = MouseEnd.x;
	}
	else
	{
		ME.x = MouseStart.x;
		MO.x = MouseEnd.x;
	}
	if(MouseStart.y < MouseEnd.y)
	{
		MO.y = MouseStart.y;
		ME.y = MouseEnd.y;
	}
	else
	{
		ME.y = MouseStart.y;
		MO.y = MouseEnd.y;
	}
	
	glBegin(GL_QUADS);
	
	glColor4d(0, 1, 1, 0.4);
	
	glVertex2d(MouseO.x, MouseO.y);
	glVertex2d(MouseO.x, MouseE.y);
	glVertex2d(MouseE.x, MouseE.y);
	glVertex2d(MouseE.x, MouseO.y);
	

	glColor4d(0, 0, 1, 0.4);
	glVertex2d(MO.x, MO.y);
	glVertex2d(MO.x, ME.y);
	glVertex2d(ME.x, ME.y);
	glVertex2d(ME.x, MO.y);
	
	glEnd();
	
	glFlush();
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
	MouseEnd = MouseStart = [self getRealPoint:theEvent];
}
-(void)mouseDragged:(NSEvent *)theEvent
{
	MouseEnd = [self getRealPoint:theEvent];
	if(MouseStart.x < MouseEnd.x)
	{
		MouseO.x = MouseStart.x;
		MouseE.x = MouseEnd.x;
	}
	else
	{
		MouseE.x = MouseStart.x;
		MouseO.x = MouseEnd.x;
	}
	if(MouseStart.y < MouseEnd.y)
	{
		MouseO.y = MouseStart.y;
		MouseE.y = MouseEnd.y;
	}
	else
	{
		MouseE.y = MouseStart.y;
		MouseO.y = MouseEnd.y;
	}
	[self setNeedsDisplay:true];
}
-(void)rightMouseDown:(NSEvent *)theEvent
{
	[Data Reset];
	 
}
-(void)mouseUp:(NSEvent *)theEvent
{
	if(MouseEnd.x == MouseStart.x || MouseEnd.y == MouseStart.y) return;
	MouseEnd = [self getRealPoint:theEvent];
	int dx = MouseEnd.x - MouseStart.x;
	dx /= 4;
	int dy = MouseEnd.y - MouseStart.y;
	dy /= 3;
	int g; if(abs(dx)>abs(dy))g = abs(dy);else g = abs(dx);
	if(dx>0) MouseEnd.x = MouseStart.x + g*4;
	else MouseEnd.x = MouseStart.x - g*4;
	if(dy>0) MouseEnd.y = MouseStart.y + g*3;
	else MouseEnd.y = MouseStart.y - g*3;
	if(MouseStart.x < MouseEnd.x)
	{
		MouseO.x = MouseStart.x;
		MouseE.x = MouseEnd.x;
	}
	else
	{
		MouseE.x = MouseStart.x;
		MouseO.x = MouseEnd.x;
	}
	if(MouseStart.y < MouseEnd.y)
	{
		MouseO.y = MouseStart.y;
		MouseE.y = MouseEnd.y;
	}
	else
	{
		MouseE.y = MouseStart.y;
		MouseO.y = MouseEnd.y;
	}
	
	[Data newRange:MouseO :MouseE];
	
	MouseStart = MouseEnd = MouseO = MouseE = NSMakePoint(0, 0);
	
	
}

@end
