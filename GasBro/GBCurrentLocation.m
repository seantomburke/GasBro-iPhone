//
//  GBCurrentLocation.m
//  GasBro
//
//  Created by Sean Thomas Burke on 5/9/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBCurrentLocation.h"

@implementation GBCurrentLocation
@synthesize baseColor;
@synthesize shadow;


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self drawRect:frame];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [self drawButton:rect];
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self setNeedsDisplay];
}

-(void)setHighlighted:(BOOL)value {
    [super setHighlighted:value];
    [self setNeedsDisplay];
}

-(void)setSelected:(BOOL)value {
    [super setSelected:value];
    [self setNeedsDisplay];
}



-(void)drawButton:(CGRect)rect{
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    shadow = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:0];
    if(self.isEnabled)
    {
        baseColor = [UIColor colorWithRed: 0.469 green: 0.469 blue: 0.469 alpha: 1];
    }
    else{
        baseColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:.5];
    }
    
    if (self.isHighlighted)
    {
        baseColor = [UIColor colorWithRed: 0 green: 0.827 blue: 0.276 alpha: 1];
        shadow = [UIColor colorWithRed: 0 green: 0.827 blue: 0.276 alpha: 1];
    }
    
    //// Shadow Declarations
    CGSize shadowOffset = CGSizeMake(0.1, -0.1);
    CGFloat shadowBlurRadius = 8.5;
    
    //// Frames
    CGRect button = CGRectMake(0, 0, 50, 50);
    
    
    //// Button Main
    {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
        
        
        //// Left Drawing
        UIBezierPath* leftPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(button) + 10, CGRectGetMinY(button) + 25, 10, 1) cornerRadius: 0.5];
        [[UIColor whiteColor] setFill];
        [leftPath fill];
        [baseColor setStroke];
        leftPath.lineWidth = 3;
        [leftPath stroke];
        
        
        //// Right Drawing
        UIBezierPath* rightPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(button) + 30, CGRectGetMinY(button) + 25, 10, 1) cornerRadius: 0.5];
        [[UIColor whiteColor] setFill];
        [rightPath fill];
        [baseColor setStroke];
        rightPath.lineWidth = 3;
        [rightPath stroke];
        
        
        //// Top Drawing
        UIBezierPath* topPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(button) + 25, CGRectGetMinY(button) + 10, 1, 10) cornerRadius: 0.5];
        [[UIColor whiteColor] setFill];
        [topPath fill];
        [baseColor setStroke];
        topPath.lineWidth = 3;
        [topPath stroke];
        
        
        //// Bottom Drawing
        UIBezierPath* bottomPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(button) + 25, CGRectGetMinY(button) + 30, 1, 10) cornerRadius: 0.5];
        [[UIColor whiteColor] setFill];
        [bottomPath fill];
        [baseColor setStroke];
        bottomPath.lineWidth = 3;
        [bottomPath stroke];
        
        
        //// Oval 2 Drawing
        UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(button) + 10, CGRectGetMinY(button) + 10, 30, 30)];
        [baseColor setStroke];
        oval2Path.lineWidth = 3;
        [oval2Path stroke];
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    


    
}
@end


