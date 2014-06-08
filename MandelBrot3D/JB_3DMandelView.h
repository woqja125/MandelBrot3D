//
//  JB_3DMandelView.h
//  MandelBrot3D
//
//  Created by 이재범 on 2014. 6. 3..
//  Copyright (c) 2014년 jb. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>
#import "JB_ArcBall.h"

@class JB_MandelModelController;

@interface JB_3DMandelView : NSOpenGLView
{
	IBOutlet JB_MandelModelController *Data;
	double magni, Tx, Ty, Tz, xRotAng, yRotAng, zRotAng, HeightRatio;
	NSPoint pMouseClicked, pRMouseClicked, pCMouseClicked;
	bool DrawLine;
	
	JB_ArcBall *ArcBall;
	
	Matrix4fT    Transform;
	Matrix3fT    LastRot;
	Matrix3fT    ThisRot;

}

- (id)initWithFrame:(NSRect)frame;

@end
