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
}
- (id)initWithCoder:(NSCoder *)aDecoder;
@end
