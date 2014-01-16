//
//  GBGasLabel.m
//  GasBro
//
//  Created by Sean Thomas Burke on 1/16/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBGasLabel.h"

@implementation GBGasLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* white = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* yellow = [UIColor colorWithRed: 0.063 green: 0.366 blue: 0.295 alpha: 1];
    CGFloat yellowHSBA[4];
    [yellow getHue: &yellowHSBA[0] saturation: &yellowHSBA[1] brightness: &yellowHSBA[2] alpha: &yellowHSBA[3]];
    
    UIColor* color = [UIColor colorWithHue: yellowHSBA[0] saturation: yellowHSBA[1] brightness: 0.7 alpha: yellowHSBA[3]];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)yellow.CGColor,
                               (id)color.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow = yellow;
    CGSize shadowOffset = CGSizeMake(1.1, -1.1);
    CGFloat shadowBlurRadius = 1;
    UIColor* shadow3 = [UIColor blackColor];
    CGSize shadow3Offset = CGSizeMake(0.1, -0.1);
    CGFloat shadow3BlurRadius = 5;
    
    //// Abstracted Attributes
    NSString* textContent = self.text;
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(76.5, 32.5, 85, 30) cornerRadius: 5];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [rectangle2Path addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(119, 32.5), CGPointMake(119, 62.5), 0);
    CGContextEndTransparencyLayer(context);
    
    ////// Rectangle 2 Inner Shadow
    CGRect rectangle2BorderRect = CGRectInset([rectangle2Path bounds], -shadow3BlurRadius, -shadow3BlurRadius);
    rectangle2BorderRect = CGRectOffset(rectangle2BorderRect, -shadow3Offset.width, -shadow3Offset.height);
    rectangle2BorderRect = CGRectInset(CGRectUnion(rectangle2BorderRect, [rectangle2Path bounds]), -1, -1);
    
    UIBezierPath* rectangle2NegativePath = [UIBezierPath bezierPathWithRect: rectangle2BorderRect];
    [rectangle2NegativePath appendPath: rectangle2Path];
    rectangle2NegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadow3Offset.width + round(rectangle2BorderRect.size.width);
        CGFloat yOffset = shadow3Offset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadow3BlurRadius,
                                    shadow3.CGColor);
        
        [rectangle2Path addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rectangle2BorderRect.size.width), 0);
        [rectangle2NegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [rectangle2NegativePath fill];
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    
    [yellow setStroke];
    rectangle2Path.lineWidth = 2.5;
    [rectangle2Path stroke];
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(82, 33, 75, 29);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-Regular" size: 24], NSForegroundColorAttributeName: white, NSParagraphStyleAttributeName: textStyle};
    
    [textContent drawInRect: textRect withAttributes: textFontAttributes];
    CGContextRestoreGState(context);
    
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}


@end
