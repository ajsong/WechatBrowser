//
//  AJGoodsConfig.h
//
//  Created by ajsong on 2017/3/15.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#define GOODS_EDIT_IMAGE_MEMO 0 //商品图片可添加各自的描述
#define GOODS_EDIT_NAME_NUMS 40 //最多商品名称字数(只是提示用,不会限制)
#define GOODS_EDIT_SPECS_NUMS 9 //最多规格数
#define GOODS_EDIT_TEXT_COLOR COLOR333 //全局字体颜色
#define GOODS_EDIT_FONTBOLD FONT(13) //全局粗字体
#define GOODS_EDIT_FONT FONT(13) //全局字体
#define GOODS_EDIT_ADD_IMAGES_COLOR COLORORANGE //添加图片按钮颜色
#define GOODS_EDIT_ADD_SPECS_COLOR COLORBLUE //添加规格按钮颜色
#define GOODS_EDIT_BTN_COLOR COLORORANGE //按钮颜色
#define GOODS_EDIT_TIPS @"注：填写价格请严格遵守法律规定、遵循市场规律，确保可以提供该价格的合法依据或可供比较的出处，不得虚构原价。" //提示文字
#define GOODS_EDIT_IMAGE_UPYUN_PATH @"uploadfiles/goods" //商品图片上传空间路径(留空即直接显示,待提交时再作上传操作)
#define GOODS_EDIT_CONTENT_UPYUN_PATH @"uploadfiles/goodsdetail" //商品详情图片上传空间路径(这里是又拍云路径)(留空即不允许添加图片)

#define GOODS_EDIT_SUBTYPE_KEY @"categories" //下级分类集合
#define GOODS_EDIT_TYPE_ID @"id" //分类ID
#define GOODS_EDIT_TYPE_NAME @"name" //分类名称

#define GOODS_EDIT_PICS @"pics" //商品图片数据集
#define GOODS_EDIT_PIC @"pic" //商品图片
#define GOODS_EDIT_PIC_MEMO @"memo" //商品图片描述
#define GOODS_EDIT_ID @"id" //商品ID
#define GOODS_EDIT_NAME @"name" //商品名称
#define GOODS_EDIT_CATE_ID @"category_id" //商品分类
#define GOODS_EDIT_SPECS @"specs" //规格数据集
#define GOODS_EDIT_DEFAULT_SPEC @"默认规格" //规格默认名称
#define GOODS_EDIT_SPEC @"spec" //规格名称
#define GOODS_EDIT_PRICE @"price" //价格
#define GOODS_EDIT_PROMOTE_PRICE @"promote_price" //促销价
#define GOODS_EDIT_STOCKS @"stocks" //库存
#define GOODS_EDIT_SHIPPING_FEE @"shipping_fee" //运费
#define GOODS_EDIT_DESCRIPTION @"description" //商品描述
#define GOODS_EDIT_CONTENT @"content" //商品详情
