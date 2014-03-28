//
//  SWProgressView.h
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/4/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWProgressView.h"

@implementation SWProgressView

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{    
	CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height);
	CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);

	CGContextRef context = UIGraphicsGetCurrentContext();

	// Background circle
	CGRect circleRect = CGRectMake(center.x - radius, center.y - radius, radius * 2.0, radius * 2.0);
	CGContextAddEllipseInRect(context, circleRect);

	CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextFillPath(context);

	// Elapsed arc
    CGFloat startAngle = (3 * M_PI) / 2 + self.progress * 2.0 * M_PI;
    CGFloat endEngle = (3 * M_PI) / 2 + 2.0 * M_PI;
	CGContextAddArc(context, center.x, center.y, radius, startAngle, endEngle, 0);
	CGContextAddLineToPoint(context, center.x, center.y);
	CGContextClosePath(context);
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
	CGContextFillPath(context);
}

@end
