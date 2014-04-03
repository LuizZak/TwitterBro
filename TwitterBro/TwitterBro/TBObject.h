//
//  TBObject.h
//  PassagemDeViews
//
//  Created by Luiz Fernando Silva on 27/03/14.
//  Copyright (c) 2014 FILIPE KUNIOSHI. All rights reserved.
//

#import <Foundation/Foundation.h>

// TBObject define um objeto do TwitterBro que teve suas definições carregadas
// a partir de um trecho de JSON
@interface TBObject : NSObject

// NSDictionary que foi usado para compor este TBObject
@property NSDictionary *origin;

@end