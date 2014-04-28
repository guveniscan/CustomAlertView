//
//  CustomAlertView.h
//  AD CLASSICS
//
//  Created by Guven Iscan on 8/5/13.
//  Copyright (c) 2013 Guven Iscan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertView : UIView

//Main image of the alert view
@property (nonatomic, strong) UIImageView *alertMainImage;
//Completion block which will be called upon button presses
@property (copy, nonatomic) void (^completion)(NSInteger);
//Dynamic content which can display additional data which cannot be addressed
//statically in the alert image (ie to display in-app purchase prices)
@property (nonatomic, strong) UIView *dynamicContent;
//Array of buttons allocated in the initializer
@property (nonatomic, strong) NSMutableArray *buttons;
//When enabled custom alert view will dismiss itself when user tapped any area
//in the screen which is not covered by alertMainImage. Default is TRUE
@property (nonatomic, assign) BOOL dismissesWithBackgroundTap;
//When enabled custom alert view will dismiss itself after any of
//its buttons is pressed. Default is TRUE
@property (nonatomic, assign) BOOL dismissesWithButtonPress;
//Enable if your dynamic content view contains buttons or other controls
//which will let user interaction. Default is FALSE
@property (nonatomic, assign) BOOL userInteractionEnabledOnDynamicContent;

-(void) show;
-(void) hide;
-(void) setHighlightedImage:(UIImage *) image forButtonAtIndex:(NSInteger) btnIndex;
-(void) setHighlightedImagesForButtons:(NSArray *) highlightedImages;
-(void) setDisabledImage:(UIImage *) image forButtonAtIndex:(NSInteger) btnIndex;
-(void) setDisabledImagesForButtons:(NSArray *) disabledImages;
-(void) setButtonAtIndex:(NSInteger) index enabled:(BOOL) enabled;
-(CGRect) getFrameOfButtonAtIndex:(NSInteger) btnIndex;
//Designated initializer
-(id) initWithFrame:(CGRect)frame
              image:(UIImage *) image
         completion:(void (^)(NSInteger buttonIndex))completion
       buttonFrames:(NSArray *) buttonFrames;

@end
