//
//  HeartRateView.m
//  EdooonGPS
//
//  Created by Jack on 16/5/26.
//  Copyright © 2016年 edooon team. All rights reserved.
//

#import "HeartRateView.h"
#import <HealthKit/HealthKit.h>

@interface HeartRateView ()
@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic,strong)UILabel *heartRateLabel;
@property (nonatomic,strong)HKQuery *currentQuery;

@end

@implementation HeartRateView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, 35, 30);
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"content_heartrate"]];
        [self addSubview:imageView];
        __weakSelf__
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.centerY.equalTo(weakSelf.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        self.heartRateLabel = [[UILabel alloc]init];
        self.heartRateLabel.text = @"--";
        self.heartRateLabel.font = [UIFont systemFontOfSize:12];
        self.heartRateLabel.textColor = KBlue;
        [self addSubview:self.heartRateLabel];
        
        [self.heartRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(imageView.mas_trailing);
            make.centerY.equalTo(weakSelf.mas_centerY);
        }];
        
    }
    return self;
}

- (void)queryHealthDataHeart{
    self.healthStore = [[HKHealthStore alloc]init];
    HKQuantityType *typeHeart =[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    if ([[UIDevice currentDevice]isIOS9OrLater]) {
        HKAnchoredObjectQuery *query = [[HKAnchoredObjectQuery alloc]initWithType:typeHeart predicate:nil anchor:0 limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
            
        }];
        __weakSelf__
        [query setUpdateHandler:^(HKAnchoredObjectQuery * query, NSArray<__kindof HKSample *> * samples, NSArray<HKDeletedObject *> * deletedObjects, HKQueryAnchor * anchor, NSError * err) {
            HKQuantitySample*sample = samples.lastObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.heartRateLabel.text =[NSString stringWithFormat:@"%ld",(long)[sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]];
                weakSelf.heartRate = [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]];
            });
        }];
        [self.healthStore executeQuery:query];
    }
   else
   {
       NSDateComponents *comps = [[NSDateComponents alloc]init];
       comps.second = 2;
       HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc]initWithQuantityType:typeHeart quantitySamplePredicate:nil options:HKStatisticsOptionDiscreteMin anchorDate:[NSDate date] intervalComponents:comps];
       [query setStatisticsUpdateHandler:^(HKStatisticsCollectionQuery * _Nonnull query, HKStatistics * _Nullable statistics, HKStatisticsCollection * _Nullable collection, NSError * _Nullable error) {
           dispatch_async(dispatch_get_main_queue(), ^{
               self.heartRateLabel.text =[NSString stringWithFormat:@"%ld",(long)[statistics.minimumQuantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]];
               self.heartRate = [statistics.minimumQuantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]];
           });
           
       }];
       [query setInitialResultsHandler:^(HKStatisticsCollectionQuery * _Nonnull query, HKStatisticsCollection * _Nullable collection, NSError * _Nullable error) {
           HKStatistics *statistics =  collection.statistics.lastObject;
           dispatch_async(dispatch_get_main_queue(), ^{
               self.heartRateLabel.text =[NSString stringWithFormat:@"%ld",(long)[statistics.minimumQuantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]];
               self.heartRate = [statistics.minimumQuantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]];
           });
           
       }];
   }
}

-(void)getAvgHeartRateWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime successBlock:(GetHeartRateBlock)block
{
    HKHealthStore *healthStore = [[HKHealthStore alloc]init];
    HKQuantityType *typeHeart =[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSPredicate*predicate = [HKQuery predicateForSamplesWithStartDate:startTime endDate:endTime options:HKQueryOptionStrictStartDate];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc]initWithQuantityType:typeHeart quantitySamplePredicate:predicate options:HKStatisticsOptionDiscreteAverage completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        if (error) {
            block(0);
        }
        else
        {
            block([result.averageQuantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
        }
    }];
    self.currentQuery = query;
    [healthStore executeQuery:query];

}


-(void)getMaxHeartRateWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime successBlock:(GetHeartRateBlock)block
{
    HKHealthStore *healthStore = [[HKHealthStore alloc]init];
    HKQuantityType *typeHeart =[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSPredicate*predicate = [HKQuery predicateForSamplesWithStartDate:startTime endDate:endTime options:HKQueryOptionStrictStartDate];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc]initWithQuantityType:typeHeart quantitySamplePredicate:predicate options:HKStatisticsOptionDiscreteMax completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        if (error) {
            block(0);

        }
        else
        {
            block([result.maximumQuantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
        }
    }];
    [healthStore executeQuery:query];
    
    
}

-(void)stopCurrentQuery
{
    [self.healthStore stopQuery:self.currentQuery];
}

-(void)startCurrentQuery
{
    [self.healthStore executeQuery:self.currentQuery];
}


-(void)getMinHeartRateWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime successBlock:(GetHeartRateBlock)block
{
    HKHealthStore *healthStore = [[HKHealthStore alloc]init];
    HKQuantityType *typeHeart =[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSPredicate*predicate = [HKQuery predicateForSamplesWithStartDate:startTime endDate:endTime options:HKQueryOptionStrictEndDate];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc]initWithQuantityType:typeHeart quantitySamplePredicate:predicate options:HKStatisticsOptionDiscreteMin completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        if (error) {
            block(0);
            
        }
        else
        {
            block([result.minimumQuantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]]);
        }
    }];
    [healthStore executeQuery:query];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
