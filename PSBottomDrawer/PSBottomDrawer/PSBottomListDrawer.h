//
//  PSBottomListDrawer.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomDrawer.h"

typedef void(^DidPickListItemBlock)(NSInteger itemIndex);

@interface PSBottomListDrawer : PSBottomDrawer

@property (nonatomic, copy) DidPickListItemBlock pickListItemBlock;

- (instancetype)initWithItems:(NSArray<NSDictionary *> *)items;

@end

