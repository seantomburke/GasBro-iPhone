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
    self.adjustsImageWhenHighlighted = NO;
    [self setNeedsDisplay];
}



-(void)drawButton:(CGRect)rect{
    self.adjustsImageWhenHighlighted = NO;
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    shadow = [UIColor colorWithRed: 0 green: 0.827 blue: 0.276 alpha: 0];

    if(self.isEnabled)
    {
        baseColor = [UIColor colorWithRed: 0.469 green: 0.469 blue: 0.469 alpha: 1];
    }
    else{
        baseColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:.5];
    }
    
    if (self.isSelected || self.isHighlighted)
    {
        baseColor = [UIColor colorWithRed: .1911 green: 0.7467 blue: 0.1098 alpha: 1];
        //baseColor = [UIColor blueColor];
        //shadow = baseColor;
        
        //shadow = [UIColor blueColor];
        
        self.layer.shadowColor = baseColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        CABasicAnimation *theAnimation;
        
        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=1.0;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.6];
        [self.layer addAnimation:theAnimation forKey:@"animateOpacity"];
        
        
        CABasicAnimation *shadowOpacityAnimation;
        
        shadowOpacityAnimation=[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowOpacityAnimation.duration=1;
        shadowOpacityAnimation.repeatCount=HUGE_VALF;
        shadowOpacityAnimation.autoreverses=YES;
        shadowOpacityAnimation.fromValue=[NSNumber numberWithFloat:0.95];
        shadowOpacityAnimation.toValue=[NSNumber numberWithFloat:0.0];
        [self.layer addAnimation:shadowOpacityAnimation forKey:@"animateShadowOpacity"];
        
        CABasicAnimation *shadowColorAnimation;
        
        shadowColorAnimation=[CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        shadowColorAnimation.duration=1;
        shadowColorAnimation.repeatCount=HUGE_VALF;
        shadowColorAnimation.autoreverses=YES;
        shadowColorAnimation.fromValue=[NSNumber numberWithFloat:5];
        shadowColorAnimation.toValue=[NSNumber numberWithFloat:1];
        [self.layer addAnimation:shadowColorAnimation forKey:@"animateRadius"];
    
    }
    else{
        [self.layer removeAllAnimations];
    }
    
    //// Shadow Declarations
    CGSize shadowOffset = CGSizeMake(0.0, 0.0);
    CGFloat shadowBlurRadius = 8.5;
    
    //// Frames
    CGRect button = CGRectMake(0, 0, 50, 50);
    
    CGRect rightRect = CGRectMake(CGRectGetMinX(button) + 27, CGRectGetMinY(button) + 22.5, 8, 1);
    CGRect bottomRect = CGRectMake(CGRectGetMinX(button) + 22.5, CGRectGetMinY(button) + 27, 1, 8);
    CGRect leftRect = CGRectMake(CGRectGetMinX(button) + 10, CGRectGetMinY(button) + 22.5, 8, 1);
    CGRect topRect = CGRectMake(CGRectGetMinX(button) + 22.5, CGRectGetMinY(button) + 10, 1, 8);
    CGFloat cornerRadius = 0.5;
    CGRect oval2Rect = CGRectMake(CGRectGetMinX(button) + 10, CGRectGetMinY(button) + 10, 25, 25);
    Float32 lineWidth = 1;
    
    
    //// Button Main
    {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
        
        
        //// Left Drawing
        UIBezierPath* leftPath = [UIBezierPath bezierPathWithRoundedRect: leftRect cornerRadius: cornerRadius];
        [[UIColor whiteColor] setFill];
        [leftPath fill];
        [baseColor setStroke];
        leftPath.lineWidth = lineWidth;
        [leftPath stroke];
        
        
        //// Right Drawing
        UIBezierPath* rightPath = [UIBezierPath bezierPathWithRoundedRect: rightRect cornerRadius: cornerRadius];
        [[UIColor whiteColor] setFill];
        [rightPath fill];
        [baseColor setStroke];
        rightPath.lineWidth = lineWidth;
        [rightPath stroke];
        
        
        //// Top Drawing
        UIBezierPath* topPath = [UIBezierPath bezierPathWithRoundedRect: topRect cornerRadius: cornerRadius];
        [[UIColor whiteColor] setFill];
        [topPath fill];
        [baseColor setStroke];
        topPath.lineWidth = lineWidth;
        [topPath stroke];
        
        
        //// Bottom Drawing
        UIBezierPath* bottomPath = [UIBezierPath bezierPathWithRoundedRect: bottomRect cornerRadius: cornerRadius];
        [[UIColor whiteColor] setFill];
        [bottomPath fill];
        [baseColor setStroke];
        bottomPath.lineWidth = lineWidth;
        [bottomPath stroke];
        
        
        //// Oval 2 Drawing
        UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: oval2Rect];
        [baseColor setStroke];
        oval2Path.lineWidth = lineWidth + 1;
        [oval2Path stroke];
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    


    
}
@end


