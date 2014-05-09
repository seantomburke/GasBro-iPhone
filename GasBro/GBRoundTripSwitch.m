//
//  GBRoundTripSwitch.m
//  GasBro
//
//  Created by Sean Thomas Burke on 5/9/14.
//  Copyright (c) 2014 Nyquist Labs. All rights reserved.
//

#import "GBRoundTripSwitch.h"

@implementation GBRoundTripSwitch

- (id)initWithFrame:(CGRect)frame
{
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self drawGBRoundTripSwitchWithXPosition:0];
}

- (void)drawGBRoundTripSwitchWithXPosition: (CGFloat)xPosition;
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* gradientColor = [UIColor colorWithRed: 0.025 green: 0.521 blue: 0.185 alpha: 1];
    CGFloat gradientColorHSBA[4];
    [gradientColor getHue: &gradientColorHSBA[0] saturation: &gradientColorHSBA[1] brightness: &gradientColorHSBA[2] alpha: &gradientColorHSBA[3]];
    
    CGFloat colorHSBA[4];
    //UIColor *color = [UIColor colorWithHue:colorHSBA[0] saturation:colorHSBA[1] brightness:colorHSBA[2] alpha:colorHSBA[3]];
    
    UIColor* color5 = [UIColor greenColor];
    [UIColor colorWithHue: colorHSBA[0] saturation: colorHSBA[1] brightness: 0.2 alpha: colorHSBA[3]];
    [color5 getHue: &colorHSBA[0] saturation: &colorHSBA[1] brightness: &colorHSBA[2] alpha: &colorHSBA[3]];
    UIColor* color3 = [UIColor colorWithHue: gradientColorHSBA[0] saturation: gradientColorHSBA[1] brightness: 0.8 alpha: gradientColorHSBA[3]];
    UIColor* color6 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Shadow Declarations
    NSShadow* shadow3 = [[NSShadow alloc] init];
    shadow3.shadowBlurRadius = 5;
    shadow3.shadowOffset = CGSizeMake(0.1, 3.1);
    shadow3.shadowColor = color5;
    
    
    //// Variable Declarations
    NSString* roundTrip = @"Round Trip";
    CGFloat expression = -xPosition / 3.0 + 36;
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(4, 5, 141, 40) cornerRadius: 20];
    [color3 setFill];
    [rectanglePath fill];
    
    
    //// Text Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 6, 7);
    
    CGRect textRect = CGRectMake(expression, 0, 106, 36);
    NSMutableParagraphStyle* textStyle = [NSMutableParagraphStyle.defaultParagraphStyle mutableCopy];
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNextCondensed-UltraLight" size: 24], NSForegroundColorAttributeName: color5, NSParagraphStyleAttributeName: textStyle};
    
    [roundTrip drawInRect: CGRectOffset(textRect, 0, (CGRectGetHeight(textRect) - [roundTrip boundingRectWithSize: textRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height) / 2) withAttributes: textFontAttributes];
    
    CGContextRestoreGState(context);
    
    
    //// Oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 6, 7);
    
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(xPosition, 0, 36, 36)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow3.shadowOffset, shadow3.shadowBlurRadius, [shadow3.shadowColor CGColor]);
    [color6 setFill];
    [ovalPath fill];
    CGContextRestoreGState(context);
    
    
    CGContextRestoreGState(context);
}


@end
