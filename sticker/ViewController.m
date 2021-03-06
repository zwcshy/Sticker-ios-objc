//
//  ViewController.m
//  sticker
//
//  Created by LiuZiyang on 15/2/3.
//  Copyright (c) 2015年 LiuZiyang. All rights reserved.
//

#import "ViewController.h"
#import "WorkView.h"
#import "StickerSelectionView.h"
#import "SuccessViewController.h"

#import <UIActionSheet+Blocks.h>
#import <SHPImagePickerController.h>

typedef void(^PickBaseImageSuccessBlock)(UIImage *image);
typedef void(^PickStickerSuccessBlock)(Sticker *sticker);

@interface ViewController ()
@property (strong, nonatomic) PickBaseImageSuccessBlock pickBaseImageSuccessBlock;
@property (strong, nonatomic) PickStickerSuccessBlock pickStickerSuccessBlock;

@property (weak, nonatomic) WorkView *workView;
@property (weak, nonatomic) StickerSelectionView *stickerSelectionView;
@property (strong, nonatomic) UIImage *finalImage;
@end

@implementation ViewController

- (void)restart{
    [self.workView setBaseImage:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.pickBaseImageSuccessBlock = ^(UIImage *image){
        [weakSelf.workView setBaseImage:image];
    };
    self.pickStickerSuccessBlock = ^(Sticker *sticker){
        if ([weakSelf.workView hasImage]){
            [weakSelf.workView addSticker:sticker];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先选择一张照片"
                                                            message:@"点击选择照片按钮进行选择"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)selectImageButtonPressed:(id)sender {
    [UIActionSheet showInView:self.view
                    withTitle:@"选择照片来源"
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[@"现在拍照", @"相册"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if (buttonIndex > 1){
                             return;
                         }
                         [SHPImagePickerController showImagePickerOfType:(SHPImagePickerType)buttonIndex
                                                   fromViewController:self
                                                              success:self.pickBaseImageSuccessBlock];
                     }];
}

- (IBAction)saveAndShareButtonPressed:(id)sender {
    if (![self.workView hasImage]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先选择一张照片"
                                                        message:@"点击选择照片按钮进行选择"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.workView generateWithBlock:^(UIImage *finalImage, NSError *error) {
        weakSelf.finalImage = finalImage;
        [weakSelf performSegueWithIdentifier:@"toSuccess" sender:self];
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *desVC = segue.destinationViewController;
    if ([[segue identifier] isEqual:@"toWorkView"]){
        self.workView = (WorkView *)desVC.view;
        return;
    }
    if ([[segue identifier] isEqual:@"toStickerSelectionView"]){
        self.stickerSelectionView = (StickerSelectionView *)desVC.view;
        self.stickerSelectionView.selectStickerSuccessBlock = ^(Sticker *sticker){
            self.pickStickerSuccessBlock(sticker);
        };
        return;
    }
    if ([[segue identifier] isEqual:@"toSuccess"]){
        SuccessViewController *desVC = [segue destinationViewController];
        desVC.image = self.finalImage;
        return;
    }
}

@end
