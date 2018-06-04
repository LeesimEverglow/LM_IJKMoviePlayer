
//
//  LRMacroDefinitionHeader.h
//  LRMacroDefinition
//
//  Created by lu on 16/7/4.
//  Copyright © 2016年 scorpio. All rights reserved.
//

/*
 常用的宏定义
 */

#ifndef LRMacroDefinitionHeader_h
#define LRMacroDefinitionHeader_h


//1.获取屏幕宽度与高度
//#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
//#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height


//需要横屏或者竖屏，获取屏幕宽度与高度
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 // 当前Xcode支持iOS8及以上

#define SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)
#define SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)
#define SCREEN_SIZE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale,[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale):[UIScreen mainScreen].bounds.size)
#else
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#endif

//获取statusBarHeight、NavigationBarHeight
#define StatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define NavigationBarHeight 44.0f
#define StatusBarWithNavigationBarHeight (StatusBarHeight+NavigationBarHeight)
#define FictitiousHomeButtonHeight 34.0f
//获取TabBarHeight
#define TabBarHeight (iPhoneX?83.0f:49.0f)
//iphone678 默认tabbarheight
#define OldTabBarHeight 49.0f


//2.获取通知中心
#define LRNotificationCenter [NSNotificationCenter defaultCenter]

//3.设置随机颜色
#define LRRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

//4.设置RGB颜色/设置RGBA颜色
#define LRRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define LRRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
// clear背景颜色
#define LRClearColor [UIColor clearColor]


/// rgb颜色转换（16进制->10进制） 色值转换rgb
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


//5.自定义高效率的 NSLog
#ifdef DEBUG
#define LRLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define LRLog(...)

#endif

//6.弱引用/强引用
#define LRWeakSelf(type)  __weak typeof(type) weak##type = type;
#define LRStrongSelf(type)  __strong typeof(type) type = weak##type;

//7.设置 view 圆角和边框
#define LRViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

//8.由角度转换弧度 由弧度转换角度
#define LRDegreesToRadian(x) (M_PI * (x) / 180.0)
#define LRRadianToDegrees(radian) (radian*180.0)/(M_PI)

//9.设置加载提示框（第三方框架：Toast）
#define LRToast(str)              CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle]; \
[kWindow  makeToast:str duration:0.6 position:CSToastPositionCenter style:style];\
kWindow.userInteractionEnabled = NO; \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
kWindow.userInteractionEnabled = YES;\
});\

//10.设置加载提示框（第三方框架：MBProgressHUD）
// 加载
#define kShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
// 收起加载
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
// 设置加载
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x

#define kWindow [UIApplication sharedApplication].keyWindow

#define kBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[item removeFromSuperview]; \
UIView * aView = [[UIView alloc] init]; \
aView.frame = [UIScreen mainScreen].bounds; \
aView.tag = 10000; \
aView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3]; \
[kWindow addSubview:aView]; \
} \
} \

#define kShowHUDAndActivity kBackView;[MBProgressHUD showHUDAddedTo:kWindow animated:YES];kShowNetworkActivityIndicator()


#define kHiddenHUD [MBProgressHUD hideAllHUDsForView:kWindow animated:YES]

#define kRemoveBackView         for (UIView *item in kWindow.subviews) { \
if(item.tag == 10000) \
{ \
[UIView animateWithDuration:0.4 animations:^{ \
item.alpha = 0.0; \
} completion:^(BOOL finished) { \
[item removeFromSuperview]; \
}]; \
} \
} \

#define kHiddenHUDAndAvtivity kRemoveBackView;kHiddenHUD;HideNetworkActivityIndicator()


//11.获取view的frame/图片资源
//获取view的frame（不建议使用）
//#define kGetViewWidth(view)  view.frame.size.width
//#define kGetViewHeight(view) view.frame.size.height
//#define kGetViewX(view)      view.frame.origin.x
//#define kGetViewY(view)      view.frame.origin.y

//获取图片资源
#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]


//12.获取当前语言
#define LRCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//13.使用 ARC 和 MRC
#if __has_feature(objc_arc)
// ARC
#else
// MRC
#endif

//14.判断当前的iPhone设备/系统版本
//判断是否为iPhone
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

//判断是否为iPad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//判断是否为ipod
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

// 判断是否为 iPhone 5SE
#define iPhone5SE [[UIScreen mainScreen] bounds].size.width == 320.0f && [[UIScreen mainScreen] bounds].size.height == 568.0f

// 判断是否为iPhone 6/6s
#define iPhone6_6s [[UIScreen mainScreen] bounds].size.width == 375.0f && [[UIScreen mainScreen] bounds].size.height == 667.0f

// 判断是否为iPhone 6Plus/6sPlus
#define iPhone6Plus_6sPlus [[UIScreen mainScreen] bounds].size.width == 414.0f && [[UIScreen mainScreen] bounds].size.height == 736.0f

// 判断是否为iPhone X
#define iPhoneX [[UIScreen mainScreen] bounds].size.width == 375.0f && [[UIScreen mainScreen] bounds].size.height == 812.0f

//获取系统版本
#define IOS_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))

//判断 iOS 11 或更高的系统版本
#define IOS_VERSION_11_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=11.0)? (YES):(NO))

//15.判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//16.沙盒目录文件
//获取temp
#define kPathTemp NSTemporaryDirectory()

//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

//17.GCD 的宏定义
//GCD - 一次性执行
#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);

//GCD - 在Main线程上运行
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);

//GCD - 开启异步线程
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);



/*
 ---- Owhat_v4 常用的颜色 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */


//主色调
#define Color_Main [UIColor colorWithRed:255.0/255.0 green:88.0/255.0 blue:104.0/255.0 alpha:1]

//透明色主色调
#define Color_Main_Alpha(a) [UIColor colorWithRed:255.0/255.0 green:88.0/255.0 blue:104.0/255.0 alpha:a]

//黄色主色调
#define Color_Main_Yellow [UIColor colorWithRed:255.0/255.0 green:186.0/255.0 blue:0.0/255.0 alpha:1]

//导航栏主要背景色
#define Color_NavigationBar_Main [UIColor whiteColor]

//导航栏底部横线的颜色
#define Color_NavigationBar_BottomLine [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]


//主要的视图背景颜色[UIColor groupTableViewBackgroundColor]
#define Color_ContentView_BackgroundColor_Main [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1]


//分割线颜色
#define Color_SplitLineView [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]



//顶部提醒视图（横幅）背景颜色
#define Color_TopAlert_BackgroundColor [UIColor colorWithRed:255.0/255.0 green:186.0/255.0 blue:0 alpha:0.08]




//按钮－可点状态下的 背景颜色
#define Color_Button_Available [UIColor colorWithRed:255.0/255.0 green:88.0/255.0 blue:104.0/255.0 alpha:1]

//按钮－不可点状态下的 背景颜色
#define Color_Button_Unavailable [UIColor colorWithRed:255.0/255.0 green:88.0/255.0 blue:104.0/255.0 alpha:0.32]





//文字－浅灰色(透明度－0.24)
#define Color_Text_LightGray_24 [UIColor colorWithRed:0 green:0 blue:0 alpha:0.24]

//文字－浅灰色(透明度－0.16)
#define Color_Text_LightGray_16 [UIColor colorWithRed:0 green:0 blue:0 alpha:0.16]

//文字－次要页面的正文
#define Color_Text_LightGray_160_160_160 [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1]


//文字－灰色(透明度－0.80)
#define Color_Text_Gray_80 [UIColor colorWithRed:0 green:0 blue:0 alpha:0.80]

//文字－灰色(透明度－0.48)
#define Color_Text_Gray_48 [UIColor colorWithRed:0 green:0 blue:0 alpha:0.48]

//文字－次要页面的正文
#define Color_Text_Gray_48_48_48 [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1]


//文字－蓝色（链接文字）
#define Color_Text_Blue_24_180_188 [UIColor colorWithRed:24.0/255.0 green:180.0/255.0 blue:188.0/255.0 alpha:1]


//cell选中状态下的背景颜色
#define Color_Cell_SelectedBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.08]







/*
 ---- Owhat_v4 常用字体（fontName） & 常用字号（font） －－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */

#define FontName_MediumBold @"Helvetica-Bold"









/*
 ---- 宽、高比例(以iPhone6为基础) －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 注：
 （1）5 vs 6：6相当于在5的基础上拉长了一点点（高度放大的倍数 > 宽度放大的倍数）
 （2）6 vs 6p：6p和6几乎可以认为是等比例放大了（高度放大的倍数 约＝ 宽度放大的倍数）
 */

#define Ratio_Width (SCREEN_WIDTH/375.0)

#define Ratio_Height (SCREENH_HEIGHT/667.0)







/*
 ---- 重写CGRectMake方法 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 注：之所以＊宽度的方法倍数，是因为几代iPhone设备中 宽度的放大倍数 < 高度放大倍数
 */


#define OWRectMake(CGFloat_x, CGFloat_y, CGFloat_width, CGFloat_height) CGRectMake(CGFloat_x*Ratio_Width, CGFloat_y*Ratio_Width, CGFloat_width*Ratio_Width, CGFloat_height*Ratio_Width)







/*
 ---- Owhat_v4 按钮 常用frame设置 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */


//导航栏底部细线的高度
#define Height_NavBarBottomLine 0.5

//大按钮－常用高度
#define Height_Button_Frequently 44

//大按钮－常用圆角度数
#define Radius_Button_Frequently (Height_Button_Frequently/2)









/*
 ---- AppVersion 获取及判断 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */

//应用的版本号（version）
#define App_Version_String [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]





/*
 ---- 设备UUID 的获取 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */

//设备的UUID
#define Device_UUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]






/*
 ---- 倒计时总数 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */

//倒计时总数（60秒:需要填写59！）
#define Timer_ValidateCode_CountDown_TotalCount 59






/*
 ---- 验证码方面需要的宏 ：验证码类型 & 业务类型－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */

//短信 验证码类型
#define ValidateCode_Type_SMS @"sms"
//邮箱 验证码类型
#define ValidateCode_Type_Email @"email"
//语音 验证码类型
#define ValidateCode_Type_Voice @"voice"

//注册 验证码业务类型
#define ValidateCode_BusinessType_Register @"reg"
//第三方绑定 验证码业务类型
#define ValidateCode_BusinessType_BindThird @"bindthird"
//重置密码 验证码业务类型
#define ValidateCode_BusinessType_Resetpwd @"resetpwd"
//绑定账号 验证码业务类型
#define ValidateCode_BusinessType_BindAccount @"bindaccount"
//绑定账号 更改手机号,邮箱业务类型
#define ValidateCode_BusinessType_UpdateAccount @"updateaccount"
//更新支付密码 验证码业务类型
#define ValidateCode_BusinessType_UpdatePayPwd @"updatepaypwd"


//图片验证码业务类型-登录
#define PicValidateCode_BusinessType_Login @"login"
//图片验证码业务类型-发送验证码
#define PicValidateCode_BusinessType_SendCode @"sendcode"


/*
 ---- 引导页 列表 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */

//修改用户信息
#define GuidePageList_UpdateUserInfo @"update_user_info"

//关注明星
#define GuidePageList_FollowStar @"follow_star"


/*
 ---- 第三方登录的方式（site）定义 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */

#define ThirfLoginSite_WeChat @"wechat"

#define ThirfLoginSite_QQ @"qq"

#define ThirfLoginSite_WeiBo @"weibo"



/*
 ---- 返回结果 成功／失败 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */


#define ResponseObject_Result_Success @"success"

#define ResponseObject_Result_Fail @"fail"





/*
 ---- 密码最多字符数 (6-16位)－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 */
#define OWhat_PasswordMaxCount 16

#define OWhat_PayPasswordMaxCount 6



//xcode 8 真机打印不全
//#ifdef DEBUG
//
//#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
//
//#else
//
//#define NSLog(FORMAT, ...) nil
//
//#endif



#endif /* LRMacroDefinitionHeader_h */




