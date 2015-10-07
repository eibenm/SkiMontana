//
//  SMArrowView.h
//  SkiMontana
//
//  Created by Matt Eiben on 10/6/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

typedef NS_ENUM(NSInteger, SMArrowType) {
    SMArrowUp,
    SMArrowDown,
    SMArrowRight,
    SMArrowLeft
};

@interface SMArrowView : UIView

- (instancetype)initWithFrame:(CGRect)frame arrowType:(SMArrowType)arrowType;

@end
