//
//  DETweetComposeViewController for Sina Weibo
//  DETweetComposeViewController.h
//  Adapted by Fangjun    
//
//  DETweetComposeViewController.h
//  DETweeter
//
//  TODO: extend it for iOS6.

#import <QuartzCore/QuartzCore.h>
#import "UIDevice+DETweetComposeViewController.h"

#import "DETweetComposeViewController.h"
#import "DETweetSheetCardView.h"
#import "DETweetTextView.h"
#import "DETweetGradientView.h"


@interface DETweetComposeViewController ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *imageurls;
@property (nonatomic, retain) NSMutableArray *urls;
@property (nonatomic, retain) NSArray *attachmentFrameViews;
@property (nonatomic, retain) NSArray *attachmentImageViews;
@property (nonatomic) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, assign) UIViewController *fromViewController;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) DETweetGradientView *gradientView;
@property (nonatomic, retain) UIPickerView *accountPickerView;
@property (nonatomic, retain) UIPopoverController *accountPickerPopoverController;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (void)tweetComposeViewControllerInit;
- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)isPresented;
- (NSInteger)charactersAvailable;
- (void)updateCharacterCount;
- (NSInteger)attachmentsCount;
- (void)updateAttachments;
- (UIImage*)captureView:(UIView *)view;

@end


@implementation DETweetComposeViewController

    // IBOutlets
@synthesize cardView = _cardView;
@synthesize titleLabel = _titleLabel;
@synthesize cancelButton = _cancelButton;
@synthesize sendButton = _sendButton;
@synthesize cardHeaderLineView = _cardHeaderLineView;
@synthesize textView = _textView;
@synthesize textViewContainer = _textViewContainer;
@synthesize paperClipView = _paperClipView;
@synthesize attachment1FrameView = _attachment1FrameView;
@synthesize attachment2FrameView = _attachment2FrameView;
@synthesize attachment3FrameView = _attachment3FrameView;
@synthesize attachment1ImageView = _attachment1ImageView;
@synthesize attachment2ImageView = _attachment2ImageView;
@synthesize attachment3ImageView = _attachment3ImageView;
@synthesize characterCountLabel = _characterCountLabel;
@synthesize delegate;

//@synthesize wbEngine = _wbEngine;
//@synthesize wbEngine;

    // Public
//@synthesize completionHandler = _completionHandler;
@synthesize alwaysUseDETwitterCredentials = _alwaysUseDETwitterCredentials;

    // Private
@synthesize text = _text;
@synthesize images = _images;
@synthesize urls = _urls;
@synthesize imageurls = _imageurls;
@synthesize attachmentFrameViews = _attachmentFrameViews;
@synthesize attachmentImageViews = _attachmentImageViews;
@synthesize previousStatusBarStyle = _previousStatusBarStyle;
@synthesize fromViewController = _fromViewController;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize gradientView = _gradientView;
@synthesize accountPickerView = _accountPickerView;
@synthesize accountPickerPopoverController = _accountPickerPopoverController;
@synthesize activityIndicator = _activityIndicator;


NSInteger const DETweetMaxLength = 140;
NSInteger const DETweetURLLength = 20;  // https://dev.twitter.com/docs/tco-url-wrapper
//NSInteger const DETweetURLLength = 0;

NSInteger const DETweetMaxImages = 1;  // We'll get this dynamically later, but not today.
//static NSString * const DETweetLastAccountIdentifier = @"DETweetLastAccountIdentifier";

#define degreesToRadians(x) (M_PI * x / 180.0f)


- (UIImage*)captureView:(UIView *)view
{    
    CGRect rect = [[UIScreen mainScreen] bounds];  
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();  
    [view.layer renderInContext:context];  
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();
    return image;
    
//    // 优化retina截图清晰度 
//    BOOL isRetina = [UIScreen mainScreen].scale > 1.0;
//    UIImage *snapImage = nil;
//
//    CGFloat scale = isRetina ? [UIScreen mainScreen].scale : 1.0;
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, scale);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    if (isRetina) CGContextSetInterpolationQuality(ctx, kCGInterpolationLow);
//    [view.layer renderInContext:ctx];
//    snapImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return snapImage;
}



#pragma mark - Setup & Teardown


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self tweetComposeViewControllerInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tweetComposeViewControllerInit];
    }
    return self;
}


- (void)tweetComposeViewControllerInit
{
    _images = [[NSMutableArray alloc] init];
    _urls = [[NSMutableArray alloc] init];
    _imageurls = [[NSMutableArray alloc] init];
    
    //WEIBO
//    WBEngine *engine = [[WBEngine alloc] initWithAppKey:kWeiboAppKey appSecret:kWeiboAppSecret];
//    [engine setRootViewController:self];
//    [engine setDelegate:self];
//    [engine setRedirectURI:@"http://"];
//    [engine setIsUserExclusive:NO];
//    self.wbEngine = engine;
//    [engine release];
    
//    if ([self.wbEngine isLoggedIn] && ![self.wbEngine isAuthorizeExpired]){
//        NSLog(@"ComposerView// weibo logged in && authed");
//    }else{
//        NSLog(@"ComposerView// noooo weibo logged in && authed");
//    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
    
    // Register context with the notification center
    [nc addObserver:self
           selector:@selector(keyboardInputModeDidChange:)
               name:UITextInputCurrentInputModeDidChangeNotification
             object:nil];
}

- (void)adjustViewsFrame
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _backgroundImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [wbEngine setDelegate:nil];
//    [wbEngine release], wbEngine = nil;
    
        // IBOutlets
    [_cardView release], _cardView = nil;
    [_titleLabel release], _titleLabel = nil;
    [_cancelButton release], _cancelButton = nil;
    [_sendButton release], _sendButton = nil;
    [_cardHeaderLineView release], _cardHeaderLineView = nil;
    [_textView release], _textView = nil;
    [_textViewContainer release], _textViewContainer = nil;
    [_paperClipView release], _paperClipView = nil;
    [_attachment1FrameView release], _attachment1FrameView = nil;
    [_attachment2FrameView release], _attachment2FrameView = nil;
    [_attachment3FrameView release], _attachment3FrameView = nil;
    [_attachment1ImageView release], _attachment1ImageView = nil;
    [_attachment2ImageView release], _attachment2ImageView = nil;
    [_attachment3ImageView release], _attachment3ImageView = nil;
    [_characterCountLabel release], _characterCountLabel = nil;
    
        // Public
//    [_completionHandler release], _completionHandler = nil;
    
        // Private
    [_text release], _text = nil;
    [_images release], _images = nil;
    [_urls release], _urls = nil;
    [_imageurls release], _imageurls = nil;
    [_attachmentFrameViews release], _attachmentFrameViews = nil;
    [_attachmentImageViews release], _attachmentImageViews = nil;
    [_backgroundImageView release], _backgroundImageView = nil;
    [_gradientView release], _gradientView = nil;
    [_activityIndicator release], _activityIndicator = nil;
    
    //Delegate
    self.delegate = nil;
    
    [super dealloc];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.textViewContainer.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    self.view.clipsToBounds = NO;
        
    if ([UIDevice de_isIOS5]) {
        self.fromViewController = self.presentingViewController;
        self.textView.keyboardType = UIKeyboardTypeTwitter;
        self.textView.returnKeyType = UIReturnKeySend;
    }
    else {
        self.fromViewController = self.parentViewController;
    }

    
        // Put the attachment frames and image views into arrays so they're easier to work with.
        // Order is important, so we can't use IB object arrays. Or at least this is easier.
    self.attachmentFrameViews = [NSArray arrayWithObjects:
                                 self.attachment1FrameView,
                                 self.attachment2FrameView,
                                 self.attachment3FrameView,
                                 nil];
    
    self.attachmentImageViews = [NSArray arrayWithObjects:
                                 self.attachment1ImageView,
                                 self.attachment2ImageView,
                                 self.attachment3ImageView,
                                 nil];
    
        // Now add some angle to attachments 2 and 3.
    self.attachment2FrameView.transform = CGAffineTransformMakeRotation(degreesToRadians(-6.0f));
    self.attachment2ImageView.transform = CGAffineTransformMakeRotation(degreesToRadians(-6.0f));
    self.attachment3FrameView.transform = CGAffineTransformMakeRotation(degreesToRadians(-12.0f));
    self.attachment3ImageView.transform = CGAffineTransformMakeRotation(degreesToRadians(-12.0f));
    
        // Mask the corners on the image views so they don't stick out of the frame.
    [self.attachmentImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        ((UIImageView *)obj).layer.cornerRadius = 3.0f;
        ((UIImageView *)obj).layer.masksToBounds = YES;
    }];
    
    self.textView.text = self.text;
    [self.textView becomeFirstResponder];
    
    [self updateCharacterCount];
    [self updateAttachments];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        // Take a snapshot of the current view, and make that our background after our view animates into place.
        // This only works if our orientation is the same as the presenting view.
        // If they don't match, just display the gray background.
//    if (self.interfaceOrientation == self.fromViewController.interfaceOrientation) {
//        UIImage *backgroundImage = [self captureView:[UIApplication sharedApplication].keyWindow];
//        self.backgroundImageView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
//    }
//    else {
//        self.backgroundImageView = [[[UIImageView alloc] initWithFrame:self.fromViewController.view.bounds] autorelease];
//    }
    
    if ([UIDevice de_isPhone]) {
        self.backgroundImageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
        //    self.backgroundImageView.frame = self.view.bounds;
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundImageView.alpha = 0.0f;
        self.backgroundImageView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:self.backgroundImageView atIndex:0];
        
        // 适应不同设备
        [self adjustViewsFrame];
    }
    
    
        // Now let's fade in a gradient view over the presenting view.
//    self.gradientView = [[[DETweetGradientView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds] autorelease];
//    self.gradientView.autoresizingMask = UIViewAutoresizingNone;
//    self.gradientView.transform = self.fromViewController.view.transform;
//    self.gradientView.alpha = 0.0f;
//    self.gradientView.center = [UIApplication sharedApplication].keyWindow.center;
//    [self.fromViewController.view addSubview:self.gradientView];
//    [UIView animateWithDuration:0.3f
//                     animations:^ {
//                         self.gradientView.alpha = 1.0f;
//                     }];    
    
//    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES]; 
    
    [self updateFramesForOrientation:self.interfaceOrientation];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([UIDevice de_isPhone]) {
        self.backgroundImageView.alpha = 0.4f;
    }
//    self.backgroundImageView.frame = [self.view convertRect:self.backgroundImageView.frame fromView:[UIApplication sharedApplication].keyWindow];
//    [self.view insertSubview:self.gradientView aboveSubview:self.backgroundImageView];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([UIDevice de_isPhone]) {
        self.backgroundImageView.alpha = 0.0;
    }
    
//    UIView *presentingView = [UIDevice de_isIOS5] ? self.fromViewController.view : self.parentViewController.view;
//    [presentingView addSubview:self.gradientView];
    
//    [self.backgroundImageView removeFromSuperview];
//    self.backgroundImageView = nil;
    
//    [UIView animateWithDuration:0.3f
//                     animations:^ {
//                         self.gradientView.alpha = 0.0f;
//                     }
//                     completion:^(BOOL finished) {
//                         [self.gradientView removeFromSuperview];
//                     }];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.parentViewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.parentViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    if ([UIDevice de_isPhone]) {
        //BYFJ    
        return (interfaceOrientation == UIInterfaceOrientationPortrait);

    }

    return YES;  // Default for iPad.
}

#ifdef __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#else
- (NSUInteger)supportedInterfaceOrientations
#endif
{
    
    if (self.parentViewController && [self.parentViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.parentViewController supportedInterfaceOrientations];
    }
    
    if (self.presentingViewController && [self.presentingViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.parentViewController supportedInterfaceOrientations];
    }
    
    if ([UIDevice de_isPhone]) {
        //BYFJ
        return UIInterfaceOrientationMaskPortrait;
        
    }
    
    return UIInterfaceOrientationMaskAll;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    [self updateFramesForOrientation:interfaceOrientation];
    self.accountPickerView.alpha = 0.0f;
    
        // Our fake background won't rotate properly. Just hide it.
    if (interfaceOrientation == self.presentedViewController.interfaceOrientation) {
        self.backgroundImageView.alpha = 1.0f;
    }
    else {
        self.backgroundImageView.alpha = 0.0f;
    }
}



- (void)viewDidUnload
{
        // Keep:
        //  _completionHandler
        //  _text
        //  _images
        //  _urls
        //  _twitterAccount
    
        // Save the text.
    self.text = self.textView.text;
    
        // IBOutlets
    self.cardView = nil;
    self.titleLabel = nil;
    self.cancelButton = nil;
    self.sendButton = nil;
    self.cardHeaderLineView = nil;
    self.textView = nil;
    self.textViewContainer = nil;
    self.paperClipView = nil;
    self.attachment1FrameView = nil;
    self.attachment2FrameView = nil;
    self.attachment3FrameView = nil;
    self.attachment1ImageView = nil;
    self.attachment2ImageView = nil;
    self.attachment3ImageView = nil;
    self.characterCountLabel = nil;
    
        // Private
    self.attachmentFrameViews = nil;
    self.attachmentImageViews = nil;
    self.gradientView = nil;
    self.activityIndicator = nil;

    [super viewDidUnload];
}


#pragma mark - Public

- (BOOL)setInitialText:(NSString *)initialText
{
    if ([self isPresented]) {
//        NSLog(@"isPresented");
        return NO;
    }
    
    if (([self charactersAvailable] - (NSInteger)[initialText length]) < 0) {
//        NSLog(@"charactersAvailable %d",[self charactersAvailable]);
        return NO;
    }
    
    self.text = initialText;  // Keep a copy in case the view isn't loaded yet.
    self.textView.text = self.text;
    
    return YES;
}


- (BOOL)addImage:(UIImage *)image
{
    if (image == nil) {
        return NO;
    }
    
    if ([self isPresented]) {
        return NO;
    }
    
    if ([self.images count] >= DETweetMaxImages) {
        return NO;
    }
    
    if ([self attachmentsCount] >= 3) {
        return NO;  // Only three allowed.
    }
    
//    if (([self charactersAvailable] - (DETweetURLLength + 1)) < 0) {  // Add one for the space character.
//        return NO;
//    }
    
    [self.images addObject:image];
    return YES;
}

/*
- (BOOL)addImageWithURL:(NSURL *)url;
    // Not yet impelemented.
{
        // We should probably just start the download, rather than saving the URL.
        // Just save the image once we have it.
    return NO;
}
*/

- (BOOL)removeAllImages
{
    if ([self isPresented]) {
        return NO;
    }
    
    [self.images removeAllObjects];
    return YES;
}

- (BOOL)addImageURL:(NSString *)imageURL
{
    if (imageURL == nil) {
        return NO;
    }
    
    if ([self isPresented]) {
        return NO;
    }
    
    if ([[imageURL lowercaseString] hasSuffix:@".png"]
        || [[imageURL lowercaseString] hasSuffix:@".jpg"]
        || [[imageURL lowercaseString] hasSuffix:@".jpeg"]
        || [[imageURL lowercaseString] hasSuffix:@".png"]) {
        [self.imageurls addObject:imageURL];
        return YES;
    }
    
    return NO;
}


- (BOOL)addURL:(NSURL *)url
{
    if (url == nil) {
        return NO;
    }
    
    if ([self isPresented]) {
        return NO;
    }
    
    if ([self attachmentsCount] >= 3) {
        return NO;  // Only three allowed.
    }
    
    if (([self charactersAvailable] - (DETweetURLLength + 1)) < 0) {  // Add one for the space character.
        return NO;
    }
    
    [self.urls addObject:url];
    return YES;
}


- (BOOL)removeAllURLs
{
    if ([self isPresented]) {
        return NO;
    }
    
    [self.urls removeAllObjects];
    return YES;
}


#pragma mark - Private

- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    CGFloat buttonHorizontalMargin = 8.0f;
    CGFloat cardWidth, cardTop, cardHeight, cardHeaderLineTop, buttonTop;
    UIImage *cancelButtonImage, *sendButtonImage;
    CGFloat titleLabelFontSize, titleLabelTop;
    CGFloat characterCountLeft, characterCountTop;
    
    if ([UIDevice de_isPhone]) {
        cardWidth = CGRectGetWidth(self.view.bounds) - 30.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//            cardTop = 25.0f;
            cardTop = 35.0f;
            if (([UIScreen mainScreen].bounds.size.height == 568 || [UIScreen mainScreen].bounds.size.width == 568)) {
                cardTop += 40;
            }
            cardHeight = 189.0f;
            buttonTop = 0.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DETcancel"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DETdone"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 44.0f;
            titleLabelFontSize = 20.0f;
            titleLabelTop = 9.0f;
        }
        else {
            cardTop = -1.0f;
            cardHeight = 150.0f;
            buttonTop = 0.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DETcancel"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DETdone"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 32.0f;
            titleLabelFontSize = 17.0f;
            titleLabelTop = 5.0f;
        }
    }
    else {  // iPad. Similar to iPhone portrait.
        cardWidth = 543.0f;
        cardHeight = 189.0f;
        buttonTop = 0.0f;
        cancelButtonImage = [[UIImage imageNamed:@"DETcancel"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        sendButtonImage = [[UIImage imageNamed:@"DETdone"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        cardHeaderLineTop = 41.0f;
        titleLabelFontSize = 20.0f;
        titleLabelTop = 9.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            cardTop = 280.0f;
        }
        else {
            cardTop = 110.0f;
        }
    }
    
    CGFloat cardLeft = trunc(([UIScreen mainScreen].bounds.size.width - cardWidth) / 2);

    
//    if([[UITextInputMode currentInputMode].primaryLanguage isEqualToString:@"zh-Hans"]){
//
//    }else{
//        cardTop += 40;    
//    }
    
    self.cardView.frame = CGRectMake(cardLeft, cardTop, cardWidth, cardHeight);
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
    self.titleLabel.frame = CGRectMake(0.0f, titleLabelTop, cardWidth, self.titleLabel.frame.size.height);
    
    [self.cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(buttonHorizontalMargin, buttonTop, self.cancelButton.frame.size.width, cancelButtonImage.size.height);
    
    [self.sendButton setBackgroundImage:sendButtonImage forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.cardView.bounds.size.width - buttonHorizontalMargin - self.sendButton.frame.size.width, buttonTop, self.sendButton.frame.size.width, sendButtonImage.size.height);
    
    self.cardHeaderLineView.frame = CGRectMake(0.0f, cardHeaderLineTop, self.cardView.bounds.size.width, self.cardHeaderLineView.frame.size.height);
    self.cardHeaderLineView.backgroundColor = [UIColor colorWithRed:(CGFloat)203/255 green:(CGFloat)203/255 blue:(CGFloat)200/255 alpha:1.0];
    
    CGFloat textWidth = CGRectGetWidth(self.cardView.bounds);
    if ([self attachmentsCount] > 0) {
        textWidth -= CGRectGetWidth(self.attachment1FrameView.frame) + 10.0f;  // Got to measure frame 1, because it's not rotated. Other frames are funky.
    }
    CGFloat textTop = CGRectGetMaxY(self.cardHeaderLineView.frame) + 1.0f;
    CGFloat textHeight = self.cardView.bounds.size.height - textTop - 30.0f;
    self.textViewContainer.frame = CGRectMake(0.0f, textTop, self.cardView.bounds.size.width, textHeight);
    self.textView.frame = CGRectMake(10.0f, 0.0f, textWidth - 10, self.textViewContainer.frame.size.height);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -(self.cardView.bounds.size.width - textWidth - 1.0f));
    
    self.paperClipView.frame = CGRectMake(CGRectGetMaxX(self.cardView.frame) - self.paperClipView.frame.size.width + 6.0f,
                                          CGRectGetMinY(self.cardView.frame) + CGRectGetMaxY(self.cardHeaderLineView.frame) + 1.0f,
                                          self.paperClipView.frame.size.width,
                                          self.paperClipView.frame.size.height);
    
        // We need to position the rotated views by their center, not their frame.
        // This isn't elegant, but it is correct. Half-points are required because
        // some frame sizes aren't evenly divisible by 2.
    self.attachment1FrameView.center = CGPointMake(self.cardView.bounds.size.width - 45.0f, CGRectGetMaxY(self.paperClipView.frame) - cardTop + 18.0f);
    self.attachment1ImageView.center = CGPointMake(self.cardView.bounds.size.width - 45.5, self.attachment1FrameView.center.y - 2.0f);
    
    self.attachment2FrameView.center = CGPointMake(self.attachment1FrameView.center.x - 4.0f, self.attachment1FrameView.center.y + 5.0f);
    self.attachment2ImageView.center = CGPointMake(self.attachment1ImageView.center.x - 4.0f, self.attachment1ImageView.center.y + 5.0f);
    
    self.attachment3FrameView.center = CGPointMake(self.attachment2FrameView.center.x - 4.0f, self.attachment2FrameView.center.y + 5.0f);
    self.attachment3ImageView.center = CGPointMake(self.attachment2ImageView.center.x - 4.0f, self.attachment2ImageView.center.y + 5.0f);
    
//    characterCountLeft = CGRectGetWidth(self.cardView.frame) - CGRectGetWidth(self.characterCountLabel.frame) - 12.0f;
    characterCountLeft = 12.0;
    characterCountTop = CGRectGetHeight(self.cardView.frame) - CGRectGetHeight(self.characterCountLabel.frame) - 10.0f;
    if ([UIDevice de_isPhone]) {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            characterCountTop -= 5.0f;
            if ([self attachmentsCount] > 0) {
                characterCountLeft -= CGRectGetWidth(self.attachment3FrameView.frame) - 15.0f;
            }
        }
    }
    self.characterCountLabel.frame = CGRectMake(characterCountLeft, characterCountTop, self.characterCountLabel.frame.size.width, self.characterCountLabel.frame.size.height);
    
    self.gradientView.frame = self.gradientView.superview.bounds;
}


- (BOOL)isPresented
{
    return [self isViewLoaded];
}


- (NSInteger)charactersAvailable
{
    NSInteger available = DETweetMaxLength;
    //available -= (DETweetURLLength + 1) * [self.images count];
    available -= (DETweetURLLength + 1) * [self.urls count];
    available -= [self.textView.text length];
    
    if ( (available < DETweetMaxLength) && ([self.textView.text length] == 0) ) {
        available += 1;  // The space we added for the first URL isn't needed.
    }
    
    return available;
}


- (void)updateCharacterCount
{
    NSInteger available = [self charactersAvailable];
    
    self.characterCountLabel.text = [NSString stringWithFormat:@"%ld", (long)available];
    
    if (available >= 0) {
        self.characterCountLabel.textColor = [UIColor grayColor];
        self.sendButton.enabled = (available != DETweetMaxLength);  // At least one character is required.
    }
    else {
        self.characterCountLabel.textColor = [UIColor colorWithRed:0.64f green:0.32f blue:0.32f alpha:1.0f];
        self.sendButton.enabled = NO;
    }
}


- (NSInteger)attachmentsCount
{
    return [self.images count] + [self.urls count];
}


- (void)updateAttachments
{
    CGRect frame = self.textView.frame;
    if ([self attachmentsCount] > 0) {
        frame.size.width = self.cardView.frame.size.width - self.attachment1FrameView.frame.size.width;
    }
    else {
        frame.size.width = self.cardView.frame.size.width;
    }
    self.textView.frame = frame;
    
        // Create a array of attachment images to display.
    NSMutableArray *attachmentImages = [NSMutableArray arrayWithArray:self.images];
    for (NSInteger index = 0; index < [self.urls count]; index++) {
        [attachmentImages addObject:[UIImage imageNamed:@"DETweetURLAttachment"]];
    }
    
    self.paperClipView.hidden = YES;
    self.attachment1FrameView.hidden = YES;
    self.attachment2FrameView.hidden = YES;
    self.attachment3FrameView.hidden = YES;
    
    if ([attachmentImages count] >= 1) {
        self.paperClipView.hidden = NO;
        self.attachment1FrameView.hidden = NO;
        self.attachment1ImageView.image = [attachmentImages objectAtIndex:0];
        
        if ([attachmentImages count] >= 2) {
            self.paperClipView.hidden = NO;
            self.attachment2FrameView.hidden = NO;
            self.attachment2ImageView.image = [attachmentImages objectAtIndex:1];
            
            if ([attachmentImages count] >= 3) {
                self.paperClipView.hidden = NO;
                self.attachment3FrameView.hidden = NO;
                self.attachment3ImageView.image = [attachmentImages objectAtIndex:2];
            }
        }
    }
}


#pragma mark - WBEngineDelegate Methods

//- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
//{
////    NSLog(@"requestDidSucceed");
////    NSLog(@"%@",result);
//    
//    CGFloat yOffset = -(self.view.bounds.size.height + CGRectGetMaxY(self.cardView.frame) + 10.0f);
//    
//    [UIView animateWithDuration:0.35f
//                     animations:^ {
//                         self.cardView.frame = CGRectOffset(self.cardView.frame, 0.0f, yOffset);
//                         self.paperClipView.frame = CGRectOffset(self.paperClipView.frame, 0.0f, yOffset);
//                     }];
//    
//    
//    if (self.completionHandler) {
//        self.completionHandler(DETweetComposeViewControllerResultDone);
//    }
//    else {
//        [self dismissModalViewControllerAnimated:YES];
//    }
//    
//}
//
//- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
//{
////    NSLog(@"requestDidFail");
//
//    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Send Weibo", @"")
//                                                         message:[NSString stringWithFormat:NSLocalizedString(@"The weibo, \"%@\" cannot be sent because the connection to Weibo failed.", @""), self.textView.text]
//                                                        delegate:self
//                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
//                                               otherButtonTitles:NSLocalizedString(@"Try Again", @""), nil] autorelease];
//    [alertView show];
//    
//    self.sendButton.enabled = YES;
//    self.activityIndicator.hidden = YES;
//    [self.activityIndicator stopAnimating];
//
//
//}
//
//- (void)engineNotAuthorized:(WBEngine *)engine
//{
//    
////    NSLog(@"engineNotAuthorized");
//
//    //    [OAuth clearCrendentials];
//    [self dismissModalViewControllerAnimated:YES];
//    
//    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Send Weibo", @"")
//                                 message:NSLocalizedString(@"Unable to login to Weibo with existing credentials. Try again with new credentials.", @"")
//                                delegate:nil
//                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                       otherButtonTitles:nil] autorelease] show];
//
//}
//
//- (void)engineAuthorizeExpired:(WBEngine *)engine
//{
////    NSLog(@"engineAuthorizeExpired");
//    
//    [self dismissModalViewControllerAnimated:YES];
//    
//    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Send Weibo", @"")
//                                 message:NSLocalizedString(@"Unable to login to Weibo with existing credentials. Try again with new credentials.", @"")
//                                delegate:nil
//                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                       otherButtonTitles:nil] autorelease] show];
//
//    
//}



#pragma mark - Actions

- (IBAction)send
{
    self.sendButton.enabled = NO;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSString *tweet = self.textView.text;
    
    for (NSURL *url in self.urls) {
        NSString *urlString = [url absoluteString];
        if ([tweet length] > 0) {
            tweet = [tweet stringByAppendingString:@" "];
        }
        tweet = [tweet stringByAppendingString:urlString];
    }
    
//    if (self.wbEngine) {
//        self.wbEngine.delegate = self;
//    }
    
    if ([self.imageurls count] > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboText:imageUrl:composeViewController:)]) {
            [self.delegate sendWeiboText:tweet imageUrl:[self.imageurls objectAtIndex:0] composeViewController:self];
        }
//        [self.wbEngine sendWeiBoWithText:tweet imageUrl:[self.imageurls objectAtIndex:0]];
        return;
    }
    
    if([self.images count]>0){
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboText:image:composeViewController:)]) {
            [self.delegate sendWeiboText:tweet image:[self.images objectAtIndex:0] composeViewController:self];
        }
//        [self.wbEngine sendWeiBoWithText:tweet image:[self.images objectAtIndex:0]];
    }else{
//        [self.wbEngine sendWeiBoWithText:tweet image:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboText:composeViewController:)]) {
            [self.delegate sendWeiboText:tweet composeViewController:self];
        }
    }
    
}


- (IBAction)cancel
{
//    if (self.completionHandler) {
////        NSLog(@"self.completionHandler");
//        self.completionHandler(DETweetComposeViewControllerResultCancelled);
//    }
//    else {
        [self dismissViewControllerAnimated:YES completion:nil];
//    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboCancelledWithComposeViewController:)]) {
        [self.delegate sendWeiboCancelledWithComposeViewController:self];
    }
}



#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateCharacterCount];

}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self send];
        return NO;
    }

//    TODO
//    if([text isEqualToString:@"@"]) {
//        NSLog(@"@@@@@@");
//    }
    
    return YES;
}


- (void) keyboardInputModeDidChange:(NSNotification *)notification{
    
//    NSLog(@"%@",[UITextInputMode currentInputMode].primaryLanguage);
    

//    CGRect frame=self.cardView.frame;
//    CGRect clipFrame=self.paperClipView.frame;
//    
//    if([[UITextInputMode currentInputMode].primaryLanguage isEqualToString:@"zh-Hans"]){
//        NSLog(@"is Chinese");
//        frame.origin.y -= 40;
//        clipFrame.origin.y -=40;
//        
//    }else{
//        frame.origin.y += 40;
//        clipFrame.origin.y +=40;
//    }
//    
//    self.cardView.frame = frame;
//    self.paperClipView.frame = clipFrame;
}



@end
