//
//  AJGoodsEdit.h
//
//  Created by ajsong on 2017/3/14.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AJGoodsConfig.h"

@interface AJGoodsEdit : UIViewController
@property (nonatomic,strong) NSDictionary *data; //商品数据(修改/填充数据用)
@property (nonatomic,strong) NSArray *categories; //商品分类数据集
@property (nonatomic,strong) UIImage *image; //商品图片添加按钮图
@property (nonatomic,assign) BOOL imageMemo; //商品图片可添加各自的描述
@property (nonatomic,assign) int nameNums; //最多商品名称字数(只作提示,不会限制)
@property (nonatomic,assign) int specsNums; //最多规格数
@property (nonatomic,strong) UIColor *textColor; //全局字体颜色
@property (nonatomic,strong) UIColor *imagesColor; //添加图片按钮颜色
@property (nonatomic,strong) UIColor *specsBtnColor; //添加规格按钮颜色
@property (nonatomic,strong) UIColor *btnColor; //按钮颜色
@property (nonatomic,strong) NSString *tips; //底部提示文字
@property (nonatomic,strong) NSString *imageUpyun; //商品图片上传空间路径(又拍云路径)(留空即直接显示,待提交时需自行上传)
@property (nonatomic,strong) NSString *contentUpyun; //商品详情图片上传空间路径(又拍云路径)(留空即不允许添加图片)
@property (nonatomic,strong) NSString *contentPlaceholder; //商品详情编辑框的占位符
@property (nonatomic,strong) NSString *editorUrl; //商品详情编辑器使用在线编辑器(网页路径)(函数方法名称需遵从AJGoodsContent里面的名称)
- (NSArray*)AJGoodsEditOptionViews:(AJGoodsEdit*)goodsEdit; //扩展项
- (void)AJGoodsEditSubmit:(AJGoodsEdit*)goodsEdit postData:(NSMutableDictionary*)postData images:(NSArray*)images; //images不为空需进行上传操作
@end
