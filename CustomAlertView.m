//
//  CustomAlertView.m
//  AD CLASSICS
//
//  Created by Guven Iscan on 8/5/13.
//  Copyright (c) 2013 Guven Iscan. All rights reserved.
//

#import "CustomAlertView.h"
#import "CommonDefs.h"

#define BUTTON_TAG_OFFSET 71732423

#define ENLARGE_ANIMATION_DURATION 0.12
#define SHRINK_ANIMATION_DURATION 0.08

@interface CustomAlertView()

//Hidden properties
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) UIWindow *originalWindow;
@property (nonatomic, strong) NSArray *buttonFrames;

@end

@implementation CustomAlertView

-(NSMutableArray *) buttons
{
    //Lazy instantiation for buttons array
    if (_buttons == nil)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

-(void) setUserInteractionEnabledOnDynamicContent:(BOOL)userInteractionEnabledOnDynamicContent
{
    _userInteractionEnabledOnDynamicContent = userInteractionEnabledOnDynamicContent;
    [_dynamicContent setUserInteractionEnabled:_userInteractionEnabledOnDynamicContent];
}

-(void) setDynamicContent:(UIView *)contentView
{
    //Remove previous dynamic content view
    [self.dynamicContent removeFromSuperview];
    
    //Store and add the new one
    _dynamicContent = contentView;
    [self.alertMainImage addSubview:_dynamicContent];
    
    //Enable/disable user interaction on dynamic content view
    [_dynamicContent setUserInteractionEnabled:self.userInteractionEnabledOnDynamicContent];
}

//Triggered when user taps the background button which covers the whole screen
-(void) userTappedBackground:(UIButton *) sender
{
    //Check if custom alert view should dismiss itself and hide if required
    if (self.dismissesWithBackgroundTap)
    {
        [self hide];
    }
}

//Designated initializer
-(id) initWithFrame:(CGRect)frame image:(UIImage *) image completion:(void (^)(NSInteger buttonIndex))completion buttonFrames:(NSArray *) buttonFrames
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self != nil)
    {
        //Add a uibutton which spans the whole screen and calls userTappedBackground
        //when tapped
        UIButton *modalBG = [UIButton buttonWithType:UIButtonTypeCustom];
        [modalBG setFrame:self.bounds];
        [modalBG setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:DEFAULT_BACKGROUND_OPACITY_OF_CUSTOM_MODAL_VIEWS]];
        [modalBG addTarget:self action:@selector(userTappedBackground:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:modalBG];
        
        //Create the alert view with specified image
        self.alertMainImage = [[UIImageView alloc] initWithImage:image];
        [self.alertMainImage setFrame:frame];
        [self.alertMainImage setUserInteractionEnabled:TRUE];
        [modalBG addSubview:self.alertMainImage];
        
        //Add alert view buttons in specified frames
        CGRect buttonFrame;
        UIButton *btn;
        for (NSInteger i = 0; i < buttonFrames.count; i++)
        {
            [buttonFrames[i] getValue:&buttonFrame];
            
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:buttonFrame];
            //Set tags to identify buttons later
            [btn setTag:BUTTON_TAG_OFFSET + i];
            
            [self.alertMainImage addSubview:btn];
            
            [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            //Store buttons in a separate array
            [self.buttons addObject:btn];
        }
        
        //Store completion block
        self.completion = completion;
        
        //Set default values for boolean config variables
        self.dismissesWithBackgroundTap = TRUE;
        self.dismissesWithButtonPress = TRUE;
        self.userInteractionEnabledOnDynamicContent = FALSE;
    }
    return self;
}

//Enables/disables alert view button at specified index
-(void) setButtonAtIndex:(NSInteger) index enabled:(BOOL) enabled
{
    if ([self.buttons count] > index && index >= 0)
    {
        [self.buttons[index] setEnabled:enabled];
    }
}

//Returns the frame of alert view button at specified index
-(CGRect) getFrameOfButtonAtIndex:(NSInteger) btnIndex
{
    if ([self.buttons count] > btnIndex && btnIndex >= 0)
    {
        return [self.buttons[btnIndex] frame];
    }
    
    return CGRectZero;
}

//Sets highlighted image of a single button at specified index
-(void) setHighlightedImage:(UIImage *) image forButtonAtIndex:(NSInteger) btnIndex
{
    if ([self.buttons count] > btnIndex && btnIndex >= 0)
    {
        [self.buttons[btnIndex] setImage:image forState:UIControlStateHighlighted];
    }
}

//Sets highlighted images for buttons
-(void) setHighlightedImagesForButtons:(NSArray *) highlightedImages
{
    for (NSInteger i = 0; i < self.buttons.count && i < highlightedImages.count; i++)
    {
        [self.buttons[i] setImage:highlightedImages[i] forState:UIControlStateHighlighted];
    }
}

//Sets disabled image of a single button at specified index
-(void) setDisabledImage:(UIImage *) image forButtonAtIndex:(NSInteger) btnIndex
{
    if ([self.buttons count] > btnIndex && btnIndex >= 0)
    {
        [self.buttons[btnIndex] setImage:image forState:UIControlStateDisabled];
    }
}

//Sets disabled images for buttons
-(void) setDisabledImagesForButtons:(NSArray *) disabledImages
{
    for (NSInteger i = 0; i < self.buttons.count && i < disabledImages.count; i++)
    {
        [self.buttons[i] setImage:disabledImages[i] forState:UIControlStateDisabled];
    }
}

//Nillifies the containing window and makes the previous (original) one key and
//visible
-(void) hide
{
    self.window = nil;
    
    [self.originalWindow makeKeyAndVisible];
}

//Shows 'self' in a newly allocated UIWindow
-(void) show
{
    //Store the current window in a property, to be restored when alert view is
    //dismissed
    self.originalWindow = [UIApplication sharedApplication].keyWindow;
    
    //Allocate a new window and make it key and visible
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.screen = [UIScreen mainScreen];
    [self.window addSubview:self];
    self.window.windowLevel = UIWindowLevelAlert;
    [self.window makeKeyAndVisible];
    
    //Scale down alert view to 0.1 of its size
    self.alertMainImage.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    //Enlarge to 1.1 of its size
    [UIView animateWithDuration:ENLARGE_ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alertMainImage.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }
                     completion:^(BOOL finished) {
                         //Downsize back to actual size upon completion
                         [UIView animateWithDuration:SHRINK_ANIMATION_DURATION
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.alertMainImage.transform = CGAffineTransformIdentity;
                                          }
                                          completion:NULL];
                     }];
}

//Triggered when one of the buttons in the alert view is pressed
- (void)buttonPressed:(UIButton *) sender
{
    //Retrieve the button index and call completion block with it
    NSInteger buttonIndex = sender.tag - BUTTON_TAG_OFFSET;
    self.completion(buttonIndex);
    
    //Dismiss automatically if specified
    if (self.dismissesWithButtonPress)
    {
        [self hide];
    }
}

@end
