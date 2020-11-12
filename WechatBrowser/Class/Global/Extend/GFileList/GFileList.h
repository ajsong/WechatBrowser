//
//  GFileList.h
//
//  Created by ajsong on 15/6/30.
//  Copyright (c) 2014 @jsong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFileList : UIViewController
@property (nonatomic,strong) NSString *folderPath;
- (instancetype)initWithFolderPath:(NSString*)folderPath;
@end
