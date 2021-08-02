//
//  MaskView.m
//  Mezanger
//
//  Created by honey panda on 11/7/15.
//  Copyright © 2015 honeypanda. All rights reserved.
//

#import "MaskView.h"

@interface MaskView ()

@end

@implementation MaskView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initMaskView];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initMaskView];
    }
    return self;
}

- (void) initMaskView{
    
    // Set Default Colors
    self.backColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    self.alphaValue = 1.0;
    
    self.borderColor = [UIColor colorWithWhite:1.0 alpha:0.64];
    self.borderWidth = 0; //1;
    
    self.cornerRadius = 5;
    
    self.shadowColor = [UIColor clearColor];
    self.shadowOpacity = 0.15;
    self.shadowRadius = 3;
    self.shadowOffset = CGSizeMake(1, 1);
    
    self.isClipBounds = NO;
    self.isCircular = NO;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.isCircular) {
        
        CGRect frame = self.frame;
        CGFloat square = frame.size.width <= frame.size.height ? frame.size.width:frame.size.height;
        frame.size.width = square;
        frame.size.height = square;
        self.frame = frame;
        
        self.layer.cornerRadius = self.frame.size.height / 2;
    }
}

#pragma mark - Getter and Setter Methods

-(UIColor *)backColor{
    return _backColor;
}
-(void)setBackColor:(UIColor *)backColor{
    _backColor = backColor;
    
    self.backgroundColor = backColor;
}

-(CGFloat)alphaValue{
    return _alphaValue;
}
-(void)setAlphaValue:(CGFloat)alphaValue{
    _alphaValue = alphaValue;
    
    self.alpha = alphaValue;
}

-(UIColor *)borderColor{
    return _borderColor;
}
-(void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    
    self.layer.borderColor = borderColor.CGColor;
}

-(CGFloat)borderWidth{
    return _borderWidth;
}
-(void)setBorderWidth:(CGFloat)borderWidth{
    _borderWidth = borderWidth;
    
    self.layer.borderWidth = borderWidth;
}

-(CGFloat)cornerRadius{
    return _cornerRadius;
}
-(void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius = cornerRadius;
    
    self.layer.cornerRadius = cornerRadius;
}

-(UIColor *)shadowColor{
    return _shadowColor;
}
-(void)setShadowColor:(UIColor *)shadowColor{
    _shadowColor = shadowColor;
    
    self.layer.shadowColor = shadowColor.CGColor;
}

-(CGFloat)shadowOpacity{
    return _shadowOpacity;
}
-(void)setShadowOpacity:(CGFloat)shadowOpacity{
    _shadowOpacity = shadowOpacity;
    
    self.layer.shadowOpacity = shadowOpacity;
}

-(CGFloat)shadowRadius{
    return _shadowRadius;
}
-(void)setShadowRadius:(CGFloat)shadowRadius{
    _shadowRadius = shadowRadius;
    
    self.layer.shadowRadius = shadowRadius;
}

-(CGSize)shadowOffset{
    return _shadowOffset;
}
-(void)setShadowOffset:(CGSize)shadowOffset{
    _shadowOffset = shadowOffset;
    
    self.layer.shadowOffset = shadowOffset;
}

-(BOOL)isClipBounds{
    return _isClipBounds;
}
-(void)setIsClipBounds:(BOOL)isClipBounds{
    _isClipBounds = isClipBounds;
    
    self.clipsToBounds = isClipBounds;
    self.layer.masksToBounds = isClipBounds;
}

-(BOOL)isCircular{
    return _isCircular;
}
-(void)setIsCircular:(BOOL)isCircular{
    _isCircular = isCircular;
    
    if (isCircular) {
        self.layer.cornerRadius = self.frame.size.height / 2;
    }
    else
    {
        self.layer.cornerRadius = self.cornerRadius;
    }
}

@end
