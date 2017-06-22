//
//  NSData+TDKit.m
//  tinyDict
//
//  Created by guangbool on 2017/5/18.
//  Copyright © 2017年 bool. All rights reserved.
//

#import "NSData+TDKit.h"
#import "UIImage+TDKit.h"

@implementation NSData (TDKit)

+ (NSData *)wrapWXShareDataForImageData:(NSData *)imageData
                               emoticon:(BOOL)emoticon
                                  scene:(NSInteger)scene
                                 appkey:(NSString *)appkey {
    if (!appkey) return nil;
    if (!imageData) return nil;
    NSData *thumbData = WeChatThumbData(imageData);
    NSDictionary *wrapper = @{
                              appkey: @{
                                      @"thumbData": thumbData,
                                      @"command": @"1010",
                                      @"fileData": imageData,
                                      // 2 -> pic 8 -> emoticon
                                      @"objectType": emoticon?@"8":@"2",
                                      @"result": @"1",
                                      @"returnFromApp": @"0",
                                      @"scene": [@(scene) stringValue],
                                      @"sdkver": @"1.7"
                                      }
                              };
    NSData *shareData = [NSPropertyListSerialization dataWithPropertyList:wrapper
                                                                   format:NSPropertyListBinaryFormat_v1_0
                                                                  options:NSPropertyListImmutable
                                                                    error:nil];
    return shareData;
}

NSData* WeChatThumbData(NSData *sourceImageData) {
    if (!sourceImageData) return nil;
    UIImage *sourceImage = [UIImage imageWithData:sourceImageData];
    if (!sourceImage) return nil;
    
    CGFloat maxFileSize = 32.f * 1024; // max: 32 kb
    NSData *thumbData = UIImageJPEGRepresentation(sourceImage, 1);
    if ([thumbData length] > maxFileSize) {
        UIImage *jpgSourceImage = [UIImage imageWithData:thumbData];
        CGSize sourceImgSize = jpgSourceImage.size;
        CGFloat rate = maxFileSize/[thumbData length];
        UIImage *thumbImage =[jpgSourceImage imageByResizeToSize:CGSizeMake(sourceImgSize.width*rate, sourceImgSize.height*rate)];
        thumbData = UIImageJPEGRepresentation(thumbImage, 1);
        CGFloat compression = 0.9f;
        while ([thumbData length] > maxFileSize && compression >= 0){
            thumbData = UIImageJPEGRepresentation(thumbImage, compression);
            compression -= 0.1f;
        }
        NSLog(@"compression: %@", @(compression));
    }
    return thumbData;
}

@end
