//
//  AdBaseViewController.h
//  Vocabulary
//
//  Created by 缪和光 on 12-11-4.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface AdBaseViewController : UIViewController <GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *banner;
//@property (nonatomic, strong) YouMiView *banner;
@property (nonatomic, unsafe_unretained) CGRect bannerFrame;

@end
