//
//  ImageServices.m
//  TakePhotos
//
//  Created by 李伟超 on 15/4/24.
//  Copyright (c) 2015年 LWC. All rights reserved.
//

#import "ImageServices.h"

@implementation ImageServices

+ (NSString *)postRequestWithURL: (NSString *)url
                      postParems: (NSMutableDictionary *)postParems
                     picFilePath: (NSString *)picFilePath
                     picFileName: (NSString *)picFileName {
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //得到图片的data
    NSData* data;
    if(picFilePath){
        
        UIImage *image=[UIImage imageWithContentsOfFile:picFilePath];
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        }else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
    }
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [postParems allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //添加字段的值
        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
        
        NSLog(@"添加字段的值==%@",[postParems objectForKey:key]);
    }
    
    if(picFilePath){
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        
        //声明pic字段，文件名为boris.png
        [body appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",picFileName];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg\r\n\r\n"];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    if(picFilePath){
        //将image的data加入
        [myRequestData appendData:data];
    }
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = nil;
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponese error:&error];
    if (error) {
        NSLog(@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
    }
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300){
        NSLog(@"返回结果=====%@",result);
        return result;
    }
    return nil;
}

+ (UIImage *)imageWithImage:(UIImage *)image NewSize:(CGSize)newSize {
    
    CGSize oldSize = image.size;
    
    if (newSize.height/oldSize.height < newSize.width/oldSize.width) {
        
        newSize = CGSizeMake(oldSize.width * newSize.height/oldSize.height, newSize.height);
    }else {
        
        newSize = CGSizeMake(newSize.width, oldSize.height * newSize.width/oldSize.width);
    }
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)compressImageWith:(UIImage *)image {
    NSLog(@"%@",NSStringFromCGSize(image.size));
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    //    CGSize size = image.size;
    CGFloat ratio;
    //
    //    if (_imageOrientation == ImageOrientationPortrait || _imageOrientation == ImageOrientationPortraitUpsideDown) { //判断图片是不是正的
    //        ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    //    }else {
    //        ratio = MIN(_scrollView.frame.size.width / size.height, _scrollView.frame.size.height / size.width);
    //    }
    
    ratio = 1;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(imageWidth * ratio, imageHeight * ratio));
    
    [image drawInRect:CGRectMake(0, 0, imageWidth * ratio, imageHeight * ratio)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return newImage;
    
}

+ (NSString *)getPathDirectory {
    NSString *path = [[NSArray arrayWithObjects:NSHomeDirectory(), @"Library", @"CameraImage", nil] componentsJoinedByString:@"/"];
    return path;
}


@end
