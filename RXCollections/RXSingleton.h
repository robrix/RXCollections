//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

/**
 Returns a singleton instance of a given class, creating it if necessary.
 
 This function is thread-safe.
 
 @param singletonClass The class to get a singleton instance of.
 @param initializer A block which produces the singleton instance when required.
 @return A shared instance of this class.
 */
extern id RXSingleton(Class singletonClass, id(^initializer)());
