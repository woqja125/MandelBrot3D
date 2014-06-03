//
//  JB_MandelController.m
//  MandelBrot3D
//
//  Created by 이재범 on 2014. 6. 3..
//  Copyright (c) 2014년 jb. All rights reserved.
//

#import "JB_MandelModelController.h"

const int Width = 800;
const int Height = 600;

@implementation JB_MandelModelController

-(id)init
{
	if(self = [super init])
	{
		Origin.x = -2.7;
		Origin.y = -1.5;
		End.x = 1.3;
		End.y = 1.5;
	}
	return self;
}

-(void)awakeFromNib
{
	keepThread = true;
	CalcThread = [[NSThread alloc] initWithTarget:self selector:@selector(StartNewSet) object:nil];
	[CalcThread start];
	[NSThread detachNewThreadSelector:@selector(notifyDataChanged) toTarget:self withObject:nil];
}

-(void)StartNewSet
{
	dx = End.x - Origin.x;
	dx /= Width;
	dy = End.y - Origin.y;
	dy /= Height;
	int i, j;
	for(i=0; i<Width; i++)
	{
		for(j=0; j<Height; j++)
		{
			Data[i][j].x = Origin.x + dx*i;
			Data[i][j].y = Origin.y + dy*j;
			Iter[i][j] = -1;
		}
	}
	DataChanged = true;
	[self Calc];
}

-(void)Calc
{
	for(int iter = 1;; iter++)
	{
		for(int i=0; i<=Width; i++)for(int j=0; j<=Height; j++)
		{
			if(!keepThread) return;
			if(Iter[i][j] == -1)
			{
				double X, Y, x, y;

				X = Data[i][j].x;
				Y = Data[i][j].y;
				
				x = Origin.x + dx*i;
				y = Origin.y + dy*j;
				
				Data[i][j].x = X*X - Y*Y + x;
				Data[i][j].y = 2*X*Y + y;
				X = Data[i][j].x;
				Y = Data[i][j].y;
				if(X*X+Y*Y >= 16)
				{
					Iter[i][j] = iter;
					DataChanged = true;
				}
			}
		}
		if(!keepThread) return;
	}
}

-(void)notifyDataChanged
{
	while(1)
	{
		[NSThread sleepForTimeInterval:1./60];
		if(DataChanged)
		{
			if(View1 != nil) [View1 setNeedsDisplay:true];
			if(View2 != nil) [View2 setNeedsDisplay:true];
			DataChanged = false;
		}
	}
}

-(int)getNum:(int)x :(int)y
{
	if(x<0 || x>800 || y<0 || y>600) return -1;
	else return Iter[x][y];
}

-(RGBA)getColor:(int)x :(int)y
{
	double X = Data[x][y].x;
	double Y = Data[x][y].y;
	double H = Iter[x][y] - log2(log(sqrt(X*X+Y*Y))/log(1000));
	H *= pow(2, End.x - Origin.x)*0.001;
	H = H - (int)H;
	HSV tmp;
	tmp.h = H*360;
	tmp.s = 1;
	tmp.v = 1;
	RGBA t;
	t = [self RGBfromHSV:tmp];
	return t;
}

- (RGBA)RGBfromHSV:(HSV)value
{
    double      hh, p, q, t, ff;
    long        i;
    RGBA        out;
    out.a       = 1;
	
    if (value.s <= 0.0) // < is bogus, just shuts up warnings
    {
        if (isnan(value.h)) // value.h == NAN
        {
            out.r = value.v; out.g = value.v; out.b = value.v;
            return out;
        }
        out.r = out.g = out.b = 0.0;
        return out;
    }
	
    hh = value.h;
    if(hh >= 360.0) hh = 0.0;
    hh /= 60.0;
    i = (long)hh;
    ff = hh - i;
    p = value.v * (1.0 - value.s);
    q = value.v * (1.0 - (value.s * ff));
    t = value.v * (1.0 - (value.s * (1.0 - ff)));
	
    switch(i)
    {
        case 0:out.r = value.v;out.g = t;out.b = p;break;
        case 1:out.r = q;out.g = value.v;out.b = p;break;
        case 2:out.r = p;out.g = value.v;out.b = t;break;
        case 3:out.r = p;out.g = q;out.b = value.v;break;
        case 4:out.r = t;out.g = p;out.b = value.v;break;
        case 5:
        default:out.r = value.v;out.g = p;out.b = q;break;
    }
    return out;
}

@end
