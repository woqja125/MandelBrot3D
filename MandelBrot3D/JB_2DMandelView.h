//
//  JB_2DMandelView.h
//  MandelBrot3D
//
//  Created by 이재범 on 2014. 6. 3..
//  Copyright (c) 2014년 jb. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>


@class JB_MandelModelController;

@interface JB_2DMandelView : NSOpenGLView
{
	IBOutlet JB_MandelModelController *Data;
	NSPoint MouseStart, MouseEnd;
	NSPoint MouseO, MouseE;
	
	unsigned Index[200000], indexCnt;
	float Col[(400*300+100)*3];
	float dot[(400*300+100)*3];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
@end
