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
}

-(void)keyDown:(NSEvent *)theEvent
{
	int t = [theEvent keyCode];
	switch(t)
	{
		case 126: //key UP
			break;
		case 124: //key Right
			break;
		case 125 : //key Down
			break;
		case 123 : //key Left
			break;
	}
	printf("%d ", t);
}

-(void)prepareOpenGL
{
	glOrtho(0, 400, 0, 300, -100000, 100000);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
	glClear(GL_COLOR_BUFFER_BIT);
	glBegin(GL_TRIANGLES);
	for(int i=0; i<400; i++)for(int j=0; j<300; j++)
	{
		int d = [Data getNum:i*2:j*2];
		if(d==-1) continue;
		else
		{
			RGBA t = [Data getColor:i*2 :j*2];
			glColor3d(t.r, t.g, t.b);
			
			glVertex3d(i, j, [Data getNum:i*2 :j*2]);
			glVertex3d(i+1, j, [Data getNum:i*2+2 :j*2]);
			glVertex3d(i+0.5, j+0.5, [Data getNum:i*2+1 :j*2+1]);
			
			glVertex3d(i, j, [Data getNum:i*2 :j*2]);
			glVertex3d(i, j+1, [Data getNum:i*2 :j*2+2]);
			glVertex3d(i+0.5, j+0.5, [Data getNum:i*2+1 :j*2+1]);
			
			glVertex3d(i+0.5, j+0.5, [Data getNum:i*2+1 :j*2+1]);
			glVertex3d(i+1, j, [Data getNum:i*2+2 :j*2]);
			glVertex3d(i+1, j+1, [Data getNum:i*2+2 :j*2+2]);
			
			glVertex3d(i+0.5, j+0.5, [Data getNum:i*2+1 :j*2+1]);
			glVertex3d(i, j+1, [Data getNum:i*2 :j*2+2]);
			glVertex3d(i+1, j+1, [Data getNum:i*2+2 :j*2+2]);
		}
	}
	glEnd();
	glFlush();
}

@end
