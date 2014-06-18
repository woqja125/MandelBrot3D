//
//  JB_MandelController.h
//  MandelBrot3D
//
//  Created by 이재범 on 2014. 6. 3..
//  Copyright (c) 2014년 jb. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct
{
    double r;       // percent [0 - 1]
    double g;       // percent [0 - 1]
    double b;       // percent [0 - 1]
    double a;       // percent [0 - 1]
} RGBA;

typedef struct
{
    double h;       // angle in degrees [0 - 360]
    double s;       // percent [0 - 1]
    double v;       // percent [0 - 1]
} HSV;

@interface JB_MandelModelController : NSObject
{
	NSPoint Origin, End, Data[801][601];
	int Iter[801][601], iter;
	RGBA Color[801][601];
	double V[801][601];
	float S[801][601];
	double dx, dy;
	
	NSThread *CalcThread;
	bool keepThread;
	
	bool DataChanged;
	int SizeChangedNum;
	
	IBOutlet NSOpenGLView *View1, *View2;
}
-(RGBA)getColor:(int)x :(int)y;
-(int*) getIterArray;
-(float*)getHArray;
-(void)newRange:(NSPoint)O :(NSPoint)E;
-(void)Reset;
@end
