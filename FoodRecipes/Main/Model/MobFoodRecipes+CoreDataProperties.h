//
//  MobFoodRecipes+CoreDataProperties.h
//  FoodRecipes
//
//  Created by WinterChen on 16/8/19.
//  Copyright © 2016年 WinterChen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MobFoodRecipes.h"

NS_ASSUME_NONNULL_BEGIN

@interface MobFoodRecipes (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *checkData;
@property (nullable, nonatomic, retain) NSString *cid;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *img;
@property (nullable, nonatomic, retain) NSData *method;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *summary;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) MobFoodRecipes *relationship;

@end

NS_ASSUME_NONNULL_END
