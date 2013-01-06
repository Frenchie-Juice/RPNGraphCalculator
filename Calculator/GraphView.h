//
//  GraphView.h
//  GraphCalculator
//
//  Created by Fred Gagnepain on 2012-12-29.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphViewDataSource
- (double)computeYAxisValueFor:(double)XAxisValue;
- (void) reloadUserPreferences;
- (void) saveUserPreferencesScale:(float)aScale;
- (void) saveUserPreferencesOriginX:(float)xOrigin andOriginY:(float)yOrigin;
@end

@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)tripleTap:(UITapGestureRecognizer *)gesture;
@end
