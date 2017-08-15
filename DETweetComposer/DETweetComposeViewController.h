//
//  DETweetComposeViewController for Sina Weibo
//  DETweetComposeViewController.h
//  Adapted by Fangjun
//
//  DETweetComposeViewController.h
//  DETweeter

//#import "WBEngine.h"
//#import <weiboSDK/Global.h>
#import <UIKit/UIKit.h>

@class DETweetTextView;
@class DETweetSheetCardView;

@protocol DETweetComposeViewControllerDelegate;

@interface DETweetComposeViewController : UIViewController <
    UITextViewDelegate, 
    UIAlertViewDelegate,
    UIPopoverControllerDelegate
>

@property (retain, nonatomic) IBOutlet DETweetSheetCardView *cardView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UIView *cardHeaderLineView;
@property (retain, nonatomic) IBOutlet DETweetTextView *textView;
@property (retain, nonatomic) IBOutlet UIView *textViewContainer;
@property (retain, nonatomic) IBOutlet UIImageView *paperClipView;
@property (retain, nonatomic) IBOutlet UIImageView *attachment1FrameView;
@property (retain, nonatomic) IBOutlet UIImageView *attachment2FrameView;
@property (retain, nonatomic) IBOutlet UIImageView *attachment3FrameView;
@property (retain, nonatomic) IBOutlet UIImageView *attachment1ImageView;
@property (retain, nonatomic) IBOutlet UIImageView *attachment2ImageView;
@property (retain, nonatomic) IBOutlet UIImageView *attachment3ImageView;
@property (retain, nonatomic) IBOutlet UILabel *characterCountLabel;

@property (assign, nonatomic) id <DETweetComposeViewControllerDelegate> delegate;

- (IBAction)send;
- (IBAction)cancel;

typedef enum {
    DETweetComposeViewControllerResultCancelled,
    DETweetComposeViewControllerResultDone
} DETweetComposeViewControllerResult;

    // Completion handler for DETweetComposeViewController
//typedef void (^DETweetComposeViewControllerCompletionHandler)(DETweetComposeViewControllerResult result); 


    // Sets the initial text to be tweeted. Returns NO if the specified text will
    // not fit within the character space currently available, or if the sheet
    // has already been presented to the user.
- (BOOL)setInitialText:(NSString *)text;

    // Adds an image to the tweet. Returns NO if the additional image will not fit
    // within the character space currently available, or if the sheet has already
    // been presented to the user.
- (BOOL)addImage:(UIImage *)image;
- (BOOL)addImageURL:(NSString *)imageURL;

    // Adds a URL to the tweet. Returns NO if the additional URL will not fit
    // within the character space currently available, or if the sheet has already
    // been presented to the user.
//- (BOOL)addImageWithURL:(NSURL *)url;

    // Removes all images from the tweet. Returns NO and does not perform an operation
    // if the sheet has already been presented to the user. 
- (BOOL)removeAllImages;

    // Adds a URL to the tweet. Returns NO if the additional URL will not fit
    // within the character space currently available, or if the sheet has already
    // been presented to the user.
- (BOOL)addURL:(NSURL *)url;

    // Removes all URLs from the tweet. Returns NO and does not perform an operation
    // if the sheet has already been presented to the user.
- (BOOL)removeAllURLs;

    // Specify a block to be called when the user is finished. This block is not guaranteed
    // to be called on any particular thread.
//@property (nonatomic, copy) DETweetComposeViewControllerCompletionHandler completionHandler;

    // On iOS5+, set to YES to prevent from using built in Twitter credentials.
    // Set to NO by default.
@property (assign, nonatomic) BOOL alwaysUseDETwitterCredentials;


@end

@protocol DETweetComposeViewControllerDelegate <NSObject>

@optional
- (void)sendWeiboCancelledWithComposeViewController:(DETweetComposeViewController *)composeController;

- (void)sendWeiboText:(NSString *)weiboText composeViewController:(DETweetComposeViewController *)composeController;

- (void)sendWeiboText:(NSString *)weiboText image:(UIImage *)image composeViewController:(DETweetComposeViewController *)composeController;

- (void)sendWeiboText:(NSString *)weiboText imageUrl:(NSString *)imageUrl composeViewController:(DETweetComposeViewController *)composeController;

@end
