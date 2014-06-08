//
//  JB_ArcBall.m
//  MandelBrot3D
//
//  Created by 이재범 on 2014. 6. 8..
//  Copyright (c) 2014년 jb. All rights reserved.
//

#import "JB_ArcBall.h"

@implementation JB_ArcBall


-(id)init :(GLfloat)NewWidth :(GLfloat)NewHeight
{
	self = [super init];
	if(self)
	{
		//Clear initial values
		StVec.s.X     =
		StVec.s.Y     =
		StVec.s.Z     =
		
		EnVec.s.X     =
		EnVec.s.Y     =
		EnVec.s.Z     = 0.0f;
		
		//Set initial bounds
		[self setBounds:NewWidth :NewHeight];
	}
	return self;
}

-(void) click :(Point2fT*)NewPt
{
    [self _mapToSphere:NewPt :&StVec];
}

-(void) drag :(Point2fT*)NewPt :(Quat4fT*) NewRot
{
    //Map the point to the sphere
    [self _mapToSphere:NewPt :&EnVec];
	
    //Return the quaternion equivalent to the rotation
    if (NewRot)
    {
        Vector3fT  Perp;
		
        //Compute the vector perpendicular to the begin and end vectors
        Vector3fCross(&Perp, &StVec, &EnVec);
		
        //Compute the length of the perpendicular vector
        if (Vector3fLength(&Perp) > Epsilon)    //if its non-zero
        {
            //We're ok, so return the perpendicular vector as the transform after all
            NewRot->s.X = Perp.s.X;
            NewRot->s.Y = Perp.s.Y;
            NewRot->s.Z = Perp.s.Z;
            //In the quaternion values, w is cosine (theta / 2), where theta is rotation angle
            NewRot->s.W= Vector3fDot(&StVec, &EnVec);
        }
        else                                    //if its zero
        {
            //The begin and end vectors coincide, so return an identity transform
            NewRot->s.X =
            NewRot->s.Y =
            NewRot->s.Z =
            NewRot->s.W = 0.0f;
        }
    }
}

-(void) _mapToSphere :(Point2fT*) NewPt :(Vector3fT*) NewVec
{
    Point2fT TempPt;
    GLfloat length;
	
    //Copy paramter into temp point
    TempPt = *NewPt;
	
    //Adjust point coords and scale down to range of [-1 ... 1]
    TempPt.s.X  =        (TempPt.s.X * AdjustWidth)  - 1.0f;
    TempPt.s.Y  = 1.0f - (TempPt.s.Y * AdjustHeight);
	
    //Compute the square of the length of the vector to the point from the center
    length      = (TempPt.s.X * TempPt.s.X) + (TempPt.s.Y * TempPt.s.Y);
	
    //If the point is mapped outside of the sphere... (length > radius squared)
    if (length > 1.0f)
    {
        GLfloat norm;
		
        //Compute a normalizing factor (radius / sqrt(length))
        norm    = 1.0f / FuncSqrt(length);
		
        //Return the "normalized" vector, a point on the sphere
        NewVec->s.X = TempPt.s.X * norm;
        NewVec->s.Y = TempPt.s.Y * norm;
        NewVec->s.Z = 0.0f;
    }
    else    //Else it's on the inside
    {
        //Return a vector to a point mapped inside the sphere sqrt(radius squared - length)
        NewVec->s.X = TempPt.s.X;
        NewVec->s.Y = TempPt.s.Y;
        NewVec->s.Z = FuncSqrt(1.0f - length);
    }
}

-(void)setBounds :(GLfloat) NewWidth :(GLfloat)NewHeight
{
	AdjustWidth  = 1.0f / ((NewWidth  - 1.0f) * 0.5f);
	AdjustHeight = 1.0f / ((NewHeight - 1.0f) * 0.5f);
}

@end
