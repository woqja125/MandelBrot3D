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

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
	glFlush();
}

@end
