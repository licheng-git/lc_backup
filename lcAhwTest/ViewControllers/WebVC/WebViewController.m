//
//  WebViewController.m
//  lcAhwTest
//
//  Created by licheng on 15/4/23.
//  Copyright (c) 2015年 lc. All rights reserved.
//

#import "WebViewController.h"
#import "KUtils.h"
#import "SVProgressHUD.h"

#define INVESTBID_SUCCESS_URL    @"AhwInvestSuccess"
#define INVESTBID_FAILE_URL      @"AhwInvestFaile"

@interface WebViewController()<UIWebViewDelegate>
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (instancetype)initWithTitle:(NSString *)title UrlStr:(NSString *)urlStr
{
    self = [super init];
    if (self)
    {
        self.title = title;
        
        CGRect rect = CGRectMake(0.0, kDEFAULT_ORIGIN_Y, kSCREEN_WIDTH, kSCREEN_HEIGHT - kNAVIGATION_HEIGHT);
        if ([KUtils isIOS7])
        {
            self.automaticallyAdjustsScrollViewInsets = NO;
            rect = CGRectMake(0.0, kDEFAULT_ORIGIN_Y, kSCREEN_WIDTH, kSCREEN_HEIGHT - kNAVIGATION_HEIGHT - kSTATUSBAR_HEIGHT);
        }
        UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
        webView.scalesPageToFit = YES;
        webView.allowsInlineMediaPlayback = YES;
        webView.mediaPlaybackAllowsAirPlay = YES;
        webView.mediaPlaybackRequiresUserAction = YES;
        webView.delegate = self;
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  // 中文->乱码
        //urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  // 乱码->中文
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [webView loadRequest:urlRequest];
        [self.view addSubview:webView];
    }
    return self;
}


// UIWebViewDelegate

// 是否加载web内容
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

////    hybird app ?    UIWebViewDelegate 异步，加载web会多次执行
////    js的执行时间不能超过10秒，否则UIWebView将停止执行脚本。
////    js分配的内存限制为10M，如果超过此限制，UIWebView将引发异常。
//    
//    //NSString *jsStr = @"confirm('看得出我是js吗?');";
//    //NSString *jsStr = @"'true';";
//    NSString *jsStr = @"if (confirm('看得出我是js吗?')) { alert('好你继续'); 'true'; } else { alert('native返回'); 'false'; } ";
//    NSString *jsResult = [webView stringByEvaluatingJavaScriptFromString:jsStr];
//    NSLog(@"%@", jsResult);
//    if ([jsResult isEqualToString:@"true"])
//    {
//        return YES;
//    }
//    else
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//        return NO;
//    }
//    
//    // UIWebView中js调用oc
//    // #import <JavaScriptCore/JavaScriptCore.h>
//    JSContext *js_context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    js_context.exceptionHandler = ^(JSContext *c, JSValue *exception) {
//        NSLog(@"js异常：%@", exception);
//        c.exception = exception;
//    };
//    js_context[@"js_call_oc"] = ^() {
//        NSArray *argsArr = [JSContext currentArguments];
//        for (id obj in argsArr) {
//            NSLog(@"oc获取到的js参数：%@", obj);
//        }
//        NSLog(@"oc执行成功");
//        return @"返回oc端执行结果";
//    };
    
    
    NSString *urlStr = request.URL.relativeString;  // url整个         （http ://119.147.82.70:8099/AhwApi/XXActionFaile?errMsg=...&kk=...）
    NSString *path = request.URL.relativePath;      //                （/AhwApi/XXActionFaile）
    NSString *query = request.URL.query;            // 参数，？之后     （errMsg=...&kk=...）
    
    query = [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *errMsg;
    if ([query containsString:@"="])
    {
        NSArray *tempArr = [query componentsSeparatedByString:@"="];
        errMsg = [tempArr objectAtIndex:1];
    }
    
    if ([urlStr containsString:INVESTBID_SUCCESS_URL]) //投标成功
    {
        // 先释放自己（webvc）
        [self.navigationController popViewControllerAnimated:NO];
        // 再跳转到本地页面
        if (self.delegate && [self.delegate respondsToSelector:@selector(webStopByParticularUrl_Success)])
        {
            [self.delegate webStopByParticularUrl_Success];
        }
        return NO; // 不再加载web
    }
    else if ([urlStr containsString:INVESTBID_FAILE_URL])
    {
        [self.navigationController popViewControllerAnimated:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(webStopByParticularUrl_FaileWithMsg:)])
        {
            [self.delegate webStopByParticularUrl_FaileWithMsg:errMsg];
        }
        return NO;
    }
    
    return YES; // 继续加载web
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"正在加载..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    [SVProgressHUD dismissWithError:error.description];
}

@end
