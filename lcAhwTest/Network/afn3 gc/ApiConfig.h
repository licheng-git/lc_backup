//
//  ApiConfig.h
//  GuangCaiJiaoYi
//
//  Created by 李诚 on 16/12/8.
//  Copyright © 2016年 Steven. All rights reserved.
//

#ifndef ApiConfig_h
#define ApiConfig_h


/**
 *服务器连接的地址
 */

//#if DEBUG
//#define URL_BASE        @"http://192.168.1.26"      // 开发环境服务器
//#else
#define URL_BASE        @"http://m.api.gidax.cn"   // 生产环境服务器
//#endif


#define URL_Login                 URL_BASE"/member/login"                    // 登录
#define URL_ChiCangHuiZong        URL_BASE"/Trade/GetViewPositionSumList"    // 持仓汇总
#define URL_ChengJiaoHuiZong      URL_BASE"/Trade/GetTradeSumList"           // 成交汇总


#endif /* ApiConfig_h */

