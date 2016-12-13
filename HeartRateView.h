//
//  HeartRateView.h
//  EdooonGPS
//
//  Created by Jack on 16/5/26.
//  Copyright © 2016年 edooon team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetHeartRateBlock)(NSInteger heartRate);

@interface HeartRateView : UIView
@property (nonatomic,assign)NSInteger heartRate;
@property (nonatomic,assign,readonly)NSInteger avgHeartRate;
@property (nonatomic,assign,readonly)NSInteger maxHeartRate;
@property (nonatomic,assign,readonly)NSInteger minHeartRate;


- (void)queryHealthDataHeart;
-(void)getAvgHeartRateWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime successBlock:(GetHeartRateBlock)block;
-(void)getMaxHeartRateWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime successBlock:(GetHeartRateBlock)block;
-(void)getMinHeartRateWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime successBlock:(GetHeartRateBlock)block;

-(void)startCurrentQuery;
-(void)stopCurrentQuery;
@end
