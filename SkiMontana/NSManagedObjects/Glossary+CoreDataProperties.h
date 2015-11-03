//
//  Glossary+CoreDataProperties.h
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Glossary.h"

NS_ASSUME_NONNULL_BEGIN

@interface Glossary (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *term;

@end

NS_ASSUME_NONNULL_END
