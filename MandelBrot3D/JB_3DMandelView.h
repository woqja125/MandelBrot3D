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
	
	bool ShowLine, ShowColor, ShowCurveOnDiv;
	IBOutlet NSButton *LineCheckBox, *ColorCheckBox, *DivCheckBox;
	
	JB_ArcBall *ArcBall;
	
	Matrix4fT    Transform;
	Matrix3fT    LastRot;
	Matrix3fT    ThisRot;
	
	float ver[(801*601+10000)*3];
	float col[(801*601+10000)*3];
	float nor[(801*601+10000)*3];
	
	unsigned Index[(800*600+10000)*6], indexCnt;
}

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
