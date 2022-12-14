//
//  ZHMutableArray.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/9/28.
//
#import "ZHMutableArray.h"

@interface ZHMutableArray()

@property (nonatomic,strong)dispatch_queue_t concurrentQueue;
@property (nonatomic,strong)NSMutableArray *arr;

@end

@implementation ZHMutableArray

-(instancetype)init{
    self = [super init];
    if (self) {
        NSString *identifier = [NSString stringWithFormat:@"<ZHMutableArray>%p",self];
        self.concurrentQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_CONCURRENT);
        self.arr = [NSMutableArray array];
    }
    return self;
}

+(NSMutableArray *)array{
    return [self init];
}

- (NSMutableArray *)array
{
    __block NSMutableArray *safeArray;
    dispatch_sync(_concurrentQueue, ^{
        safeArray = self.arr;
    });
    return safeArray;
}

- (BOOL)containsObject:(id)anObject
{
    __block BOOL isExist = NO;
    dispatch_sync(_concurrentQueue, ^{
        isExist = [self.arr containsObject:anObject];
    });
    return isExist;
}

- (NSUInteger)count
{
    __block NSUInteger count;
    dispatch_sync(_concurrentQueue, ^{
        count = self.arr.count;
    });
    return count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    __block id obj;
    dispatch_sync(_concurrentQueue, ^{
        if (index < [self.arr count]) {
            obj = self.arr[index];
        }
    });
    return obj;
}

- (NSEnumerator *)objectEnumerator
{
    __block NSEnumerator *enu;
    dispatch_sync(_concurrentQueue, ^{
        enu = [self.arr objectEnumerator];
    });
    return enu;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    dispatch_barrier_async(_concurrentQueue, ^{
        if (anObject && index < [self.arr count]) {
            [self.arr insertObject:anObject atIndex:index];
        }
    });
}

- (void)addObject:(id)anObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        if(anObject){
            [self.arr addObject:anObject];
        }
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    dispatch_barrier_async(_concurrentQueue, ^{
        
        if (index < [self.arr count]) {
            [self.arr removeObjectAtIndex:index];
        }
    });
}


//????????????
- (void)removeAllObjects{
    dispatch_barrier_async(_concurrentQueue, ^{
      [self.arr removeAllObjects];
    });
}

- (void)removeObject:(id)anObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        [self.arr removeObject:anObject];//???????????????????????????
    });
}

- (void)removeLastObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        [self.arr removeLastObject];
    });
}

-(void)removeObjectsInArray:(NSArray *)arr{
    dispatch_barrier_async(_concurrentQueue, ^{
        [self.arr removeObjectsInArray:arr];
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    dispatch_barrier_async(_concurrentQueue, ^{
        if (anObject && index < [self.arr count]) {
            [self.arr replaceObjectAtIndex:index withObject:anObject];
        }
    });
}

- (NSUInteger)indexOfObject:(id)anObject
{
    __block NSUInteger index = NSNotFound;
    dispatch_sync(_concurrentQueue, ^{
        for (int i = 0; i < [self.arr count]; i ++) {
            if ([self.arr objectAtIndex:i] == anObject) {
                index = i;
                break;
            }
        }
    });
    return index;
}

- (void)dealloc
{
    if (_concurrentQueue) {
        _concurrentQueue = NULL;
    }
}

@end
