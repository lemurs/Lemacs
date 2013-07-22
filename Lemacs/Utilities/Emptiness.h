//
//  Emptiness.h
//  Lemacs
//
//  Created by Mike Lee on 7/22/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#ifndef Lemacs_Emptiness_h
#define Lemacs_Emptiness_h

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline id IfEmpty(id thing, id replacement) {
    return IsEmpty(thing) ? thing : replacement;
}

#define NonNil(thing, replacement) (thing ? : replacement)

#endif
