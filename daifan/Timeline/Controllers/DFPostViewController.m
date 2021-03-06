#import "DFPostViewController.h"


@implementation DFPostViewController {
    UITextView *_postTextView;

    TCDateSelector *_eatDateSelector;
    TCNumberSelector *_countSelector;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"发布";
    }

    return self;
}

- (void)loadView {
    [super loadView];

    CGFloat halfWidth = self.view.width / 2.0f;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat yOffset = statusBarHeight + self.barImageView.height;

    _eatDateSelector = [[TCDateSelector alloc] initWithFrame:CGRectMake(0.0f, yOffset, halfWidth, DEFAULT_BAR_HEIGHT) date:[NSDate tomorrow]];
    _eatDateSelector.textColor = [UIColor blackColor];
    _eatDateSelector.format = @"yyyy年M月d日";
    _eatDateSelector.delegate = self;
    [self.view addSubview:_eatDateSelector];

    _countSelector = [[TCNumberSelector alloc] initWithFrame:CGRectMake(halfWidth, yOffset, halfWidth, DEFAULT_BAR_HEIGHT) number:1];
    _countSelector.textColor = [UIColor blackColor];
    _countSelector.format = @"带 %d 份";
    _countSelector.minimumNumber = 1;
    _countSelector.delegate = self;
    [self.view addSubview:_countSelector];

    yOffset += DEFAULT_BAR_HEIGHT;

    _postTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, yOffset, self.view.width, self.view.height - yOffset - DEFAULT_BAR_HEIGHT)];
    _postTextView.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
    _postTextView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _postTextView.showsHorizontalScrollIndicator = NO;
    _postTextView.delegate = self;
    [self.view addSubview:_postTextView];
    [self.view sendSubviewToBack:_postTextView];

    [_postTextView becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)postContent {
    [_postTextView resignFirstResponder];

    NSString *postText = [_postTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDate *eatDate = _eatDateSelector.date;
    NSInteger totalCount = _countSelector.number;

    [_delegate post:postText date:eatDate count:totalCount];

    [super postContent];
}

- (void)relayoutViewWithKeyboardHeight:(CGFloat)newKeyboardHeight withDuration:(NSTimeInterval)duration {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat newHeight = self.view.height - statusBarHeight - self.barImageView.height - newKeyboardHeight - DEFAULT_BAR_HEIGHT;

    [UIView animateWithDuration:duration animations:^{
        _postTextView.height = newHeight;
    }];
}

#pragma mark - TCSelector delegate
- (void)selectorWillExtended:(TCSelectorBaseView *)selector {
    [_postTextView resignFirstResponder];

    if ([selector isEqual:_eatDateSelector]) {
        [_countSelector collapse];
    } else {
        [_eatDateSelector collapse];
    }
}

- (void)selectorDidCollapsed:(TCSelectorBaseView *)selector {
    if (_eatDateSelector.isExtended || _countSelector.isExtended) {
        return;
    }

    [_postTextView becomeFirstResponder];
}

#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_eatDateSelector collapse];
    [_countSelector collapse];
}

@end