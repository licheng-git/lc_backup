//
//  keyboardViewController.m
//  lcAhwTest
//
//  Created by licheng on 16/5/5.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "keyboardViewController.h"
#import "KUtils.h"
#import "UITextView+lc.h"

@interface keyboardViewController() <UISearchBarDelegate,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>
{
    UISearchBar    *_searchBar;
    UITextField    *_textField;
    UITextView     *_textView;
    UIScrollView   *_selfScrollView;
    UIView         *_tvInputView;
    //UIView         *_tvInputAccessoryView;
}
@end

@implementation keyboardViewController

- (void)viewDidLoad
{
    self.title = @"键盘";
    
    
    // 键盘出现或消失时被遮住部分跟着滚 键盘监听事件
    [self createSelfScrollView];  // *_* 需要放在createView最前面，可以放到loadView中
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, kDEFAULT_ORIGIN_Y + 10, kSCREEN_WIDTH - 40, 30)];
    [self.view addSubview:_searchBar];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"UISearchBar";
    _searchBar.backgroundColor = [UIColor yellowColor];
    //_searchBar.showsCancelButton = YES;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(220, kSCREEN_HEIGHT-60, 100, 50)];
    _textField.delegate = self;
    [self.view addSubview:_textField];
    _textField.placeholder = @"UITextField";
    _textField.backgroundColor = [UIColor orangeColor];
    //[_textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    //[_textField setValue:[UIFont systemFontOfSize:14.0f] forKeyPath:@"_placeholderLabel.font"];
    //[_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _textField.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    _textField.inputView.backgroundColor = [UIColor purpleColor];
    _textField.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    _textField.inputAccessoryView.backgroundColor = [UIColor redColor];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, kSCREEN_HEIGHT-310, 200, 300)];
    [self.view addSubview:_textView];
    _textView.delegate = self;
    _textView.placeholder = @"UITextView";
    _textView.placeholder = @"UITextView placeholder";
    _textView.backgroundColor = [UIColor greenColor];
    //_textView.inputView =
    _textView.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    _textView.inputAccessoryView.backgroundColor = [UIColor blueColor];
    
    UIButton *btn = [KUtils createButtonWithFrame:CGRectMake(10, CGRectGetMinY(_textView.frame)-50, 320, 30) title:@"_textView 自定义键盘 emoji 图文混编" titleColor:[UIColor grayColor] target:self tag:101];
    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.layer.borderWidth = 1;
    btn.layer.cornerRadius = 5;
    [self.view addSubview:btn];
    
    // 添加手势 单击 隐藏键盘 （与touchesBegan:withEvent:效果相同）
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    // 注册 键盘监听事件 键盘出现或消失时被遮住部分跟着滚
    [self registerNotificationsForKeyboard];
}

- (void)dealloc
{
    NSLog(@"dealloc");
    // 注销 键盘监听事件
    [self unregisterNotificationsForKeyboard];
}


#pragma mark -  UISearchBar Delegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _searchBar.showsCancelButton = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    [_searchBar resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

//// _textView回车时隐藏键盘
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [_textField resignFirstResponder];
//    return YES;
//}

#pragma mark - UITextViewDelegate

// _textView编辑时隐藏placeholder
- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"*_* textview.delegate textViewDidChange");
    //if (_textView.text && _textView.text.length > 0) {
    //    _lbPlaceholder.hidden = YES;
    //}
    //else {
    //    _lbPlaceholder.hidden = NO;
    //}
}


#pragma mark - UIGestureRecognizer Delegate + SelectorResponseMethod

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isKindOfClass:[UIControl class]])
//    {
//        return NO;
//    }
//    else if ([touch.view isKindOfClass:[UIImageView class]])
//    {
//        return NO;
//    }
//    return YES;
//}

- (void)singleTapGestureCaptured:(id)sender
{
    if ([_textField isFirstResponder])
    {
        [_textField resignFirstResponder];
    }
    if ([_textView isFirstResponder])
    {
        [_textView resignFirstResponder];
    }
}


#pragma mark - touchesBegan:withEvent:    <UIKit/UIResponder.h>

//// 单击 隐藏键盘 （与手势singleTapGestureCaptured效果相同）    *_* _selfScrollView影响到了
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch *anyTouch = event.allTouches.anyObject;
//    if (anyTouch.view != _textField && [_textField isFirstResponder])
//    {
//        [_textField resignFirstResponder];
//    }
//    if (anyTouch.view != _textView && [_textView isFirstResponder])
//    {
//        [_textView resignFirstResponder];
//    }
//    [super touchesBegan:touches withEvent:event];
//}


#pragma mark - Keyboard Notification

//- (void)loadView
//{
//    [super loadView];
//    // 键盘出现或消失时被遮住部分跟着滚 键盘监听事件
//    [self createSelfScrollView];  // *_* 需要放在createView最前面
//}
// 创建滚动视图 用于注册键盘监听事件后 键盘出现消失 改动frame
- (void)createSelfScrollView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _selfScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _selfScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    self.view = _selfScrollView;
}

// 注册 监听键盘事件
- (void)registerNotificationsForKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

// 注销 监听键盘事件
- (void)unregisterNotificationsForKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 键盘出现  遮住部分往上滚    // *_* 注册方法会执行多次（系统两次、第三方键盘三次），为毛？
- (void)keyboardDidShow:(NSNotification *)aNotification
{
//    NSDictionary *info = [aNotification userInfo];
//    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    double keyboardDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    [UIView animateWithDuration:keyboardDuration animations:^{
//        self.view.frame = CGRectMake(0, -keyboardEndFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
//    }];
    NSDictionary *info = [aNotification userInfo];
    CGRect keyboardEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.size.height, 0.0);
    _selfScrollView.contentInset = contentInsets;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{  // UITextField 1毫秒
        CGPoint bottom = CGPointMake(0, keyboardEndFrame.size.height);
        [_selfScrollView setContentOffset:bottom animated:YES];
    });
}

// 键盘消失  被遮住部分再滚回去
- (void)keyboardWillHidden:(NSNotification *)aNotification
{
//    NSDictionary *info = [aNotification userInfo];
//    double keyboardDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    [UIView animateWithDuration:keyboardDuration animations:^{
//        self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//    }];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    _selfScrollView.contentInset = contentInsets;
    //[_selfScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}




#pragma mark - 键盘切换 emoji 图文混编

- (void)buttonAction:(id)sender
{
    if (!_textView.inputView) {
        [self creatInputView];
        _textView.inputView = _tvInputView;
    }
    else {
        _textView.inputView = nil;
    }
    
    if ([_textView isFirstResponder]) {
        [_textView reloadInputViews];  // 切换键盘
    }
    else {
        [_textView becomeFirstResponder];  // 键盘从隐藏变为显示
    }
}

- (void)creatInputView
{
    if (_tvInputView) {
        return;
    }
    _tvInputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    _tvInputView.backgroundColor = [UIColor yellowColor];
    UIButton *btnEmoji0 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnEmoji0.frame = CGRectMake(10, 10, 20, 20);
    [btnEmoji0 setBackgroundImage:[UIImage imageNamed:@"note_left_menu_msg"] forState:UIControlStateNormal];
    [btnEmoji0 addTarget:self action:@selector(btnAction_Emoji:) forControlEvents:UIControlEventTouchUpInside];
    btnEmoji0.tag = 101;
    [_tvInputView addSubview:btnEmoji0];
    UIButton *btnEmoji1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnEmoji1.frame = CGRectMake(50, 10, 20, 20);
    [btnEmoji1 setBackgroundImage:[UIImage imageNamed:@"note_left_menu_topic"] forState:UIControlStateNormal];
    [btnEmoji1 addTarget:self action:@selector(btnAction_Emoji:) forControlEvents:UIControlEventTouchUpInside];
    btnEmoji1.tag = 102;
    [_tvInputView addSubview:btnEmoji1];
    UIButton *btnEmoji2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnEmoji2.frame = CGRectMake(kSCREEN_WIDTH - 50, 10, 20, 20);
    [btnEmoji2 setBackgroundImage:[UIImage imageNamed:@"note_left_menu_setting"] forState:UIControlStateNormal];
    [btnEmoji2 addTarget:self action:@selector(btnAction_Emoji:) forControlEvents:UIControlEventTouchUpInside];
    btnEmoji2.tag = 103;
    [_tvInputView addSubview:btnEmoji2];
}

- (void)btnAction_Emoji:(id)sender
{
//    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];  // 富文本中的图片
//    textAttachment.image = [UIImage imageNamed:@"note_left_menu_setting"];
//    textAttachment.bounds = CGRectMake(0, 0, 40, 40);  // 图片大小
//    NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:textAttachment];  // 富文本
//    NSUInteger tvCurrentLoc = _textView.selectedRange.location;  // 光标位置
//    [_textView.textStorage insertAttributedString:attrStr atIndex:tvCurrentLoc];  // 富文本中插入图片
//    _textView.selectedRange = NSMakeRange(_textView.selectedRange.location+1, _textView.selectedRange.length);  // 插入图片后移动光标位置
    
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 101 || btn.tag == 102) {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        if (btn.tag == 101) {
            textAttachment.image = [UIImage imageNamed:@"note_left_menu_msg"];
            textAttachment.bounds = CGRectMake(0, 0, 40, 40);
        }
        else if (btn.tag == 102) {
            textAttachment.image = [UIImage imageNamed:@"note_left_menu_topic"];
        }
        NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        NSUInteger tvCurrentLoc = _textView.selectedRange.location;
        [_textView.textStorage insertAttributedString:attrStr atIndex:tvCurrentLoc];
        _textView.selectedRange = NSMakeRange(_textView.selectedRange.location+1, _textView.selectedRange.length);
    }
    else if (btn.tag == 103) {
        __block NSMutableString *plainStr = [NSMutableString stringWithString:_textView.textStorage.string];
        NSLog(@"-_-%@", plainStr);
        __block int emojiIndex = 0;
        __block int addedLocation = 0;  // 图片替换成字符后新增的长度，图片只占一位
        //__block NSMutableArray *imgArr = [[NSMutableArray alloc] init];
        [_textView.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, _textView.textStorage.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (value && [value isKindOfClass:[NSTextAttachment class]]) {
                NSString *emojiStr = [NSString stringWithFormat:@"[/emoji_%02d]", emojiIndex];  // 最多支持100张图
                emojiIndex++;
                [plainStr replaceCharactersInRange:NSMakeRange(range.location+addedLocation, range.length) withString:emojiStr];
                addedLocation += emojiStr.length-1;
                //NSTextAttachment *taValue = (NSTextAttachment *)value;
                //[imgArr addObject:taValue.image];
            }
        }];
        NSLog(@"*_*%@", plainStr);
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"文字" message:plainStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:alertAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}


#pragma mark - 第三方库 IQKeyboardManager


@end

