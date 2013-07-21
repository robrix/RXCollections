//  RXSingleton.h
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/**
 Returns a singleton instance of a given class, creating it if necessary.
 
 This function is thread-safe.
 
 @param singletonClass The class to get a singleton instance of.
 @return A shared instance of this class.
 */
extern id RXSingleton(Class singletonClass);
