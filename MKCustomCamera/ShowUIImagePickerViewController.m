//
//  ViewController.m
//  MKCustomCamera
//
//  Created by ykh on 16/1/4.
//  Copyright © 2016年 MK. All rights reserved.
//

#import "ShowUIImagePickerViewController.h"
#import "UIView+RMAdditions.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ShowUIImagePickerViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
//@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@end

@implementation ShowUIImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

//拍照
- (IBAction)showImagePickerForCamera:(id)sender{
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera andCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
}

//摄像
- (IBAction)showImagePickerForCameraShooting:(id)sender {

    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera andCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
}

//相册
- (IBAction)showImagePickerForPhotoPicker:(id)sender{
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary andCameraCaptureMode:0];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType andCameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)mode{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    //这是 VC 的各种 modal 形式
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sourceType = sourceType;
    //支持的摄制类型,拍照或摄影,此处将本设备支持的所有类型全部获取,并且同时赋值给imagePickerController的话,则可左右切换摄制模式
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePickerController.delegate = self;
    //允许拍照后编辑
    imagePickerController.allowsEditing = YES;
    //显示默认相机 UI, 默认为yes--> 显示
//    imagePickerController.showsCameraControls = NO;

    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        //设置模式-->拍照/摄像
        imagePickerController.cameraCaptureMode = mode;
        //开启默认摄像头-->前置/后置
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        //设置默认的闪光灯模式-->开/关/自动
        imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;

        //拍摄时预览view的transform属性，可以实现旋转，缩放功能
//        imagePickerController.cameraViewTransform = CGAffineTransformMakeRotation(M_PI);
//        imagePickerController.cameraViewTransform = CGAffineTransformMakeScale(2.0,2.0);
        
        //自定义覆盖图层-->overlayview
        UIImage *img = [UIImage imageNamed:@"085625KMV.jpg"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        iv.width = 300;
        iv.height = 200;
        imagePickerController.cameraOverlayView = iv;
    }
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        NSLog(@"image...");

        /*
         //获取照片的原图
         UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
         //获取图片裁剪后，剩下的图
         UIImage* crop = [info objectForKey:UIImagePickerControllerCropRect];
         //获取图片的url
         NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
         //获取图片的metadata数据信息
         NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
         */
        
        //获取图片裁剪的图
        UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
        
        [self saveImage:edit];
        
    }else{  // public.movie
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        
        [self saveVideo:urlStr];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    NSLog(@"取消");
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

//取消屏幕旋转
- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark save

- (void)saveImage:(UIImage *)img
{
//    //如果是拍照的照片，则需要手动保存到本地，系统不会自动保存拍照成功后的照片
//    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [[[ALAssetsLibrary alloc]init] writeImageToSavedPhotosAlbum:[img CGImage] orientation:(ALAssetOrientation)img.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Save image fail：%@",error);
        }else{
            NSLog(@"Save image succeed.");
        }
    }];

}

- (void)saveVideo:(NSString *)videoPath
{
    [[[ALAssetsLibrary alloc]init] writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
       
        if (error) {
            NSLog(@"Save video fail：%@",error);
        }else{
            NSLog(@"Save video succeed.");
        }
        
    }];
    
    
//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
//        //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
//        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
//    }else{
//        
//        NSLog(@"您的设备不支持保存视频到相册");
//    
//    }
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error) {
        NSLog(@"保存照片过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"照片保存成功.");
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}

@end
