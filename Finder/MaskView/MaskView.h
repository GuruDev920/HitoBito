//
//  MaskView.h
//  Mezanger
//
//  Created by honey panda on 11/7/15.
//  Copyright © 2015 honeypanda. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface MaskView : UIView
{
    UIColor *_backColor;
    CGFloat _alphaValue;
    
    UIColor *_borderColor;
    CGFloat _borderWidth;
    
    CGFloat _cornerRadius;
    
    UIColor *_shadowColor;
    CGFloat _shadowOpacity;
    CGFloat _shadowRadius;
    CGSize _shadowOffset;
    
    BOOL _isClipBounds;
    BOOL _isCircular;
}

@property (nonatomic, retain) IBInspectable UIColor *backColor;
@property (readwrite) IBInspectable CGFloat alphaValue;

@property (nonatomic, retain) IBInspectable UIColor *borderColor;
@property (readwrite) IBInspectable CGFloat borderWidth;

@property (readwrite) IBInspectable CGFloat cornerRadius;

@property (nonatomic, retain) IBInspectable UIColor *shadowColor;
@property (readwrite) IBInspectable CGFloat shadowOpacity;
@property (readwrite) IBInspectable CGFloat shadowRadius;
@property (readwrite) IBInspectable CGSize shadowOffset;

@property (readwrite) IBInspectable BOOL isClipBounds;
@property (readwrite) IBInspectable BOOL isCircular;

@end
